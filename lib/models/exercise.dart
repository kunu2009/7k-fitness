/// Muscle groups that can be targeted by exercises
enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  core, // General core/abs
  abs,
  obliques,
  hipFlexors,
  quads,
  hamstrings,
  glutes,
  calves,
  traps,
  fullBody,
  cardio,
}

/// Equipment required for exercises
enum Equipment {
  none,
  dumbbells,
  barbell,
  kettlebell,
  resistanceBands,
  pullUpBar,
  parallelBars,
  bench,
  cable,
  cableMachine,
  machine,
  medicineBall,
  stabilityBall,
  foamRoller,
  treadmill,
  bike,
  rowingMachine,
  box,
  other,
}

/// Difficulty levels for exercises
enum Difficulty {
  beginner,
  intermediate,
  advanced,
  expert, // Alias for advanced+
}

/// Exercise category types
enum ExerciseCategory {
  strength,
  cardio,
  flexibility,
  balance,
  hiit,
  yoga,
  pilates,
  plyometrics, // Jump training
  calisthenics, // Bodyweight exercises
}

/// Individual exercise definition
class ExerciseDefinition {
  final String id;
  final String name;
  final String description;
  final List<MuscleGroup> primaryMuscles;
  final List<MuscleGroup> secondaryMuscles;
  final List<Equipment> equipment;
  final Difficulty difficulty;
  final ExerciseCategory category;
  final List<String> instructions;
  final String? gifUrl;
  final String? videoUrl;
  final double caloriesPerMinute;
  final bool isCompound; // Works multiple muscle groups
  final String tips;

  const ExerciseDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryMuscles,
    this.secondaryMuscles = const [],
    required this.equipment,
    required this.difficulty,
    required this.category,
    required this.instructions,
    this.gifUrl,
    this.videoUrl,
    this.caloriesPerMinute = 5.0,
    this.isCompound = false,
    this.tips = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'primaryMuscles': primaryMuscles.map((m) => m.name).toList(),
      'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
      'equipment': equipment.map((e) => e.name).toList(),
      'difficulty': difficulty.name,
      'category': category.name,
      'instructions': instructions,
      'gifUrl': gifUrl,
      'videoUrl': videoUrl,
      'caloriesPerMinute': caloriesPerMinute,
      'isCompound': isCompound,
      'tips': tips,
    };
  }

  factory ExerciseDefinition.fromJson(Map<String, dynamic> json) {
    return ExerciseDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      primaryMuscles: (json['primaryMuscles'] as List)
          .map((m) => MuscleGroup.values.firstWhere((e) => e.name == m))
          .toList(),
      secondaryMuscles:
          (json['secondaryMuscles'] as List?)
              ?.map((m) => MuscleGroup.values.firstWhere((e) => e.name == m))
              .toList() ??
          [],
      equipment: (json['equipment'] as List)
          .map((e) => Equipment.values.firstWhere((eq) => eq.name == e))
          .toList(),
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
      ),
      category: ExerciseCategory.values.firstWhere(
        (c) => c.name == json['category'],
      ),
      instructions: List<String>.from(json['instructions']),
      gifUrl: json['gifUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      caloriesPerMinute: (json['caloriesPerMinute'] as num?)?.toDouble() ?? 5.0,
      isCompound: json['isCompound'] as bool? ?? false,
      tips: json['tips'] as String? ?? '',
    );
  }

  String get difficultyText {
    switch (difficulty) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.advanced:
        return 'Advanced';
      case Difficulty.expert:
        return 'Expert';
    }
  }

  String get equipmentText {
    if (equipment.isEmpty || equipment.contains(Equipment.none)) {
      return 'No Equipment';
    }
    return equipment
        .map((e) => e.name.replaceAll(RegExp(r'(?=[A-Z])'), ' ').trim())
        .join(', ');
  }

  String get muscleText {
    return primaryMuscles
        .map((m) => m.name.replaceAll(RegExp(r'(?=[A-Z])'), ' ').trim())
        .join(', ');
  }
}

/// A single set performed during a workout
class ExerciseSet {
  final int setNumber;
  final int? reps;
  final double? weight; // in kg
  final int? durationSeconds;
  final bool isWarmup;
  final bool isDropSet;
  final bool isFailure;
  final int? restAfterSeconds;
  final DateTime? completedAt;

  ExerciseSet({
    required this.setNumber,
    this.reps,
    this.weight,
    this.durationSeconds,
    this.isWarmup = false,
    this.isDropSet = false,
    this.isFailure = false,
    this.restAfterSeconds,
    this.completedAt,
  });

  // Aliases for UI compatibility
  bool get isCompleted => completedAt != null;
  Duration? get duration =>
      durationSeconds != null ? Duration(seconds: durationSeconds!) : null;

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'durationSeconds': durationSeconds,
      'isWarmup': isWarmup,
      'isDropSet': isDropSet,
      'isFailure': isFailure,
      'restAfterSeconds': restAfterSeconds,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      setNumber: json['setNumber'] as int,
      reps: json['reps'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      durationSeconds: json['durationSeconds'] as int?,
      isWarmup: json['isWarmup'] as bool? ?? false,
      isDropSet: json['isDropSet'] as bool? ?? false,
      isFailure: json['isFailure'] as bool? ?? false,
      restAfterSeconds: json['restAfterSeconds'] as int?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  double get volume => (reps ?? 0) * (weight ?? 0);

  ExerciseSet copyWith({
    int? setNumber,
    int? reps,
    double? weight,
    int? durationSeconds,
    bool? isWarmup,
    bool? isDropSet,
    bool? isFailure,
    int? restAfterSeconds,
    DateTime? completedAt,
  }) {
    return ExerciseSet(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isWarmup: isWarmup ?? this.isWarmup,
      isDropSet: isDropSet ?? this.isDropSet,
      isFailure: isFailure ?? this.isFailure,
      restAfterSeconds: restAfterSeconds ?? this.restAfterSeconds,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// An exercise performed in a workout with its sets
class WorkoutExercise {
  final String id;
  final ExerciseDefinition exercise;
  final List<ExerciseSet> sets;
  final int targetSets;
  final int targetReps;
  final double? targetWeight;
  final int restSeconds;
  final String? notes;
  final int orderIndex;

  WorkoutExercise({
    required this.id,
    required this.exercise,
    this.sets = const [],
    this.targetSets = 3,
    this.targetReps = 10,
    this.targetWeight,
    this.restSeconds = 60,
    this.notes,
    this.orderIndex = 0,
  });

  // Aliases for UI compatibility
  String get exerciseName => exercise.name;
  String get exerciseId => exercise.id;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise': exercise.toJson(),
      'sets': sets.map((s) => s.toJson()).toList(),
      'targetSets': targetSets,
      'targetReps': targetReps,
      'targetWeight': targetWeight,
      'restSeconds': restSeconds,
      'notes': notes,
      'orderIndex': orderIndex,
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'] as String,
      exercise: ExerciseDefinition.fromJson(json['exercise']),
      sets:
          (json['sets'] as List?)
              ?.map((s) => ExerciseSet.fromJson(s))
              .toList() ??
          [],
      targetSets: json['targetSets'] as int? ?? 3,
      targetReps: json['targetReps'] as int? ?? 10,
      targetWeight: (json['targetWeight'] as num?)?.toDouble(),
      restSeconds: json['restSeconds'] as int? ?? 60,
      notes: json['notes'] as String?,
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }

  int get completedSets => sets.where((s) => s.completedAt != null).length;

  double get totalVolume => sets.fold(0, (sum, set) => sum + set.volume);

  int get totalReps => sets.fold(0, (sum, set) => sum + (set.reps ?? 0));

  WorkoutExercise copyWith({
    String? id,
    ExerciseDefinition? exercise,
    List<ExerciseSet>? sets,
    int? targetSets,
    int? targetReps,
    double? targetWeight,
    int? restSeconds,
    String? notes,
    int? orderIndex,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: targetWeight ?? this.targetWeight,
      restSeconds: restSeconds ?? this.restSeconds,
      notes: notes ?? this.notes,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}

/// A complete workout session
class WorkoutSession {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final List<WorkoutExercise> exercises;
  final String? notes;
  final double? totalCalories;
  final bool isCompleted;
  final String? programId; // If part of a program
  final int? rating; // 1-5 star rating

  WorkoutSession({
    required this.id,
    required this.name,
    required this.startTime,
    this.endTime,
    this.exercises = const [],
    this.notes,
    this.totalCalories,
    this.isCompleted = false,
    this.programId,
    this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
      'totalCalories': totalCalories,
      'isCompleted': isCompleted,
      'programId': programId,
      'rating': rating,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      name: json['name'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      exercises:
          (json['exercises'] as List?)
              ?.map((e) => WorkoutExercise.fromJson(e))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      totalCalories: (json['totalCalories'] as num?)?.toDouble(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      programId: json['programId'] as String?,
      rating: json['rating'] as int?,
    );
  }

  Duration get duration {
    if (endTime == null) return Duration.zero;
    return endTime!.difference(startTime);
  }

  String get durationText {
    final d = duration;
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m';
  }

  double get totalVolume {
    return exercises.fold(0, (sum, ex) => sum + ex.totalVolume);
  }

  int get totalSets {
    return exercises.fold(0, (sum, ex) => sum + ex.completedSets);
  }

  WorkoutSession copyWith({
    String? id,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    List<WorkoutExercise>? exercises,
    String? notes,
    double? totalCalories,
    bool? isCompleted,
    String? programId,
    int? rating,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      totalCalories: totalCalories ?? this.totalCalories,
      isCompleted: isCompleted ?? this.isCompleted,
      programId: programId ?? this.programId,
      rating: rating ?? this.rating,
    );
  }
}
