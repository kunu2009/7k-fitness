import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/progress_photo.dart';
import '../../providers/photo_timeline_provider.dart';
import '../../theme/app_theme.dart';

/// Widget displaying progress charts for weight and measurements
class ProgressChartsWidget extends StatefulWidget {
  const ProgressChartsWidget({super.key});

  @override
  State<ProgressChartsWidget> createState() => _ProgressChartsWidgetState();
}

class _ProgressChartsWidgetState extends State<ProgressChartsWidget> {
  String _selectedChart = 'weight';
  String _selectedMeasurement = 'chest';

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoTimelineProvider>(
      builder: (context, provider, _) {
        final photosWithWeight = provider.photos
            .where((p) => p.weight != null)
            .toList();
        final photosWithMeasurements = provider.photos
            .where((p) => p.measurements != null)
            .toList();

        if (photosWithWeight.isEmpty && photosWithMeasurements.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart type selector
            _buildChartTypeSelector(
              hasWeight: photosWithWeight.isNotEmpty,
              hasMeasurements: photosWithMeasurements.isNotEmpty,
            ),

            const SizedBox(height: 16),

            // Chart
            SizedBox(
              height: 250,
              child: _selectedChart == 'weight'
                  ? _buildWeightChart(photosWithWeight)
                  : _buildMeasurementChart(photosWithMeasurements),
            ),

            // Stats summary
            const SizedBox(height: 16),
            if (_selectedChart == 'weight')
              _buildWeightStats(photosWithWeight)
            else
              _buildMeasurementSelector(photosWithMeasurements),
          ],
        );
      },
    );
  }

  Widget _buildChartTypeSelector({
    required bool hasWeight,
    required bool hasMeasurements,
  }) {
    return Row(
      children: [
        if (hasWeight)
          Expanded(
            child: _buildChartTypeButton(
              label: 'Weight',
              icon: Icons.monitor_weight,
              isSelected: _selectedChart == 'weight',
              onTap: () => setState(() => _selectedChart = 'weight'),
            ),
          ),
        if (hasWeight && hasMeasurements) const SizedBox(width: 12),
        if (hasMeasurements)
          Expanded(
            child: _buildChartTypeButton(
              label: 'Measurements',
              icon: Icons.straighten,
              isSelected: _selectedChart == 'measurements',
              onTap: () => setState(() => _selectedChart = 'measurements'),
            ),
          ),
      ],
    );
  }

  Widget _buildChartTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart(List<ProgressPhoto> photos) {
    if (photos.isEmpty) return _buildNoDataMessage('No weight data available');

    // Sort by date
    photos.sort((a, b) => a.takenAt.compareTo(b.takenAt));

    final spots = photos.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight!);
    }).toList();

    final minWeight = photos
        .map((p) => p.weight!)
        .reduce((a, b) => a < b ? a : b);
    final maxWeight = photos
        .map((p) => p.weight!)
        .reduce((a, b) => a > b ? a : b);
    final padding = (maxWeight - minWeight) * 0.1 + 2;

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppColors.textSecondary.withValues(alpha: 0.1),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < photos.length) {
                      final photo = photos[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${photo.takenAt.day}/${photo.takenAt.month}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minY: minWeight - padding,
            maxY: maxWeight + padding,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: AppColors.primary,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final index = spot.spotIndex;
                    final photo = photos[index];
                    return LineTooltipItem(
                      '${photo.weight!.toStringAsFixed(1)} kg\n${photo.formattedDate}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementChart(List<ProgressPhoto> photos) {
    if (photos.isEmpty) {
      return _buildNoDataMessage('No measurement data available');
    }

    // Filter photos that have the selected measurement
    final filteredPhotos = photos
        .where(
          (p) =>
              p.measurements != null &&
              p.measurements!.containsKey(_selectedMeasurement),
        )
        .toList();

    if (filteredPhotos.isEmpty) {
      return _buildNoDataMessage('No $_selectedMeasurement data available');
    }

    // Sort by date
    filteredPhotos.sort((a, b) => a.takenAt.compareTo(b.takenAt));

    final spots = filteredPhotos.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.measurements![_selectedMeasurement]!,
      );
    }).toList();

    final values = filteredPhotos
        .map((p) => p.measurements![_selectedMeasurement]!)
        .toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxValue - minValue) * 0.1 + 2;

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppColors.textSecondary.withValues(alpha: 0.1),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < filteredPhotos.length) {
                      final photo = filteredPhotos[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${photo.takenAt.day}/${photo.takenAt.month}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minY: minValue - padding,
            maxY: maxValue + padding,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.secondary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: AppColors.secondary,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.secondary.withValues(alpha: 0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final index = spot.spotIndex;
                    final photo = filteredPhotos[index];
                    final value = photo.measurements![_selectedMeasurement]!;
                    return LineTooltipItem(
                      '${value.toStringAsFixed(1)} cm\n${photo.formattedDate}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightStats(List<ProgressPhoto> photos) {
    if (photos.length < 2) return const SizedBox.shrink();

    photos.sort((a, b) => a.takenAt.compareTo(b.takenAt));
    final first = photos.first.weight!;
    final last = photos.last.weight!;
    final change = last - first;
    final isLoss = change < 0;

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatColumn(
                label: 'Starting',
                value: '${first.toStringAsFixed(1)} kg',
                color: AppColors.textSecondary,
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _buildStatColumn(
                label: 'Current',
                value: '${last.toStringAsFixed(1)} kg',
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _buildStatColumn(
                label: 'Change',
                value:
                    '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg',
                color: isLoss ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementSelector(List<ProgressPhoto> photos) {
    // Get all available measurements
    final availableMeasurements = <String>{};
    for (final photo in photos) {
      if (photo.measurements != null) {
        availableMeasurements.addAll(photo.measurements!.keys);
      }
    }

    if (availableMeasurements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Measurement',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableMeasurements.map((measurement) {
            final isSelected = _selectedMeasurement == measurement;
            return GestureDetector(
              onTap: () => setState(() => _selectedMeasurement = measurement),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatMeasurementName(measurement),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatMeasurementName(String name) {
    return name
        .replaceAll('_', ' ')
        .replaceFirst(name[0], name[0].toUpperCase());
  }

  Widget _buildEmptyState() {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Data Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add progress photos with weight or measurements to see charts',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataMessage(String message) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

/// Compact progress summary card for dashboard
class ProgressSummaryCard extends StatelessWidget {
  final VoidCallback? onTap;

  const ProgressSummaryCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoTimelineProvider>(
      builder: (context, provider, _) {
        final stats = provider.stats;
        final recentPhotos = provider.photos.take(3).toList();

        return GestureDetector(
          onTap: onTap,
          child: Card(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.photo_library, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Progress Photos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${stats.totalPhotos}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (recentPhotos.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 60,
                      child: Row(
                        children: [
                          ...recentPhotos.take(3).map((photo) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Image.file(
                                    File(photo.imagePath),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.background,
                                      child: const Icon(
                                        Icons.image,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          if (stats.totalPhotos > 3)
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '+${stats.totalPhotos - 3}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Start tracking your progress',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (stats.journeyDurationString != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.timeline,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Journey: ${stats.journeyDurationString}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
