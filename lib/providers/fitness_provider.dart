import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/fitness_data.dart';
import '../models/achievement.dart';
import '../models/goal.dart';
import '../models/exercise.dart';
import '../models/workout_program.dart';
import '../models/nutrition.dart';

class FitnessProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  List<FitnessData> _fitnessHistory = [];
  FitnessData? _todayData;
  UserProfile? _userProfile;
  bool _isFirstTime = true;
  bool _isDarkMode = false;

  // New: Achievements, Goals, Workouts, Programs
  List<Achievement> _achievements = [];
  List<FitnessGoal> _goals = [];
  List<WorkoutSession> _workoutSessions = [];
  List<UserProgram> _enrolledPrograms = [];
  Streak _workoutStreak = Streak(id: 'workout_streak', type: 'workout');
  WorkoutSession? _activeWorkout;

  // Queued achievement unlocks for UI notification
  final List<Achievement> _pendingAchievementUnlocks = [];

  // Nutrition: logged food entries
  List<FoodEntry> _foodEntries = [];

  List<FitnessData> get fitnessHistory => _fitnessHistory;
  FitnessData? get todayData => _todayData;
  UserProfile? get userProfile => _userProfile;
  bool get isDarkMode => _isDarkMode;
  bool get isFirstTime => _isFirstTime;

  // New getters
  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();
  int get totalAchievementPoints =>
      unlockedAchievements.fold(0, (sum, a) => sum + a.points);
  List<FitnessGoal> get goals => _goals;
  List<FitnessGoal> get activeGoals => _goals.where((g) => g.isActive).toList();
  List<FitnessGoal> get todayGoals => _goals
      .where((g) => g.frequency == GoalFrequency.daily && g.isActive)
      .toList();
  List<WorkoutSession> get workoutSessions => _workoutSessions;
  List<UserProgram> get enrolledPrograms => _enrolledPrograms;
  Streak get workoutStreak => _workoutStreak;
  WorkoutSession? get activeWorkout => _activeWorkout;
  bool get hasActiveWorkout => _activeWorkout != null;
  List<Achievement> get pendingAchievementUnlocks => _pendingAchievementUnlocks;

  // Nutrition getters
  List<FoodEntry> get foodEntries => _foodEntries;
  List<FoodEntry> foodEntriesForDate(DateTime date) {
    return _foodEntries
        .where(
          (e) =>
              e.loggedAt.year == date.year &&
              e.loggedAt.month == date.month &&
              e.loggedAt.day == date.day,
        )
        .toList();
  }

  int get totalWorkoutsCompleted =>
      _workoutSessions.where((w) => w.isCompleted).length;
  Duration get totalWorkoutTime =>
      _workoutSessions.fold(Duration.zero, (sum, w) => sum + w.duration);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadData();
    _loadDarkMode();
    _initializeAchievements();
    _loadAchievements();
    _loadFoodEntries();
    _loadGoals();
    _loadWorkoutSessions();
    _loadStreak();
    _loadEnrolledPrograms();
  }

  void _loadDarkMode() {
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void _initializeAchievements() {
    // Initialize with all predefined achievements if empty
    if (_achievements.isEmpty) {
      _achievements = AchievementDefinitions.allAchievements;
    }
  }

  void _loadData() {
    // Load user profile
    final profileJson = _prefs.getString('userProfile');
    if (profileJson != null) {
      try {
        _userProfile = UserProfile.fromJson(jsonDecode(profileJson));
        _isFirstTime = false;
      } catch (e) {
        debugPrint('Error loading profile JSON: $e');
        _tryLoadProfileFromKeys();
      }
    } else {
      _tryLoadProfileFromKeys();
    }

    // Load fitness history
    final historyJson = _prefs.getStringList('fitnessHistory') ?? [];
    _fitnessHistory = historyJson
        .map((json) => FitnessData.fromJson(jsonDecode(json)))
        .toList();

    // Initialize today's data if not exists
    if (_todayData == null || _todayData!.date.day != DateTime.now().day) {
      _todayData = FitnessData(
        date: DateTime.now(),
        calories: 0,
        steps: 0,
        waterGlasses: 0,
        sleepHours: 0,
        bpm: 72,
        weight: _userProfile?.weight ?? 70,
      );
    }
  }

  void _tryLoadProfileFromKeys() {
    // Fallback: Try to load from individual settings keys
    final name = _prefs.getString('user_name');
    if (name != null && name.isNotEmpty) {
      final age = _prefs.getInt('user_age') ?? 25;
      final height = _prefs.getDouble('user_height') ?? 170.0;
      final weight = _prefs.getDouble('user_weight') ?? 70.0;

      // Handle Enums stored as Ints
      final genderIndex = _prefs.getInt('user_gender') ?? 0;
      final gender = genderIndex == 0
          ? 'Male'
          : (genderIndex == 1 ? 'Female' : 'Other');

      final activityIndex = _prefs.getInt('activity_level') ?? 2;
      final activityLevel = [
        'Sedentary',
        'Light',
        'Moderate',
        'Very Active',
        'Extra Active',
      ][activityIndex.clamp(0, 4)];

      final goalIndex = _prefs.getInt('fitness_goal') ?? 1;
      final fitnessGoal = [
        'Lose Weight',
        'Maintain Weight',
        'Gain Muscle',
      ][goalIndex.clamp(0, 2)];

      _userProfile = UserProfile(
        name: name,
        age: age,
        height: height,
        weight: weight,
        gender: gender,
        activityLevel: activityLevel,
        fitnessGoal: fitnessGoal,
      );
      _isFirstTime = false;

      // Save as JSON for next time
      final json = jsonEncode(_userProfile!.toJson());
      _prefs.setString('userProfile', json);
    } else {
      _isFirstTime = true;
    }
  }

  // ==================== NUTRITION ====================

  void _loadFoodEntries() {
    final entriesJson = _prefs.getStringList('foodEntries') ?? [];
    if (entriesJson.isNotEmpty) {
      _foodEntries = entriesJson
          .map((json) => FoodEntry.fromJson(jsonDecode(json)))
          .toList();
    }
  }

  void _saveFoodEntries() {
    final entriesJson = _foodEntries
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    _prefs.setStringList('foodEntries', entriesJson);
  }

  void addFoodEntry(FoodEntry entry) {
    _foodEntries.add(entry);
    _saveFoodEntries();
    // Update today's calories if applicable
    if (entry.loggedAt.year == DateTime.now().year &&
        entry.loggedAt.month == DateTime.now().month &&
        entry.loggedAt.day == DateTime.now().day) {
      updateTodayData(
        calories: (_todayData?.calories ?? 0) + entry.nutrition.calories,
      );
    }
    notifyListeners();
  }

  void removeFoodEntry(String entryId) {
    _foodEntries.removeWhere((e) => e.id == entryId);
    _saveFoodEntries();
    notifyListeners();
  }

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    _isFirstTime = false;
    final json = jsonEncode(_userProfile!.toJson());
    _prefs.setString('userProfile', json);
    notifyListeners();
  }

  Future<void> resetProfileAndData() async {
    _userProfile = null;
    _isFirstTime = true;

    _fitnessHistory = [];
    _todayData = null;
    _foodEntries = [];
    _goals = [];
    _workoutSessions = [];
    _enrolledPrograms = [];
    _activeWorkout = null;
    _workoutStreak = Streak(id: 'workout_streak', type: 'workout');
    _pendingAchievementUnlocks.clear();
    _achievements = AchievementDefinitions.allAchievements;

    await _prefs.remove('userProfile');
    await _prefs.remove('fitnessHistory');
    await _prefs.remove('todayData');
    await _prefs.remove('foodEntries');
    await _prefs.remove('achievements');
    await _prefs.remove('goals');
    await _prefs.remove('workoutSessions');
    await _prefs.remove('workoutStreak');
    await _prefs.remove('enrolledPrograms');

    await _prefs.remove('user_name');
    await _prefs.remove('user_age');
    await _prefs.remove('user_height');
    await _prefs.remove('user_weight');
    await _prefs.remove('user_gender');
    await _prefs.remove('activity_level');
    await _prefs.remove('fitness_goal');

    notifyListeners();
  }

  void updateTodayData({
    double? calories,
    int? steps,
    int? waterGlasses,
    double? sleepHours,
    int? bpm,
    double? weight,
  }) {
    if (_todayData == null) {
      _todayData = FitnessData(
        date: DateTime.now(),
        calories: calories ?? 0,
        steps: steps ?? 0,
        waterGlasses: waterGlasses ?? 0,
        sleepHours: sleepHours ?? 0,
        bpm: bpm ?? 72,
        weight: weight ?? _userProfile?.weight ?? 70,
      );
    } else {
      _todayData = FitnessData(
        date: _todayData!.date,
        calories: calories ?? _todayData!.calories,
        steps: steps ?? _todayData!.steps,
        waterGlasses: waterGlasses ?? _todayData!.waterGlasses,
        sleepHours: sleepHours ?? _todayData!.sleepHours,
        bpm: bpm ?? _todayData!.bpm,
        weight: weight ?? _todayData!.weight,
      );
    }
    _saveTodayData();
    notifyListeners();
  }

  void _saveTodayData() {
    if (_todayData != null) {
      final json = jsonEncode(_todayData!.toJson());
      _prefs.setString('todayData', json);
    }
  }

  void addToHistory() {
    if (_todayData != null) {
      _fitnessHistory.add(_todayData!);
      _saveHistory();
    }
  }

  void _saveHistory() {
    final historyJson = _fitnessHistory
        .map((data) => jsonEncode(data.toJson()))
        .toList();
    _prefs.setStringList('fitnessHistory', historyJson);
  }

  List<FitnessData> getWeeklyData() {
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    return _fitnessHistory
        .where((data) => data.date.isAfter(weekAgo) && data.date.isBefore(now))
        .toList();
  }

  double getTotalCaloriesToday() {
    return _todayData?.calories ?? 0;
  }

  int getTotalStepsToday() {
    return _todayData?.steps ?? 0;
  }

  int getTotalWaterToday() {
    return _todayData?.waterGlasses ?? 0;
  }

  double getCalorieProgress() {
    if (_userProfile == null) return 0;
    final total = _todayData?.calories ?? 0;
    return (total / _userProfile!.dailyCalorieGoal) * 100;
  }

  FitnessData getTodayData() {
    return _todayData ??
        FitnessData(
          date: DateTime.now(),
          calories: 0,
          steps: 0,
          waterGlasses: 0,
          sleepHours: 0,
          bpm: 72,
          weight: _userProfile?.weight ?? 70,
        );
  }

  // ==================== ACHIEVEMENTS ====================

  void _loadAchievements() {
    final achievementsJson = _prefs.getStringList('achievements') ?? [];
    if (achievementsJson.isNotEmpty) {
      _achievements = achievementsJson
          .map((json) => Achievement.fromJson(jsonDecode(json)))
          .toList();
    }
  }

  void _saveAchievements() {
    final achievementsJson = _achievements
        .map((a) => jsonEncode(a.toJson()))
        .toList();
    _prefs.setStringList('achievements', achievementsJson);
  }

  void checkAndUnlockAchievements() {
    for (var i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;
      double currentValue = 0;

      switch (achievement.category) {
        case AchievementCategory.workout:
          currentValue = totalWorkoutsCompleted.toDouble();
          if (currentValue >= achievement.targetValue) {
            shouldUnlock = true;
          }
          break;
        case AchievementCategory.streak:
          currentValue = _workoutStreak.currentStreak.toDouble();
          if (currentValue >= achievement.targetValue) {
            shouldUnlock = true;
          }
          break;
        case AchievementCategory.steps:
          currentValue = (_todayData?.steps ?? 0).toDouble();
          if (currentValue >= achievement.targetValue) {
            shouldUnlock = true;
          }
          break;
        case AchievementCategory.calories:
          currentValue = _todayData?.calories ?? 0;
          if (currentValue >= achievement.targetValue) {
            shouldUnlock = true;
          }
          break;
        case AchievementCategory.water:
          currentValue = (_todayData?.waterGlasses ?? 0).toDouble();
          if (currentValue >= achievement.targetValue) {
            shouldUnlock = true;
          }
          break;
        case AchievementCategory.nutrition:
        case AchievementCategory.social:
        case AchievementCategory.milestone:
        case AchievementCategory.weight:
        case AchievementCategory.special:
          // These require special conditions
          break;
      }

      if (shouldUnlock) {
        _achievements[i] = achievement.copyWith(
          isUnlocked: true,
          currentValue: currentValue,
        );
        _pendingAchievementUnlocks.add(_achievements[i]);
      } else if (currentValue > 0) {
        _achievements[i] = achievement.copyWith(currentValue: currentValue);
      }
    }

    _saveAchievements();
    notifyListeners();
  }

  Achievement? popPendingAchievementUnlock() {
    if (_pendingAchievementUnlocks.isEmpty) return null;
    return _pendingAchievementUnlocks.removeAt(0);
  }

  // ==================== GOALS ====================

  void _loadGoals() {
    final goalsJson = _prefs.getStringList('goals') ?? [];
    if (goalsJson.isNotEmpty) {
      _goals = goalsJson
          .map((json) => FitnessGoal.fromJson(jsonDecode(json)))
          .toList();
    } else {
      // Initialize with default goals
      _goals = [
        GoalTemplates.dailySteps(),
        GoalTemplates.dailyCalories(),
        GoalTemplates.dailyWater(),
        GoalTemplates.weeklyWorkouts(),
      ];
      _saveGoals();
    }
  }

  void _saveGoals() {
    final goalsJson = _goals.map((g) => jsonEncode(g.toJson())).toList();
    _prefs.setStringList('goals', goalsJson);
  }

  void addGoal(FitnessGoal goal) {
    _goals.add(goal);
    _saveGoals();
    notifyListeners();
  }

  void updateGoal(FitnessGoal updatedGoal) {
    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      _saveGoals();
      notifyListeners();
    }
  }

  void deleteGoal(String goalId) {
    _goals.removeWhere((g) => g.id == goalId);
    _saveGoals();
    notifyListeners();
  }

  void logGoalProgress(String goalId, double value) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(
        currentValue: _goals[index].currentValue + value,
      );
      _saveGoals();
      checkAndUnlockAchievements();
      notifyListeners();
    }
  }

  void updateGoalsFromTodayData() {
    for (var i = 0; i < _goals.length; i++) {
      final goal = _goals[i];
      if (goal.frequency != GoalFrequency.daily) continue;

      double newValue = goal.currentValue;
      switch (goal.type) {
        case GoalType.steps:
          newValue = (_todayData?.steps ?? 0).toDouble();
          break;
        case GoalType.calories:
          newValue = _todayData?.calories ?? 0;
          break;
        case GoalType.water:
          newValue = (_todayData?.waterGlasses ?? 0).toDouble();
          break;
        case GoalType.sleep:
          newValue = _todayData?.sleepHours ?? 0;
          break;
        default:
          continue;
      }

      _goals[i] = goal.copyWith(currentValue: newValue);
    }
    _saveGoals();
    notifyListeners();
  }

  // ==================== WORKOUT SESSIONS ====================

  void _loadWorkoutSessions() {
    final sessionsJson = _prefs.getStringList('workoutSessions') ?? [];
    if (sessionsJson.isNotEmpty) {
      _workoutSessions = sessionsJson
          .map((json) => WorkoutSession.fromJson(jsonDecode(json)))
          .toList();
    }
  }

  void _saveWorkoutSessions() {
    final sessionsJson = _workoutSessions
        .map((s) => jsonEncode(s.toJson()))
        .toList();
    _prefs.setStringList('workoutSessions', sessionsJson);
  }

  void startWorkout({String? name, String? programId}) {
    _activeWorkout = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name ?? 'Quick Workout',
      startTime: DateTime.now(),
      exercises: [],
      programId: programId,
    );
    notifyListeners();
  }

  void addExerciseToWorkout(WorkoutExercise exercise) {
    if (_activeWorkout == null) return;
    _activeWorkout = _activeWorkout!.copyWith(
      exercises: [..._activeWorkout!.exercises, exercise],
    );
    notifyListeners();
  }

  void updateExerciseInWorkout(int index, WorkoutExercise exercise) {
    if (_activeWorkout == null) return;
    final exercises = List<WorkoutExercise>.from(_activeWorkout!.exercises);
    exercises[index] = exercise;
    _activeWorkout = _activeWorkout!.copyWith(exercises: exercises);
    notifyListeners();
  }

  void removeExerciseFromWorkout(int index) {
    if (_activeWorkout == null) return;
    final exercises = List<WorkoutExercise>.from(_activeWorkout!.exercises);
    exercises.removeAt(index);
    _activeWorkout = _activeWorkout!.copyWith(exercises: exercises);
    notifyListeners();
  }

  void completeWorkout({String? notes, int? rating}) {
    if (_activeWorkout == null) return;

    final completedWorkout = _activeWorkout!.copyWith(
      endTime: DateTime.now(),
      isCompleted: true,
      notes: notes,
      rating: rating,
    );

    _workoutSessions.add(completedWorkout);
    _saveWorkoutSessions();

    // Update streak
    _workoutStreak.recordActivity(DateTime.now());
    _saveStreak();

    // Update weekly workout goal
    final weeklyWorkoutGoal = _goals.firstWhere(
      (g) => g.type == GoalType.workout && g.frequency == GoalFrequency.weekly,
      orElse: () => GoalTemplates.weeklyWorkouts(),
    );
    logGoalProgress(weeklyWorkoutGoal.id, 1);

    // Check achievements
    checkAndUnlockAchievements();

    _activeWorkout = null;
    notifyListeners();
  }

  void cancelWorkout() {
    _activeWorkout = null;
    notifyListeners();
  }

  List<WorkoutSession> getWorkoutsForDate(DateTime date) {
    return _workoutSessions
        .where(
          (w) =>
              w.startTime.year == date.year &&
              w.startTime.month == date.month &&
              w.startTime.day == date.day,
        )
        .toList();
  }

  List<WorkoutSession> getRecentWorkouts({int limit = 10}) {
    final sorted = List<WorkoutSession>.from(_workoutSessions)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    return sorted.take(limit).toList();
  }

  // ==================== STREAK ====================

  void _loadStreak() {
    final streakJson = _prefs.getString('workoutStreak');
    if (streakJson != null) {
      _workoutStreak = Streak.fromJson(jsonDecode(streakJson));
    }
  }

  void _saveStreak() {
    _prefs.setString('workoutStreak', jsonEncode(_workoutStreak.toJson()));
  }

  // ==================== PROGRAMS ====================

  void _loadEnrolledPrograms() {
    final programsJson = _prefs.getStringList('enrolledPrograms') ?? [];
    if (programsJson.isNotEmpty) {
      _enrolledPrograms = programsJson
          .map((json) => UserProgram.fromJson(jsonDecode(json)))
          .toList();
    }
  }

  void _saveEnrolledPrograms() {
    final programsJson = _enrolledPrograms
        .map((p) => jsonEncode(p.toJson()))
        .toList();
    _prefs.setStringList('enrolledPrograms', programsJson);
  }

  void enrollInProgram(WorkoutProgram program) {
    final userProgram = UserProgram(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      programId: program.id,
      programName: program.name,
      startDate: DateTime.now(),
      currentDay: 1,
      completedDaysList: [],
    );
    _enrolledPrograms.add(userProgram);
    _saveEnrolledPrograms();
    notifyListeners();
  }

  void updateProgramProgress(String userProgramId, int week, int day) {
    final index = _enrolledPrograms.indexWhere((p) => p.id == userProgramId);
    if (index != -1) {
      final program = _enrolledPrograms[index];
      final completedDays = List<String>.from(program.completedDaysList);
      completedDays.add('$week-$day');

      _enrolledPrograms[index] = program.copyWith(
        currentDay: (week - 1) * 7 + day + 1, // Calculate total day number
        completedDaysList: completedDays,
      );
      _saveEnrolledPrograms();
      notifyListeners();
    }
  }

  void unenrollFromProgram(String userProgramId) {
    _enrolledPrograms.removeWhere((p) => p.id == userProgramId);
    _saveEnrolledPrograms();
    notifyListeners();
  }
}
