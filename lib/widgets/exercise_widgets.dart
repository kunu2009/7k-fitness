import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../theme/app_theme.dart';

/// Exercise card widget
class ExerciseCard extends StatelessWidget {
  final ExerciseDefinition exercise;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final bool showDetails;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.onAdd,
    this.showDetails = true,
  });

  Color get _difficultyColor {
    switch (exercise.difficulty) {
      case Difficulty.beginner:
        return Colors.green;
      case Difficulty.intermediate:
        return Colors.orange;
      case Difficulty.advanced:
        return Colors.red;
      case Difficulty.expert:
        return Colors.purple;
    }
  }

  IconData get _categoryIcon {
    switch (exercise.category) {
      case ExerciseCategory.strength:
        return Icons.fitness_center;
      case ExerciseCategory.cardio:
        return Icons.directions_run;
      case ExerciseCategory.flexibility:
        return Icons.self_improvement;
      case ExerciseCategory.balance:
        return Icons.accessibility_new;
      case ExerciseCategory.hiit:
        return Icons.flash_on;
      case ExerciseCategory.yoga:
        return Icons.self_improvement;
      case ExerciseCategory.pilates:
        return Icons.accessibility_new;
      case ExerciseCategory.plyometrics:
        return Icons.sports_gymnastics;
      case ExerciseCategory.calisthenics:
        return Icons.sports_martial_arts;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            // Exercise icon/image placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_categoryIcon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (showDetails) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            exercise.primaryMuscles
                                .map((m) => m.name)
                                .join(', '),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _difficultyColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            exercise.difficulty.name,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _difficultyColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.build,
                          size: 10,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            exercise.equipment.map((e) => e.name).join(', '),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onAdd != null)
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact exercise chip for selection
class ExerciseChip extends StatelessWidget {
  final ExerciseDefinition exercise;
  final bool isSelected;
  final VoidCallback? onTap;

  const ExerciseChip({
    super.key,
    required this.exercise,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.check, size: 16, color: Colors.white),
              ),
            Text(
              exercise.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Muscle group filter chips
class MuscleGroupFilter extends StatelessWidget {
  final List<MuscleGroup> selectedGroups;
  final ValueChanged<MuscleGroup> onToggle;

  const MuscleGroupFilter({
    super.key,
    required this.selectedGroups,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: MuscleGroup.values.map((group) {
          final isSelected = selectedGroups.contains(group);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                group.name
                    .replaceAllMapped(
                      RegExp(r'([A-Z])'),
                      (match) => ' ${match.group(0)}',
                    )
                    .trim(),
              ),
              selected: isSelected,
              onSelected: (_) => onToggle(group),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Equipment filter chips
class EquipmentFilter extends StatelessWidget {
  final List<Equipment> selectedEquipment;
  final ValueChanged<Equipment> onToggle;

  const EquipmentFilter({
    super.key,
    required this.selectedEquipment,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: Equipment.values.map((equipment) {
          final isSelected = selectedEquipment.contains(equipment);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                equipment.name
                    .replaceAllMapped(
                      RegExp(r'([A-Z])'),
                      (match) => ' ${match.group(0)}',
                    )
                    .trim(),
              ),
              selected: isSelected,
              onSelected: (_) => onToggle(equipment),
              selectedColor: AppColors.secondary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.secondary,
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? AppColors.secondary
                    : AppColors.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Exercise set input row
class ExerciseSetRow extends StatelessWidget {
  final int setNumber;
  final ExerciseSet? set;
  final bool isTimeBased;
  final ValueChanged<ExerciseSet> onChanged;
  final VoidCallback? onDelete;
  final bool isCompleted;

  const ExerciseSetRow({
    super.key,
    required this.setNumber,
    this.set,
    this.isTimeBased = false,
    required this.onChanged,
    this.onDelete,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          // Set number
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : AppColors.divider,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      '$setNumber',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Weight input
          if (!isTimeBased) ...[
            Expanded(
              child: _buildInput(
                label: 'Weight',
                value: set?.weight ?? 0,
                suffix: 'kg',
                onChanged: (value) {
                  onChanged(
                    ExerciseSet(
                      setNumber: setNumber,
                      reps: set?.reps ?? 0,
                      weight: value,
                      completedAt: set?.completedAt,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            // Reps input
            Expanded(
              child: _buildInput(
                label: 'Reps',
                value: (set?.reps ?? 0).toDouble(),
                suffix: '',
                onChanged: (value) {
                  onChanged(
                    ExerciseSet(
                      setNumber: setNumber,
                      reps: value.toInt(),
                      weight: set?.weight ?? 0,
                      completedAt: set?.completedAt,
                    ),
                  );
                },
              ),
            ),
          ],
          // Duration input for time-based exercises
          if (isTimeBased) ...[
            Expanded(
              child: _buildInput(
                label: 'Duration',
                value: (set?.durationSeconds ?? 0).toDouble(),
                suffix: 'sec',
                onChanged: (value) {
                  onChanged(
                    ExerciseSet(
                      setNumber: setNumber,
                      reps: 1,
                      durationSeconds: value.toInt(),
                      completedAt: set?.completedAt,
                    ),
                  );
                },
              ),
            ),
          ],
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required double value,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => onChanged((value - 1).clamp(0, 9999)),
              child: const Icon(
                Icons.remove_circle_outline,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: Text(
                suffix.isEmpty
                    ? value.toInt().toString()
                    : value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => onChanged(value + 1),
              child: const Icon(
                Icons.add_circle_outline,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        if (suffix.isNotEmpty)
          Text(
            suffix,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}

/// Exercise detail view
class ExerciseDetailCard extends StatelessWidget {
  final ExerciseDefinition exercise;

  const ExerciseDetailCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.category.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDifficultyBadge(),
                        const SizedBox(width: 8),
                        if (exercise.isCompound)
                          _buildBadge('Compound', Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Description
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            exercise.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Primary Muscles
          _buildMuscleSection(
            'Primary Muscles',
            exercise.primaryMuscles,
            AppColors.primary,
          ),

          // Secondary Muscles
          if (exercise.secondaryMuscles.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMuscleSection(
              'Secondary Muscles',
              exercise.secondaryMuscles,
              AppColors.secondary,
            ),
          ],

          // Equipment
          const SizedBox(height: 16),
          const Text(
            'Equipment',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: exercise.equipment.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.build,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      e.name
                          .replaceAllMapped(
                            RegExp(r'([A-Z])'),
                            (match) => ' ${match.group(0)}',
                          )
                          .trim(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          // Instructions
          if (exercise.instructions.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Instructions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...exercise.instructions.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Tips
          if (exercise.tips.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        'Tips',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (exercise.tips.isNotEmpty)
                    Text(
                      exercise.tips,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    Color color;
    switch (exercise.difficulty) {
      case Difficulty.beginner:
        color = Colors.green;
        break;
      case Difficulty.intermediate:
        color = Colors.orange;
        break;
      case Difficulty.advanced:
        color = Colors.red;
        break;
      case Difficulty.expert:
        color = Colors.purple;
        break;
    }
    return _buildBadge(exercise.difficulty.name, color);
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMuscleSection(
    String title,
    List<MuscleGroup> muscles,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: muscles.map((m) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                m.name
                    .replaceAllMapped(
                      RegExp(r'([A-Z])'),
                      (match) => ' ${match.group(0)}',
                    )
                    .trim(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
