import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/fitness_provider.dart';
import '../providers/water_provider.dart';
import '../providers/nutrition_provider.dart';
import '../providers/step_provider.dart';
import '../providers/sleep_provider.dart';
import '../services/settings_service.dart';

/// Quick Actions Widget for the dashboard
class QuickActionsWidget extends StatelessWidget {
  final VoidCallback? onAddWater;
  final VoidCallback? onLogMeal;
  final VoidCallback? onStartWorkout;
  final VoidCallback? onLogWeight;

  const QuickActionsWidget({
    super.key,
    this.onAddWater,
    this.onLogMeal,
    this.onStartWorkout,
    this.onLogWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickAction(
                icon: Icons.water_drop,
                label: '+Water',
                color: Colors.cyan,
                onTap: onAddWater,
              ),
              _buildQuickAction(
                icon: Icons.restaurant,
                label: 'Meal',
                color: Colors.green,
                onTap: onLogMeal,
              ),
              _buildQuickAction(
                icon: Icons.fitness_center,
                label: 'Workout',
                color: AppColors.primary,
                onTap: onStartWorkout,
              ),
              _buildQuickAction(
                icon: Icons.monitor_weight,
                label: 'Weight',
                color: Colors.purple,
                onTap: onLogWeight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Today's Summary Widget
class TodaySummaryWidget extends StatelessWidget {
  const TodaySummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (context, provider, _) {
        final todayData = provider.todayData;
        final userProfile = provider.userProfile;

        final caloriesGoal = userProfile?.dailyCalorieGoal ?? 2000;
        final stepsGoal = 10000;
        final waterGoal = 8;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.secondary.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Summary",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getFormattedDate(),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      icon: Icons.local_fire_department,
                      label: 'Calories',
                      value: '${todayData?.calories.toInt() ?? 0}',
                      target: caloriesGoal.toInt().toString(),
                      progress: (todayData?.calories ?? 0) / caloriesGoal,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryItem(
                      icon: Icons.directions_walk,
                      label: 'Steps',
                      value: '${todayData?.steps ?? 0}',
                      target: stepsGoal.toString(),
                      progress: (todayData?.steps ?? 0) / stepsGoal,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      icon: Icons.water_drop,
                      label: 'Water',
                      value: '${todayData?.waterGlasses ?? 0}',
                      target: waterGoal.toString(),
                      progress: (todayData?.waterGlasses ?? 0) / waterGoal,
                      color: Colors.cyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildWorkoutStatus(provider)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required String target,
    required double progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$value / $target',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStatus(FitnessProvider provider) {
    final hasWorkedOut = provider.workoutStreak.isActiveToday;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasWorkedOut ? Icons.check_circle : Icons.fitness_center,
                color: hasWorkedOut ? Colors.green : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Workout',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasWorkedOut ? 'Completed!' : 'Not yet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: hasWorkedOut ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: hasWorkedOut ? 1.0 : 0.0,
              backgroundColor: Colors.green.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

/// Motivation Quote Widget
class MotivationQuoteWidget extends StatelessWidget {
  const MotivationQuoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final quote = _getDailyQuote();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.1),
            Colors.deepPurple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('💪', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote['text']!,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '— ${quote['author']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getDailyQuote() {
    final quotes = [
      {
        'text': "The only bad workout is the one that didn't happen.",
        'author': 'Unknown',
      },
      {
        'text':
            "Success is not final, failure is not fatal: it is the courage to continue that counts.",
        'author': 'Winston Churchill',
      },
      {
        'text':
            "Your body can stand almost anything. It's your mind you have to convince.",
        'author': 'Unknown',
      },
      {
        'text':
            "The pain you feel today will be the strength you feel tomorrow.",
        'author': 'Arnold Schwarzenegger',
      },
      {'text': "Don't wish for it. Work for it.", 'author': 'Unknown'},
      {
        'text':
            "Fitness is not about being better than someone else. It's about being better than you used to be.",
        'author': 'Khloe Kardashian',
      },
      {
        'text': "The body achieves what the mind believes.",
        'author': 'Napoleon Hill',
      },
      {
        'text':
            "No matter how slow you go, you are still lapping everybody on the couch.",
        'author': 'Unknown',
      },
      {
        'text': "Strength does not come from the body. It comes from the will.",
        'author': 'Unknown',
      },
      {
        'text': "The only way to define your limits is by going beyond them.",
        'author': 'Arthur Clarke',
      },
      {
        'text': "Wake up with determination. Go to bed with satisfaction.",
        'author': 'Unknown',
      },
      {
        'text': "The hard days are what make you stronger.",
        'author': 'Aly Raisman',
      },
      {
        'text': "Exercise is a celebration of what your body can do.",
        'author': 'Unknown',
      },
      {'text': "Sweat is just fat crying.", 'author': 'Unknown'},
      {
        'text':
            "You don't have to be great to start, but you have to start to be great.",
        'author': 'Zig Ziglar',
      },
      {
        'text':
            "The only person you are destined to become is the person you decide to be.",
        'author': 'Ralph Waldo Emerson',
      },
      {
        'text': "Believe you can and you're halfway there.",
        'author': 'Theodore Roosevelt',
      },
      {
        'text': "It never gets easier. You just get better.",
        'author': 'Unknown',
      },
      {
        'text': "Your health is an investment, not an expense.",
        'author': 'Unknown',
      },
      {
        'text': "Every champion was once a contender that refused to give up.",
        'author': 'Rocky Balboa',
      },
      {
        'text': "The difference between try and triumph is just a little umph!",
        'author': 'Marvin Phillips',
      },
      {
        'text':
            "Make yourself a priority once in a while. It's not selfish, it's necessary.",
        'author': 'Unknown',
      },
      {'text': "Progress, not perfection.", 'author': 'Unknown'},
      {'text': "You are stronger than you think.", 'author': 'Unknown'},
      {
        'text': "Fall seven times, stand up eight.",
        'author': 'Japanese Proverb',
      },
      {'text': "Today's pain is tomorrow's power.", 'author': 'Unknown'},
      {
        'text': "Champions keep playing until they get it right.",
        'author': 'Billie Jean King',
      },
      {
        'text': "The secret of getting ahead is getting started.",
        'author': 'Mark Twain',
      },
      {
        'text': "Push yourself because no one else is going to do it for you.",
        'author': 'Unknown',
      },
      {
        'text': "Great things never come from comfort zones.",
        'author': 'Unknown',
      },
    ];

    // Use day of year to pick a quote
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    return quotes[dayOfYear % quotes.length];
  }
}

/// Provider-backed "Today" dashboard section.
///
/// Shows a simple checklist + quick actions wired to real providers.
class TodayDashboardSection extends StatelessWidget {
  final VoidCallback onOpenWorkout;
  final VoidCallback onOpenWater;
  final VoidCallback onOpenNutrition;
  final VoidCallback onOpenSteps;
  final VoidCallback onOpenSleep;
  final VoidCallback onQuickAddWater;
  final VoidCallback onQuickLogMeal;
  final VoidCallback onQuickLogWeight;

  const TodayDashboardSection({
    super.key,
    required this.onOpenWorkout,
    required this.onOpenWater,
    required this.onOpenNutrition,
    required this.onOpenSteps,
    required this.onOpenSleep,
    required this.onQuickAddWater,
    required this.onQuickLogMeal,
    required this.onQuickLogWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer5<
      FitnessProvider,
      WaterProvider,
      NutritionProvider,
      StepProvider,
      SleepProvider
    >(
      builder: (context, fitness, water, nutrition, steps, sleep, _) {
        final settings = context.watch<SettingsService>();

        final hasWorkout = fitness.workoutStreak.isActiveToday;
        final waterProgress = water.dailyGoal > 0
            ? (water.dailyIntake / water.dailyGoal).clamp(0.0, 1.0)
            : 0.0;
        final nutritionProgress = nutrition.calorieGoal > 0
            ? (nutrition.todaySummary.calories / nutrition.calorieGoal).clamp(
                0.0,
                1.5,
              )
            : 0.0;
        final stepsProgress = steps.dailyGoal > 0
            ? (steps.todaySteps / steps.dailyGoal).clamp(0.0, 1.0)
            : 0.0;
        final lastNight = sleep.getSleepForDate(DateTime.now());
        final sleepProgress = sleep.sleepGoalHours > 0
            ? (((lastNight?.duration.inMinutes ?? 0) / 60) /
                      sleep.sleepGoalHours)
                  .clamp(0.0, 1.0)
            : 0.0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '${_weekdayShort(DateTime.now())} · ${DateTime.now().day}/${DateTime.now().month}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ChecklistRow(
                title: 'Workout',
                subtitle: hasWorkout
                    ? 'Completed'
                    : (fitness.hasActiveWorkout ? 'In progress' : 'Start'),
                progress: hasWorkout
                    ? 1.0
                    : (fitness.hasActiveWorkout ? 0.6 : 0.0),
                icon: Icons.fitness_center,
                color: AppColors.primary,
                completed: hasWorkout,
                onTap: onOpenWorkout,
              ),
              const SizedBox(height: 10),
              _ChecklistRow(
                title: 'Water',
                subtitle:
                    '${water.dailyIntake.toInt()} / ${water.dailyGoal.toInt()} ml',
                progress: waterProgress,
                icon: Icons.water_drop,
                color: Colors.cyan,
                completed: water.goalReached,
                onTap: onOpenWater,
              ),
              const SizedBox(height: 10),
              _ChecklistRow(
                title: 'Nutrition',
                subtitle:
                    '${nutrition.todaySummary.calories} / ${nutrition.calorieGoal} kcal',
                progress: nutritionProgress.clamp(0.0, 1.0),
                icon: Icons.restaurant,
                color: Colors.green,
                completed: nutrition.todaySummary.calories > 0,
                onTap: onOpenNutrition,
              ),
              const SizedBox(height: 10),
              _ChecklistRow(
                title: 'Steps',
                subtitle: '${steps.todaySteps} / ${steps.dailyGoal}',
                progress: stepsProgress,
                icon: Icons.directions_walk,
                color: Colors.green.shade700,
                completed: steps.todayGoalMet,
                onTap: onOpenSteps,
              ),
              const SizedBox(height: 10),
              _ChecklistRow(
                title: 'Sleep',
                subtitle: lastNight == null
                    ? 'Not logged'
                    : '${((lastNight.duration.inMinutes) / 60).toStringAsFixed(1)}h / ${sleep.sleepGoalHours.toStringAsFixed(0)}h',
                progress: sleepProgress,
                icon: Icons.bedtime,
                color: Colors.indigo,
                completed: lastNight != null,
                onTap: onOpenSleep,
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionChip(
                      icon: Icons.water_drop,
                      label: '+ Water',
                      color: Colors.cyan,
                      onTap: onQuickAddWater,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionChip(
                      icon: Icons.restaurant,
                      label: 'Log meal',
                      color: Colors.green,
                      onTap: onQuickLogMeal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionChip(
                      icon: Icons.monitor_weight,
                      label: 'Weight',
                      color: Colors.purple,
                      onTap: onQuickLogWeight,
                    ),
                  ),
                ],
              ),
              if (settings.dailyWaterGoal > 0 ||
                  settings.dailyStepsGoal > 0) ...[
                const SizedBox(height: 12),
                Text(
                  'Goals: Water ${settings.dailyWaterGoal} ml · Steps ${settings.dailyStepsGoal}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final IconData icon;
  final Color color;
  final bool completed;
  final VoidCallback onTap;

  const _ChecklistRow({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.icon,
    required this.color,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      if (completed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _weekdayShort(DateTime date) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return weekdays[date.weekday - 1];
}
