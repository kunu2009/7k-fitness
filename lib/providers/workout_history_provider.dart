import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for tracking workout history with real data persistence
class WorkoutHistoryProvider with ChangeNotifier {
  static const String _keyWorkoutHistory = 'workout_history';
  static const String _keyPersonalRecords = 'personal_records';

  SharedPreferences? _prefs;

  // Workout history
  List<CompletedWorkout> _workoutHistory = [];

  // Personal records
  Map<String, PersonalRecord> _personalRecords = {};

  // Statistics
  WorkoutStatistics _stats = WorkoutStatistics.empty();

  // Getters
  List<CompletedWorkout> get workoutHistory =>
      List.unmodifiable(_workoutHistory);
  Map<String, PersonalRecord> get personalRecords =>
      Map.unmodifiable(_personalRecords);
  WorkoutStatistics get stats => _stats;

  List<CompletedWorkout> get recentWorkouts =>
      _workoutHistory.take(10).toList();

  int get totalWorkouts => _workoutHistory.length;
  int get workoutsThisWeek => _getWorkoutsInPeriod(7);
  int get workoutsThisMonth => _getWorkoutsInPeriod(30);

  /// Initialize the provider
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadHistory();
    await _loadPersonalRecords();
    _calculateStats();
  }

  Future<void> _loadHistory() async {
    if (_prefs == null) return;

    final historyJson = _prefs!.getString(_keyWorkoutHistory);
    if (historyJson != null) {
      try {
        final List decoded = jsonDecode(historyJson);
        _workoutHistory =
            decoded.map((e) => CompletedWorkout.fromJson(e)).toList()
              ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
      } catch (e) {
        debugPrint('Error loading workout history: $e');
      }
    }
  }

  Future<void> _loadPersonalRecords() async {
    if (_prefs == null) return;

    final recordsJson = _prefs!.getString(_keyPersonalRecords);
    if (recordsJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(recordsJson);
        _personalRecords = decoded.map(
          (key, value) => MapEntry(key, PersonalRecord.fromJson(value)),
        );
      } catch (e) {
        debugPrint('Error loading personal records: $e');
      }
    }
  }

  /// Log a completed workout
  Future<void> logWorkout(CompletedWorkout workout) async {
    _workoutHistory.insert(0, workout);

    // Check for new personal records
    for (final exercise in workout.exercises) {
      await _checkPersonalRecord(exercise);
    }

    _calculateStats();
    await _saveHistory();
    notifyListeners();
  }

  /// Delete a workout from history
  Future<void> deleteWorkout(String workoutId) async {
    _workoutHistory.removeWhere((w) => w.id == workoutId);
    _calculateStats();
    await _saveHistory();
    notifyListeners();
  }

  Future<void> _checkPersonalRecord(ExerciseLog exercise) async {
    final exerciseId = exercise.exerciseId;

    // Find best set
    double? bestWeight;
    int? bestReps;
    double? bestVolume;

    for (final set in exercise.sets) {
      if (set.weight != null &&
          (bestWeight == null || set.weight! > bestWeight)) {
        bestWeight = set.weight;
      }
      if (set.reps != null && (bestReps == null || set.reps! > bestReps)) {
        bestReps = set.reps;
      }
      if (set.weight != null && set.reps != null) {
        final volume = set.weight! * set.reps!;
        if (bestVolume == null || volume > bestVolume) {
          bestVolume = volume;
        }
      }
    }

    // Compare with existing record
    final existing = _personalRecords[exerciseId];
    bool updated = false;

    if (existing == null) {
      _personalRecords[exerciseId] = PersonalRecord(
        exerciseId: exerciseId,
        exerciseName: exercise.exerciseName,
        maxWeight: bestWeight,
        maxReps: bestReps,
        maxVolume: bestVolume,
        achievedAt: DateTime.now(),
      );
      updated = true;
    } else {
      if (bestWeight != null &&
          (existing.maxWeight == null || bestWeight > existing.maxWeight!)) {
        _personalRecords[exerciseId] = existing.copyWith(
          maxWeight: bestWeight,
          achievedAt: DateTime.now(),
        );
        updated = true;
      }
      if (bestReps != null &&
          (existing.maxReps == null || bestReps > existing.maxReps!)) {
        _personalRecords[exerciseId] = existing.copyWith(
          maxReps: bestReps,
          achievedAt: DateTime.now(),
        );
        updated = true;
      }
      if (bestVolume != null &&
          (existing.maxVolume == null || bestVolume > existing.maxVolume!)) {
        _personalRecords[exerciseId] = existing.copyWith(
          maxVolume: bestVolume,
          achievedAt: DateTime.now(),
        );
        updated = true;
      }
    }

    if (updated) {
      await _savePersonalRecords();
    }
  }

  void _calculateStats() {
    if (_workoutHistory.isEmpty) {
      _stats = WorkoutStatistics.empty();
      return;
    }

    int totalDuration = 0;
    int totalSets = 0;
    double totalVolume = 0;
    int totalCalories = 0;
    Map<String, int> muscleGroupCounts = {};
    Map<String, int> workoutTypeCounts = {};

    for (final workout in _workoutHistory) {
      totalDuration += workout.durationMinutes;
      totalCalories += workout.caloriesBurned;

      workoutTypeCounts[workout.type] =
          (workoutTypeCounts[workout.type] ?? 0) + 1;

      for (final exercise in workout.exercises) {
        totalSets += exercise.sets.length;

        // Count muscle groups
        for (final muscle in exercise.muscleGroups) {
          muscleGroupCounts[muscle] = (muscleGroupCounts[muscle] ?? 0) + 1;
        }

        // Calculate volume
        for (final set in exercise.sets) {
          if (set.weight != null && set.reps != null) {
            totalVolume += set.weight! * set.reps!;
          }
        }
      }
    }

    // Calculate streak
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final hasWorkout = _workoutHistory.any(
        (w) =>
            w.completedAt.year == date.year &&
            w.completedAt.month == date.month &&
            w.completedAt.day == date.day,
      );

      if (hasWorkout) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    // Find favorite muscle group
    String? favoriteMuscle;
    int maxCount = 0;
    muscleGroupCounts.forEach((muscle, count) {
      if (count > maxCount) {
        maxCount = count;
        favoriteMuscle = muscle;
      }
    });

    _stats = WorkoutStatistics(
      totalWorkouts: _workoutHistory.length,
      totalDurationMinutes: totalDuration,
      totalSets: totalSets,
      totalVolumeKg: totalVolume,
      totalCaloriesBurned: totalCalories,
      currentStreak: streak,
      longestStreak: streak, // Simplified - could track separately
      favoriteMuscleGroup: favoriteMuscle,
      workoutTypeCounts: workoutTypeCounts,
      muscleGroupCounts: muscleGroupCounts,
    );
  }

  int _getWorkoutsInPeriod(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _workoutHistory.where((w) => w.completedAt.isAfter(cutoff)).length;
  }

  /// Get workouts for a specific date
  List<CompletedWorkout> getWorkoutsForDate(DateTime date) {
    return _workoutHistory
        .where(
          (w) =>
              w.completedAt.year == date.year &&
              w.completedAt.month == date.month &&
              w.completedAt.day == date.day,
        )
        .toList();
  }

  /// Get weekly workout data
  List<DailyWorkoutData> getWeeklyData() {
    final List<DailyWorkoutData> weekData = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayWorkouts = getWorkoutsForDate(date);

      weekData.add(
        DailyWorkoutData(
          date: date,
          workoutCount: dayWorkouts.length,
          totalDuration: dayWorkouts.fold(
            0,
            (sum, w) => sum + w.durationMinutes,
          ),
          totalCalories: dayWorkouts.fold(
            0,
            (sum, w) => sum + w.caloriesBurned,
          ),
        ),
      );
    }

    return weekData;
  }

  /// Get personal record for exercise
  PersonalRecord? getPersonalRecord(String exerciseId) {
    return _personalRecords[exerciseId];
  }

  /// Get insights
  List<String> getInsights() {
    final insights = <String>[];

    if (_stats.currentStreak >= 7) {
      insights.add(
        '🔥 ${_stats.currentStreak} day workout streak! Keep it up!',
      );
    } else if (_stats.currentStreak >= 3) {
      insights.add(
        '💪 ${_stats.currentStreak} days in a row! Building momentum!',
      );
    }

    if (workoutsThisWeek == 0) {
      insights.add('🏋️ No workouts this week yet. Time to get moving!');
    } else if (workoutsThisWeek >= 5) {
      insights.add(
        '🎉 $workoutsThisWeek workouts this week! Excellent dedication!',
      );
    }

    if (_stats.favoriteMuscleGroup != null) {
      insights.add(
        '💪 Your most trained muscle: ${_stats.favoriteMuscleGroup}',
      );
    }

    if (_stats.totalVolumeKg > 10000) {
      insights.add(
        '🏆 Total volume lifted: ${(_stats.totalVolumeKg / 1000).toStringAsFixed(1)} tons!',
      );
    }

    return insights;
  }

  Future<void> _saveHistory() async {
    if (_prefs == null) return;
    final json = jsonEncode(_workoutHistory.map((w) => w.toJson()).toList());
    await _prefs!.setString(_keyWorkoutHistory, json);
  }

  Future<void> _savePersonalRecords() async {
    if (_prefs == null) return;
    final json = jsonEncode(
      _personalRecords.map((key, value) => MapEntry(key, value.toJson())),
    );
    await _prefs!.setString(_keyPersonalRecords, json);
  }
}

/// A completed workout
class CompletedWorkout {
  final String id;
  final String name;
  final String type;
  final DateTime completedAt;
  final int durationMinutes;
  final int caloriesBurned;
  final List<ExerciseLog> exercises;
  final String? notes;
  final int rating; // 1-5 stars

  CompletedWorkout({
    required this.id,
    required this.name,
    required this.type,
    required this.completedAt,
    required this.durationMinutes,
    this.caloriesBurned = 0,
    required this.exercises,
    this.notes,
    this.rating = 0,
  });

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets.length);

  double get totalVolume {
    double volume = 0;
    for (final exercise in exercises) {
      for (final set in exercise.sets) {
        if (set.weight != null && set.reps != null) {
          volume += set.weight! * set.reps!;
        }
      }
    }
    return volume;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'completedAt': completedAt.toIso8601String(),
    'durationMinutes': durationMinutes,
    'caloriesBurned': caloriesBurned,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'notes': notes,
    'rating': rating,
  };

  factory CompletedWorkout.fromJson(Map<String, dynamic> json) =>
      CompletedWorkout(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String? ?? 'General',
        completedAt: DateTime.parse(json['completedAt'] as String),
        durationMinutes: json['durationMinutes'] as int,
        caloriesBurned: json['caloriesBurned'] as int? ?? 0,
        exercises: (json['exercises'] as List)
            .map((e) => ExerciseLog.fromJson(e))
            .toList(),
        notes: json['notes'] as String?,
        rating: json['rating'] as int? ?? 0,
      );
}

/// Log of a single exercise in a workout
class ExerciseLog {
  final String exerciseId;
  final String exerciseName;
  final List<String> muscleGroups;
  final List<SetLog> sets;

  ExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroups,
    required this.sets,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'muscleGroups': muscleGroups,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory ExerciseLog.fromJson(Map<String, dynamic> json) => ExerciseLog(
    exerciseId: json['exerciseId'] as String,
    exerciseName: json['exerciseName'] as String,
    muscleGroups: (json['muscleGroups'] as List?)?.cast<String>() ?? [],
    sets: (json['sets'] as List).map((s) => SetLog.fromJson(s)).toList(),
  );
}

/// Log of a single set
class SetLog {
  final int setNumber;
  final double? weight;
  final int? reps;
  final int? durationSeconds;
  final double? distance;
  final bool isWarmup;
  final bool isDropSet;

  SetLog({
    required this.setNumber,
    this.weight,
    this.reps,
    this.durationSeconds,
    this.distance,
    this.isWarmup = false,
    this.isDropSet = false,
  });

  Map<String, dynamic> toJson() => {
    'setNumber': setNumber,
    'weight': weight,
    'reps': reps,
    'durationSeconds': durationSeconds,
    'distance': distance,
    'isWarmup': isWarmup,
    'isDropSet': isDropSet,
  };

  factory SetLog.fromJson(Map<String, dynamic> json) => SetLog(
    setNumber: json['setNumber'] as int,
    weight: (json['weight'] as num?)?.toDouble(),
    reps: json['reps'] as int?,
    durationSeconds: json['durationSeconds'] as int?,
    distance: (json['distance'] as num?)?.toDouble(),
    isWarmup: json['isWarmup'] as bool? ?? false,
    isDropSet: json['isDropSet'] as bool? ?? false,
  );
}

/// Personal record for an exercise
class PersonalRecord {
  final String exerciseId;
  final String exerciseName;
  final double? maxWeight;
  final int? maxReps;
  final double? maxVolume;
  final DateTime achievedAt;

  PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    this.maxWeight,
    this.maxReps,
    this.maxVolume,
    required this.achievedAt,
  });

  PersonalRecord copyWith({
    double? maxWeight,
    int? maxReps,
    double? maxVolume,
    DateTime? achievedAt,
  }) => PersonalRecord(
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    maxWeight: maxWeight ?? this.maxWeight,
    maxReps: maxReps ?? this.maxReps,
    maxVolume: maxVolume ?? this.maxVolume,
    achievedAt: achievedAt ?? this.achievedAt,
  );

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'maxWeight': maxWeight,
    'maxReps': maxReps,
    'maxVolume': maxVolume,
    'achievedAt': achievedAt.toIso8601String(),
  };

  factory PersonalRecord.fromJson(Map<String, dynamic> json) => PersonalRecord(
    exerciseId: json['exerciseId'] as String,
    exerciseName: json['exerciseName'] as String,
    maxWeight: (json['maxWeight'] as num?)?.toDouble(),
    maxReps: json['maxReps'] as int?,
    maxVolume: (json['maxVolume'] as num?)?.toDouble(),
    achievedAt: DateTime.parse(json['achievedAt'] as String),
  );
}

/// Daily workout data for charts
class DailyWorkoutData {
  final DateTime date;
  final int workoutCount;
  final int totalDuration;
  final int totalCalories;

  DailyWorkoutData({
    required this.date,
    required this.workoutCount,
    required this.totalDuration,
    required this.totalCalories,
  });
}

/// Workout statistics
class WorkoutStatistics {
  final int totalWorkouts;
  final int totalDurationMinutes;
  final int totalSets;
  final double totalVolumeKg;
  final int totalCaloriesBurned;
  final int currentStreak;
  final int longestStreak;
  final String? favoriteMuscleGroup;
  final Map<String, int> workoutTypeCounts;
  final Map<String, int> muscleGroupCounts;

  WorkoutStatistics({
    required this.totalWorkouts,
    required this.totalDurationMinutes,
    required this.totalSets,
    required this.totalVolumeKg,
    required this.totalCaloriesBurned,
    required this.currentStreak,
    required this.longestStreak,
    this.favoriteMuscleGroup,
    required this.workoutTypeCounts,
    required this.muscleGroupCounts,
  });

  factory WorkoutStatistics.empty() => WorkoutStatistics(
    totalWorkouts: 0,
    totalDurationMinutes: 0,
    totalSets: 0,
    totalVolumeKg: 0,
    totalCaloriesBurned: 0,
    currentStreak: 0,
    longestStreak: 0,
    workoutTypeCounts: {},
    muscleGroupCounts: {},
  );

  int get totalHours => totalDurationMinutes ~/ 60;
  double get averageWorkoutDuration =>
      totalWorkouts > 0 ? totalDurationMinutes / totalWorkouts : 0;
}
