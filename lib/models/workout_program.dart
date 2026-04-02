import 'exercise.dart';

/// Workout program difficulty
enum ProgramDifficulty { beginner, intermediate, advanced, allLevels }

/// Program category
enum ProgramCategory {
  strength,
  weightLoss,
  muscleBuilding,
  endurance,
  flexibility,
  hiit,
  homeWorkout,
  fullBody,
  upperBody,
  lowerBody,
  core,
  powerlifting,
  bodybuilding,
  yoga,
  athletic,
  senior,
  postpartum,
  teen,
}

/// A single day in a workout program
class ProgramDay {
  final String id;
  final int dayNumber;
  final String name;
  final String? focus; // e.g., "Chest & Triceps", "Cardio"
  final List<WorkoutExercise> exercises;
  final int estimatedMinutes;
  final bool isRestDay;
  final String? notes;

  ProgramDay({
    required this.id,
    required this.dayNumber,
    required this.name,
    this.focus,
    this.exercises = const [],
    this.estimatedMinutes = 45,
    this.isRestDay = false,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayNumber': dayNumber,
      'name': name,
      'focus': focus,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'estimatedMinutes': estimatedMinutes,
      'isRestDay': isRestDay,
      'notes': notes,
    };
  }

  factory ProgramDay.fromJson(Map<String, dynamic> json) {
    return ProgramDay(
      id: json['id'] as String,
      dayNumber: json['dayNumber'] as int,
      name: json['name'] as String,
      focus: json['focus'] as String?,
      exercises:
          (json['exercises'] as List?)
              ?.map((e) => WorkoutExercise.fromJson(e))
              .toList() ??
          [],
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 45,
      isRestDay: json['isRestDay'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}

/// A complete workout program
class WorkoutProgram {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final ProgramDifficulty difficulty;
  final ProgramCategory category;
  final int durationWeeks;
  final int daysPerWeek;
  final List<ProgramDay> days;
  final List<Equipment> requiredEquipment;
  final bool isPremium;
  final double rating;
  final int reviewCount;
  final String? createdBy;
  final List<String> tags;
  final String? benefits;

  WorkoutProgram({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.difficulty,
    required this.category,
    required this.durationWeeks,
    required this.daysPerWeek,
    this.days = const [],
    this.requiredEquipment = const [],
    this.isPremium = false,
    this.rating = 0,
    this.reviewCount = 0,
    this.createdBy,
    this.tags = const [],
    this.benefits,
  });

  int get totalWorkouts => days.where((d) => !d.isRestDay).length;

  // Goals/benefits as a list for UI compatibility
  List<String> get goals =>
      benefits?.split('\n').where((s) => s.isNotEmpty).toList() ?? [];

  String get difficultyText {
    switch (difficulty) {
      case ProgramDifficulty.beginner:
        return 'Beginner';
      case ProgramDifficulty.intermediate:
        return 'Intermediate';
      case ProgramDifficulty.advanced:
        return 'Advanced';
      case ProgramDifficulty.allLevels:
        return 'All Levels';
    }
  }

  String get categoryText {
    switch (category) {
      case ProgramCategory.strength:
        return 'Strength';
      case ProgramCategory.weightLoss:
        return 'Weight Loss';
      case ProgramCategory.muscleBuilding:
        return 'Muscle Building';
      case ProgramCategory.endurance:
        return 'Endurance';
      case ProgramCategory.flexibility:
        return 'Flexibility';
      case ProgramCategory.hiit:
        return 'HIIT';
      case ProgramCategory.homeWorkout:
        return 'Home Workout';
      case ProgramCategory.fullBody:
        return 'Full Body';
      case ProgramCategory.upperBody:
        return 'Upper Body';
      case ProgramCategory.lowerBody:
        return 'Lower Body';
      case ProgramCategory.core:
        return 'Core';
      case ProgramCategory.powerlifting:
        return 'Powerlifting';
      case ProgramCategory.bodybuilding:
        return 'Bodybuilding';
      case ProgramCategory.yoga:
        return 'Yoga';
      case ProgramCategory.athletic:
        return 'Athletic';
      case ProgramCategory.senior:
        return 'Senior';
      case ProgramCategory.postpartum:
        return 'Postpartum';
      case ProgramCategory.teen:
        return 'Teen';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'difficulty': difficulty.name,
      'category': category.name,
      'durationWeeks': durationWeeks,
      'daysPerWeek': daysPerWeek,
      'days': days.map((d) => d.toJson()).toList(),
      'requiredEquipment': requiredEquipment.map((e) => e.name).toList(),
      'isPremium': isPremium,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdBy': createdBy,
      'tags': tags,
      'benefits': benefits,
    };
  }

  factory WorkoutProgram.fromJson(Map<String, dynamic> json) {
    return WorkoutProgram(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      difficulty: ProgramDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
      ),
      category: ProgramCategory.values.firstWhere(
        (c) => c.name == json['category'],
      ),
      durationWeeks: json['durationWeeks'] as int,
      daysPerWeek: json['daysPerWeek'] as int,
      days:
          (json['days'] as List?)
              ?.map((d) => ProgramDay.fromJson(d))
              .toList() ??
          [],
      requiredEquipment:
          (json['requiredEquipment'] as List?)
              ?.map((e) => Equipment.values.firstWhere((eq) => eq.name == e))
              .toList() ??
          [],
      isPremium: json['isPremium'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      createdBy: json['createdBy'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      benefits: json['benefits'] as String?,
    );
  }
}

/// User's enrollment in a program
class UserProgram {
  final String id;
  final String programId;
  final String? programName; // Cached for display
  final DateTime startDate;
  final int currentDay;
  final List<String> completedDaysList; // Track which days completed
  final bool isActive;
  final DateTime? completedAt;
  final List<DateTime> workoutDates;

  UserProgram({
    required this.id,
    required this.programId,
    this.programName,
    required this.startDate,
    this.currentDay = 1,
    this.completedDaysList = const [],
    this.isActive = true,
    this.completedAt,
    this.workoutDates = const [],
  });

  double get progressPercent {
    // This would need the program's total days to calculate
    return 0;
  }

  // Alias for UI compatibility - estimate current week from current day
  int get currentWeek => ((currentDay - 1) ~/ 7) + 1;

  // Alias for completedDays count
  int get completedDays => completedDaysList.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'programId': programId,
      'programName': programName,
      'startDate': startDate.toIso8601String(),
      'currentDay': currentDay,
      'completedDaysList': completedDaysList,
      'isActive': isActive,
      'completedAt': completedAt?.toIso8601String(),
      'workoutDates': workoutDates.map((d) => d.toIso8601String()).toList(),
    };
  }

  factory UserProgram.fromJson(Map<String, dynamic> json) {
    return UserProgram(
      id: json['id'] as String,
      programId: json['programId'] as String,
      programName: json['programName'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      currentDay: json['currentDay'] as int? ?? 1,
      completedDaysList: List<String>.from(json['completedDaysList'] ?? []),
      isActive: json['isActive'] as bool? ?? true,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      workoutDates:
          (json['workoutDates'] as List?)
              ?.map((d) => DateTime.parse(d as String))
              .toList() ??
          [],
    );
  }

  UserProgram copyWith({
    String? id,
    String? programId,
    String? programName,
    DateTime? startDate,
    int? currentDay,
    List<String>? completedDaysList,
    bool? isActive,
    DateTime? completedAt,
    List<DateTime>? workoutDates,
  }) {
    return UserProgram(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      programName: programName ?? this.programName,
      startDate: startDate ?? this.startDate,
      currentDay: currentDay ?? this.currentDay,
      completedDaysList: completedDaysList ?? this.completedDaysList,
      isActive: isActive ?? this.isActive,
      completedAt: completedAt ?? this.completedAt,
      workoutDates: workoutDates ?? this.workoutDates,
    );
  }
}
