import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/gamification.dart';

/// Provider for managing gamification state (XP, levels, badges, challenges)
class GamificationProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  UserGamification _gamification = UserGamification();
  List<DailyChallenge> _dailyChallenges = [];
  bool _isInitialized = false;

  // Pending notifications for UI
  final List<XPEvent> _pendingXPNotifications = [];
  final List<String> _pendingBadgeUnlocks = [];
  int? _levelUpNotification;

  // Getters
  UserGamification get gamification => _gamification;
  int get totalXP => _gamification.totalXP;
  int get level => _gamification.level;
  String get title => _gamification.title;
  int get currentStreak => _gamification.currentStreak;
  int get longestStreak => _gamification.longestStreak;
  double get progressToNextLevel => _gamification.progressToNextLevel;
  int get xpToNextLevel => _gamification.xpToNextLevel;
  int get todayXP => _gamification.todayXP;
  List<String> get unlockedBadgeIds => _gamification.unlockedBadgeIds;
  List<DailyChallenge> get dailyChallenges => _dailyChallenges;
  bool get isInitialized => _isInitialized;

  // Notification getters
  List<XPEvent> get pendingXPNotifications => _pendingXPNotifications;
  List<String> get pendingBadgeUnlocks => _pendingBadgeUnlocks;
  int? get levelUpNotification => _levelUpNotification;
  bool get hasNotifications =>
      _pendingXPNotifications.isNotEmpty ||
      _pendingBadgeUnlocks.isNotEmpty ||
      _levelUpNotification != null;

  /// Initialize the provider
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadGamification();
    _loadDailyChallenges();
    _checkDailyLogin();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load gamification data from storage
  void _loadGamification() {
    final json = _prefs.getString('gamification');
    if (json != null) {
      try {
        _gamification = UserGamification.fromJson(jsonDecode(json));
      } catch (e) {
        debugPrint('Error loading gamification: $e');
        _gamification = UserGamification();
      }
    }
  }

  /// Save gamification data to storage
  void _saveGamification() {
    _prefs.setString('gamification', jsonEncode(_gamification.toJson()));
  }

  /// Load daily challenges
  void _loadDailyChallenges() {
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final json = _prefs.getString('dailyChallenges_$todayKey');
    if (json != null) {
      try {
        final List<dynamic> list = jsonDecode(json);
        _dailyChallenges = list
            .map((e) => DailyChallenge.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error loading daily challenges: $e');
        _dailyChallenges = DailyChallengeGenerator.generateDailyChallenges(
          today,
        );
        _saveDailyChallenges();
      }
    } else {
      _dailyChallenges = DailyChallengeGenerator.generateDailyChallenges(today);
      _saveDailyChallenges();
    }
  }

  /// Save daily challenges
  void _saveDailyChallenges() {
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    _prefs.setString(
      'dailyChallenges_$todayKey',
      jsonEncode(_dailyChallenges.map((c) => c.toJson()).toList()),
    );
  }

  /// Check daily login and award XP
  void _checkDailyLogin() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_gamification.lastLoginDate == null ||
        !_isSameDay(_gamification.lastLoginDate!, today)) {
      // Calculate login streak
      int newLoginStreak = 1;
      if (_gamification.lastLoginDate != null) {
        final yesterday = today.subtract(const Duration(days: 1));
        if (_isSameDay(_gamification.lastLoginDate!, yesterday)) {
          newLoginStreak = _gamification.loginStreak + 1;
        }
      }

      _gamification = _gamification.copyWith(
        lastLoginDate: today,
        loginStreak: newLoginStreak,
      );

      // Award daily login XP
      addXP(XPValues.dailyLogin, XPEventType.dailyLogin, 'Daily login');
    }
  }

  /// Add XP and check for level up
  void addXP(int amount, XPEventType type, [String? description]) {
    if (amount <= 0) return;

    final previousLevel = _gamification.level;
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Create XP event
    final event = XPEvent(
      id: '${now.millisecondsSinceEpoch}',
      type: type,
      amount: amount,
      timestamp: now,
      description: description,
    );

    // Update daily XP
    final updatedDailyXP = Map<String, int>.from(_gamification.dailyXP);
    updatedDailyXP[todayKey] = (updatedDailyXP[todayKey] ?? 0) + amount;

    // Update recent events (keep last 50)
    final updatedEvents = [..._gamification.recentXPEvents, event];
    if (updatedEvents.length > 50) {
      updatedEvents.removeRange(0, updatedEvents.length - 50);
    }

    _gamification = _gamification.copyWith(
      totalXP: _gamification.totalXP + amount,
      dailyXP: updatedDailyXP,
      recentXPEvents: updatedEvents,
    );

    // Check for level up
    if (_gamification.level > previousLevel) {
      _levelUpNotification = _gamification.level;
      // Check for level badges
      _checkLevelBadges();
    }

    // Add to pending notifications
    _pendingXPNotifications.add(event);

    _saveGamification();
    notifyListeners();
  }

  /// Record a workout completion
  void recordWorkoutCompletion() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Update streak
    int newStreak = _gamification.currentStreak;
    if (_gamification.lastActivityDate == null) {
      newStreak = 1;
    } else {
      final lastDate = DateTime(
        _gamification.lastActivityDate!.year,
        _gamification.lastActivityDate!.month,
        _gamification.lastActivityDate!.day,
      );

      if (_isSameDay(lastDate, today)) {
        // Already recorded today, no streak update
      } else if (_isSameDay(
        lastDate,
        today.subtract(const Duration(days: 1)),
      )) {
        // Consecutive day
        newStreak = _gamification.currentStreak + 1;
      } else {
        // Streak broken
        newStreak = 1;
      }
    }

    final newLongestStreak = newStreak > _gamification.longestStreak
        ? newStreak
        : _gamification.longestStreak;

    _gamification = _gamification.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastActivityDate: today,
    );

    // Award workout XP
    addXP(XPValues.completeWorkout, XPEventType.workout, 'Completed workout');

    // Check streak bonuses
    if (newStreak == 7) {
      addXP(
        XPValues.streak7DayBonus,
        XPEventType.streak,
        '7-day streak bonus!',
      );
    } else if (newStreak == 30) {
      addXP(
        XPValues.streak30DayBonus,
        XPEventType.streak,
        '30-day streak bonus!',
      );
    } else if (newStreak == 100) {
      addXP(
        XPValues.streak100DayBonus,
        XPEventType.streak,
        '100-day streak bonus!',
      );
    }

    // Check workout time for special badges
    if (now.hour < 7) {
      _checkAndUnlockBadge('early_bird');
    } else if (now.hour >= 21) {
      _checkAndUnlockBadge('night_owl');
    }

    // Update daily challenges
    _updateChallengeProgress(ChallengeType.workout, 1);

    // Check workout badges
    _checkWorkoutBadges();
    _checkStreakBadges();

    _saveGamification();
    notifyListeners();
  }

  /// Record a completed set
  void recordSetCompletion(double weightLifted) {
    addXP(XPValues.completedSet, XPEventType.set, 'Completed set');

    // Track total weight lifted for badges (would need to persist this)
    _updateChallengeProgress(ChallengeType.sets, 1);

    notifyListeners();
  }

  /// Record meal logged
  void recordMealLogged() {
    addXP(XPValues.logAllMeals, XPEventType.meal, 'Logged meal');
    _checkNutritionBadges();
    notifyListeners();
  }

  /// Record water intake
  void recordWaterIntake(int glasses, int goal) {
    if (glasses >= goal) {
      addXP(XPValues.hitWaterGoal, XPEventType.water, 'Hit water goal');
      _updateChallengeProgress(ChallengeType.water, glasses);
      _checkHydrationBadges();
    }
    notifyListeners();
  }

  /// Record steps
  void recordSteps(int steps, int goal) {
    if (steps >= goal) {
      addXP(XPValues.hitStepGoal, XPEventType.steps, 'Hit step goal');
    }
    _updateChallengeProgress(ChallengeType.steps, steps);
    _checkStepBadges(steps);
    notifyListeners();
  }

  /// Record weight logged
  void recordWeightLogged() {
    addXP(XPValues.logWeight, XPEventType.weight, 'Logged weight');
    _checkWeightBadges();
    notifyListeners();
  }

  /// Record personal record
  void recordPersonalRecord() {
    addXP(
      XPValues.personalRecord,
      XPEventType.personalRecord,
      'New personal record!',
    );
    _checkPRBadges();
    notifyListeners();
  }

  /// Update challenge progress
  void _updateChallengeProgress(ChallengeType type, int amount) {
    bool updated = false;

    for (int i = 0; i < _dailyChallenges.length; i++) {
      if (_dailyChallenges[i].type == type &&
          !_dailyChallenges[i].isCompleted) {
        final challenge = _dailyChallenges[i];
        final newProgress =
            type == ChallengeType.steps || type == ChallengeType.water
            ? amount // For steps/water, use the total amount
            : challenge.currentProgress + amount; // For others, increment

        _dailyChallenges[i] = challenge.copyWith(
          currentProgress: newProgress,
          isCompleted: newProgress >= challenge.target,
        );

        // Award XP if challenge completed
        if (_dailyChallenges[i].isCompleted && !challenge.isCompleted) {
          addXP(
            challenge.xpReward,
            XPEventType.other,
            'Challenge: ${challenge.title}',
          );
        }

        updated = true;
      }
    }

    if (updated) {
      _saveDailyChallenges();
    }
  }

  /// Check and unlock a badge
  void _checkAndUnlockBadge(String badgeId) {
    if (!_gamification.unlockedBadgeIds.contains(badgeId)) {
      final updatedBadges = [..._gamification.unlockedBadgeIds, badgeId];
      _gamification = _gamification.copyWith(unlockedBadgeIds: updatedBadges);
      _pendingBadgeUnlocks.add(badgeId);
      addXP(XPValues.unlockBadge, XPEventType.badge, 'Badge unlocked!');
    }
  }

  /// Check workout-related badges
  void _checkWorkoutBadges() {
    // This would need workout count from fitness provider
    // For now, we'll check based on XP events
    final workoutEvents = _gamification.recentXPEvents
        .where((e) => e.type == XPEventType.workout)
        .length;

    if (workoutEvents >= 1) _checkAndUnlockBadge('first_flame');
    if (workoutEvents >= 10) _checkAndUnlockBadge('ten_timer');
    if (workoutEvents >= 50) _checkAndUnlockBadge('fifty_fit');
    if (workoutEvents >= 100) _checkAndUnlockBadge('century');
  }

  /// Check streak badges
  void _checkStreakBadges() {
    if (_gamification.currentStreak >= 7) _checkAndUnlockBadge('week_warrior');
    if (_gamification.currentStreak >= 14) {
      _checkAndUnlockBadge('two_week_titan');
    }
    if (_gamification.currentStreak >= 30) {
      _checkAndUnlockBadge('monthly_master');
    }
    if (_gamification.currentStreak >= 100) {
      _checkAndUnlockBadge('streak_immortal');
    }
  }

  /// Check level badges
  void _checkLevelBadges() {
    if (_gamification.level >= 10) _checkAndUnlockBadge('level_10');
    if (_gamification.level >= 25) _checkAndUnlockBadge('level_25');
    if (_gamification.level >= 50) _checkAndUnlockBadge('level_50');
  }

  /// Check step badges
  void _checkStepBadges(int dailySteps) {
    if (dailySteps >= 10000) _checkAndUnlockBadge('step_starter');
    if (dailySteps >= 20000) _checkAndUnlockBadge('step_master');
  }

  /// Check hydration badges
  void _checkHydrationBadges() {
    // Would need water goal tracking
    _checkAndUnlockBadge('hydration_starter');
  }

  /// Check nutrition badges
  void _checkNutritionBadges() {
    _checkAndUnlockBadge('meal_logger');
  }

  /// Check weight badges
  void _checkWeightBadges() {
    _checkAndUnlockBadge('scale_starter');
  }

  /// Check PR badges
  void _checkPRBadges() {
    _checkAndUnlockBadge('pr_crusher');
  }

  /// Clear XP notifications
  void clearXPNotifications() {
    _pendingXPNotifications.clear();
    notifyListeners();
  }

  /// Clear badge notifications
  void clearBadgeNotifications() {
    _pendingBadgeUnlocks.clear();
    notifyListeners();
  }

  /// Clear level up notification
  void clearLevelUpNotification() {
    _levelUpNotification = null;
    notifyListeners();
  }

  /// Clear all notifications
  void clearAllNotifications() {
    _pendingXPNotifications.clear();
    _pendingBadgeUnlocks.clear();
    _levelUpNotification = null;
    notifyListeners();
  }

  /// Get all badges with unlock status
  List<Map<String, dynamic>> getAllBadgesWithStatus() {
    return BadgeDefinitions.all.map((badge) {
      return {
        'badge': badge,
        'isUnlocked': _gamification.unlockedBadgeIds.contains(badge.id),
      };
    }).toList();
  }

  /// Get unlocked badges
  List<GamificationBadge> getUnlockedBadges() {
    return _gamification.unlockedBadgeIds
        .map((id) => BadgeDefinitions.getBadgeById(id))
        .whereType<GamificationBadge>()
        .toList();
  }

  /// Get badges by category with status
  List<Map<String, dynamic>> getBadgesByCategory(BadgeCategory category) {
    return BadgeDefinitions.getBadgesByCategory(category).map((badge) {
      return {
        'badge': badge,
        'isUnlocked': _gamification.unlockedBadgeIds.contains(badge.id),
      };
    }).toList();
  }

  /// Helper: Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Reset gamification data (for testing)
  void resetGamification() {
    _gamification = UserGamification();
    _dailyChallenges = DailyChallengeGenerator.generateDailyChallenges(
      DateTime.now(),
    );
    _saveGamification();
    _saveDailyChallenges();
    notifyListeners();
  }
}
