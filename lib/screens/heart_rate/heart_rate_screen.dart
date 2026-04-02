import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/heart_rate.dart';
import '../../providers/heart_rate_provider.dart';

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({super.key});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  Timer? _heartbeatTimer;
  bool _isMeasuring = false;
  int _measuringBpm = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  void _startMeasurement(HeartRateProvider provider) {
    setState(() {
      _isMeasuring = true;
      _measuringBpm = 0;
    });

    int measureCount = 0;
    final random = Random();

    _heartbeatTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      measureCount++;
      setState(() {
        _measuringBpm = 65 + random.nextInt(20);
      });

      if (measureCount >= 10) {
        timer.cancel();

        // Add reading to provider
        provider.addReading(bpm: _measuringBpm);

        setState(() {
          _isMeasuring = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Heart rate recorded: $_measuringBpm BPM'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HeartRateProvider>(
      builder: (context, heartRateProvider, _) {
        final stats = heartRateProvider.heartRateStats;
        final currentBpm = _isMeasuring
            ? _measuringBpm
            : heartRateProvider.currentBpm;
        final maxHeartRate = heartRateProvider.maxHeartRate;
        final restingBpm = heartRateProvider.restingHeartRate;
        final avgBpm = stats['avgBpm'] as int;
        final maxBpm = stats['maxBpm'] as int;
        final weeklyData = heartRateProvider.getWeeklyDailyAverages();
        final todayReadings = heartRateProvider.todaysReadings;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: Colors.red[600],
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Heart Rate',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.red[600]!, Colors.red[800]!],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.insights),
                    onPressed: () => _showInsights(heartRateProvider),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => _showSettings(heartRateProvider),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Current Heart Rate Display
                      _HeartRateDisplay(
                        bpm: currentBpm,
                        isMeasuring: _isMeasuring,
                        pulseAnimation: _pulseController,
                        onMeasure: () => _startMeasurement(heartRateProvider),
                      ),
                      const SizedBox(height: 24),

                      // Quick Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Resting',
                              value: '$restingBpm',
                              unit: 'BPM',
                              icon: Icons.hotel,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Average',
                              value: '$avgBpm',
                              unit: 'BPM',
                              icon: Icons.show_chart,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Max',
                              value: '$maxBpm',
                              unit: 'BPM',
                              icon: Icons.trending_up,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Heart Rate Zones Card
                      _HeartRateZonesCard(
                        maxHeartRate: maxHeartRate,
                        currentBpm: currentBpm,
                      ),
                      const SizedBox(height: 16),

                      // Weekly Chart
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
                                'This Week\'s Heart Rate',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 180,
                                child: _WeeklyHeartRateChart(
                                  weeklyData: weeklyData,
                                  weekDays: heartRateProvider.weekDayLabels,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Recent Measurements
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
                                    'Recent Measurements',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _showAllMeasurements(heartRateProvider),
                                    child: const Text('See All'),
                                  ),
                                ],
                              ),
                              if (todayReadings.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.favorite_border,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No readings today',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const Text(
                                          'Tap Measure to record your heart rate',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ...todayReadings.take(5).map((record) {
                                  return _RecordTile(
                                    record: record,
                                    onDelete: () => heartRateProvider
                                        .deleteReading(record.id),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Health Tips Card
                      _HealthTipsCard(
                        currentBpm: currentBpm,
                        restingBpm: restingBpm,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isMeasuring
                ? null
                : () => _startMeasurement(heartRateProvider),
            backgroundColor: _isMeasuring ? Colors.grey : Colors.red[600],
            icon: Icon(_isMeasuring ? Icons.hourglass_top : Icons.favorite),
            label: Text(_isMeasuring ? 'Measuring...' : 'Measure'),
          ),
        );
      },
    );
  }

  void _showInsights(HeartRateProvider provider) {
    final insights = provider.getInsights();

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
            color: Colors.white,
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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Heart Rate Insights',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              if (insights.isEmpty)
                _buildInsightCard(
                  '📊',
                  'Start Tracking',
                  'Record more heart rate readings to get personalized insights.',
                  Colors.blue,
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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

  void _showSettings(HeartRateProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _SettingsSheet(
        age: provider.userAge,
        restingHr: provider.restingHeartRate,
        maxHr: provider.maxHeartRate,
        onAgeChanged: (age) {
          provider.setUserAge(age);
          Navigator.pop(context);
        },
        onRestingHrChanged: (hr) {
          provider.setRestingHeartRate(hr);
        },
        onMaxHrChanged: (hr) {
          provider.setMaxHeartRate(hr);
        },
      ),
    );
  }

  void _showAllMeasurements(HeartRateProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (context, controller) => _MeasurementsSheet(
          records: provider.records,
          scrollController: controller,
          onDelete: provider.deleteReading,
        ),
      ),
    );
  }
}

// Heart Rate Display Widget
class _HeartRateDisplay extends StatelessWidget {
  final int bpm;
  final bool isMeasuring;
  final AnimationController pulseAnimation;
  final VoidCallback onMeasure;

  const _HeartRateDisplay({
    required this.bpm,
    required this.isMeasuring,
    required this.pulseAnimation,
    required this.onMeasure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red[50]!, Colors.red[100]!],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + (pulseAnimation.value * 0.1),
                child: Icon(
                  Icons.favorite,
                  size: 80,
                  color: isMeasuring
                      ? Colors.red.withValues(
                          alpha: 0.5 + pulseAnimation.value * 0.5,
                        )
                      : Colors.red[400],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (isMeasuring)
            Column(
              children: [
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red[100],
                    valueColor: AlwaysStoppedAnimation(Colors.red[400]),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Measuring...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            )
          else
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      bpm.toString(),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        ' BPM',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                Text(
                  _getHeartRateStatus(bpm),
                  style: TextStyle(
                    color: _getStatusColor(bpm),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _getHeartRateStatus(int bpm) {
    if (bpm < 60) return 'Below Normal';
    if (bpm < 100) return 'Normal Resting';
    if (bpm < 140) return 'Elevated';
    if (bpm < 170) return 'High';
    return 'Very High';
  }

  Color _getStatusColor(int bpm) {
    if (bpm < 60) return Colors.blue;
    if (bpm < 100) return Colors.green;
    if (bpm < 140) return Colors.orange;
    return Colors.red;
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
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
              fontSize: 20,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

// Heart Rate Zones Card
class _HeartRateZonesCard extends StatelessWidget {
  final int maxHeartRate;
  final int currentBpm;

  const _HeartRateZonesCard({
    required this.maxHeartRate,
    required this.currentBpm,
  });

  @override
  Widget build(BuildContext context) {
    final zones = [
      _ZoneInfo(HeartRateZone.rest, Colors.grey),
      _ZoneInfo(HeartRateZone.warmUp, Colors.blue),
      _ZoneInfo(HeartRateZone.fatBurn, Colors.green),
      _ZoneInfo(HeartRateZone.cardio, Colors.orange),
      _ZoneInfo(HeartRateZone.peak, Colors.red),
      _ZoneInfo(HeartRateZone.max, Colors.purple),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Heart Rate Zones',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Max HR: $maxHeartRate',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...zones.map((zone) {
              final (minBpm, maxBpm) = HeartRateStats.getZoneRange(
                maxHeartRate,
                zone.zone,
              );
              final isCurrentZone = currentBpm >= minBpm && currentBpm < maxBpm;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: zone.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                zone.zone.name,
                                style: TextStyle(
                                  fontWeight: isCurrentZone
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isCurrentZone ? zone.color : null,
                                ),
                              ),
                              if (isCurrentZone) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: zone.color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Current',
                                    style: TextStyle(
                                      color: zone.color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '$minBpm - $maxBpm BPM (${zone.zone.minPercentage.toInt()}-${zone.zone.maxPercentage.toInt()}%)',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ZoneInfo {
  final HeartRateZone zone;
  final Color color;

  _ZoneInfo(this.zone, this.color);
}

// Record Tile Widget (for HeartRateRecord from provider)
class _RecordTile extends StatelessWidget {
  final HeartRateRecord record;
  final VoidCallback onDelete;

  const _RecordTile({required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getZoneColor(record.zone).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.favorite,
                color: _getZoneColor(record.zone),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.bpm} BPM',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatTime(record.timestamp),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getZoneColor(record.zone).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                record.zone.name,
                style: TextStyle(
                  color: _getZoneColor(record.zone),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getZoneColor(HeartRateZone zone) {
    switch (zone) {
      case HeartRateZone.rest:
        return Colors.grey;
      case HeartRateZone.warmUp:
        return Colors.blue;
      case HeartRateZone.fatBurn:
        return Colors.green;
      case HeartRateZone.cardio:
        return Colors.orange;
      case HeartRateZone.peak:
        return Colors.red;
      case HeartRateZone.max:
        return Colors.deepPurple;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// Weekly Heart Rate Chart
class _WeeklyHeartRateChart extends StatelessWidget {
  final List<int> weeklyData;
  final List<String> weekDays;

  const _WeeklyHeartRateChart({
    required this.weeklyData,
    required this.weekDays,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        minY: 40,
        maxY: 120,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${weeklyData[groupIndex]} BPM',
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
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                );
              },
            ),
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
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey[200]!, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: weeklyData.asMap().entries.map((entry) {
          final index = entry.key;
          final bpm = entry.value;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: bpm.toDouble(),
                color: _getBpmColor(bpm),
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

  Color _getBpmColor(int bpm) {
    if (bpm < 60) return Colors.blue;
    if (bpm < 80) return Colors.green;
    if (bpm < 100) return Colors.orange;
    return Colors.red;
  }
}

// Health Tips Card
class _HealthTipsCard extends StatelessWidget {
  final int currentBpm;
  final int restingBpm;

  const _HealthTipsCard({required this.currentBpm, required this.restingBpm});

  @override
  Widget build(BuildContext context) {
    final tips = _getTips();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Health Tips',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.blue[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getTips() {
    final tips = <String>[];

    if (restingBpm < 60) {
      tips.add(
        'Your resting heart rate is excellent! This often indicates good cardiovascular fitness.',
      );
    } else if (restingBpm < 70) {
      tips.add(
        'Your resting heart rate is in a healthy range. Keep up the good work!',
      );
    } else {
      tips.add(
        'Consider regular cardio exercise to help lower your resting heart rate over time.',
      );
    }

    tips.add('Aim for 150 minutes of moderate aerobic activity per week.');
    tips.add('Stay hydrated - dehydration can increase your heart rate.');

    return tips;
  }
}

// Settings Sheet
class _SettingsSheet extends StatefulWidget {
  final int age;
  final int restingHr;
  final int maxHr;
  final Function(int) onAgeChanged;
  final Function(int) onRestingHrChanged;
  final Function(int) onMaxHrChanged;

  const _SettingsSheet({
    required this.age,
    required this.restingHr,
    required this.maxHr,
    required this.onAgeChanged,
    required this.onRestingHrChanged,
    required this.onMaxHrChanged,
  });

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late int _age;
  late int _restingHr;
  late int _maxHr;

  @override
  void initState() {
    super.initState();
    _age = widget.age;
    _restingHr = widget.restingHr;
    _maxHr = widget.maxHr;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Heart Rate Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.cake),
            title: const Text('Your Age'),
            subtitle: Text('Max HR calculated: ${220 - _age} BPM'),
            trailing: _buildCounter(
              value: _age,
              onDecrement: () =>
                  setState(() => _age = (_age - 1).clamp(10, 100)),
              onIncrement: () =>
                  setState(() => _age = (_age + 1).clamp(10, 100)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.hotel),
            title: const Text('Resting Heart Rate'),
            subtitle: const Text('Measured at rest'),
            trailing: _buildCounter(
              value: _restingHr,
              onDecrement: () =>
                  setState(() => _restingHr = (_restingHr - 1).clamp(40, 100)),
              onIncrement: () =>
                  setState(() => _restingHr = (_restingHr + 1).clamp(40, 100)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('Max Heart Rate'),
            subtitle: const Text('Override calculated max'),
            trailing: _buildCounter(
              value: _maxHr,
              onDecrement: () =>
                  setState(() => _maxHr = (_maxHr - 1).clamp(140, 220)),
              onIncrement: () =>
                  setState(() => _maxHr = (_maxHr + 1).clamp(140, 220)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onRestingHrChanged(_restingHr);
                widget.onMaxHrChanged(_maxHr);
                widget.onAgeChanged(_age);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCounter({
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: const Icon(Icons.remove, size: 18),
          ),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: onIncrement,
            child: const Icon(Icons.add, size: 18),
          ),
        ],
      ),
    );
  }
}

// Measurements Sheet
class _MeasurementsSheet extends StatelessWidget {
  final List<HeartRateRecord> records;
  final ScrollController scrollController;
  final Function(String) onDelete;

  const _MeasurementsSheet({
    required this.records,
    required this.scrollController,
    required this.onDelete,
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
              'All Measurements',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Expanded(
            child: records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No measurements yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return _RecordTile(
                        record: record,
                        onDelete: () => onDelete(record.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
