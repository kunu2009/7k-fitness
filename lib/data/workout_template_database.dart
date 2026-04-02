/// Pre-built workout templates database
library;
import '../models/workout_template.dart';

class WorkoutTemplateDatabase {
  static final List<WorkoutTemplate> templates = [
    // STRENGTH TRAINING
    WorkoutTemplate(
      id: 'full_body_strength',
      name: 'Full Body Strength',
      description:
          'Complete full body workout targeting all major muscle groups',
      category: WorkoutCategory.strength,
      difficulty: DifficultyLevel.intermediate,
      estimatedDuration: const Duration(minutes: 45),
      estimatedCalories: 350,
      targetMuscles: ['Chest', 'Back', 'Shoulders', 'Legs', 'Core'],
      equipment: ['Barbell', 'Dumbbells', 'Bench'],
      exercises: [
        TemplateExercise(
          exerciseId: 'squat',
          exerciseName: 'Barbell Squat',
          sets: 4,
          reps: 8,
          restSeconds: 90,
          order: 1,
        ),
        TemplateExercise(
          exerciseId: 'bench_press',
          exerciseName: 'Bench Press',
          sets: 4,
          reps: 8,
          restSeconds: 90,
          order: 2,
        ),
        TemplateExercise(
          exerciseId: 'bent_over_row',
          exerciseName: 'Bent Over Row',
          sets: 4,
          reps: 10,
          restSeconds: 60,
          order: 3,
        ),
        TemplateExercise(
          exerciseId: 'overhead_press',
          exerciseName: 'Overhead Press',
          sets: 3,
          reps: 10,
          restSeconds: 60,
          order: 4,
        ),
        TemplateExercise(
          exerciseId: 'deadlift',
          exerciseName: 'Romanian Deadlift',
          sets: 3,
          reps: 10,
          restSeconds: 90,
          order: 5,
        ),
        TemplateExercise(
          exerciseId: 'plank',
          exerciseName: 'Plank',
          sets: 3,
          durationSeconds: 45,
          restSeconds: 30,
          order: 6,
        ),
      ],
    ),

    WorkoutTemplate(
      id: 'push_day',
      name: 'Push Day',
      description: 'Focus on chest, shoulders, and triceps',
      category: WorkoutCategory.strength,
      difficulty: DifficultyLevel.intermediate,
      estimatedDuration: const Duration(minutes: 50),
      estimatedCalories: 300,
      targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
      equipment: ['Barbell', 'Dumbbells', 'Cables'],
      exercises: [
        TemplateExercise(
          exerciseId: 'bench_press',
          exerciseName: 'Flat Bench Press',
          sets: 4,
          reps: 8,
          restSeconds: 90,
          order: 1,
        ),
        TemplateExercise(
          exerciseId: 'incline_press',
          exerciseName: 'Incline Dumbbell Press',
          sets: 3,
          reps: 10,
          restSeconds: 60,
          order: 2,
        ),
        TemplateExercise(
          exerciseId: 'ohp',
          exerciseName: 'Standing Overhead Press',
          sets: 4,
          reps: 8,
          restSeconds: 90,
          order: 3,
        ),
        TemplateExercise(
          exerciseId: 'lateral_raise',
          exerciseName: 'Lateral Raises',
          sets: 3,
          reps: 15,
          restSeconds: 45,
          order: 4,
        ),
        TemplateExercise(
          exerciseId: 'tricep_pushdown',
          exerciseName: 'Tricep Pushdown',
          sets: 3,
          reps: 12,
          restSeconds: 45,
          order: 5,
        ),
        TemplateExercise(
          exerciseId: 'dips',
          exerciseName: 'Dips',
          sets: 3,
          reps: 10,
          restSeconds: 60,
          order: 6,
        ),
      ],
    ),

    WorkoutTemplate(
      id: 'pull_day',
      name: 'Pull Day',
      description: 'Focus on back and biceps',
      category: WorkoutCategory.strength,
      difficulty: DifficultyLevel.intermediate,
      estimatedDuration: const Duration(minutes: 50),
      estimatedCalories: 280,
      targetMuscles: ['Back', 'Biceps', 'Rear Delts'],
      equipment: ['Pull-up Bar', 'Barbell', 'Cables'],
      exercises: [
        TemplateExercise(
          exerciseId: 'pull_ups',
          exerciseName: 'Pull-ups',
          sets: 4,
          reps: 8,
          restSeconds: 90,
          order: 1,
        ),
        TemplateExercise(
          exerciseId: 'barbell_row',
          exerciseName: 'Barbell Row',
          sets: 4,
          reps: 8,
          restSeconds: 90,
          order: 2,
        ),
        TemplateExercise(
          exerciseId: 'lat_pulldown',
          exerciseName: 'Lat Pulldown',
          sets: 3,
          reps: 12,
          restSeconds: 60,
          order: 3,
        ),
        TemplateExercise(
          exerciseId: 'face_pull',
          exerciseName: 'Face Pulls',
          sets: 3,
          reps: 15,
          restSeconds: 45,
          order: 4,
        ),
        TemplateExercise(
          exerciseId: 'barbell_curl',
          exerciseName: 'Barbell Curl',
          sets: 3,
          reps: 10,
          restSeconds: 60,
          order: 5,
        ),
        TemplateExercise(
          exerciseId: 'hammer_curl',
          exerciseName: 'Hammer Curls',
          sets: 3,
          reps: 12,
          restSeconds: 45,
          order: 6,
        ),
      ],
    ),

    WorkoutTemplate(
      id: 'leg_day',
      name: 'Leg Day',
      description: 'Complete lower body workout',
      category: WorkoutCategory.strength,
      difficulty: DifficultyLevel.intermediate,
      estimatedDuration: const Duration(minutes: 55),
      estimatedCalories: 400,
      targetMuscles: ['Quads', 'Hamstrings', 'Glutes', 'Calves'],
      equipment: ['Barbell', 'Leg Press', 'Dumbbells'],
      exercises: [
        TemplateExercise(
          exerciseId: 'squat',
          exerciseName: 'Back Squat',
          sets: 4,
          reps: 8,
          restSeconds: 120,
          order: 1,
        ),
        TemplateExercise(
          exerciseId: 'rdl',
          exerciseName: 'Romanian Deadlift',
          sets: 4,
          reps: 10,
          restSeconds: 90,
          order: 2,
        ),
        TemplateExercise(
          exerciseId: 'leg_press',
          exerciseName: 'Leg Press',
          sets: 3,
          reps: 12,
          restSeconds: 60,
          order: 3,
        ),
        TemplateExercise(
          exerciseId: 'walking_lunge',
          exerciseName: 'Walking Lunges',
          sets: 3,
          reps: 12,
          restSeconds: 60,
          order: 4,
        ),
        TemplateExercise(
          exerciseId: 'leg_curl',
          exerciseName: 'Leg Curl',
          sets: 3,
          reps: 12,
          restSeconds: 45,
          order: 5,
        ),
        TemplateExercise(
          exerciseId: 'calf_raise',
          exerciseName: 'Standing Calf Raise',
          sets: 4,
          reps: 15,
          restSeconds: 45,
          order: 6,
        ),
      ],
    ),

    // HIIT WORKOUTS
    WorkoutTemplate(
      id: 'hiit_beginner',
      name: 'HIIT Starter',
      description: 'Beginner-friendly high intensity interval training',
      category: WorkoutCategory.hiit,
      difficulty: DifficultyLevel.beginner,
      estimatedDuration: const Duration(minutes: 20),
      estimatedCalories: 250,
      targetMuscles: ['Full Body'],
      equipment: ['None'],
      exercises: [
        TemplateExercise(
          exerciseId: 'jumping_jacks',
          exerciseName: 'Jumping Jacks',
          sets: 3,
          durationSeconds: 30,
          restSeconds: 30,
          order: 1,
        ),
        TemplateExercise(
          exerciseId: 'high_knees',
          exerciseName: 'High Knees',
          sets: 3,
          durationSeconds: 30,
          restSeconds: 30,
          order: 2,
        ),
        TemplateExercise(
          exerciseId: 'squats',
          exerciseName: 'Bodyweight Squats',
          sets: 3,
          durationSeconds: 30,
          restSeconds: 30,
          order: 3,
        ),
        TemplateExercise(
          exerciseId: 'mountain_climbers',
          exerciseName: 'Mountain Climbers',
          sets: 3,
          durationSeconds: 30,
          restSeconds: 30,
          order: 4,
        ),
        TemplateExercise(
          exerciseId: 'push_ups',
          exerciseName: 'Push-ups',
          sets: 3,
          durationSeconds: 30,
          restSeconds: 30,
          order: 5,
        ),
        TemplateExercise(
          exerciseId: 'burpees',
          exerciseName: 'Burpees',
          sets: 3,
          durationSeconds: 20,
          restSeconds: 40,
          order: 6,
        ),
      ],
    ),

    WorkoutTemplate(
      id: 'hiit_advanced',
      name: 'HIIT Burn',
      description: 'Advanced fat-burning HIIT circuit',
      category: WorkoutCategory.hiit,
      difficulty: DifficultyLevel.advanced,
      estimatedDuration: const Duration(minutes: 30),
      estimatedCalories: 400,
      targetMuscles: ['Full Body'],
      equipment: ['None'],
      exercises: [
        TemplateExercise(
          exerciseId: 'burpees',
          exerciseName: 'Burpees',
          sets: 4,
          durationSeconds: 45,
          restSeconds: 15,
          order: 1,
        ),
        TemplateExercise(
          exerciseId: 'jump_squats',
          exerciseName: 'Jump Squats',
          sets: 4,
          durationSeconds: 45,
          restSeconds: 15,
          order: 2,
        ),
        TemplateExercise(
          exerciseId: 'plyo_push_ups',
          exerciseName: 'Plyo Push-ups',
          sets: 4,
          durationSeconds: 45,
          restSeconds: 15,
          order: 3,
        ),
        TemplateExercise(
          exerciseId: 'box_jumps',
          exerciseName: 'Tuck Jumps',
          sets: 4,
          durationSeconds: 45,
          restSeconds: 15,
          order: 4,
        ),
        TemplateExercise(
          exerciseId: 'mountain_climbers',
          exerciseName: 'Mountain Climbers',
          sets: 4,
          durationSeconds: 45,
          restSeconds: 15,
          order: 5,
        ),
        TemplateExercise(
          exerciseId: 'v_ups',
          exerciseName: 'V-Ups',
          sets: 4,
          durationSeconds: 45,
          restSeconds: 15,
          order: 6,
        ),
      ],
    ),

    // CARDIO
    WorkoutTemplate(
      id: 'cardio_blast',
      name: 'Cardio Blast',
      description: 'Heart-pumping cardio session',
      category: WorkoutCategory.cardio,
      difficulty: DifficultyLevel.intermediate,
      estimatedDuration: const Duration(minutes: 30),
      estimatedCalories: 350,
      targetMuscles: ['Full Body', 'Core'],
      equipment: ['None'],
      exercises: [
        TemplateExercise(
          exerciseId: 'warm_up_jog',
          exerciseName: 'Light Jog',
          sets: 1,
          durationSeconds: 180,
          restSeconds: 0,
          order: 1,
        ),
        TemplateExercise(
          exerciseId: 'jumping_jacks',
          exerciseName: 'Jumping Jacks',
          sets: 3,
          durationSeconds: 60,
          restSeconds: 30,
          order: 2,
        ),
        TemplateExercise(
          exerciseId: 'high_knees',
          exerciseName: 'High Knees',
          sets: 3,
          durationSeconds: 45,
          restSeconds: 30,
          order: 3,
        ),
        TemplateExercise(
          exerciseId: 'butt_kicks',
          exerciseName: 'Butt Kicks',
          sets: 3,
          durationSeconds: 45,
          restSeconds: 30,
          order: 4,
        ),
        TemplateExercise(
          exerciseId: 'skaters',
          exerciseName: 'Skaters',
          sets: 3,
          durationSeconds: 45,
          restSeconds: 30,
          order: 5,
        ),
        TemplateExercise(
          exerciseId: 'jump_rope',
          exerciseName: 'Imaginary Jump Rope',
          sets: 3,
          durationSeconds: 60,
          restSeconds: 30,
          order: 6,
        ),
      ],
    ),

    // BODYWEIGHT
    WorkoutTemplate(
      id: 'bodyweight_basics',
      name: 'Bodyweight Basics',
      description: 'No equipment needed full body workout',
      category: WorkoutCategory.bodyweight,
      difficulty: DifficultyLevel.beginner,
      estimatedDuration: const Duration(minutes: 25),
      estimatedCalories: 200,
      targetMuscles: ['Full Body'],
      equipment: ['None'],
      exercises: [
        TemplateExercise(
          exerciseId: 'push_ups',
          exerciseName: 'Push-ups',
          sets: 3,
          reps: 10,
          restSeconds: 45,
          order: 1,
        ),
        TemplateExercise(
          exerciseId: 'squats',
          exerciseName: 'Bodyweight Squats',
          sets: 3,
          reps: 15,
          restSeconds: 45,
          order: 2,
        ),
        TemplateExercise(
          exerciseId: 'lunges',
          exerciseName: 'Alternating Lunges',
          sets: 3,
          reps: 12,
          restSeconds: 45,
          order: 3,
        ),
        TemplateExercise(
          exerciseId: 'plank',
          exerciseName: 'Plank',
          sets: 3,
          durationSeconds: 30,
          restSeconds: 30,
          order: 4,
        ),
        TemplateExercise(
          exerciseId: 'glute_bridge',
          exerciseName: 'Glute Bridge',
          sets: 3,
          reps: 15,
          restSeconds: 30,
          order: 5,
        ),
        TemplateExercise(
          exerciseId: 'superman',
          exerciseName: 'Superman',
          sets: 3,
          reps: 12,
          restSeconds: 30,
          order: 6,
        ),
      ],
    ),

    WorkoutTemplate(
      id: 'calisthenics_intermediate',
      name: 'Calisthenics Challenge',
      description: 'Intermediate bodyweight training',
      category: WorkoutCategory.bodyweight,
      difficulty: DifficultyLevel.intermediate,
      estimatedDuration: const Duration(minutes: 40),
      estimatedCalories: 300,
      targetMuscles: ['Chest', 'Back', 'Core', 'Legs'],
      equipment: ['Pull-up Bar'],
      exercises: [
        TemplateExercise(
          exerciseId: 'pull_ups',
          exerciseName: 'Pull-ups',
          sets: 4,
          reps: 8,
          restSeconds: 90,
          order: 1,
        ),
        TemplateExercise(
          exerciseId: 'dips',
          exerciseName: 'Dips',
          sets: 4,
          reps: 10,
          restSeconds: 60,
          order: 2,
        ),
        TemplateExercise(
          exerciseId: 'pike_push_ups',
          exerciseName: 'Pike Push-ups',
          sets: 3,
          reps: 12,
          restSeconds: 60,
          order: 3,
        ),
        TemplateExercise(
          exerciseId: 'pistol_squat',
          exerciseName: 'Assisted Pistol Squat',
          sets: 3,
          reps: 6,
          restSeconds: 60,
          order: 4,
        ),
        TemplateExercise(
          exerciseId: 'leg_raises',
          exerciseName: 'Hanging Leg Raises',
          sets: 3,
          reps: 10,
          restSeconds: 45,
          order: 5,
        ),
        TemplateExercise(
          exerciseId: 'hollow_body',
          exerciseName: 'Hollow Body Hold',
          sets: 3,
          durationSeconds: 30,
          restSeconds: 30,
          order: 6,
        ),
      ],
    ),

    // FLEXIBILITY & YOGA
    WorkoutTemplate(
      id: 'morning_stretch',
      name: 'Morning Stretch',
      description: 'Gentle morning stretching routine',
      category: WorkoutCategory.flexibility,
      difficulty: DifficultyLevel.beginner,
      estimatedDuration: const Duration(minutes: 15),
      estimatedCalories: 50,
      targetMuscles: ['Full Body'],
      equipment: ['Yoga Mat'],
      exercises: [
        TemplateExercise(
          exerciseId: 'neck_stretch',
          exerciseName: 'Neck Rolls',
          sets: 1,
          durationSeconds: 60,
          restSeconds: 0,
          order: 1,
        ),
        TemplateExercise(
          exerciseId: 'cat_cow',
          exerciseName: 'Cat-Cow Stretch',
          sets: 1,
          durationSeconds: 90,
          restSeconds: 0,
          order: 2,
        ),
        TemplateExercise(
          exerciseId: 'child_pose',
          exerciseName: 'Child\'s Pose',
          sets: 1,
          durationSeconds: 60,
          restSeconds: 0,
          order: 3,
        ),
        TemplateExercise(
          exerciseId: 'downward_dog',
          exerciseName: 'Downward Dog',
          sets: 1,
          durationSeconds: 60,
          restSeconds: 0,
          order: 4,
        ),
        TemplateExercise(
          exerciseId: 'hip_flexor',
          exerciseName: 'Hip Flexor Stretch',
          sets: 2,
          durationSeconds: 45,
          restSeconds: 0,
          order: 5,
        ),
        TemplateExercise(
          exerciseId: 'hamstring',
          exerciseName: 'Seated Hamstring Stretch',
          sets: 2,
          durationSeconds: 45,
          restSeconds: 0,
          order: 6,
        ),
      ],
    ),

    WorkoutTemplate(
      id: 'yoga_flow',
      name: 'Yoga Flow',
      description: 'Relaxing yoga sequence for flexibility and mindfulness',
      category: WorkoutCategory.yoga,
      difficulty: DifficultyLevel.intermediate,
      estimatedDuration: const Duration(minutes: 30),
      estimatedCalories: 100,
      targetMuscles: ['Full Body', 'Core'],
      equipment: ['Yoga Mat'],
      exercises: [
        TemplateExercise(
          exerciseId: 'sun_salutation',
          exerciseName: 'Sun Salutation A',
          sets: 3,
          durationSeconds: 120,
          restSeconds: 0,
          order: 1,
        ),
        TemplateExercise(
          exerciseId: 'warrior_1',
          exerciseName: 'Warrior I',
          sets: 2,
          durationSeconds: 45,
          restSeconds: 0,
          order: 2,
        ),
        TemplateExercise(
          exerciseId: 'warrior_2',
          exerciseName: 'Warrior II',
          sets: 2,
          durationSeconds: 45,
          restSeconds: 0,
          order: 3,
        ),
        TemplateExercise(
          exerciseId: 'triangle',
          exerciseName: 'Triangle Pose',
          sets: 2,
          durationSeconds: 45,
          restSeconds: 0,
          order: 4,
        ),
        TemplateExercise(
          exerciseId: 'tree',
          exerciseName: 'Tree Pose',
          sets: 2,
          durationSeconds: 45,
          restSeconds: 0,
          order: 5,
        ),
        TemplateExercise(
          exerciseId: 'savasana',
          exerciseName: 'Savasana',
          sets: 1,
          durationSeconds: 180,
          restSeconds: 0,
          order: 6,
        ),
      ],
    ),

    // RECOVERY
    WorkoutTemplate(
      id: 'active_recovery',
      name: 'Active Recovery',
      description: 'Light movement for rest days',
      category: WorkoutCategory.recovery,
      difficulty: DifficultyLevel.beginner,
      estimatedDuration: const Duration(minutes: 20),
      estimatedCalories: 80,
      targetMuscles: ['Full Body'],
      equipment: ['Foam Roller', 'Yoga Mat'],
      exercises: [
        TemplateExercise(
          exerciseId: 'foam_roll_back',
          exerciseName: 'Foam Roll Upper Back',
          sets: 1,
          durationSeconds: 60,
          restSeconds: 0,
          order: 1,
        ),
        TemplateExercise(
          exerciseId: 'foam_roll_quads',
          exerciseName: 'Foam Roll Quads',
          sets: 1,
          durationSeconds: 60,
          restSeconds: 0,
          order: 2,
        ),
        TemplateExercise(
          exerciseId: 'foam_roll_it',
          exerciseName: 'Foam Roll IT Band',
          sets: 1,
          durationSeconds: 60,
          restSeconds: 0,
          order: 3,
        ),
        TemplateExercise(
          exerciseId: 'pigeon_pose',
          exerciseName: 'Pigeon Pose',
          sets: 2,
          durationSeconds: 60,
          restSeconds: 0,
          order: 4,
        ),
        TemplateExercise(
          exerciseId: 'figure_4',
          exerciseName: 'Figure 4 Stretch',
          sets: 2,
          durationSeconds: 45,
          restSeconds: 0,
          order: 5,
        ),
        TemplateExercise(
          exerciseId: 'spinal_twist',
          exerciseName: 'Supine Spinal Twist',
          sets: 2,
          durationSeconds: 45,
          restSeconds: 0,
          order: 6,
        ),
      ],
    ),

    // POWERLIFTING
    WorkoutTemplate(
      id: 'powerlifting_squat',
      name: 'Squat Focus',
      description: 'Heavy squat day for strength',
      category: WorkoutCategory.powerlifting,
      difficulty: DifficultyLevel.advanced,
      estimatedDuration: const Duration(minutes: 60),
      estimatedCalories: 350,
      targetMuscles: ['Quads', 'Glutes', 'Core'],
      equipment: ['Barbell', 'Squat Rack', 'Belt'],
      exercises: [
        TemplateExercise(
          exerciseId: 'squat_warm',
          exerciseName: 'Squat Warm-up Sets',
          sets: 3,
          reps: 5,
          restSeconds: 60,
          order: 1,
        ),
        TemplateExercise(
          exerciseId: 'squat_work',
          exerciseName: 'Back Squat (Working)',
          sets: 5,
          reps: 5,
          restSeconds: 180,
          order: 2,
        ),
        TemplateExercise(
          exerciseId: 'pause_squat',
          exerciseName: 'Pause Squat',
          sets: 3,
          reps: 3,
          restSeconds: 120,
          order: 3,
        ),
        TemplateExercise(
          exerciseId: 'front_squat',
          exerciseName: 'Front Squat',
          sets: 3,
          reps: 6,
          restSeconds: 90,
          order: 4,
        ),
        TemplateExercise(
          exerciseId: 'leg_press',
          exerciseName: 'Leg Press',
          sets: 3,
          reps: 10,
          restSeconds: 60,
          order: 5,
        ),
        TemplateExercise(
          exerciseId: 'ab_wheel',
          exerciseName: 'Ab Wheel Rollout',
          sets: 3,
          reps: 10,
          restSeconds: 60,
          order: 6,
        ),
      ],
    ),

    // ENDURANCE
    WorkoutTemplate(
      id: 'endurance_circuit',
      name: 'Endurance Builder',
      description: 'Build muscular endurance',
      category: WorkoutCategory.endurance,
      difficulty: DifficultyLevel.intermediate,
      estimatedDuration: const Duration(minutes: 40),
      estimatedCalories: 320,
      targetMuscles: ['Full Body'],
      equipment: ['Dumbbells', 'Kettlebell'],
      exercises: [
        TemplateExercise(
          exerciseId: 'goblet_squat',
          exerciseName: 'Goblet Squat',
          sets: 4,
          reps: 20,
          restSeconds: 30,
          order: 1,
        ),
        TemplateExercise(
          exerciseId: 'push_ups',
          exerciseName: 'Push-ups',
          sets: 4,
          reps: 20,
          restSeconds: 30,
          order: 2,
        ),
        TemplateExercise(
          exerciseId: 'kb_swing',
          exerciseName: 'Kettlebell Swings',
          sets: 4,
          reps: 20,
          restSeconds: 30,
          order: 3,
        ),
        TemplateExercise(
          exerciseId: 'db_row',
          exerciseName: 'Dumbbell Row',
          sets: 4,
          reps: 15,
          restSeconds: 30,
          order: 4,
        ),
        TemplateExercise(
          exerciseId: 'lunges',
          exerciseName: 'Walking Lunges',
          sets: 4,
          reps: 20,
          restSeconds: 30,
          order: 5,
        ),
        TemplateExercise(
          exerciseId: 'plank',
          exerciseName: 'Plank',
          sets: 4,
          durationSeconds: 45,
          restSeconds: 15,
          order: 6,
        ),
      ],
    ),
  ];

  /// Get templates by category
  static List<WorkoutTemplate> getByCategory(WorkoutCategory category) {
    return templates.where((t) => t.category == category).toList();
  }

  /// Get templates by difficulty
  static List<WorkoutTemplate> getByDifficulty(DifficultyLevel difficulty) {
    return templates.where((t) => t.difficulty == difficulty).toList();
  }

  /// Get templates by equipment (returns templates that can be done with given equipment)
  static List<WorkoutTemplate> getByEquipment(List<String> availableEquipment) {
    return templates.where((t) {
      // If template requires no equipment, always include
      if (t.equipment.isEmpty || t.equipment.contains('None')) return true;
      // Otherwise, check if all required equipment is available
      return t.equipment.every((e) => availableEquipment.contains(e));
    }).toList();
  }

  /// Get templates by duration (within specified minutes)
  static List<WorkoutTemplate> getByDuration(int maxMinutes) {
    return templates
        .where((t) => t.estimatedDuration.inMinutes <= maxMinutes)
        .toList();
  }

  /// Search templates by name or description
  static List<WorkoutTemplate> search(String query) {
    final lowercaseQuery = query.toLowerCase();
    return templates
        .where(
          (t) =>
              t.name.toLowerCase().contains(lowercaseQuery) ||
              t.description.toLowerCase().contains(lowercaseQuery) ||
              t.targetMuscles.any(
                (m) => m.toLowerCase().contains(lowercaseQuery),
              ),
        )
        .toList();
  }

  /// Get featured/popular templates
  static List<WorkoutTemplate> getFeatured() {
    return [
      templates.firstWhere((t) => t.id == 'full_body_strength'),
      templates.firstWhere((t) => t.id == 'hiit_beginner'),
      templates.firstWhere((t) => t.id == 'bodyweight_basics'),
      templates.firstWhere((t) => t.id == 'yoga_flow'),
    ];
  }
}
