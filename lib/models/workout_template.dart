/// Workout templates model

library;

/// Workout template model

class WorkoutTemplate {
  final String id;
  final String name;
  final String description;
  final WorkoutCategory category;
  final DifficultyLevel difficulty;
  final Duration estimatedDuration;
  final List<TemplateExercise> exercises;
  final int estimatedCalories;
  final List<String> targetMuscles;
  final List<String> equipment;
  final bool isCustom;
  final String? createdBy;
  final DateTime? createdAt;
  final int timesCompleted;

  const WorkoutTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedDuration,
    required this.exercises,
    this.estimatedCalories = 0,
    this.targetMuscles = const [],
    this.equipment = const [],
    this.isCustom = false,
    this.createdBy,
    this.createdAt,
    this.timesCompleted = 0,
  });

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets);
  int get exerciseCount => exercises.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category.name,
    'difficulty': difficulty.name,
    'estimatedDurationMinutes': estimatedDuration.inMinutes,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'estimatedCalories': estimatedCalories,
    'targetMuscles': targetMuscles,
    'equipment': equipment,
    'isCustom': isCustom,
    'createdBy': createdBy,
    'createdAt': createdAt?.toIso8601String(),
    'timesCompleted': timesCompleted,
  };

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) =>
      WorkoutTemplate(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        category: WorkoutCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => WorkoutCategory.strength,
        ),
        difficulty: DifficultyLevel.values.firstWhere(
          (e) => e.name == json['difficulty'],
          orElse: () => DifficultyLevel.intermediate,
        ),
        estimatedDuration: Duration(
          minutes: json['estimatedDurationMinutes'] ?? 30,
        ),
        exercises: (json['exercises'] as List)
            .map((e) => TemplateExercise.fromJson(e))
            .toList(),
        estimatedCalories: json['estimatedCalories'] ?? 0,
        targetMuscles: List<String>.from(json['targetMuscles'] ?? []),
        equipment: List<String>.from(json['equipment'] ?? []),
        isCustom: json['isCustom'] ?? false,
        createdBy: json['createdBy'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        timesCompleted: json['timesCompleted'] ?? 0,
      );

  WorkoutTemplate copyWith({
    String? id,
    String? name,
    String? description,
    WorkoutCategory? category,
    DifficultyLevel? difficulty,
    Duration? estimatedDuration,
    List<TemplateExercise>? exercises,
    int? estimatedCalories,
    List<String>? targetMuscles,
    List<String>? equipment,
    bool? isCustom,
    String? createdBy,
    DateTime? createdAt,
    int? timesCompleted,
  }) {
    return WorkoutTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      exercises: exercises ?? this.exercises,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      equipment: equipment ?? this.equipment,
      isCustom: isCustom ?? this.isCustom,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      timesCompleted: timesCompleted ?? this.timesCompleted,
    );
  }
}

class TemplateExercise {
  final String exerciseId;
  final String exerciseName;
  final int sets;
  final int? reps;
  final int? durationSeconds;
  final double? weight;
  final int restSeconds;
  final String? notes;
  final int order;

  const TemplateExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    this.reps,
    this.durationSeconds,
    this.weight,
    this.restSeconds = 60,
    this.notes,
    required this.order,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'sets': sets,
    'reps': reps,
    'durationSeconds': durationSeconds,
    'weight': weight,
    'restSeconds': restSeconds,
    'notes': notes,
    'order': order,
  };

  factory TemplateExercise.fromJson(Map<String, dynamic> json) =>
      TemplateExercise(
        exerciseId: json['exerciseId'],
        exerciseName: json['exerciseName'],
        sets: json['sets'],
        reps: json['reps'],
        durationSeconds: json['durationSeconds'],
        weight: (json['weight'] as num?)?.toDouble(),
        restSeconds: json['restSeconds'] ?? 60,
        notes: json['notes'],
        order: json['order'] ?? 0,
      );
}

enum WorkoutCategory {
  strength,
  cardio,
  hiit,
  flexibility,
  yoga,
  pilates,
  crossfit,
  bodyweight,
  powerlifting,
  olympic,
  endurance,
  recovery,
  custom,
}

extension WorkoutCategoryExtension on WorkoutCategory {
  String get displayName {
    switch (this) {
      case WorkoutCategory.strength:
        return 'Strength Training';
      case WorkoutCategory.cardio:
        return 'Cardio';
      case WorkoutCategory.hiit:
        return 'HIIT';
      case WorkoutCategory.flexibility:
        return 'Flexibility';
      case WorkoutCategory.yoga:
        return 'Yoga';
      case WorkoutCategory.pilates:
        return 'Pilates';
      case WorkoutCategory.crossfit:
        return 'CrossFit';
      case WorkoutCategory.bodyweight:
        return 'Bodyweight';
      case WorkoutCategory.powerlifting:
        return 'Powerlifting';
      case WorkoutCategory.olympic:
        return 'Olympic Lifting';
      case WorkoutCategory.endurance:
        return 'Endurance';
      case WorkoutCategory.recovery:
        return 'Recovery';
      case WorkoutCategory.custom:
        return 'Custom';
    }
  }

  String get icon {
    switch (this) {
      case WorkoutCategory.strength:
        return '🏋️';
      case WorkoutCategory.cardio:
        return '🏃';
      case WorkoutCategory.hiit:
        return '⚡';
      case WorkoutCategory.flexibility:
        return '🧘';
      case WorkoutCategory.yoga:
        return '🧘‍♀️';
      case WorkoutCategory.pilates:
        return '🤸';
      case WorkoutCategory.crossfit:
        return '💪';
      case WorkoutCategory.bodyweight:
        return '🙆';
      case WorkoutCategory.powerlifting:
        return '🏋️‍♂️';
      case WorkoutCategory.olympic:
        return '🏅';
      case WorkoutCategory.endurance:
        return '🚴';
      case WorkoutCategory.recovery:
        return '😌';
      case WorkoutCategory.custom:
        return '⭐';
    }
  }
}

enum DifficultyLevel { beginner, intermediate, advanced, expert }

extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }

  int get colorValue {
    switch (this) {
      case DifficultyLevel.beginner:
        return 0xFF66BB6A;
      case DifficultyLevel.intermediate:
        return 0xFFFFA726;
      case DifficultyLevel.advanced:
        return 0xFFFF7043;
      case DifficultyLevel.expert:
        return 0xFFEF5350;
    }
  }

  int get level {
    switch (this) {
      case DifficultyLevel.beginner:
        return 1;
      case DifficultyLevel.intermediate:
        return 2;
      case DifficultyLevel.advanced:
        return 3;
      case DifficultyLevel.expert:
        return 4;
    }
  }
}
