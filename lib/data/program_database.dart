import '../models/workout_program.dart';
import '../models/exercise.dart';
import 'exercise_database.dart';

/// Pre-built workout programs
class ProgramDatabase {
  static List<WorkoutProgram> get all => [
    // BEGINNER PROGRAMS
    WorkoutProgram(
      id: 'beginner_full_body',
      name: 'Beginner Full Body',
      description:
          'Perfect for those just starting their fitness journey. This 4-week program introduces fundamental movements with 3 workouts per week.',
      difficulty: ProgramDifficulty.beginner,
      category: ProgramCategory.fullBody,
      durationWeeks: 4,
      daysPerWeek: 3,
      requiredEquipment: [Equipment.none],
      rating: 4.8,
      reviewCount: 1250,
      tags: ['Beginner', 'No Equipment', 'Full Body'],
      benefits:
          'Build a foundation of strength and learn proper form for basic exercises.',
      days: _generateBeginnerFullBodyDays(),
    ),
    WorkoutProgram(
      id: 'beginner_strength',
      name: 'Strength Foundations',
      description:
          'Learn the fundamental strength training movements with proper form. 4 weeks to build your base.',
      difficulty: ProgramDifficulty.beginner,
      category: ProgramCategory.strength,
      durationWeeks: 4,
      daysPerWeek: 3,
      requiredEquipment: [Equipment.dumbbells],
      rating: 4.7,
      reviewCount: 890,
      tags: ['Beginner', 'Strength', 'Dumbbells'],
      benefits: 'Master basic lifts and build functional strength.',
      days: _generateStrengthFoundationsDays(),
    ),

    // INTERMEDIATE PROGRAMS
    WorkoutProgram(
      id: 'intermediate_ppl',
      name: 'Push Pull Legs',
      description:
          'A classic bodybuilding split that trains each muscle group twice per week. 6 workouts per week for serious gains.',
      difficulty: ProgramDifficulty.intermediate,
      category: ProgramCategory.muscleBuilding,
      durationWeeks: 8,
      daysPerWeek: 6,
      requiredEquipment: [
        Equipment.barbell,
        Equipment.dumbbells,
        Equipment.cable,
      ],
      rating: 4.9,
      reviewCount: 2340,
      tags: ['Intermediate', 'Muscle Building', 'Gym'],
      benefits: 'Optimize muscle growth with proper recovery between sessions.',
      days: _generatePPLDays(),
    ),
    WorkoutProgram(
      id: 'intermediate_upper_lower',
      name: 'Upper Lower Split',
      description:
          'A 4-day split alternating between upper and lower body workouts. Great for building strength and muscle.',
      difficulty: ProgramDifficulty.intermediate,
      category: ProgramCategory.strength,
      durationWeeks: 6,
      daysPerWeek: 4,
      requiredEquipment: [Equipment.barbell, Equipment.dumbbells],
      rating: 4.8,
      reviewCount: 1560,
      tags: ['Intermediate', 'Strength', '4 Days'],
      benefits: 'Balance strength and muscle building with adequate recovery.',
      days: _generateUpperLowerDays(),
    ),

    // HOME WORKOUT PROGRAMS
    WorkoutProgram(
      id: 'home_hiit_4week',
      name: 'Home HIIT Challenge',
      description:
          'High-intensity interval training you can do at home with no equipment. Burn fat and build endurance in just 4 weeks.',
      difficulty: ProgramDifficulty.intermediate,
      category: ProgramCategory.hiit,
      durationWeeks: 4,
      daysPerWeek: 4,
      requiredEquipment: [Equipment.none],
      rating: 4.6,
      reviewCount: 3200,
      tags: ['HIIT', 'No Equipment', 'Fat Loss', 'Home'],
      benefits:
          'Maximize calorie burn in minimum time with no equipment needed.',
      days: _generateHomeHIITDays(),
    ),
    WorkoutProgram(
      id: 'home_bodyweight',
      name: 'Bodyweight Master',
      description:
          'Build impressive strength using just your bodyweight. Progress from basic to advanced calisthenics.',
      difficulty: ProgramDifficulty.intermediate,
      category: ProgramCategory.homeWorkout,
      durationWeeks: 8,
      daysPerWeek: 4,
      requiredEquipment: [Equipment.pullUpBar],
      rating: 4.7,
      reviewCount: 1890,
      tags: ['Bodyweight', 'Calisthenics', 'Home'],
      benefits: 'Develop functional strength and body control.',
      days: _generateBodyweightDays(),
    ),

    // WEIGHT LOSS PROGRAMS
    WorkoutProgram(
      id: 'weight_loss_beginner',
      name: 'Fat Burn Kickstart',
      description:
          'A beginner-friendly program designed to kickstart your weight loss journey with cardio and strength training.',
      difficulty: ProgramDifficulty.beginner,
      category: ProgramCategory.weightLoss,
      durationWeeks: 6,
      daysPerWeek: 4,
      requiredEquipment: [Equipment.none],
      rating: 4.5,
      reviewCount: 4500,
      tags: ['Weight Loss', 'Beginner', 'Cardio'],
      benefits: 'Burn calories, build muscle, and develop healthy habits.',
      days: _generateWeightLossBeginnerDays(),
    ),
    WorkoutProgram(
      id: 'weight_loss_advanced',
      name: 'Shred 12-Week',
      description:
          'An intensive 12-week program combining strength training and cardio for maximum fat loss while preserving muscle.',
      difficulty: ProgramDifficulty.advanced,
      category: ProgramCategory.weightLoss,
      durationWeeks: 12,
      daysPerWeek: 5,
      requiredEquipment: [Equipment.dumbbells, Equipment.barbell],
      rating: 4.8,
      reviewCount: 2100,
      tags: ['Weight Loss', 'Advanced', 'Shred'],
      benefits: 'Achieve significant fat loss while maintaining muscle mass.',
      days: _generateWeightLossAdvancedDays(),
    ),

    // MUSCLE BUILDING
    WorkoutProgram(
      id: 'muscle_building_5x5',
      name: 'StrongLifts 5x5',
      description:
          'The classic 5x5 program for building raw strength. Simple, effective, and proven over decades.',
      difficulty: ProgramDifficulty.intermediate,
      category: ProgramCategory.strength,
      durationWeeks: 12,
      daysPerWeek: 3,
      requiredEquipment: [Equipment.barbell],
      rating: 4.9,
      reviewCount: 5600,
      tags: ['Strength', '5x5', 'Classic'],
      benefits: 'Build serious strength with proven methodology.',
      days: _generateStrongLiftsDays(),
    ),
    WorkoutProgram(
      id: 'muscle_building_hypertrophy',
      name: 'Hypertrophy Specialist',
      description:
          'Maximize muscle growth with higher volume training designed for size.',
      difficulty: ProgramDifficulty.intermediate,
      category: ProgramCategory.muscleBuilding,
      durationWeeks: 8,
      daysPerWeek: 5,
      requiredEquipment: [
        Equipment.dumbbells,
        Equipment.barbell,
        Equipment.cable,
      ],
      rating: 4.7,
      reviewCount: 1800,
      tags: ['Hypertrophy', 'Muscle Building', 'Volume'],
      benefits:
          'Optimize muscle hypertrophy with scientific training principles.',
      days: _generateHypertrophyDays(),
    ),

    // FLEXIBILITY & MOBILITY
    WorkoutProgram(
      id: 'flexibility_30day',
      name: '30-Day Flexibility',
      description:
          'Improve your flexibility and mobility with daily stretching routines. Perfect for anyone feeling stiff.',
      difficulty: ProgramDifficulty.beginner,
      category: ProgramCategory.flexibility,
      durationWeeks: 4,
      daysPerWeek: 7,
      requiredEquipment: [Equipment.none],
      rating: 4.6,
      reviewCount: 2300,
      tags: ['Flexibility', 'Stretching', 'Daily'],
      benefits: 'Reduce muscle tension and improve range of motion.',
      days: _generateFlexibilityDays(),
    ),

    // CORE FOCUSED
    WorkoutProgram(
      id: 'core_strength',
      name: 'Core Crusher',
      description: 'Build a rock-solid core with this focused 4-week program.',
      difficulty: ProgramDifficulty.intermediate,
      category: ProgramCategory.core,
      durationWeeks: 4,
      daysPerWeek: 4,
      requiredEquipment: [Equipment.none],
      rating: 4.5,
      reviewCount: 1400,
      tags: ['Core', 'Abs', 'Stability'],
      benefits: 'Strengthen your core for better posture and performance.',
      days: _generateCoreDays(),
    ),

    // SPECIALIZED
    WorkoutProgram(
      id: 'runner_strength',
      name: 'Strength for Runners',
      description:
          'Complement your running with targeted strength training to prevent injuries and improve performance.',
      difficulty: ProgramDifficulty.beginner,
      category: ProgramCategory.strength,
      durationWeeks: 6,
      daysPerWeek: 2,
      requiredEquipment: [Equipment.dumbbells],
      rating: 4.7,
      reviewCount: 890,
      tags: ['Running', 'Strength', 'Injury Prevention'],
      benefits: 'Run faster and stay injury-free with targeted strength work.',
      days: _generateRunnerStrengthDays(),
    ),
    WorkoutProgram(
      id: 'desk_worker',
      name: 'Desk Worker Recovery',
      description:
          'Combat the effects of sitting all day with exercises targeting posture and mobility.',
      difficulty: ProgramDifficulty.beginner,
      category: ProgramCategory.flexibility,
      durationWeeks: 4,
      daysPerWeek: 5,
      requiredEquipment: [Equipment.none],
      rating: 4.8,
      reviewCount: 3400,
      tags: ['Posture', 'Office', 'Mobility'],
      benefits: 'Reduce pain and improve posture from desk work.',
      days: _generateDeskWorkerDays(),
    ),

    // ADVANCED PROGRAMS
    WorkoutProgram(
      id: 'advanced_phul',
      name: 'PHUL (Power Hypertrophy)',
      description:
          'Power Hypertrophy Upper Lower - combines strength and hypertrophy training for maximum results.',
      difficulty: ProgramDifficulty.advanced,
      category: ProgramCategory.muscleBuilding,
      durationWeeks: 12,
      daysPerWeek: 4,
      requiredEquipment: [
        Equipment.barbell,
        Equipment.dumbbells,
        Equipment.cable,
      ],
      rating: 4.9,
      reviewCount: 3200,
      tags: ['PHUL', 'Power', 'Hypertrophy', 'Advanced'],
      benefits: 'Build both strength and size with this proven 4-day split.',
      days: _generatePHULDays(),
    ),
    WorkoutProgram(
      id: 'advanced_phat',
      name: 'PHAT (Layne Norton)',
      description:
          'Power Hypertrophy Adaptive Training by Dr. Layne Norton. Combines power and hypertrophy for elite results.',
      difficulty: ProgramDifficulty.advanced,
      category: ProgramCategory.muscleBuilding,
      durationWeeks: 12,
      daysPerWeek: 5,
      requiredEquipment: [
        Equipment.barbell,
        Equipment.dumbbells,
        Equipment.cable,
        Equipment.machine,
      ],
      rating: 4.8,
      reviewCount: 2800,
      tags: ['PHAT', 'Layne Norton', 'Advanced', 'Bodybuilding'],
      benefits: 'Elite-level program for serious muscle and strength gains.',
      days: _generatePHATDays(),
    ),
    WorkoutProgram(
      id: 'advanced_arnold_split',
      name: 'Arnold Split',
      description:
          'The classic 6-day split used by Arnold Schwarzenegger. High volume bodybuilding for maximum muscle.',
      difficulty: ProgramDifficulty.advanced,
      category: ProgramCategory.muscleBuilding,
      durationWeeks: 8,
      daysPerWeek: 6,
      requiredEquipment: [
        Equipment.barbell,
        Equipment.dumbbells,
        Equipment.cable,
        Equipment.machine,
      ],
      rating: 4.9,
      reviewCount: 4500,
      tags: ['Arnold', 'Classic', 'Bodybuilding', '6-Day'],
      benefits: 'Train like a champion with this legendary high-volume split.',
      days: _generateArnoldSplitDays(),
    ),
    WorkoutProgram(
      id: 'powerbuilding_12week',
      name: 'Powerbuilding Program',
      description:
          'The best of both worlds - build strength like a powerlifter and size like a bodybuilder.',
      difficulty: ProgramDifficulty.advanced,
      category: ProgramCategory.strength,
      durationWeeks: 12,
      daysPerWeek: 4,
      requiredEquipment: [Equipment.barbell, Equipment.dumbbells],
      rating: 4.8,
      reviewCount: 2100,
      tags: ['Powerbuilding', 'Strength', 'Hypertrophy'],
      benefits: 'Maximize strength while building impressive muscle mass.',
      days: _generatePowerbuildingDays(),
    ),

    // ATHLETIC PROGRAMS
    WorkoutProgram(
      id: 'athletic_performance',
      name: 'Athletic Performance',
      description:
          'Train like an athlete with explosive power, speed, and agility exercises.',
      difficulty: ProgramDifficulty.intermediate,
      category: ProgramCategory.athletic,
      durationWeeks: 8,
      daysPerWeek: 4,
      requiredEquipment: [Equipment.dumbbells, Equipment.kettlebell],
      rating: 4.7,
      reviewCount: 1650,
      tags: ['Athletic', 'Speed', 'Power', 'Agility'],
      benefits: 'Develop explosive power and athletic performance.',
      days: _generateAthleticDays(),
    ),
    WorkoutProgram(
      id: 'functional_fitness',
      name: 'Functional Fitness',
      description:
          'Real-world strength and conditioning for everyday life and sports.',
      difficulty: ProgramDifficulty.intermediate,
      category: ProgramCategory.strength,
      durationWeeks: 6,
      daysPerWeek: 4,
      requiredEquipment: [Equipment.kettlebell, Equipment.dumbbells],
      rating: 4.6,
      reviewCount: 1890,
      tags: ['Functional', 'Conditioning', 'Full Body'],
      benefits: 'Build strength that transfers to real-world activities.',
      days: _generateFunctionalDays(),
    ),

    // QUICK PROGRAMS
    WorkoutProgram(
      id: 'quick_20min',
      name: '20-Minute Express',
      description:
          'No time? No problem. Full body workouts in just 20 minutes.',
      difficulty: ProgramDifficulty.beginner,
      category: ProgramCategory.homeWorkout,
      durationWeeks: 4,
      daysPerWeek: 4,
      requiredEquipment: [Equipment.none],
      rating: 4.5,
      reviewCount: 5200,
      tags: ['Quick', '20 Minutes', 'No Equipment', 'Busy'],
      benefits: 'Stay fit even with the busiest schedule.',
      days: _generateQuick20Days(),
    ),
    WorkoutProgram(
      id: 'lunch_break',
      name: 'Lunch Break Workouts',
      description:
          '15-minute high-intensity workouts perfect for your lunch break.',
      difficulty: ProgramDifficulty.beginner,
      category: ProgramCategory.hiit,
      durationWeeks: 4,
      daysPerWeek: 5,
      requiredEquipment: [Equipment.none],
      rating: 4.4,
      reviewCount: 3100,
      tags: ['Quick', 'Lunch Break', 'Office', 'HIIT'],
      benefits: 'Boost energy and burn calories during your work day.',
      days: _generateLunchBreakDays(),
    ),

    // SPORT-SPECIFIC
    WorkoutProgram(
      id: 'basketball_training',
      name: 'Basketball Performance',
      description: 'Jump higher, move faster, and dominate on the court.',
      difficulty: ProgramDifficulty.intermediate,
      category: ProgramCategory.athletic,
      durationWeeks: 8,
      daysPerWeek: 4,
      requiredEquipment: [Equipment.dumbbells, Equipment.resistanceBands],
      rating: 4.7,
      reviewCount: 980,
      tags: ['Basketball', 'Vertical Jump', 'Speed', 'Sport'],
      benefits: 'Increase vertical jump and court performance.',
      days: _generateBasketballDays(),
    ),
    WorkoutProgram(
      id: 'swimming_dryland',
      name: 'Swimmer\'s Dryland',
      description: 'Build swimming-specific strength and power on land.',
      difficulty: ProgramDifficulty.intermediate,
      category: ProgramCategory.athletic,
      durationWeeks: 8,
      daysPerWeek: 3,
      requiredEquipment: [Equipment.resistanceBands, Equipment.dumbbells],
      rating: 4.6,
      reviewCount: 720,
      tags: ['Swimming', 'Dryland', 'Core', 'Shoulders'],
      benefits: 'Improve stroke power and endurance out of the water.',
      days: _generateSwimmerDays(),
    ),
  ];

  /// Get program by ID
  static WorkoutProgram? getById(String id) {
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get programs by difficulty
  static List<WorkoutProgram> getByDifficulty(ProgramDifficulty difficulty) {
    return all.where((p) => p.difficulty == difficulty).toList();
  }

  /// Get programs by category
  static List<WorkoutProgram> getByCategory(ProgramCategory category) {
    return all.where((p) => p.category == category).toList();
  }

  /// Get programs that don't require equipment
  static List<WorkoutProgram> getNoEquipmentPrograms() {
    return all
        .where(
          (p) =>
              p.requiredEquipment.isEmpty ||
              (p.requiredEquipment.length == 1 &&
                  p.requiredEquipment.contains(Equipment.none)),
        )
        .toList();
  }

  /// Get featured/popular programs
  static List<WorkoutProgram> getFeatured() {
    return all.where((p) => p.rating >= 4.7).toList()
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
  }

  /// Search programs
  static List<WorkoutProgram> search(String query) {
    final lowercaseQuery = query.toLowerCase();
    return all
        .where(
          (p) =>
              p.name.toLowerCase().contains(lowercaseQuery) ||
              p.description.toLowerCase().contains(lowercaseQuery) ||
              p.tags.any((t) => t.toLowerCase().contains(lowercaseQuery)),
        )
        .toList();
  }

  /// Get all programs (aliases for UI compatibility)
  static List<WorkoutProgram> get allPrograms => all;
  static List<WorkoutProgram> getAll() => all;

  // --- HELPER METHODS TO GENERATE DAYS ---

  static List<ProgramDay> _generateBeginnerFullBodyDays() {
    final exercises = [
      _createWorkoutExercise('push_up', 3, 10),
      _createWorkoutExercise('squat', 3, 12),
      _createWorkoutExercise('plank', 3, 30, isTime: true),
      _createWorkoutExercise('lunges', 3, 10),
    ];

    return List.generate(4 * 3, (index) {
      final week = (index / 3).floor() + 1;
      final dayInWeek = (index % 3) + 1;
      return ProgramDay(
        id: 'beginner_full_body_w${week}_d$dayInWeek',
        dayNumber: index + 1,
        name: 'Full Body Workout',
        focus: 'Full Body',
        exercises: exercises,
        estimatedMinutes: 30,
      );
    });
  }

  static List<ProgramDay> _generateStrengthFoundationsDays() {
    final exercises = [
      _createWorkoutExercise('dumbbell_chest_press', 3, 10),
      _createWorkoutExercise('dumbbell_row', 3, 10),
      _createWorkoutExercise('goblet_squat', 3, 10),
      _createWorkoutExercise('dumbbell_shoulder_press', 3, 10),
    ];

    return List.generate(4 * 3, (index) {
      return ProgramDay(
        id: 'strength_foundations_d${index + 1}',
        dayNumber: index + 1,
        name: 'Strength Workout',
        focus: 'Strength',
        exercises: exercises,
        estimatedMinutes: 45,
      );
    });
  }

  static List<ProgramDay> _generatePPLDays() {
    // Simplified PPL generation
    return List.generate(8 * 6, (index) {
      final dayType = index % 3; // 0: Push, 1: Pull, 2: Legs
      String name;
      List<WorkoutExercise> exercises;

      if (dayType == 0) {
        name = 'Push Day';
        exercises = [
          _createWorkoutExercise('bench_press', 4, 8),
          _createWorkoutExercise('overhead_press', 3, 10),
          _createWorkoutExercise('tricep_pushdown', 3, 12),
        ];
      } else if (dayType == 1) {
        name = 'Pull Day';
        exercises = [
          _createWorkoutExercise('pull_up', 3, 8),
          _createWorkoutExercise('barbell_row', 3, 10),
          _createWorkoutExercise('bicep_curl', 3, 12),
        ];
      } else {
        name = 'Leg Day';
        exercises = [
          _createWorkoutExercise('squat', 4, 8),
          _createWorkoutExercise('deadlift', 3, 5),
          _createWorkoutExercise('leg_press', 3, 12),
        ];
      }

      return ProgramDay(
        id: 'ppl_d${index + 1}',
        dayNumber: index + 1,
        name: name,
        focus: name,
        exercises: exercises,
        estimatedMinutes: 60,
      );
    });
  }

  static List<ProgramDay> _generateUpperLowerDays() {
    return List.generate(6 * 4, (index) {
      final isUpper = index % 2 == 0;
      return ProgramDay(
        id: 'ul_d${index + 1}',
        dayNumber: index + 1,
        name: isUpper ? 'Upper Body' : 'Lower Body',
        focus: isUpper ? 'Upper' : 'Lower',
        exercises: isUpper
            ? [
                _createWorkoutExercise('bench_press', 3, 10),
                _createWorkoutExercise('pull_up', 3, 10),
              ]
            : [
                _createWorkoutExercise('squat', 3, 10),
                _createWorkoutExercise('deadlift', 3, 10),
              ],
        estimatedMinutes: 50,
      );
    });
  }

  static List<ProgramDay> _generateHomeHIITDays() {
    final exercises = [
      _createWorkoutExercise('jumping_jacks', 3, 45, isTime: true),
      _createWorkoutExercise('burpees', 3, 15),
      _createWorkoutExercise('mountain_climbers', 3, 45, isTime: true),
      _createWorkoutExercise('high_knees', 3, 45, isTime: true),
    ];

    return List.generate(4 * 4, (index) {
      return ProgramDay(
        id: 'hiit_d${index + 1}',
        dayNumber: index + 1,
        name: 'HIIT Session',
        focus: 'Cardio & Endurance',
        exercises: exercises,
        estimatedMinutes: 25,
      );
    });
  }

  static List<ProgramDay> _generateBodyweightDays() {
    final exercises = [
      _createWorkoutExercise('push_up', 3, 15),
      _createWorkoutExercise('pull_up', 3, 8),
      _createWorkoutExercise('squat', 3, 20),
      _createWorkoutExercise('plank', 3, 60, isTime: true),
    ];

    return List.generate(8 * 4, (index) {
      return ProgramDay(
        id: 'bw_d${index + 1}',
        dayNumber: index + 1,
        name: 'Bodyweight Strength',
        focus: 'Full Body',
        exercises: exercises,
        estimatedMinutes: 40,
      );
    });
  }

  static List<ProgramDay> _generateWeightLossBeginnerDays() {
    return _generateHomeHIITDays(); // Reuse HIIT for weight loss
  }

  static List<ProgramDay> _generateWeightLossAdvancedDays() {
    return _generatePPLDays(); // Reuse PPL for advanced weight loss
  }

  static List<ProgramDay> _generateStrongLiftsDays() {
    // A/B Split
    return List.generate(12 * 3, (index) {
      final isA = index % 2 == 0;
      return ProgramDay(
        id: 'sl5x5_d${index + 1}',
        dayNumber: index + 1,
        name: isA ? 'Workout A' : 'Workout B',
        focus: 'Strength',
        exercises: isA
            ? [
                _createWorkoutExercise('squat', 5, 5),
                _createWorkoutExercise('bench_press', 5, 5),
                _createWorkoutExercise('barbell_row', 5, 5),
              ]
            : [
                _createWorkoutExercise('squat', 5, 5),
                _createWorkoutExercise('overhead_press', 5, 5),
                _createWorkoutExercise('deadlift', 1, 5),
              ],
        estimatedMinutes: 45,
      );
    });
  }

  static List<ProgramDay> _generateHypertrophyDays() {
    return _generatePPLDays(); // Reuse PPL
  }

  static List<ProgramDay> _generateFlexibilityDays() {
    final exercises = [
      _createWorkoutExercise('cat_cow', 1, 60, isTime: true),
      _createWorkoutExercise('child_pose', 1, 60, isTime: true),
      _createWorkoutExercise('cobra_stretch', 1, 60, isTime: true),
    ];

    return List.generate(4 * 7, (index) {
      return ProgramDay(
        id: 'flex_d${index + 1}',
        dayNumber: index + 1,
        name: 'Daily Stretch',
        focus: 'Flexibility',
        exercises: exercises,
        estimatedMinutes: 15,
      );
    });
  }

  static List<ProgramDay> _generateCoreDays() {
    final exercises = [
      _createWorkoutExercise('plank', 3, 45, isTime: true),
      _createWorkoutExercise('crunches', 3, 20),
      _createWorkoutExercise('leg_raises', 3, 15),
      _createWorkoutExercise('russian_twist', 3, 20),
    ];

    return List.generate(4 * 4, (index) {
      return ProgramDay(
        id: 'core_d${index + 1}',
        dayNumber: index + 1,
        name: 'Core Workout',
        focus: 'Core',
        exercises: exercises,
        estimatedMinutes: 20,
      );
    });
  }

  static List<ProgramDay> _generateRunnerStrengthDays() {
    final exercises = [
      _createWorkoutExercise('lunges', 3, 12),
      _createWorkoutExercise('squat', 3, 15),
      _createWorkoutExercise('calf_raises', 3, 20),
      _createWorkoutExercise('plank', 3, 60, isTime: true),
    ];

    return List.generate(6 * 2, (index) {
      return ProgramDay(
        id: 'run_str_d${index + 1}',
        dayNumber: index + 1,
        name: 'Runner Strength',
        focus: 'Legs & Core',
        exercises: exercises,
        estimatedMinutes: 30,
      );
    });
  }

  static List<ProgramDay> _generateDeskWorkerDays() {
    final exercises = [
      _createWorkoutExercise('neck_rolls', 1, 60, isTime: true),
      _createWorkoutExercise('shoulder_rolls', 1, 60, isTime: true),
      _createWorkoutExercise('cat_cow', 1, 60, isTime: true),
      _createWorkoutExercise('glute_bridge', 3, 15),
    ];

    return List.generate(4 * 5, (index) {
      return ProgramDay(
        id: 'desk_d${index + 1}',
        dayNumber: index + 1,
        name: 'Posture Correction',
        focus: 'Mobility',
        exercises: exercises,
        estimatedMinutes: 15,
      );
    });
  }

  // PHUL (Power Hypertrophy Upper Lower) Days
  static List<ProgramDay> _generatePHULDays() {
    return List.generate(12 * 4, (index) {
      final dayType = index % 4;
      String name;
      String focus;
      List<WorkoutExercise> exercises;

      switch (dayType) {
        case 0: // Upper Power
          name = 'Upper Power';
          focus = 'Strength - Upper';
          exercises = [
            _createWorkoutExercise('bench_press', 4, 5),
            _createWorkoutExercise('barbell_row', 4, 5),
            _createWorkoutExercise('overhead_press', 3, 6),
            _createWorkoutExercise('pull_up', 3, 8),
            _createWorkoutExercise('barbell_curl', 2, 8),
            _createWorkoutExercise('skull_crusher', 2, 8),
          ];
          break;
        case 1: // Lower Power
          name = 'Lower Power';
          focus = 'Strength - Lower';
          exercises = [
            _createWorkoutExercise('squat', 4, 5),
            _createWorkoutExercise('deadlift', 4, 5),
            _createWorkoutExercise('leg_press', 3, 8),
            _createWorkoutExercise('leg_curl', 3, 8),
            _createWorkoutExercise('calf_raises', 4, 10),
          ];
          break;
        case 2: // Upper Hypertrophy
          name = 'Upper Hypertrophy';
          focus = 'Volume - Upper';
          exercises = [
            _createWorkoutExercise('incline_dumbbell_press', 4, 12),
            _createWorkoutExercise('cable_row', 4, 12),
            _createWorkoutExercise('dumbbell_lateral_raise', 3, 15),
            _createWorkoutExercise('cable_fly', 3, 15),
            _createWorkoutExercise('hammer_curl', 3, 12),
            _createWorkoutExercise('tricep_pushdown', 3, 12),
          ];
          break;
        default: // Lower Hypertrophy
          name = 'Lower Hypertrophy';
          focus = 'Volume - Lower';
          exercises = [
            _createWorkoutExercise('front_squat', 4, 10),
            _createWorkoutExercise('romanian_deadlift', 4, 10),
            _createWorkoutExercise('walking_lunges', 3, 12),
            _createWorkoutExercise('leg_extension', 3, 15),
            _createWorkoutExercise('seated_calf_raise', 4, 15),
          ];
      }

      return ProgramDay(
        id: 'phul_d${index + 1}',
        dayNumber: index + 1,
        name: name,
        focus: focus,
        exercises: exercises,
        estimatedMinutes: 70,
      );
    });
  }

  // PHAT Days
  static List<ProgramDay> _generatePHATDays() {
    return List.generate(12 * 5, (index) {
      final dayType = index % 5;
      String name;
      String focus;
      List<WorkoutExercise> exercises;

      switch (dayType) {
        case 0: // Upper Power
          name = 'Upper Power';
          focus = 'Strength';
          exercises = [
            _createWorkoutExercise('bench_press', 4, 5),
            _createWorkoutExercise('barbell_row', 4, 5),
            _createWorkoutExercise('overhead_press', 3, 8),
            _createWorkoutExercise('weighted_pull_up', 3, 6),
          ];
          break;
        case 1: // Lower Power
          name = 'Lower Power';
          focus = 'Strength';
          exercises = [
            _createWorkoutExercise('squat', 4, 5),
            _createWorkoutExercise('deadlift', 3, 5),
            _createWorkoutExercise('leg_press', 3, 10),
            _createWorkoutExercise('hamstring_curl', 3, 10),
          ];
          break;
        case 2: // Back & Shoulders Hypertrophy
          name = 'Back & Shoulders';
          focus = 'Hypertrophy';
          exercises = [
            _createWorkoutExercise('lat_pulldown', 4, 12),
            _createWorkoutExercise('cable_row', 4, 12),
            _createWorkoutExercise('dumbbell_shoulder_press', 3, 12),
            _createWorkoutExercise('face_pull', 3, 15),
            _createWorkoutExercise('rear_delt_fly', 3, 15),
          ];
          break;
        case 3: // Chest & Arms Hypertrophy
          name = 'Chest & Arms';
          focus = 'Hypertrophy';
          exercises = [
            _createWorkoutExercise('incline_bench_press', 4, 10),
            _createWorkoutExercise('dumbbell_fly', 3, 12),
            _createWorkoutExercise('cable_crossover', 3, 15),
            _createWorkoutExercise('barbell_curl', 3, 12),
            _createWorkoutExercise('overhead_tricep_extension', 3, 12),
          ];
          break;
        default: // Legs Hypertrophy
          name = 'Legs Hypertrophy';
          focus = 'Hypertrophy';
          exercises = [
            _createWorkoutExercise('hack_squat', 4, 10),
            _createWorkoutExercise('romanian_deadlift', 4, 10),
            _createWorkoutExercise('leg_extension', 3, 15),
            _createWorkoutExercise('leg_curl', 3, 15),
            _createWorkoutExercise('calf_raises', 4, 15),
          ];
      }

      return ProgramDay(
        id: 'phat_d${index + 1}',
        dayNumber: index + 1,
        name: name,
        focus: focus,
        exercises: exercises,
        estimatedMinutes: 75,
      );
    });
  }

  // Arnold Split Days
  static List<ProgramDay> _generateArnoldSplitDays() {
    return List.generate(8 * 6, (index) {
      final dayType = index % 6;
      String name;
      String focus;
      List<WorkoutExercise> exercises;

      switch (dayType) {
        case 0: // Chest & Back
          name = 'Chest & Back';
          focus = 'Push/Pull Superset';
          exercises = [
            _createWorkoutExercise('bench_press', 4, 10),
            _createWorkoutExercise('pull_up', 4, 10),
            _createWorkoutExercise('incline_dumbbell_press', 4, 10),
            _createWorkoutExercise('barbell_row', 4, 10),
            _createWorkoutExercise('dumbbell_fly', 3, 12),
            _createWorkoutExercise('cable_row', 3, 12),
          ];
          break;
        case 1: // Shoulders & Arms
          name = 'Shoulders & Arms';
          focus = 'Delts/Bis/Tris';
          exercises = [
            _createWorkoutExercise('overhead_press', 4, 10),
            _createWorkoutExercise('dumbbell_lateral_raise', 4, 12),
            _createWorkoutExercise('barbell_curl', 4, 10),
            _createWorkoutExercise('close_grip_bench', 4, 10),
            _createWorkoutExercise('incline_dumbbell_curl', 3, 12),
            _createWorkoutExercise('tricep_pushdown', 3, 12),
          ];
          break;
        case 2: // Legs
          name = 'Legs';
          focus = 'Quads/Hams/Calves';
          exercises = [
            _createWorkoutExercise('squat', 5, 8),
            _createWorkoutExercise('leg_press', 4, 10),
            _createWorkoutExercise('leg_curl', 4, 10),
            _createWorkoutExercise('leg_extension', 3, 12),
            _createWorkoutExercise('standing_calf_raise', 5, 15),
          ];
          break;
        case 3: // Chest & Back 2
          name = 'Chest & Back 2';
          focus = 'Volume Day';
          exercises = [
            _createWorkoutExercise('incline_bench_press', 4, 10),
            _createWorkoutExercise('lat_pulldown', 4, 10),
            _createWorkoutExercise('cable_crossover', 3, 15),
            _createWorkoutExercise('t_bar_row', 4, 10),
            _createWorkoutExercise('dips', 3, 12),
          ];
          break;
        case 4: // Shoulders & Arms 2
          name = 'Shoulders & Arms 2';
          focus = 'Volume Day';
          exercises = [
            _createWorkoutExercise('dumbbell_shoulder_press', 4, 10),
            _createWorkoutExercise('cable_lateral_raise', 3, 15),
            _createWorkoutExercise('preacher_curl', 3, 12),
            _createWorkoutExercise('skull_crusher', 3, 12),
            _createWorkoutExercise('hammer_curl', 3, 12),
            _createWorkoutExercise('tricep_kickback', 3, 15),
          ];
          break;
        default: // Legs 2
          name = 'Legs 2';
          focus = 'Volume Day';
          exercises = [
            _createWorkoutExercise('front_squat', 4, 10),
            _createWorkoutExercise('romanian_deadlift', 4, 10),
            _createWorkoutExercise('walking_lunges', 3, 12),
            _createWorkoutExercise('leg_curl', 3, 15),
            _createWorkoutExercise('seated_calf_raise', 4, 20),
          ];
      }

      return ProgramDay(
        id: 'arnold_d${index + 1}',
        dayNumber: index + 1,
        name: name,
        focus: focus,
        exercises: exercises,
        estimatedMinutes: 70,
      );
    });
  }

  // Powerbuilding Days
  static List<ProgramDay> _generatePowerbuildingDays() {
    return List.generate(12 * 4, (index) {
      final dayType = index % 4;
      String name;
      String focus;
      List<WorkoutExercise> exercises;

      switch (dayType) {
        case 0: // Squat Day
          name = 'Squat Focus';
          focus = 'Strength + Volume';
          exercises = [
            _createWorkoutExercise('squat', 5, 5),
            _createWorkoutExercise('front_squat', 3, 8),
            _createWorkoutExercise('leg_press', 3, 12),
            _createWorkoutExercise('leg_curl', 3, 12),
            _createWorkoutExercise('ab_wheel', 3, 15),
          ];
          break;
        case 1: // Bench Day
          name = 'Bench Focus';
          focus = 'Strength + Volume';
          exercises = [
            _createWorkoutExercise('bench_press', 5, 5),
            _createWorkoutExercise('close_grip_bench', 3, 8),
            _createWorkoutExercise('incline_dumbbell_press', 3, 12),
            _createWorkoutExercise('tricep_pushdown', 3, 15),
            _createWorkoutExercise('dumbbell_lateral_raise', 3, 15),
          ];
          break;
        case 2: // Deadlift Day
          name = 'Deadlift Focus';
          focus = 'Strength + Volume';
          exercises = [
            _createWorkoutExercise('deadlift', 5, 5),
            _createWorkoutExercise('barbell_row', 4, 8),
            _createWorkoutExercise('pull_up', 3, 10),
            _createWorkoutExercise('face_pull', 3, 15),
            _createWorkoutExercise('barbell_curl', 3, 12),
          ];
          break;
        default: // OHP Day
          name = 'OHP Focus';
          focus = 'Strength + Volume';
          exercises = [
            _createWorkoutExercise('overhead_press', 5, 5),
            _createWorkoutExercise('dumbbell_shoulder_press', 3, 10),
            _createWorkoutExercise('dumbbell_lateral_raise', 4, 12),
            _createWorkoutExercise('rear_delt_fly', 3, 15),
            _createWorkoutExercise('skull_crusher', 3, 12),
          ];
      }

      return ProgramDay(
        id: 'powerbuilding_d${index + 1}',
        dayNumber: index + 1,
        name: name,
        focus: focus,
        exercises: exercises,
        estimatedMinutes: 75,
      );
    });
  }

  // Athletic Performance Days
  static List<ProgramDay> _generateAthleticDays() {
    return List.generate(8 * 4, (index) {
      final dayType = index % 4;
      String name;
      String focus;
      List<WorkoutExercise> exercises;

      switch (dayType) {
        case 0:
          name = 'Lower Power';
          focus = 'Explosiveness';
          exercises = [
            _createWorkoutExercise('box_jump', 4, 8),
            _createWorkoutExercise('squat', 4, 6),
            _createWorkoutExercise('jump_squat', 3, 10),
            _createWorkoutExercise('single_leg_hop', 3, 8),
          ];
          break;
        case 1:
          name = 'Upper Power';
          focus = 'Explosiveness';
          exercises = [
            _createWorkoutExercise('medicine_ball_throw', 4, 10),
            _createWorkoutExercise('push_up', 4, 15),
            _createWorkoutExercise('plyo_push_up', 3, 10),
            _createWorkoutExercise('pull_up', 3, 10),
          ];
          break;
        case 2:
          name = 'Speed & Agility';
          focus = 'Conditioning';
          exercises = [
            _createWorkoutExercise('high_knees', 4, 30, isTime: true),
            _createWorkoutExercise('lateral_shuffle', 4, 30, isTime: true),
            _createWorkoutExercise('burpees', 3, 10),
            _createWorkoutExercise('mountain_climbers', 3, 45, isTime: true),
          ];
          break;
        default:
          name = 'Core & Stability';
          focus = 'Foundation';
          exercises = [
            _createWorkoutExercise('plank', 3, 60, isTime: true),
            _createWorkoutExercise('russian_twist', 3, 20),
            _createWorkoutExercise('bird_dog', 3, 12),
            _createWorkoutExercise('dead_bug', 3, 12),
          ];
      }

      return ProgramDay(
        id: 'athletic_d${index + 1}',
        dayNumber: index + 1,
        name: name,
        focus: focus,
        exercises: exercises,
        estimatedMinutes: 45,
      );
    });
  }

  // Functional Fitness Days
  static List<ProgramDay> _generateFunctionalDays() {
    return List.generate(6 * 4, (index) {
      final exercises = [
        _createWorkoutExercise('kettlebell_swing', 4, 15),
        _createWorkoutExercise('goblet_squat', 3, 12),
        _createWorkoutExercise('turkish_get_up', 3, 5),
        _createWorkoutExercise('farmers_walk', 3, 60, isTime: true),
        _createWorkoutExercise('plank', 3, 45, isTime: true),
      ];

      return ProgramDay(
        id: 'functional_d${index + 1}',
        dayNumber: index + 1,
        name: 'Functional Circuit',
        focus: 'Full Body',
        exercises: exercises,
        estimatedMinutes: 40,
      );
    });
  }

  // Quick 20-Minute Days
  static List<ProgramDay> _generateQuick20Days() {
    return List.generate(4 * 4, (index) {
      final exercises = [
        _createWorkoutExercise('jumping_jacks', 2, 30, isTime: true),
        _createWorkoutExercise('push_up', 3, 15),
        _createWorkoutExercise('squat', 3, 20),
        _createWorkoutExercise('plank', 2, 45, isTime: true),
        _createWorkoutExercise('burpees', 2, 10),
      ];

      return ProgramDay(
        id: 'quick20_d${index + 1}',
        dayNumber: index + 1,
        name: '20-Min Express',
        focus: 'Full Body',
        exercises: exercises,
        estimatedMinutes: 20,
      );
    });
  }

  // Lunch Break Days
  static List<ProgramDay> _generateLunchBreakDays() {
    return List.generate(4 * 5, (index) {
      final exercises = [
        _createWorkoutExercise('high_knees', 2, 30, isTime: true),
        _createWorkoutExercise('burpees', 2, 8),
        _createWorkoutExercise('mountain_climbers', 2, 30, isTime: true),
        _createWorkoutExercise('squat_jumps', 2, 10),
      ];

      return ProgramDay(
        id: 'lunch_d${index + 1}',
        dayNumber: index + 1,
        name: 'Lunch HIIT',
        focus: 'Quick Burn',
        exercises: exercises,
        estimatedMinutes: 15,
      );
    });
  }

  // Basketball Training Days
  static List<ProgramDay> _generateBasketballDays() {
    return List.generate(8 * 4, (index) {
      final dayType = index % 4;
      String name;
      List<WorkoutExercise> exercises;

      switch (dayType) {
        case 0:
          name = 'Vertical Jump';
          exercises = [
            _createWorkoutExercise('box_jump', 4, 8),
            _createWorkoutExercise('depth_jump', 3, 6),
            _createWorkoutExercise('squat', 4, 8),
            _createWorkoutExercise('calf_raises', 4, 15),
          ];
          break;
        case 1:
          name = 'Agility';
          exercises = [
            _createWorkoutExercise('lateral_shuffle', 4, 30, isTime: true),
            _createWorkoutExercise('high_knees', 4, 30, isTime: true),
            _createWorkoutExercise('defensive_slides', 3, 30, isTime: true),
            _createWorkoutExercise('jump_rope', 3, 60, isTime: true),
          ];
          break;
        case 2:
          name = 'Core & Stability';
          exercises = [
            _createWorkoutExercise('plank', 3, 60, isTime: true),
            _createWorkoutExercise('russian_twist', 3, 20),
            _createWorkoutExercise('medicine_ball_slam', 3, 12),
            _createWorkoutExercise('single_leg_balance', 3, 30, isTime: true),
          ];
          break;
        default:
          name = 'Upper Body';
          exercises = [
            _createWorkoutExercise('push_up', 3, 20),
            _createWorkoutExercise('pull_up', 3, 10),
            _createWorkoutExercise('dumbbell_shoulder_press', 3, 12),
            _createWorkoutExercise('resistance_band_rotation', 3, 15),
          ];
      }

      return ProgramDay(
        id: 'basketball_d${index + 1}',
        dayNumber: index + 1,
        name: name,
        focus: 'Basketball Performance',
        exercises: exercises,
        estimatedMinutes: 45,
      );
    });
  }

  // Swimmer Dryland Days
  static List<ProgramDay> _generateSwimmerDays() {
    return List.generate(8 * 3, (index) {
      final dayType = index % 3;
      String name;
      List<WorkoutExercise> exercises;

      switch (dayType) {
        case 0:
          name = 'Pull Strength';
          exercises = [
            _createWorkoutExercise('lat_pulldown', 4, 12),
            _createWorkoutExercise('pull_up', 3, 10),
            _createWorkoutExercise('resistance_band_pull', 3, 15),
            _createWorkoutExercise('face_pull', 3, 15),
          ];
          break;
        case 1:
          name = 'Core & Rotation';
          exercises = [
            _createWorkoutExercise('plank', 3, 60, isTime: true),
            _createWorkoutExercise('russian_twist', 3, 20),
            _createWorkoutExercise('medicine_ball_rotation', 3, 12),
            _createWorkoutExercise('flutter_kicks', 3, 30, isTime: true),
          ];
          break;
        default:
          name = 'Shoulder Stability';
          exercises = [
            _createWorkoutExercise('external_rotation', 3, 15),
            _createWorkoutExercise('internal_rotation', 3, 15),
            _createWorkoutExercise('dumbbell_lateral_raise', 3, 12),
            _createWorkoutExercise('prone_y_raise', 3, 12),
          ];
      }

      return ProgramDay(
        id: 'swimmer_d${index + 1}',
        dayNumber: index + 1,
        name: name,
        focus: 'Swimming Performance',
        exercises: exercises,
        estimatedMinutes: 35,
      );
    });
  }

  static WorkoutExercise _createWorkoutExercise(
    String exerciseId,
    int sets,
    int repsOrSeconds, {
    bool isTime = false,
  }) {
    // Try to find the exercise, or use a placeholder if not found
    var exerciseDef = ExerciseDatabase.getById(exerciseId);

    exerciseDef ??= ExerciseDefinition(
        id: exerciseId,
        name: exerciseId
            .split('_')
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
            .join(' '),
        description: 'Exercise description not found',
        primaryMuscles: [],
        secondaryMuscles: [],
        equipment: [],
        difficulty: Difficulty.beginner,
        category: ExerciseCategory.strength,
        instructions: [],
      );

    return WorkoutExercise(
      id: '${exerciseId}_${DateTime.now().microsecondsSinceEpoch}',
      exercise: exerciseDef,
      sets: List.generate(
        sets,
        (i) => ExerciseSet(
          setNumber: i + 1,
          reps: isTime ? null : repsOrSeconds,
          weight: 0,
          durationSeconds: isTime ? repsOrSeconds : null,
        ),
      ),
      targetSets: sets,
      targetReps: isTime ? 0 : repsOrSeconds,
      restSeconds: 60,
    );
  }
}
