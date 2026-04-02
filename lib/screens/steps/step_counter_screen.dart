import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/step_data.dart';
import '../../providers/fitness_provider.dart';
import '../../providers/step_provider.dart';
import '../../services/settings_service.dart';

class StepCounterScreen extends StatefulWidget {
  const StepCounterScreen({super.key});

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  // Hourly breakdown
  List<HourlySteps> _hourlySteps = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Initial animation setup
    _progressAnimation =
        Tween<double>(
          begin: 0,
          end: 0, // Will be updated in build
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _generateHourlyData();
    _animationController.forward();
  }

  void _generateHourlyData() {
    // Initialize with zeros
    _hourlySteps = List.generate(24, (hour) {
      return HourlySteps(hour: hour, steps: 0);
    });

    // In a real app with a pedometer package, we would fetch historical data here.
    // For now, we just show the current total distributed (simplified) or just 0s.
    // We avoid generating random dummy data to not confuse the user.
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<FitnessProvider, SettingsService, StepProvider>(
      builder: (context, fitnessProvider, settingsService, stepProvider, child) {
        final currentSteps = stepProvider.todaySteps > 0
            ? stepProvider.todaySteps
            : (fitnessProvider.todayData?.steps ?? 0);
        final stepGoal = stepProvider.dailyGoal;

        // Get weekly data from StepProvider
        final weeklyData = stepProvider.getWeeklyData();
        final weeklySteps = weeklyData.map((d) => d.steps).toList();
        final weekDays = weeklyData.map((d) => d.dayLabel).toList();

        // Calculate derived metrics
        // Average stride length ~0.762m (2.5ft)
        final distanceKm = (currentSteps * 0.762) / 1000;
        // Approx 0.04 kcal per step
        final caloriesBurned = (currentSteps * 0.04).round();
        // Approx 100 steps per minute for moderate walking
        final activeMinutes = (currentSteps / 100).round();

        final progress = (currentSteps / stepGoal).clamp(0.0, 1.0);
        final isGoalMet = progress >= 1.0;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: Colors.green[600],
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Step Counter',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.green[600]!, Colors.green[800]!],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: () => _showHistoryBottomSheet(),
                    tooltip: 'History',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => _showGoalSettings(),
                    tooltip: 'Goals',
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Main Progress Ring
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return _StepProgressRing(
                            progress: progress, // Use real progress
                            steps: currentSteps,
                            goal: stepGoal,
                            isGoalMet: isGoalMet,
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Stats Grid
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.straighten,
                              value: '${distanceKm.toStringAsFixed(1)} km',
                              label: 'Distance',
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.local_fire_department,
                              value: '$caloriesBurned',
                              label: 'Calories',
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.timer,
                              value: '$activeMinutes min',
                              label: 'Active',
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Manual Add Button (Since we don't have real pedometer)
                      ElevatedButton.icon(
                        onPressed: () {
                          stepProvider.addSteps(100);
                          fitnessProvider.updateTodayData(
                            steps: currentSteps + 100,
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add 100 Steps'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Weekly Overview Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'This Week',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    '${stepProvider.getWeeklyTotal()} steps',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 150,
                                child: _WeeklyChart(
                                  weeklySteps: weeklySteps,
                                  weekDays: weekDays,
                                  goal: stepGoal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Hourly Breakdown
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Today\'s Activity',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 120,
                                child: _HourlyChart(hourlySteps: _hourlySteps),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '12 AM',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '12 PM',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '11 PM',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Achievement Cards
                      _AchievementSection(
                        currentSteps: currentSteps,
                        goalMet: isGoalMet,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHistoryBottomSheet() {
    final stepProvider = Provider.of<StepProvider>(context, listen: false);
    final history = stepProvider.stepHistoryList;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _StepHistorySheet(
          scrollController: scrollController,
          history: history,
          stepGoal: stepProvider.stepGoal,
        ),
      ),
    );
  }

  void _showGoalSettings() {
    final stepProvider = Provider.of<StepProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => _GoalSettingsDialog(
        currentGoal: stepProvider.stepGoal,
        onSave: (newGoal) {
          stepProvider.setStepGoal(newGoal);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// Step Progress Ring Widget
class _StepProgressRing extends StatelessWidget {
  final double progress;
  final int steps;
  final int goal;
  final bool isGoalMet;

  const _StepProgressRing({
    required this.progress,
    required this.steps,
    required this.goal,
    required this.isGoalMet,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: 220,
            height: 220,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 16,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(Colors.grey[200]),
            ),
          ),
          // Progress ring
          SizedBox(
            width: 220,
            height: 220,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 16,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                isGoalMet ? Colors.green : Colors.green[400]!,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Overflow indicator (when over goal)
          if (progress > 1.0)
            SizedBox(
              width: 196,
              height: 196,
              child: CircularProgressIndicator(
                value: (progress - 1.0).clamp(0.0, 1.0),
                strokeWidth: 8,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(Colors.amber[400]!),
                strokeCap: StrokeCap.round,
              ),
            ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isGoalMet ? Icons.emoji_events : Icons.directions_walk,
                size: 36,
                color: isGoalMet ? Colors.amber : Colors.green[600],
              ),
              const SizedBox(height: 4),
              Text(
                steps.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                ),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'of ${goal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} steps',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              if (isGoalMet)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Goal Met! 🎉',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

// Weekly Chart Widget
class _WeeklyChart extends StatelessWidget {
  final List<int> weeklySteps;
  final List<String> weekDays;
  final int goal;

  const _WeeklyChart({
    required this.weeklySteps,
    required this.weekDays,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final maxSteps = weeklySteps.reduce((a, b) => a > b ? a : b);
    final maxY = (maxSteps > goal ? maxSteps : goal) * 1.2;

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${weeklySteps[groupIndex]} steps',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < weekDays.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      weekDays[index],
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: goal.toDouble(),
          getDrawingHorizontalLine: (value) => FlLine(
            color: value == goal
                ? Colors.green.withValues(alpha: 0.5)
                : Colors.grey[200]!,
            strokeWidth: value == goal ? 2 : 1,
            dashArray: value == goal ? [5, 5] : null,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: weeklySteps.asMap().entries.map((entry) {
          final index = entry.key;
          final steps = entry.value;
          final isGoalMet = steps >= goal;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: steps.toDouble(),
                color: isGoalMet ? Colors.green : Colors.green[300],
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Hourly Chart Widget
class _HourlyChart extends StatelessWidget {
  final List<HourlySteps> hourlySteps;

  const _HourlyChart({required this.hourlySteps});

  @override
  Widget build(BuildContext context) {
    final maxSteps = hourlySteps
        .map((h) => h.steps)
        .reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxSteps * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: hourlySteps.map((hourly) {
          return BarChartGroupData(
            x: hourly.hour,
            barRods: [
              BarChartRodData(
                toY: hourly.steps.toDouble(),
                color: Colors.green[400],
                width: 8,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Achievement Section Widget
class _AchievementSection extends StatelessWidget {
  final int currentSteps;
  final bool goalMet;

  const _AchievementSection({
    required this.currentSteps,
    required this.goalMet,
  });

  @override
  Widget build(BuildContext context) {
    final achievements = [
      _Achievement(
        title: 'First Steps',
        description: 'Walk 1,000 steps',
        icon: Icons.emoji_events,
        color: Colors.amber,
        isUnlocked: currentSteps >= 1000,
      ),
      _Achievement(
        title: 'Morning Walker',
        description: 'Walk 5,000 steps',
        icon: Icons.wb_sunny,
        color: Colors.orange,
        isUnlocked: currentSteps >= 5000,
      ),
      _Achievement(
        title: 'Goal Crusher',
        description: 'Reach daily goal',
        icon: Icons.military_tech,
        color: Colors.green,
        isUnlocked: goalMet,
      ),
      _Achievement(
        title: 'Overachiever',
        description: 'Walk 15,000 steps',
        icon: Icons.stars,
        color: Colors.purple,
        isUnlocked: currentSteps >= 15000,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Achievements',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: achievements.map((achievement) {
            return _AchievementCard(achievement: achievement);
          }).toList(),
        ),
      ],
    );
  }
}

class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });
}

class _AchievementCard extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? achievement.color.withValues(alpha: 0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: achievement.isUnlocked
            ? Border.all(
                color: achievement.color.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            achievement.icon,
            color: achievement.isUnlocked
                ? achievement.color
                : Colors.grey[400],
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: achievement.isUnlocked ? null : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            achievement.description,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Step History Sheet
class _StepHistorySheet extends StatelessWidget {
  final ScrollController scrollController;
  final List<DailyStepData> history;
  final int stepGoal;

  const _StepHistorySheet({
    required this.scrollController,
    required this.history,
    required this.stepGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Step History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? const Center(child: Text('No history available yet'))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final record = history[index];
                      final isGoalMet = record.steps >= stepGoal;
                      final distanceKm = record.steps * 0.0008;
                      final calories = (record.steps * 0.04).round();

                      return ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isGoalMet
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isGoalMet
                                ? Icons.check_circle
                                : Icons.directions_walk,
                            color: isGoalMet ? Colors.green : Colors.grey[400],
                          ),
                        ),
                        title: Text(
                          _formatDate(record.date),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${distanceKm.toStringAsFixed(1)} km • $calories cal',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        trailing: Text(
                          '${record.steps}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isGoalMet ? Colors.green : null,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Yesterday';

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
    return '${months[date.month - 1]} ${date.day}';
  }
}

// Goal Settings Dialog
class _GoalSettingsDialog extends StatefulWidget {
  final int currentGoal;
  final Function(int) onSave;

  const _GoalSettingsDialog({required this.currentGoal, required this.onSave});

  @override
  State<_GoalSettingsDialog> createState() => _GoalSettingsDialogState();
}

class _GoalSettingsDialogState extends State<_GoalSettingsDialog> {
  late int _selectedGoal;
  final List<int> _presetGoals = [5000, 7500, 10000, 12500, 15000];

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.currentGoal;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Daily Step Goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _selectedGoal.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            ),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const Text('steps per day'),
          const SizedBox(height: 24),
          Slider(
            value: _selectedGoal.toDouble(),
            min: 3000,
            max: 20000,
            divisions: 17,
            activeColor: Colors.green,
            onChanged: (value) {
              setState(() => _selectedGoal = value.round());
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _presetGoals.map((goal) {
              final isSelected = _selectedGoal == goal;
              return ChoiceChip(
                label: Text('${goal ~/ 1000}K'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedGoal = goal);
                },
                selectedColor: Colors.green[100],
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => widget.onSave(_selectedGoal),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
