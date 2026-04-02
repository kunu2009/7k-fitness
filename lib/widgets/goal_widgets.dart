import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../theme/app_theme.dart';

/// Circular progress ring widget
class ProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.progressColor,
    this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor ?? AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressColor ?? AppColors.primary,
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// Goal progress card widget
class GoalProgressCard extends StatelessWidget {
  final FitnessGoal goal;
  final VoidCallback? onTap;
  final VoidCallback? onLogProgress;

  const GoalProgressCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onLogProgress,
  });

  IconData get _goalIcon {
    switch (goal.type) {
      case GoalType.steps:
        return Icons.directions_walk;
      case GoalType.calories:
        return Icons.local_fire_department;
      case GoalType.water:
        return Icons.water_drop;
      case GoalType.weight:
      case GoalType.weightLoss:
      case GoalType.weightGain:
        return Icons.monitor_weight;
      case GoalType.workouts:
      case GoalType.workout:
        return Icons.fitness_center;
      case GoalType.activeMinutes:
        return Icons.timer;
      case GoalType.distance:
        return Icons.route;
      case GoalType.sleep:
        return Icons.bedtime;
      case GoalType.bodyFat:
        return Icons.percent;
      case GoalType.muscle:
      case GoalType.strength:
        return Icons.fitness_center;
      case GoalType.habit:
        return Icons.check_circle;
      case GoalType.custom:
        return Icons.flag;
    }
  }

  Color get _goalColor {
    switch (goal.type) {
      case GoalType.steps:
        return Colors.blue;
      case GoalType.calories:
        return Colors.orange;
      case GoalType.water:
        return Colors.cyan;
      case GoalType.weight:
      case GoalType.weightLoss:
      case GoalType.weightGain:
        return Colors.purple;
      case GoalType.workouts:
      case GoalType.workout:
        return AppColors.primary;
      case GoalType.activeMinutes:
        return Colors.green;
      case GoalType.distance:
        return Colors.teal;
      case GoalType.sleep:
        return Colors.indigo;
      case GoalType.bodyFat:
        return Colors.pink;
      case GoalType.muscle:
      case GoalType.strength:
        return Colors.red;
      case GoalType.habit:
        return Colors.amber;
      case GoalType.custom:
        return Colors.grey;
    }
  }

  String get _frequencyText {
    switch (goal.frequency) {
      case GoalFrequency.daily:
        return 'Daily';
      case GoalFrequency.weekly:
        return 'Weekly';
      case GoalFrequency.monthly:
        return 'Monthly';
      case GoalFrequency.total:
        return 'Total';
      case GoalFrequency.custom:
        return 'Custom';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: goal.isCompleted
              ? Border.all(color: Colors.green, width: 2)
              : null,
        ),
        child: Row(
          children: [
            ProgressRing(
              progress: goal.progress,
              size: 70,
              strokeWidth: 6,
              progressColor: goal.isCompleted ? Colors.green : _goalColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    goal.isCompleted ? Icons.check : _goalIcon,
                    color: goal.isCompleted ? Colors.green : _goalColor,
                    size: 24,
                  ),
                  Text(
                    '${(goal.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: goal.isCompleted ? Colors.green : _goalColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          goal.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _goalColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _frequencyText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _goalColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${goal.currentValue.toStringAsFixed(goal.currentValue.truncateToDouble() == goal.currentValue ? 0 : 1)} / ${goal.targetValue.toStringAsFixed(goal.targetValue.truncateToDouble() == goal.targetValue ? 0 : 1)} ${goal.unit}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (goal.description != null &&
                      goal.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      goal.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (!goal.isCompleted && goal.remainingDays != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      goal.remainingDays == 0
                          ? 'Ends today'
                          : '${goal.remainingDays} days remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: goal.remainingDays! <= 3
                            ? Colors.red
                            : AppColors.textSecondary,
                        fontWeight: goal.remainingDays! <= 3
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onLogProgress != null && !goal.isCompleted)
              IconButton(
                onPressed: onLogProgress,
                icon: Icon(Icons.add_circle, color: _goalColor),
              ),
          ],
        ),
      ),
    );
  }
}

/// Streak display widget
class StreakDisplay extends StatelessWidget {
  final Streak streak;
  final bool showLabel;

  const StreakDisplay({super.key, required this.streak, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    final isOnFire = streak.currentStreak >= 7;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isOnFire
            ? LinearGradient(colors: [Colors.orange, Colors.red.shade400])
            : null,
        color: isOnFire ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isOnFire ? null : Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isOnFire ? 'ðŸ”¥' : 'ðŸ“…', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${streak.currentStreak} day${streak.currentStreak == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isOnFire ? Colors.white : AppColors.textPrimary,
                ),
              ),
              if (showLabel)
                Text(
                  'Current streak',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnFire ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          if (streak.longestStreak > streak.currentStreak) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isOnFire
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ðŸ† ${streak.longestStreak}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isOnFire ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Streak calendar widget showing activity
class StreakCalendar extends StatelessWidget {
  final List<DateTime> activityDates;
  final DateTime? startDate;
  final int weeks;

  const StreakCalendar({
    super.key,
    required this.activityDates,
    this.startDate,
    this.weeks = 12,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = startDate ?? now.subtract(Duration(days: weeks * 7));

    // Generate all dates in range
    final dates = <DateTime>[];
    var current = start;
    while (current.isBefore(now) || current.isAtSameMomentAs(now)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    // Group by week
    final weekGroups = <List<DateTime?>>[];
    var currentWeek = <DateTime?>[];

    // Fill in empty days at start of first week
    final startWeekday = start.weekday;
    for (var i = 1; i < startWeekday; i++) {
      currentWeek.add(null);
    }

    for (final date in dates) {
      if (date.weekday == 1 && currentWeek.isNotEmpty) {
        weekGroups.add(currentWeek);
        currentWeek = [];
      }
      currentWeek.add(date);
    }

    // Fill in remaining days
    while (currentWeek.length < 7) {
      currentWeek.add(null);
    }
    weekGroups.add(currentWeek);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            SizedBox(
              width: 20,
              child: Text(
                'M',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
            SizedBox(
              width: 20,
              child: Text(
                'T',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
            SizedBox(
              width: 20,
              child: Text(
                'W',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
            SizedBox(
              width: 20,
              child: Text(
                'T',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
            SizedBox(
              width: 20,
              child: Text(
                'F',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
            SizedBox(
              width: 20,
              child: Text(
                'S',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
            SizedBox(
              width: 20,
              child: Text(
                'S',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: (weekGroups.length * 14.0) + 4,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: weekGroups.length,
            itemBuilder: (context, weekIndex) {
              return Row(
                children: weekGroups[weekIndex].map((date) {
                  if (date == null) {
                    return const SizedBox(width: 20, height: 14);
                  }

                  final hasActivity = activityDates.any(
                    (d) =>
                        d.year == date.year &&
                        d.month == date.month &&
                        d.day == date.day,
                  );

                  final isToday =
                      date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;

                  return Container(
                    width: 16,
                    height: 10,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: hasActivity
                          ? AppColors.primary
                          : AppColors.divider.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                      border: isToday
                          ? Border.all(color: AppColors.primary, width: 1)
                          : null,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Goals summary widget for home screen
class GoalsSummary extends StatelessWidget {
  final List<FitnessGoal> goals;
  final VoidCallback? onTap;

  const GoalsSummary({super.key, required this.goals, this.onTap});

  @override
  Widget build(BuildContext context) {
    final completedCount = goals.where((g) => g.isCompleted).length;
    final totalProgress = goals.isEmpty
        ? 0.0
        : goals.map((g) => g.progress).reduce((a, b) => a + b) / goals.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Today\'s Goals',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '$completedCount/${goals.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalProgress,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  completedCount == goals.length
                      ? Colors.green
                      : AppColors.primary,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: goals.take(5).map((goal) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: goal.isCompleted
                        ? Colors.green.withValues(alpha: 0.1)
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(12),
                    border: goal.isCompleted
                        ? Border.all(color: Colors.green.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        goal.isCompleted
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        size: 14,
                        color: goal.isCompleted
                            ? Colors.green
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        goal.title,
                        style: TextStyle(
                          fontSize: 12,
                          color: goal.isCompleted
                              ? Colors.green
                              : AppColors.textSecondary,
                          decoration: goal.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

