import '../models/exercise.dart';
import '../data/exercise_database.dart';

/// Muscle recovery time in hours
class MuscleRecoveryTime {
  // Large muscle groups need more recovery
  static const Map<MuscleGroup, int> recoveryHours = {
    MuscleGroup.chest: 72,
    MuscleGroup.back: 72,
    MuscleGroup.quads: 72,
    MuscleGroup.hamstrings: 72,
    MuscleGroup.glutes: 72,
    MuscleGroup.shoulders: 48,
    MuscleGroup.biceps: 48,
    MuscleGroup.triceps: 48,
    MuscleGroup.forearms: 48,
    MuscleGroup.abs: 24,
    MuscleGroup.obliques: 24,
    MuscleGroup.calves: 24,
    MuscleGroup.fullBody: 72,
    MuscleGroup.cardio: 24,
  };

  static int getRecoveryHours(MuscleGroup muscle) {
    return recoveryHours[muscle] ?? 48;
  }
}

/// Workout suggestion types
enum SuggestionType {
  push, // Chest, Shoulders, Triceps
  pull, // Back, Biceps
  legs, // Quads, Hamstrings, Glutes, Calves
  upper, // All upper body
  lower, // All lower body
  fullBody, // Full body workout
  cardio, // Cardio focused
  rest, // Rest day recommended
}

/// A workout suggestion
class WorkoutSuggestion {
  final String id;
  final String title;
  final String description;
  final SuggestionType type;
  final List<MuscleGroup> targetMuscles;
  final int estimatedMinutes;
  final int estimatedCalories;
  final List<ExerciseDefinition> suggestedExercises;
  final String reason;
  final double confidenceScore; // 0-1, how good this suggestion is

  WorkoutSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetMuscles,
    required this.estimatedMinutes,
    required this.estimatedCalories,
    required this.suggestedExercises,
    required this.reason,
    this.confidenceScore = 0.8,
  });
}

/// Service for generating rule-based workout suggestions
class WorkoutSuggestionService {
  /// Get workout suggestions based on recent workout history
  static WorkoutSuggestion getSuggestion({
    required List<WorkoutSession> recentWorkouts,
    List<Equipment> availableEquipment = const [],
    int availableMinutes = 45,
    Difficulty preferredDifficulty = Difficulty.intermediate,
  }) {
    // Get muscles worked in the last 72 hours
    final now = DateTime.now();
    final recentMuscles = _getRecentlyWorkedMuscles(recentWorkouts, now);

    // Determine what type of workout to suggest
    final suggestionType = _determineSuggestionType(
      recentMuscles,
      recentWorkouts,
    );

    // Get exercises for the suggested workout type
    final exercises = _getExercisesForType(
      suggestionType,
      availableEquipment,
      preferredDifficulty,
    );

    // Build the suggestion
    return _buildSuggestion(
      type: suggestionType,
      exercises: exercises,
      availableMinutes: availableMinutes,
      recentMuscles: recentMuscles,
    );
  }

  /// Get muscles worked in the last N hours
  static Map<MuscleGroup, DateTime> _getRecentlyWorkedMuscles(
    List<WorkoutSession> workouts,
    DateTime now,
  ) {
    final recentMuscles = <MuscleGroup, DateTime>{};

    for (final workout in workouts) {
      if (!workout.isCompleted) continue;

      final workoutTime = workout.endTime ?? workout.startTime;

      for (final exercise in workout.exercises) {
        // Get muscles from the exercise
        final muscles = _getMusclesFromExercise(exercise);

        for (final muscle in muscles) {
          // Only track the most recent time each muscle was worked
          if (!recentMuscles.containsKey(muscle) ||
              workoutTime.isAfter(recentMuscles[muscle]!)) {
            recentMuscles[muscle] = workoutTime;
          }
        }
      }
    }

    return recentMuscles;
  }

  /// Get muscles targeted by an exercise
  static List<MuscleGroup> _getMusclesFromExercise(WorkoutExercise exercise) {
    // Try to find the exercise in our database
    final exerciseDef = ExerciseDatabase.getById(exercise.exerciseId);
    if (exerciseDef != null) {
      return [...exerciseDef.primaryMuscles, ...exerciseDef.secondaryMuscles];
    }

    // Fallback: try to infer from the exercise name
    return _inferMusclesFromName(exercise.exerciseName);
  }

  /// Infer muscle groups from exercise name
  static List<MuscleGroup> _inferMusclesFromName(String name) {
    final lowerName = name.toLowerCase();
    final muscles = <MuscleGroup>[];

    // Chest
    if (lowerName.contains('bench') ||
        lowerName.contains('chest') ||
        lowerName.contains('push') && lowerName.contains('up') ||
        lowerName.contains('fly') ||
        lowerName.contains('flye')) {
      muscles.add(MuscleGroup.chest);
    }

    // Back
    if (lowerName.contains('row') ||
        lowerName.contains('pull') ||
        lowerName.contains('lat') ||
        lowerName.contains('back') ||
        lowerName.contains('deadlift')) {
      muscles.add(MuscleGroup.back);
    }

    // Shoulders
    if (lowerName.contains('shoulder') ||
        lowerName.contains('press') && !lowerName.contains('bench') ||
        lowerName.contains('lateral') ||
        lowerName.contains('delt')) {
      muscles.add(MuscleGroup.shoulders);
    }

    // Biceps
    if (lowerName.contains('bicep') || lowerName.contains('curl')) {
      muscles.add(MuscleGroup.biceps);
    }

    // Triceps
    if (lowerName.contains('tricep') ||
        lowerName.contains('dip') ||
        lowerName.contains('extension') && !lowerName.contains('leg')) {
      muscles.add(MuscleGroup.triceps);
    }

    // Legs
    if (lowerName.contains('squat') ||
        lowerName.contains('leg') ||
        lowerName.contains('lunge')) {
      muscles.add(MuscleGroup.quads);
      muscles.add(MuscleGroup.glutes);
    }

    if (lowerName.contains('hamstring') || lowerName.contains('leg curl')) {
      muscles.add(MuscleGroup.hamstrings);
    }

    if (lowerName.contains('calf') || lowerName.contains('calves')) {
      muscles.add(MuscleGroup.calves);
    }

    // Abs
    if (lowerName.contains('ab') ||
        lowerName.contains('crunch') ||
        lowerName.contains('plank') ||
        lowerName.contains('core')) {
      muscles.add(MuscleGroup.abs);
    }

    // Cardio
    if (lowerName.contains('run') ||
        lowerName.contains('cardio') ||
        lowerName.contains('bike') ||
        lowerName.contains('cycle') ||
        lowerName.contains('walk') ||
        lowerName.contains('jog')) {
      muscles.add(MuscleGroup.cardio);
    }

    if (muscles.isEmpty) {
      muscles.add(MuscleGroup.fullBody);
    }

    return muscles;
  }

  /// Determine what type of workout to suggest based on recovery
  static SuggestionType _determineSuggestionType(
    Map<MuscleGroup, DateTime> recentMuscles,
    List<WorkoutSession> recentWorkouts,
  ) {
    final now = DateTime.now();

    // Check if we've worked out today
    final hasWorkedOutToday = recentWorkouts.any((w) {
      if (!w.isCompleted) return false;
      final workoutDate = w.endTime ?? w.startTime;
      return workoutDate.year == now.year &&
          workoutDate.month == now.month &&
          workoutDate.day == now.day;
    });

    if (hasWorkedOutToday) {
      return SuggestionType.rest;
    }

    // Check recovery for each muscle group
    final recoveredMuscles = <MuscleGroup>{};

    for (final muscle in MuscleGroup.values) {
      if (!recentMuscles.containsKey(muscle)) {
        recoveredMuscles.add(muscle);
        continue;
      }

      final lastWorked = recentMuscles[muscle]!;
      final hoursSince = now.difference(lastWorked).inHours;
      final recoveryNeeded = MuscleRecoveryTime.getRecoveryHours(muscle);

      if (hoursSince >= recoveryNeeded) {
        recoveredMuscles.add(muscle);
      }
    }

    // Determine split based on what's recovered
    final pushMuscles = {
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps,
    };
    final pullMuscles = {MuscleGroup.back, MuscleGroup.biceps};
    final legMuscles = {
      MuscleGroup.quads,
      MuscleGroup.hamstrings,
      MuscleGroup.glutes,
      MuscleGroup.calves,
    };

    final pushRecovered =
        pushMuscles.intersection(recoveredMuscles).length >= 2;
    final pullRecovered =
        pullMuscles.intersection(recoveredMuscles).isNotEmpty;
    final legsRecovered = legMuscles.intersection(recoveredMuscles).length >= 2;

    // Find the last workout type to avoid repeating
    final lastWorkoutType = _getLastWorkoutType(recentWorkouts);

    // Suggest based on what's recovered and what we haven't done recently
    if (legsRecovered && lastWorkoutType != SuggestionType.legs) {
      return SuggestionType.legs;
    }
    if (pushRecovered && lastWorkoutType != SuggestionType.push) {
      return SuggestionType.push;
    }
    if (pullRecovered && lastWorkoutType != SuggestionType.pull) {
      return SuggestionType.pull;
    }

    // If everything is recovered or nothing specific, suggest full body
    if (recoveredMuscles.length >= MuscleGroup.values.length ~/ 2) {
      return SuggestionType.fullBody;
    }

    // If most muscles are still recovering, suggest cardio or rest
    if (recoveredMuscles.contains(MuscleGroup.cardio)) {
      return SuggestionType.cardio;
    }

    return SuggestionType.rest;
  }

  /// Get the type of the last workout
  static SuggestionType? _getLastWorkoutType(List<WorkoutSession> workouts) {
    final completed = workouts.where((w) => w.isCompleted).toList();
    if (completed.isEmpty) return null;

    // Sort by end time descending
    completed.sort((a, b) {
      final aTime = a.endTime ?? a.startTime;
      final bTime = b.endTime ?? b.startTime;
      return bTime.compareTo(aTime);
    });

    final lastWorkout = completed.first;
    final muscles = <MuscleGroup>{};

    for (final exercise in lastWorkout.exercises) {
      muscles.addAll(_getMusclesFromExercise(exercise));
    }

    // Determine type based on muscles worked
    final pushMuscles = {
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.triceps,
    };
    final pullMuscles = {MuscleGroup.back, MuscleGroup.biceps};
    final legMuscles = {
      MuscleGroup.quads,
      MuscleGroup.hamstrings,
      MuscleGroup.glutes,
      MuscleGroup.calves,
    };

    if (muscles.intersection(legMuscles).isNotEmpty &&
        muscles.intersection(pushMuscles).isEmpty &&
        muscles.intersection(pullMuscles).isEmpty) {
      return SuggestionType.legs;
    }
    if (muscles.intersection(pushMuscles).isNotEmpty &&
        muscles.intersection(pullMuscles).isEmpty) {
      return SuggestionType.push;
    }
    if (muscles.intersection(pullMuscles).isNotEmpty &&
        muscles.intersection(pushMuscles).isEmpty) {
      return SuggestionType.pull;
    }

    return SuggestionType.fullBody;
  }

  /// Get exercises for a specific workout type
  static List<ExerciseDefinition> _getExercisesForType(
    SuggestionType type,
    List<Equipment> availableEquipment,
    Difficulty difficulty,
  ) {
    List<MuscleGroup> targetMuscles;

    switch (type) {
      case SuggestionType.push:
        targetMuscles = [
          MuscleGroup.chest,
          MuscleGroup.shoulders,
          MuscleGroup.triceps,
        ];
        break;
      case SuggestionType.pull:
        targetMuscles = [MuscleGroup.back, MuscleGroup.biceps];
        break;
      case SuggestionType.legs:
        targetMuscles = [
          MuscleGroup.quads,
          MuscleGroup.hamstrings,
          MuscleGroup.glutes,
          MuscleGroup.calves,
        ];
        break;
      case SuggestionType.upper:
        targetMuscles = [
          MuscleGroup.chest,
          MuscleGroup.back,
          MuscleGroup.shoulders,
          MuscleGroup.biceps,
          MuscleGroup.triceps,
        ];
        break;
      case SuggestionType.lower:
        targetMuscles = [
          MuscleGroup.quads,
          MuscleGroup.hamstrings,
          MuscleGroup.glutes,
          MuscleGroup.calves,
        ];
        break;
      case SuggestionType.cardio:
        targetMuscles = [MuscleGroup.cardio];
        break;
      case SuggestionType.fullBody:
      case SuggestionType.rest:
        targetMuscles = [MuscleGroup.fullBody];
        break;
    }

    // Get exercises from database that match
    final exercises = <ExerciseDefinition>[];
    final allExercises = ExerciseDatabase.allExercises;

    for (final muscle in targetMuscles) {
      final muscleExercises = allExercises
          .where((e) {
            // Check if exercise targets this muscle
            if (!e.primaryMuscles.contains(muscle)) return false;

            // Check equipment availability
            if (availableEquipment.isNotEmpty) {
              if (!e.equipment.any(
                (eq) => eq == Equipment.none || availableEquipment.contains(eq),
              )) {
                return false;
              }
            }

            // Check difficulty
            if (difficulty == Difficulty.beginner &&
                e.difficulty != Difficulty.beginner) {
              return false;
            }

            return true;
          })
          .take(3);

      exercises.addAll(muscleExercises);
    }

    // Limit to reasonable number
    return exercises.take(6).toList();
  }

  /// Build the final suggestion
  static WorkoutSuggestion _buildSuggestion({
    required SuggestionType type,
    required List<ExerciseDefinition> exercises,
    required int availableMinutes,
    required Map<MuscleGroup, DateTime> recentMuscles,
  }) {
    String title;
    String description;
    String reason;
    List<MuscleGroup> targetMuscles;

    switch (type) {
      case SuggestionType.push:
        title = 'Push Day';
        description = 'Chest, Shoulders & Triceps';
        targetMuscles = [
          MuscleGroup.chest,
          MuscleGroup.shoulders,
          MuscleGroup.triceps,
        ];
        reason = 'Your pushing muscles are fully recovered and ready to train!';
        break;
      case SuggestionType.pull:
        title = 'Pull Day';
        description = 'Back & Biceps';
        targetMuscles = [MuscleGroup.back, MuscleGroup.biceps];
        reason = 'Your pulling muscles are ready for action!';
        break;
      case SuggestionType.legs:
        title = 'Leg Day';
        description = 'Quads, Hamstrings & Glutes';
        targetMuscles = [
          MuscleGroup.quads,
          MuscleGroup.hamstrings,
          MuscleGroup.glutes,
          MuscleGroup.calves,
        ];
        reason = 'Time to build those legs! They\'re fully recovered.';
        break;
      case SuggestionType.upper:
        title = 'Upper Body';
        description = 'Chest, Back, Shoulders & Arms';
        targetMuscles = [
          MuscleGroup.chest,
          MuscleGroup.back,
          MuscleGroup.shoulders,
        ];
        reason = 'Hit all your upper body muscles today!';
        break;
      case SuggestionType.lower:
        title = 'Lower Body';
        description = 'Complete Leg Workout';
        targetMuscles = [
          MuscleGroup.quads,
          MuscleGroup.hamstrings,
          MuscleGroup.glutes,
        ];
        reason = 'Focus on lower body strength today!';
        break;
      case SuggestionType.fullBody:
        title = 'Full Body';
        description = 'Hit Every Major Muscle';
        targetMuscles = [MuscleGroup.fullBody];
        reason = 'A complete full body session for overall fitness!';
        break;
      case SuggestionType.cardio:
        title = 'Active Recovery';
        description = 'Light Cardio & Movement';
        targetMuscles = [MuscleGroup.cardio];
        reason = 'Most muscles are still recovering. Light cardio will help!';
        break;
      case SuggestionType.rest:
        title = 'Rest Day';
        description = 'Recovery & Stretching';
        targetMuscles = [];
        reason = 'You\'ve already worked out today. Rest and recover!';
        break;
    }

    // Calculate estimated calories
    final estimatedCalories = (availableMinutes * 8)
        .round(); // ~8 cal/min average

    return WorkoutSuggestion(
      id: '${type.name}_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      type: type,
      targetMuscles: targetMuscles,
      estimatedMinutes: availableMinutes,
      estimatedCalories: estimatedCalories,
      suggestedExercises: exercises,
      reason: reason,
      confidenceScore: type == SuggestionType.rest ? 0.5 : 0.85,
    );
  }

  /// Get suggested exercises for a quick workout
  static List<ExerciseDefinition> getQuickWorkoutExercises({
    int count = 4,
    List<Equipment> availableEquipment = const [],
  }) {
    final allExercises = ExerciseDatabase.allExercises;

    // Get compound exercises for efficiency
    final compounds = allExercises.where((e) => e.isCompound).toList();

    if (compounds.isEmpty) {
      return allExercises.take(count).toList();
    }

    // Filter by available equipment
    final available = compounds.where((e) {
      if (availableEquipment.isEmpty) return true;
      return e.equipment.any(
        (eq) => eq == Equipment.none || availableEquipment.contains(eq),
      );
    }).toList();

    if (available.isEmpty) {
      return compounds.take(count).toList();
    }

    // Shuffle for variety and take the requested count
    available.shuffle();
    return available.take(count).toList();
  }
}
