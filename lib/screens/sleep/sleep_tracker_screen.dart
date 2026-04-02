import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/sleep_data.dart';
import '../../providers/sleep_provider.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);
  SleepQuality _selectedQuality = SleepQuality.good;
  final List<SleepFactor> _selectedFactors = [];

  Duration get _sleepDuration {
    final now = DateTime.now();
    final bed = DateTime(
      now.year,
      now.month,
      now.day,
      _bedTime.hour,
      _bedTime.minute,
    );
    var wake = DateTime(
      now.year,
      now.month,
      now.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );

    if (wake.isBefore(bed)) {
      wake = wake.add(const Duration(days: 1));
    }

    return wake.difference(bed);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, sleepProvider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Sleep Tracker'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.insights),
                onPressed: () => _showSleepInsights(sleepProvider),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showSleepSettings(sleepProvider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sleep goal card
                _buildSleepGoalCard(sleepProvider),
                const SizedBox(height: 24),

                // Log sleep section
                _buildLogSleepSection(sleepProvider),
                const SizedBox(height: 24),

                // Weekly sleep chart
                _buildWeeklySleepChart(sleepProvider),
                const SizedBox(height: 24),

                // Recent sleep entries
                _buildRecentSleepEntries(sleepProvider),
                const SizedBox(height: 24),

                // Sleep tips
                _buildSleepTips(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSleepGoalCard(SleepProvider sleepProvider) {
    final stats = sleepProvider.sleepStats;
    final avgSleep = stats['averageHours'] as double;
    final goalSleep = sleepProvider.sleepGoalHours;
    final progress = (avgSleep / goalSleep).clamp(0.0, 1.0);
    final qualityScore = stats['averageQuality'] as double;
    final bestDay = stats['bestDay'] as String;
    final streak = stats['streak'] as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1A237E), const Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.nightlight_round,
                          color: Colors.amber,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Sleep Goal',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${avgSleep.toStringAsFixed(1)}h',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'avg of ${goalSleep.toInt()}h goal',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.amber,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'of goal',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                  'Avg Quality',
                  '${_qualityEmoji(qualityScore)} ${_qualityLabel(qualityScore)}',
                ),
                Container(width: 1, height: 30, color: Colors.white24),
                _buildMiniStat('Best Day', bestDay),
                Container(width: 1, height: 30, color: Colors.white24),
                _buildMiniStat('Streak', '$streak days'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _qualityEmoji(double score) {
    if (score >= 4.5) return '😊';
    if (score >= 3.5) return '🙂';
    if (score >= 2.5) return '😐';
    if (score >= 1.5) return '😕';
    return '😞';
  }

  String _qualityLabel(double score) {
    if (score >= 4.5) return 'Excellent';
    if (score >= 3.5) return 'Good';
    if (score >= 2.5) return 'Fair';
    if (score >= 1.5) return 'Poor';
    return 'Very Poor';
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildLogSleepSection(SleepProvider sleepProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Log Last Night\'s Sleep',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Time pickers
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  'Bed Time',
                  _bedTime,
                  Icons.bedtime,
                  (time) => setState(() => _bedTime = time),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePicker(
                  'Wake Time',
                  _wakeTime,
                  Icons.wb_sunny,
                  (time) => setState(() => _wakeTime = time),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Duration display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Total: ${_sleepDuration.inHours}h ${_sleepDuration.inMinutes % 60}m',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quality selector
          const Text(
            'Sleep Quality',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: SleepQuality.values.map((quality) {
              final isSelected = quality == _selectedQuality;
              return GestureDetector(
                onTap: () => setState(() => _selectedQuality = quality),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          quality.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quality.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Factors
          const Text(
            'Factors Affecting Sleep',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SleepFactor.values
                .where((f) => f != SleepFactor.none)
                .map((factor) {
                  final isSelected = _selectedFactors.contains(factor);
                  return FilterChip(
                    label: Text('${factor.icon} ${factor.displayName}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFactors.add(factor);
                        } else {
                          _selectedFactors.remove(factor);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withAlpha(51),
                    checkmarkColor: AppColors.primary,
                  );
                })
                .toList(),
          ),

          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveSleepEntry(sleepProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Sleep Log',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay time,
    IconData icon,
    Function(TimeOfDay) onChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySleepChart(SleepProvider sleepProvider) {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weeklyData = sleepProvider.getWeeklySleepHours();
    final goalHours = sleepProvider.sleepGoalHours;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Week',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final hours = weeklyData[index];
                final height = hours > 0 ? (hours / 10) * 120 : 5.0;
                final isGood = hours >= goalHours - 1;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${hours.toStringAsFixed(1)}h',
                      style: TextStyle(
                        fontSize: 10,
                        color: isGood ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isGood
                              ? [
                                  const Color(0xFF1A237E),
                                  const Color(0xFF3949AB),
                                ]
                              : [
                                  AppColors.warning,
                                  AppColors.warning.withAlpha(150),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weekDays[index],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSleepEntries(SleepProvider sleepProvider) {
    final recentEntries = sleepProvider.sleepHistory.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Sleep',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => _showAllSleepHistory(sleepProvider),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentEntries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.bedtime,
                      size: 48,
                      color: AppColors.textSecondary.withAlpha(100),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No sleep entries yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const Text(
                      'Log your first sleep to start tracking',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...recentEntries.map((entry) {
              final hours =
                  entry.duration.inHours +
                  (entry.duration.inMinutes % 60) / 60.0;
              final quality = entry.quality;
              final bedTimeStr = _formatTimeOfDay(
                TimeOfDay.fromDateTime(entry.bedTime),
              );
              final wakeTimeStr = _formatTimeOfDay(
                TimeOfDay.fromDateTime(entry.wakeTime),
              );

              return Dismissible(
                key: Key(entry.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppColors.error,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  sleepProvider.deleteSleepEntry(entry.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sleep entry deleted')),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E).withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            quality.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(entry.bedTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${hours.toStringAsFixed(1)} hours • ${quality.displayName}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            bedTimeStr,
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            wakeTimeStr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildSleepTips() {
    final tips = [
      {'icon': '🌙', 'tip': 'Keep a consistent sleep schedule'},
      {'icon': '📱', 'tip': 'Avoid screens 1 hour before bed'},
      {'icon': '☕', 'tip': 'No caffeine after 2 PM'},
      {'icon': '🏃', 'tip': 'Exercise regularly but not before bed'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sleep Tips',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(tip['icon']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip['tip']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.day}/${date.month}';
  }

  void _saveSleepEntry(SleepProvider sleepProvider) {
    final now = DateTime.now();
    final bed = DateTime(
      now.year,
      now.month,
      now.day,
      _bedTime.hour,
      _bedTime.minute,
    );
    var wake = DateTime(
      now.year,
      now.month,
      now.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );

    if (wake.isBefore(bed)) {
      wake = wake.add(const Duration(days: 1));
    }

    final entry = SleepEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bedTime: bed,
      wakeTime: wake,
      quality: _selectedQuality,
      factors: _selectedFactors,
    );

    sleepProvider.addSleepEntry(entry);

    // Reset form
    setState(() {
      _selectedQuality = SleepQuality.good;
      _selectedFactors.clear();
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sleep logged successfully! 😴'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showAllSleepHistory(SleepProvider sleepProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sleep History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: sleepProvider.sleepHistory.isEmpty
                    ? const Center(child: Text('No sleep entries yet'))
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: sleepProvider.sleepHistory.length,
                        itemBuilder: (context, index) {
                          final entry = sleepProvider.sleepHistory[index];
                          final hours =
                              entry.duration.inHours +
                              (entry.duration.inMinutes % 60) / 60.0;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  entry.quality.emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatDate(entry.bedTime),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${hours.toStringAsFixed(1)} hours • ${entry.quality.displayName}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () {
                                    sleepProvider.deleteSleepEntry(entry.id);
                                    if (sleepProvider.sleepHistory.isEmpty) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSleepInsights(SleepProvider sleepProvider) {
    final insights = sleepProvider.getSleepInsights();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sleep Insights',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              if (insights.isEmpty)
                _buildInsightCard(
                  '📝',
                  'Log Your Sleep',
                  'Start tracking your sleep to get personalized insights and recommendations.',
                  AppColors.primary,
                )
              else
                ...insights.map(
                  (insight) => _buildInsightCard(
                    insight['emoji'] as String,
                    insight['title'] as String,
                    insight['description'] as String,
                    insight['color'] as Color,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    String emoji,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSleepSettings(SleepProvider sleepProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sleep Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Sleep Goal'),
                  subtitle: Text(
                    '${sleepProvider.sleepGoalHours.toStringAsFixed(1)} hours',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    _showGoalPicker(sleepProvider);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bedtime),
                  title: const Text('Bedtime Reminder'),
                  subtitle: Text(
                    _formatTimeOfDay(sleepProvider.bedtimeReminder),
                  ),
                  trailing: Switch(
                    value: sleepProvider.bedtimeReminderEnabled,
                    onChanged: (value) {
                      sleepProvider.setBedtimeReminderEnabled(value);
                      setModalState(() {});
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: sleepProvider.bedtimeReminder,
                    );
                    if (picked != null) {
                      sleepProvider.setBedtimeReminder(picked);
                      setModalState(() {});
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.alarm),
                  title: const Text('Wake Alarm'),
                  subtitle: Text(_formatTimeOfDay(sleepProvider.wakeAlarm)),
                  trailing: Switch(
                    value: sleepProvider.wakeAlarmEnabled,
                    onChanged: (value) {
                      sleepProvider.setWakeAlarmEnabled(value);
                      setModalState(() {});
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: sleepProvider.wakeAlarm,
                    );
                    if (picked != null) {
                      sleepProvider.setWakeAlarm(picked);
                      setModalState(() {});
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showGoalPicker(SleepProvider sleepProvider) {
    double selectedHours = sleepProvider.sleepGoalHours;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Sleep Goal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${selectedHours.toStringAsFixed(1)} hours',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: selectedHours,
                  min: 5.0,
                  max: 12.0,
                  divisions: 14,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setDialogState(() => selectedHours = value);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Recommended: 7-9 hours for adults',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
                  sleepProvider.setSleepGoalHours(selectedHours);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
