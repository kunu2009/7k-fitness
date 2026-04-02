import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise.dart';
import '../../providers/fitness_provider.dart';
import '../../widgets/rest_timer.dart';
import '../exercises/exercises_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int _restTimerSeconds = 60;
  bool _showRestTimer = false;
  int _currentExerciseIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (context, provider, _) {
        final workout = provider.activeWorkout;

        if (workout == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Workout')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No active workout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.startWorkout();
                      setState(() {});
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Workout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final shouldExit = await _showExitConfirmation();
            if (!mounted || !shouldExit) return;
            Navigator.of(this.context).pop();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(workout.name),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () async {
                  final shouldExit = await _showExitConfirmation();
                  if (!mounted) return;
                  if (shouldExit) {
                    Navigator.of(this.context).pop();
                  }
                },
              ),
              actions: [
                // Timer display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      StreamBuilder(
                        stream: Stream.periodic(const Duration(seconds: 1)),
                        builder: (context, _) {
                          final d = DateTime.now().difference(
                            workout.startTime,
                          );
                          return Text(
                            '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                // Rest timer overlay
                if (_showRestTimer)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.background,
                    child: RestTimer(
                      seconds: _restTimerSeconds,
                      onComplete: () {
                        setState(() => _showRestTimer = false);
                      },
                      onSkip: () {
                        setState(() => _showRestTimer = false);
                      },
                    ),
                  ),

                // Exercise list
                Expanded(
                  child: workout.exercises.isEmpty
                      ? _buildEmptyExercises()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: workout.exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = workout.exercises[index];
                            final isActive = index == _currentExerciseIndex;

                            return _ExerciseWorkoutCard(
                              exercise: exercise,
                              isActive: isActive,
                              onTap: () {
                                setState(() => _currentExerciseIndex = index);
                              },
                              onSetCompleted: (setIndex) {
                                _onSetCompleted(provider, index, setIndex);
                              },
                              onAddSet: () {
                                _addSet(provider, index);
                              },
                              onRemoveExercise: () {
                                provider.removeExerciseFromWorkout(index);
                              },
                              onUpdateSet: (setIndex, set) {
                                _updateSet(provider, index, setIndex, set);
                              },
                            );
                          },
                        ),
                ),

                // Bottom action bar
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Rest timer selector
                        Row(
                          children: [
                            const Text(
                              'Rest Timer:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: RestTimerSelector(
                                  selectedSeconds: _restTimerSeconds,
                                  onChanged: (seconds) {
                                    setState(() => _restTimerSeconds = seconds);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _navigateToExercisePicker(context, provider);
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Exercise'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: workout.exercises.isEmpty
                                    ? null
                                    : () => _finishWorkout(context, provider),
                                icon: const Icon(Icons.check),
                                label: const Text('Finish'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyExercises() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No exercises yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add exercises to start your workout',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _navigateToExercisePicker(
                context,
                context.read<FitnessProvider>(),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
          ),
        ],
      ),
    );
  }

  void _navigateToExercisePicker(
    BuildContext context,
    FitnessProvider provider,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisesScreen(
          isSelectionMode: true,
          onExerciseSelected: (exercise) {
            provider.addExerciseToWorkout(
              WorkoutExercise(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                exercise: exercise,
                sets: [ExerciseSet(setNumber: 1, reps: 10, weight: 0)],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onSetCompleted(
    FitnessProvider provider,
    int exerciseIndex,
    int setIndex,
  ) {
    final exercise = provider.activeWorkout!.exercises[exerciseIndex];
    final sets = List<ExerciseSet>.from(exercise.sets);
    final isCurrentlyCompleted = sets[setIndex].completedAt != null;
    sets[setIndex] = sets[setIndex].copyWith(
      completedAt: isCurrentlyCompleted ? null : DateTime.now(),
    );

    provider.updateExerciseInWorkout(
      exerciseIndex,
      exercise.copyWith(sets: sets),
    );

    // Show rest timer if set was completed
    if (!isCurrentlyCompleted && !_showRestTimer) {
      setState(() => _showRestTimer = true);
    }
  }

  void _addSet(FitnessProvider provider, int exerciseIndex) {
    final exercise = provider.activeWorkout!.exercises[exerciseIndex];
    final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;

    final newSet = ExerciseSet(
      setNumber: exercise.sets.length + 1,
      reps: lastSet?.reps ?? 10,
      weight: lastSet?.weight ?? 0,
    );

    provider.updateExerciseInWorkout(
      exerciseIndex,
      exercise.copyWith(sets: [...exercise.sets, newSet]),
    );
  }

  void _updateSet(
    FitnessProvider provider,
    int exerciseIndex,
    int setIndex,
    ExerciseSet set,
  ) {
    final exercise = provider.activeWorkout!.exercises[exerciseIndex];
    final sets = List<ExerciseSet>.from(exercise.sets);
    sets[setIndex] = set;

    provider.updateExerciseInWorkout(
      exerciseIndex,
      exercise.copyWith(sets: sets),
    );
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Cancel Workout?'),
            content: const Text(
              'Are you sure you want to cancel this workout? Your progress will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Continue Workout'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<FitnessProvider>().cancelWorkout();
                  Navigator.pop(dialogContext, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancel Workout'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _finishWorkout(BuildContext context, FitnessProvider provider) {
    int rating = 4;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Finish Workout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was your workout?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() => rating = index + 1);
                    },
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add notes (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.completeWorkout(
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                  rating: rating,
                );
                Navigator.pop(context);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 Workout completed! Great job!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Complete'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseWorkoutCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final bool isActive;
  final VoidCallback onTap;
  final Function(int) onSetCompleted;
  final VoidCallback onAddSet;
  final VoidCallback onRemoveExercise;
  final Function(int, ExerciseSet) onUpdateSet;

  const _ExerciseWorkoutCard({
    required this.exercise,
    required this.isActive,
    required this.onTap,
    required this.onSetCompleted,
    required this.onAddSet,
    required this.onRemoveExercise,
    required this.onUpdateSet,
  });

  @override
  Widget build(BuildContext context) {
    final completedSets = exercise.sets
        .where((s) => s.completedAt != null)
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : null,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.exerciseName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '$completedSets / ${exercise.sets.length} sets',
                          style: TextStyle(
                            fontSize: 13,
                            color: completedSets == exercise.sets.length
                                ? Colors.green
                                : AppColors.textSecondary,
                            fontWeight: completedSets == exercise.sets.length
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.textSecondary,
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Remove'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'remove') {
                        onRemoveExercise();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Sets
          if (isActive) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header row
                  const Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          'Set',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Weight',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Reps',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Sets
                  ...exercise.sets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final set = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _SetRow(
                        set: set,
                        onCompleted: () => onSetCompleted(index),
                        onUpdate: (newSet) => onUpdateSet(index, newSet),
                      ),
                    );
                  }),

                  // Add set button
                  TextButton.icon(
                    onPressed: onAddSet,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Set'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final ExerciseSet set;
  final VoidCallback onCompleted;
  final Function(ExerciseSet) onUpdate;

  const _SetRow({
    required this.set,
    required this.onCompleted,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = set.completedAt != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withValues(alpha: 0.1)
            : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: isCompleted
            ? Border.all(color: Colors.green.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 32,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : AppColors.divider,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text(
                        '${set.setNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),

          // Weight
          Expanded(
            child: _ValueAdjuster(
              value: set.weight ?? 0,
              suffix: 'kg',
              onChanged: (value) {
                onUpdate(set.copyWith(weight: value));
              },
            ),
          ),

          // Reps
          Expanded(
            child: _ValueAdjuster(
              value: (set.reps ?? 0).toDouble(),
              suffix: '',
              onChanged: (value) {
                onUpdate(set.copyWith(reps: value.toInt()));
              },
            ),
          ),

          // Complete button
          SizedBox(
            width: 48,
            child: IconButton(
              onPressed: onCompleted,
              icon: Icon(
                isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                color: isCompleted ? Colors.green : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueAdjuster extends StatelessWidget {
  final double value;
  final String suffix;
  final Function(double) onChanged;

  const _ValueAdjuster({
    required this.value,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onChanged((value - 2.5).clamp(0, 999)),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.remove, size: 16, color: AppColors.textSecondary),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Show input dialog
            _showValueDialog(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              suffix.isEmpty
                  ? value.toInt().toString()
                  : value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(value + 2.5),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.add, size: 16, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  void _showValueDialog(BuildContext context) {
    final controller = TextEditingController(
      text: suffix.isEmpty ? value.toInt().toString() : value.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter ${suffix.isEmpty ? 'Reps' : 'Weight'}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            suffix: suffix.isNotEmpty ? Text(suffix) : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text);
              if (newValue != null) {
                onChanged(newValue);
              }
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
