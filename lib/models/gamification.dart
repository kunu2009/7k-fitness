/// Gamification models for XP, Levels, and enhanced badges
/// Works with the existing Achievement and Streak models
library;

/// XP values for different actions
class XPValues {
  static const int completeWorkout = 100;
  static const int logAllMeals = 50;
  static const int hitWaterGoal = 25;
  static const int hitStepGoal = 50;
  static const int streak7DayBonus = 200;
  static const int streak30DayBonus = 1000;
  static const int streak100DayBonus = 5000;
  static const int logWeight = 10;
  static const int completedSet = 5;
  static const int personalRecord = 150;
  static const int unlockBadge = 50;
  static const int dailyLogin = 10;
}

/// Level thresholds - XP required to reach each level
class LevelThresholds {
  static const Map<int, int> levels = {
    1: 0,
    2: 100,
    3: 300,
    4: 600,
    5: 1000,
    6: 1500,
    7: 2100,
    8: 2800,
    9: 3600,
    10: 4500,
    11: 5500,
    12: 6600,
    13: 7800,
    14: 9100,
    15: 10500,
    16: 12000,
    17: 13600,
    18: 15300,
    19: 17100,
    20: 19000,
    21: 21000,
    22: 23100,
    23: 25300,
    24: 27600,
    25: 30000,
    26: 32500,
    27: 35100,
    28: 37800,
    29: 40600,
    30: 43500,
    31: 46500,
    32: 49600,
    33: 52800,
    34: 56100,
    35: 59500,
    36: 63000,
    37: 66600,
    38: 70300,
    39: 74100,
    40: 78000,
    41: 82000,
    42: 86100,
    43: 90300,
    44: 94600,
    45: 99000,
    46: 103500,
    47: 108100,
    48: 112800,
    49: 117600,
    50: 122500,
  };

  static int getLevelForXP(int xp) {
    int level = 1;
    for (var entry in levels.entries) {
      if (xp >= entry.value) {
        level = entry.key;
      } else {
        break;
      }
    }
    return level;
  }

  static int getXPForLevel(int level) {
    return levels[level] ?? levels[50]!;
  }

  static int getXPForNextLevel(int currentLevel) {
    final nextLevel = currentLevel + 1;
    return levels[nextLevel] ?? levels[50]!;
  }

  static double getProgressToNextLevel(int xp) {
    final currentLevel = getLevelForXP(xp);
    final currentLevelXP = getXPForLevel(currentLevel);
    final nextLevelXP = getXPForNextLevel(currentLevel);

    if (nextLevelXP == currentLevelXP) return 1.0;

    return (xp - currentLevelXP) / (nextLevelXP - currentLevelXP);
  }
}

/// Level titles based on level number
class LevelTitles {
  static const Map<int, String> titles = {
    1: 'Beginner',
    5: 'Novice',
    10: 'Intermediate',
    15: 'Dedicated',
    20: 'Advanced',
    25: 'Expert',
    30: 'Master',
    35: 'Elite',
    40: 'Champion',
    45: 'Legend',
    50: 'Immortal',
  };

  static String getTitleForLevel(int level) {
    String title = 'Beginner';
    for (var entry in titles.entries) {
      if (level >= entry.key) {
        title = entry.value;
      }
    }
    return title;
  }
}

/// XP Event record for history tracking
class XPEvent {
  final String id;
  final XPEventType type;
  final int amount;
  final DateTime timestamp;
  final String? description;

  XPEvent({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }

  factory XPEvent.fromJson(Map<String, dynamic> json) {
    return XPEvent(
      id: json['id'] as String,
      type: XPEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => XPEventType.other,
      ),
      amount: json['amount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String?,
    );
  }
}

/// Types of XP events
enum XPEventType {
  workout,
  meal,
  water,
  steps,
  weight,
  streak,
  badge,
  personalRecord,
  dailyLogin,
  set,
  other,
}

/// User gamification data
class UserGamification {
  final int totalXP;
  final int level;
  final String title;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final List<String> unlockedBadgeIds;
  final List<XPEvent> recentXPEvents;
  final Map<String, int> dailyXP; // date string -> xp earned that day
  final DateTime? lastLoginDate;
  final int loginStreak;

  UserGamification({
    this.totalXP = 0,
    this.level = 1,
    this.title = 'Beginner',
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    this.unlockedBadgeIds = const [],
    this.recentXPEvents = const [],
    this.dailyXP = const {},
    this.lastLoginDate,
    this.loginStreak = 0,
  });

  int get xpToNextLevel => LevelThresholds.getXPForNextLevel(level) - totalXP;
  double get progressToNextLevel =>
      LevelThresholds.getProgressToNextLevel(totalXP);

  int get todayXP {
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return dailyXP[todayKey] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalXP': totalXP,
      'level': level,
      'title': title,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
      'unlockedBadgeIds': unlockedBadgeIds,
      'recentXPEvents': recentXPEvents.map((e) => e.toJson()).toList(),
      'dailyXP': dailyXP,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'loginStreak': loginStreak,
    };
  }

  factory UserGamification.fromJson(Map<String, dynamic> json) {
    final totalXP = json['totalXP'] as int? ?? 0;
    final level = LevelThresholds.getLevelForXP(totalXP);

    return UserGamification(
      totalXP: totalXP,
      level: level,
      title: LevelTitles.getTitleForLevel(level),
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'] as String)
          : null,
      unlockedBadgeIds:
          (json['unlockedBadgeIds'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      recentXPEvents:
          (json['recentXPEvents'] as List?)
              ?.map((e) => XPEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dailyXP:
          (json['dailyXP'] as Map?)?.map(
            (key, value) => MapEntry(key as String, value as int),
          ) ??
          {},
      lastLoginDate: json['lastLoginDate'] != null
          ? DateTime.parse(json['lastLoginDate'] as String)
          : null,
      loginStreak: json['loginStreak'] as int? ?? 0,
    );
  }

  UserGamification copyWith({
    int? totalXP,
    int? level,
    String? title,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    List<String>? unlockedBadgeIds,
    List<XPEvent>? recentXPEvents,
    Map<String, int>? dailyXP,
    DateTime? lastLoginDate,
    int? loginStreak,
  }) {
    final newXP = totalXP ?? this.totalXP;
    final newLevel = LevelThresholds.getLevelForXP(newXP);

    return UserGamification(
      totalXP: newXP,
      level: newLevel,
      title: LevelTitles.getTitleForLevel(newLevel),
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      unlockedBadgeIds: unlockedBadgeIds ?? this.unlockedBadgeIds,
      recentXPEvents: recentXPEvents ?? this.recentXPEvents,
      dailyXP: dailyXP ?? this.dailyXP,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      loginStreak: loginStreak ?? this.loginStreak,
    );
  }
}

/// Badge definitions for gamification
class GamificationBadge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BadgeCategory category;
  final BadgeRarity rarity;
  final int requirement;
  final String requirementType;

  const GamificationBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.rarity = BadgeRarity.common,
    required this.requirement,
    required this.requirementType,
  });
}

enum BadgeCategory {
  workout,
  streak,
  nutrition,
  hydration,
  steps,
  weight,
  special,
}

enum BadgeRarity { common, uncommon, rare, epic, legendary }

/// All badge definitions
class BadgeDefinitions {
  static const List<GamificationBadge> all = [
    // Workout badges
    GamificationBadge(
      id: 'first_flame',
      name: 'First Flame',
      description: 'Complete your first workout',
      icon: '🔥',
      category: BadgeCategory.workout,
      rarity: BadgeRarity.common,
      requirement: 1,
      requirementType: 'total_workouts',
    ),
    GamificationBadge(
      id: 'ten_timer',
      name: 'Ten Timer',
      description: 'Complete 10 workouts',
      icon: '💪',
      category: BadgeCategory.workout,
      rarity: BadgeRarity.common,
      requirement: 10,
      requirementType: 'total_workouts',
    ),
    GamificationBadge(
      id: 'fifty_fit',
      name: 'Fifty Fit',
      description: 'Complete 50 workouts',
      icon: '🏋️',
      category: BadgeCategory.workout,
      rarity: BadgeRarity.uncommon,
      requirement: 50,
      requirementType: 'total_workouts',
    ),
    GamificationBadge(
      id: 'century',
      name: 'Century',
      description: 'Complete 100 workouts',
      icon: '💯',
      category: BadgeCategory.workout,
      rarity: BadgeRarity.rare,
      requirement: 100,
      requirementType: 'total_workouts',
    ),
    GamificationBadge(
      id: 'workout_warrior',
      name: 'Workout Warrior',
      description: 'Complete 500 workouts',
      icon: '⚔️',
      category: BadgeCategory.workout,
      rarity: BadgeRarity.epic,
      requirement: 500,
      requirementType: 'total_workouts',
    ),
    GamificationBadge(
      id: 'fitness_legend',
      name: 'Fitness Legend',
      description: 'Complete 1000 workouts',
      icon: '👑',
      category: BadgeCategory.workout,
      rarity: BadgeRarity.legendary,
      requirement: 1000,
      requirementType: 'total_workouts',
    ),

    // Streak badges
    GamificationBadge(
      id: 'week_warrior',
      name: 'Week Warrior',
      description: '7-day workout streak',
      icon: '📅',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.uncommon,
      requirement: 7,
      requirementType: 'workout_streak',
    ),
    GamificationBadge(
      id: 'two_week_titan',
      name: 'Two Week Titan',
      description: '14-day workout streak',
      icon: '⚡',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.rare,
      requirement: 14,
      requirementType: 'workout_streak',
    ),
    GamificationBadge(
      id: 'monthly_master',
      name: 'Monthly Master',
      description: '30-day workout streak',
      icon: '🏆',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.epic,
      requirement: 30,
      requirementType: 'workout_streak',
    ),
    GamificationBadge(
      id: 'streak_immortal',
      name: 'Streak Immortal',
      description: '100-day workout streak',
      icon: '💎',
      category: BadgeCategory.streak,
      rarity: BadgeRarity.legendary,
      requirement: 100,
      requirementType: 'workout_streak',
    ),

    // Weight lifted badges
    GamificationBadge(
      id: 'heavy_lifter',
      name: 'Heavy Lifter',
      description: 'Lift 10,000 kg total',
      icon: '🏋️',
      category: BadgeCategory.workout,
      rarity: BadgeRarity.uncommon,
      requirement: 10000,
      requirementType: 'total_weight_lifted',
    ),
    GamificationBadge(
      id: 'iron_pumper',
      name: 'Iron Pumper',
      description: 'Lift 50,000 kg total',
      icon: '💪',
      category: BadgeCategory.workout,
      rarity: BadgeRarity.rare,
      requirement: 50000,
      requirementType: 'total_weight_lifted',
    ),
    GamificationBadge(
      id: 'strength_titan',
      name: 'Strength Titan',
      description: 'Lift 100,000 kg total',
      icon: '🦾',
      category: BadgeCategory.workout,
      rarity: BadgeRarity.epic,
      requirement: 100000,
      requirementType: 'total_weight_lifted',
    ),

    // Steps badges
    GamificationBadge(
      id: 'step_starter',
      name: 'Step Starter',
      description: 'Walk 10,000 steps in a day',
      icon: '🚶',
      category: BadgeCategory.steps,
      rarity: BadgeRarity.common,
      requirement: 10000,
      requirementType: 'daily_steps',
    ),
    GamificationBadge(
      id: 'step_master',
      name: 'Step Master',
      description: 'Walk 20,000 steps in a day',
      icon: '🏃',
      category: BadgeCategory.steps,
      rarity: BadgeRarity.rare,
      requirement: 20000,
      requirementType: 'daily_steps',
    ),
    GamificationBadge(
      id: 'step_champion',
      name: 'Step Champion',
      description: '100,000 total steps',
      icon: '👟',
      category: BadgeCategory.steps,
      rarity: BadgeRarity.uncommon,
      requirement: 100000,
      requirementType: 'total_steps',
    ),
    GamificationBadge(
      id: 'marathon_walker',
      name: 'Marathon Walker',
      description: '1,000,000 total steps',
      icon: '🏅',
      category: BadgeCategory.steps,
      rarity: BadgeRarity.epic,
      requirement: 1000000,
      requirementType: 'total_steps',
    ),

    // Hydration badges
    GamificationBadge(
      id: 'hydration_starter',
      name: 'Hydration Starter',
      description: 'Hit water goal for the first time',
      icon: '💧',
      category: BadgeCategory.hydration,
      rarity: BadgeRarity.common,
      requirement: 1,
      requirementType: 'water_goal_days',
    ),
    GamificationBadge(
      id: 'hydration_habit',
      name: 'Hydration Habit',
      description: 'Hit water goal for 7 days',
      icon: '🌊',
      category: BadgeCategory.hydration,
      rarity: BadgeRarity.uncommon,
      requirement: 7,
      requirementType: 'water_goal_days',
    ),
    GamificationBadge(
      id: 'hydration_hero',
      name: 'Hydration Hero',
      description: 'Hit water goal for 30 days',
      icon: '🐳',
      category: BadgeCategory.hydration,
      rarity: BadgeRarity.rare,
      requirement: 30,
      requirementType: 'water_goal_days',
    ),

    // Nutrition badges
    GamificationBadge(
      id: 'meal_logger',
      name: 'Meal Logger',
      description: 'Log your first meal',
      icon: '🍽️',
      category: BadgeCategory.nutrition,
      rarity: BadgeRarity.common,
      requirement: 1,
      requirementType: 'meals_logged',
    ),
    GamificationBadge(
      id: 'nutrition_tracker',
      name: 'Nutrition Tracker',
      description: 'Log meals for 7 days',
      icon: '📊',
      category: BadgeCategory.nutrition,
      rarity: BadgeRarity.uncommon,
      requirement: 7,
      requirementType: 'meal_logging_days',
    ),
    GamificationBadge(
      id: 'nutrition_ninja',
      name: 'Nutrition Ninja',
      description: 'Log meals for 30 days',
      icon: '🥗',
      category: BadgeCategory.nutrition,
      rarity: BadgeRarity.rare,
      requirement: 30,
      requirementType: 'meal_logging_days',
    ),

    // Weight tracking badges
    GamificationBadge(
      id: 'scale_starter',
      name: 'Scale Starter',
      description: 'Log your weight for the first time',
      icon: '⚖️',
      category: BadgeCategory.weight,
      rarity: BadgeRarity.common,
      requirement: 1,
      requirementType: 'weight_logs',
    ),
    GamificationBadge(
      id: 'consistent_tracker',
      name: 'Consistent Tracker',
      description: 'Log weight for 30 days',
      icon: '📈',
      category: BadgeCategory.weight,
      rarity: BadgeRarity.uncommon,
      requirement: 30,
      requirementType: 'weight_logs',
    ),

    // Special badges
    GamificationBadge(
      id: 'early_bird',
      name: 'Early Bird',
      description: 'Complete a workout before 7 AM',
      icon: '🌅',
      category: BadgeCategory.special,
      rarity: BadgeRarity.uncommon,
      requirement: 1,
      requirementType: 'early_workout',
    ),
    GamificationBadge(
      id: 'night_owl',
      name: 'Night Owl',
      description: 'Complete a workout after 9 PM',
      icon: '🌙',
      category: BadgeCategory.special,
      rarity: BadgeRarity.uncommon,
      requirement: 1,
      requirementType: 'night_workout',
    ),
    GamificationBadge(
      id: 'weekend_warrior',
      name: 'Weekend Warrior',
      description: 'Work out on both Saturday and Sunday',
      icon: '🗓️',
      category: BadgeCategory.special,
      rarity: BadgeRarity.uncommon,
      requirement: 1,
      requirementType: 'weekend_workout',
    ),
    GamificationBadge(
      id: 'pr_crusher',
      name: 'PR Crusher',
      description: 'Set your first personal record',
      icon: '🎯',
      category: BadgeCategory.special,
      rarity: BadgeRarity.uncommon,
      requirement: 1,
      requirementType: 'personal_records',
    ),
    GamificationBadge(
      id: 'pr_machine',
      name: 'PR Machine',
      description: 'Set 10 personal records',
      icon: '🚀',
      category: BadgeCategory.special,
      rarity: BadgeRarity.rare,
      requirement: 10,
      requirementType: 'personal_records',
    ),
    GamificationBadge(
      id: 'level_10',
      name: 'Double Digits',
      description: 'Reach level 10',
      icon: '🔟',
      category: BadgeCategory.special,
      rarity: BadgeRarity.uncommon,
      requirement: 10,
      requirementType: 'level',
    ),
    GamificationBadge(
      id: 'level_25',
      name: 'Quarter Century',
      description: 'Reach level 25',
      icon: '🏅',
      category: BadgeCategory.special,
      rarity: BadgeRarity.rare,
      requirement: 25,
      requirementType: 'level',
    ),
    GamificationBadge(
      id: 'level_50',
      name: 'Maximum Level',
      description: 'Reach level 50',
      icon: '👑',
      category: BadgeCategory.special,
      rarity: BadgeRarity.legendary,
      requirement: 50,
      requirementType: 'level',
    ),
  ];

  static GamificationBadge? getBadgeById(String id) {
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<GamificationBadge> getBadgesByCategory(BadgeCategory category) {
    return all.where((b) => b.category == category).toList();
  }

  static List<GamificationBadge> getBadgesByRarity(BadgeRarity rarity) {
    return all.where((b) => b.rarity == rarity).toList();
  }
}

/// Daily challenge model
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int target;
  final int xpReward;
  final DateTime date;
  int currentProgress;
  bool isCompleted;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.xpReward,
    required this.date,
    this.currentProgress = 0,
    this.isCompleted = false,
  });

  double get progress =>
      target > 0 ? (currentProgress / target).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'target': target,
      'xpReward': xpReward,
      'date': date.toIso8601String(),
      'currentProgress': currentProgress,
      'isCompleted': isCompleted,
    };
  }

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.workout,
      ),
      target: json['target'] as int,
      xpReward: json['xpReward'] as int,
      date: DateTime.parse(json['date'] as String),
      currentProgress: json['currentProgress'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  DailyChallenge copyWith({int? currentProgress, bool? isCompleted}) {
    return DailyChallenge(
      id: id,
      title: title,
      description: description,
      type: type,
      target: target,
      xpReward: xpReward,
      date: date,
      currentProgress: currentProgress ?? this.currentProgress,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

enum ChallengeType { workout, steps, water, calories, sets, exercises }

/// Daily challenge generator
class DailyChallengeGenerator {
  static List<DailyChallenge> generateDailyChallenges(DateTime date) {
    final dayOfWeek = date.weekday;
    final challenges = <DailyChallenge>[];

    // Always have a workout challenge
    challenges.add(
      DailyChallenge(
        id: 'daily_workout_${date.toIso8601String()}',
        title: 'Complete a Workout',
        description: 'Finish any workout today',
        type: ChallengeType.workout,
        target: 1,
        xpReward: 50,
        date: date,
      ),
    );

    // Steps challenge
    challenges.add(
      DailyChallenge(
        id: 'daily_steps_${date.toIso8601String()}',
        title: 'Step It Up',
        description: 'Walk 8,000 steps today',
        type: ChallengeType.steps,
        target: 8000,
        xpReward: 40,
        date: date,
      ),
    );

    // Water challenge
    challenges.add(
      DailyChallenge(
        id: 'daily_water_${date.toIso8601String()}',
        title: 'Stay Hydrated',
        description: 'Drink 8 glasses of water',
        type: ChallengeType.water,
        target: 8,
        xpReward: 25,
        date: date,
      ),
    );

    // Weekend bonus challenge
    if (dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday) {
      challenges.add(
        DailyChallenge(
          id: 'weekend_bonus_${date.toIso8601String()}',
          title: 'Weekend Warrior',
          description: 'Complete 2 workouts this weekend',
          type: ChallengeType.workout,
          target: 2,
          xpReward: 100,
          date: date,
        ),
      );
    }

    return challenges;
  }
}
