import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/water_intake.dart';
import '../../providers/water_provider.dart';
import '../../services/settings_service.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _waveAnimation;

  final List<QuickAddOption> _quickAddOptions = [
    QuickAddOption(amount: 150, label: 'Small', icon: Icons.local_drink),
    QuickAddOption(amount: 250, label: 'Glass', icon: Icons.water_drop),
    QuickAddOption(amount: 350, label: 'Medium', icon: Icons.coffee),
    QuickAddOption(amount: 500, label: 'Bottle', icon: Icons.sports_bar),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WaterProvider, SettingsService>(
      builder: (context, waterProvider, settingsService, child) {
        final totalIntake = waterProvider.dailyIntake;
        final dailyGoal = waterProvider.dailyGoal;
        final progress = (totalIntake / dailyGoal).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Water Tracker'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => _showHistory(waterProvider),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showSettings(waterProvider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main water display
                _buildWaterDisplay(progress, totalIntake, dailyGoal),
                const SizedBox(height: 24),

                // Quick add buttons
                _buildQuickAddSection(waterProvider),
                const SizedBox(height: 24),

                // Add custom amount
                _buildCustomAddSection(waterProvider),
                const SizedBox(height: 24),

                // Today's log
                _buildTodayLog(waterProvider),
                const SizedBox(height: 24),

                // Weekly stats
                _buildWeeklyStats(waterProvider),
                const SizedBox(height: 24),

                // Insights
                _buildInsights(waterProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaterDisplay(
    double progress,
    double totalIntake,
    double dailyGoal,
  ) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Water level animation
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CustomPaint(
                  size: const Size(double.infinity, 300),
                  painter: WaterWavePainter(
                    progress: progress,
                    wavePhase: _waveAnimation.value,
                  ),
                ),
              );
            },
          ),

          // Content overlay
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop,
                size: 48,
                color: progress > 0.5 ? Colors.white : AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                '${totalIntake.toInt()} ml',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: progress > 0.5 ? Colors.white : AppColors.textPrimary,
                ),
              ),
              Text(
                'of ${dailyGoal.toInt()} ml',
                style: TextStyle(
                  fontSize: 16,
                  color: progress > 0.5
                      ? Colors.white70
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: progress > 0.5
                      ? Colors.white24
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: progress > 0.5 ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
              if (totalIntake < dailyGoal) ...[
                const SizedBox(height: 8),
                Text(
                  '${(dailyGoal - totalIntake).toInt()} ml remaining',
                  style: TextStyle(
                    fontSize: 14,
                    color: progress > 0.5
                        ? Colors.white70
                        : AppColors.textSecondary,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Goal reached! 🎉',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: progress > 0.5
                            ? Colors.white
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddSection(WaterProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Add',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: _quickAddOptions.map((option) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildQuickAddButton(option, provider),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(QuickAddOption option, WaterProvider provider) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _addWater(provider, option.amount.toDouble()),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(option.icon, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                option.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${option.amount.toInt()}ml',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAddSection(WaterProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Custom Amount',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: WaterSource.values
                      .where((s) => s != WaterSource.other)
                      .map((source) {
                        return ChoiceChip(
                          label: Text('${source.icon} ${source.displayName}'),
                          selected: false,
                          onSelected: (selected) {
                            _showCustomAmountDialog(source, provider);
                          },
                        );
                      })
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayLog(WaterProvider provider) {
    final entries = provider.getTodayEntries();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Log',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${entries.length} entries',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No water logged yet today.\nTap a quick add button to start!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length > 5 ? 5 : entries.length,
              itemBuilder: (context, index) {
                final entry =
                    entries[entries.length - 1 - index]; // Show newest first
                return _buildLogEntry(entry, provider);
              },
            ),
          if (entries.length > 5)
            TextButton(
              onPressed: () => _showHistory(provider),
              child: const Text('View all entries'),
            ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(WaterEntry entry, WaterProvider provider) {
    final time = TimeOfDay.fromDateTime(entry.timestamp);
    final beverageType = _getBeverageIcon(entry.beverageType);

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        provider.removeEntry(entry.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Entry removed')));
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(beverageType),
        ),
        title: Text('${entry.amountMl.toInt()} ml'),
        subtitle: Text(entry.beverageType),
        trailing: Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  String _getBeverageIcon(String type) {
    switch (type.toLowerCase()) {
      case 'water':
        return '💧';
      case 'tea':
        return '🍵';
      case 'coffee':
        return '☕';
      case 'juice':
        return '🧃';
      case 'milk':
        return '🥛';
      case 'smoothie':
        return '🥤';
      case 'sports_drink':
        return '⚡';
      default:
        return '💧';
    }
  }

  Widget _buildWeeklyStats(WaterProvider provider) {
    final weeklyData = provider.getWeeklyIntake();
    final dailyGoal = provider.dailyGoal;
    final today = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Week',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final dayIndex = index; // 0 = Monday
              final intake = weeklyData[dayIndex];
              final progress = (intake / dailyGoal).clamp(0.0, 1.0);
              final isToday = dayIndex == today - 1;

              return _buildWeekDay(days[dayIndex], progress, isToday);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDay(String day, double progress, bool isToday) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: isToday
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 32,
                height: 80 * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.primary, AppColors.skyBlue],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              if (progress >= 1.0)
                const Positioned(
                  top: 4,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 10,
            color: isToday ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInsights(WaterProvider provider) {
    final insights = provider.getInsights();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInsightTile(
            icon: Icons.water_drop,
            title: 'Daily Average',
            value: '${insights['averageDaily'].toInt()} ml',
            color: AppColors.primary,
          ),
          _buildInsightTile(
            icon: Icons.trending_up,
            title: 'Best Day This Week',
            value: '${insights['bestDay'].toInt()} ml',
            color: AppColors.success,
          ),
          _buildInsightTile(
            icon: Icons.local_fire_department,
            title: 'Current Streak',
            value: '${insights['streak']} days',
            color: AppColors.orange,
          ),
          _buildInsightTile(
            icon: Icons.emoji_events,
            title: 'Goals Met This Week',
            value: '${insights['goalsMet']}/7 days',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _addWater(
    WaterProvider provider,
    double amount, [
    String beverageType = 'water',
  ]) {
    provider.addEntry(amount, beverageType: beverageType);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${amount.toInt()}ml ${_getBeverageIcon(beverageType)}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showHistory(WaterProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final allEntries = provider.entries;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Water History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: allEntries.isEmpty
                    ? const Center(
                        child: Text(
                          'No history yet.\nStart tracking your water intake!',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: allEntries.length,
                        itemBuilder: (context, index) {
                          final entry =
                              allEntries[allEntries.length - 1 - index];
                          final date = entry.timestamp;
                          final isNewDay =
                              index == 0 ||
                              !_isSameDay(
                                allEntries[allEntries.length - index].timestamp,
                                date,
                              );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isNewDay)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    _formatDate(date),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              _buildLogEntry(entry, provider),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'Today';
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }

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

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  void _showSettings(WaterProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        double goal = provider.dailyGoal;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Text('Daily Goal'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: goal,
                          min: 1000,
                          max: 5000,
                          divisions: 40,
                          label: '${goal.toInt()} ml',
                          onChanged: (value) {
                            setState(() => goal = value);
                          },
                        ),
                      ),
                      Text(
                        '${goal.toInt()} ml',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        provider.setDailyGoal(goal);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Daily goal set to ${goal.toInt()} ml',
                            ),
                          ),
                        );
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomAmountDialog(WaterSource source, WaterProvider provider) {
    double customAmount = 250;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add ${source.displayName}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(source.icon, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    '${customAmount.toInt()} ml',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: customAmount,
                    min: 50,
                    max: 1000,
                    divisions: 19,
                    label: '${customAmount.toInt()} ml',
                    onChanged: (value) {
                      setState(() => customAmount = value);
                    },
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
                    Navigator.pop(context);
                    _addWater(provider, customAmount, _sourceToType(source));
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _sourceToType(WaterSource source) {
    switch (source) {
      case WaterSource.water:
        return 'water';
      case WaterSource.tea:
        return 'tea';
      case WaterSource.coffee:
        return 'coffee';
      case WaterSource.juice:
        return 'juice';
      case WaterSource.milk:
        return 'milk';
      case WaterSource.smoothie:
        return 'smoothie';
      case WaterSource.sportsDrink:
        return 'sports_drink';
      default:
        return 'water';
    }
  }
}

class QuickAddOption {
  final double amount;
  final String label;
  final IconData icon;

  QuickAddOption({
    required this.amount,
    required this.label,
    required this.icon,
  });
}

class WaterWavePainter extends CustomPainter {
  final double progress;
  final double wavePhase;

  WaterWavePainter({required this.progress, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF42A5F5).withValues(alpha: 0.8),
          const Color(0xFF1976D2),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final waterHeight = size.height * (1 - progress);

    path.moveTo(0, size.height);
    path.lineTo(0, waterHeight);

    // Smooth sine wave
    // Reduced amplitude (3) and adjusted frequency for smoother look
    for (double x = 0; x <= size.width; x++) {
      final y =
          waterHeight +
          3 * math.sin((x / size.width * 2 * math.pi) + wavePhase);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaterWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase;
  }
}
