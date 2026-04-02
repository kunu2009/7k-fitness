import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise.dart';
import '../../widgets/exercise_widgets.dart';
import '../../providers/fitness_provider.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final ExerciseDefinition exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final text = _buildShareText(exercise);
              await Clipboard.setData(ClipboardData(text: text));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exercise details copied to clipboard.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ExerciseDetailCard(exercise: exercise),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              final provider = context.read<FitnessProvider>();
              if (!provider.hasActiveWorkout) {
                provider.startWorkout(name: 'Quick Workout');
              }

              provider.addExerciseToWorkout(
                WorkoutExercise(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  exercise: exercise,
                  sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 0)],
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${exercise.name} added to workout'),
                  action: SnackBarAction(
                    label: 'View Workout',
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Add to Workout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  String _buildShareText(ExerciseDefinition exercise) {
    final primaryMuscles = exercise.primaryMuscles
        .map((m) => m.name)
        .join(', ');
    final equipment = exercise.equipment.map((e) => e.name).join(', ');

    return 'Exercise: ${exercise.name}\n'
        'Category: ${exercise.category.name}\n'
        'Difficulty: ${exercise.difficulty.name}\n'
        'Primary Muscles: $primaryMuscles\n'
        'Equipment: $equipment\n\n'
        '${exercise.description}';
  }
}
