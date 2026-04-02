import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../models/body_measurement.dart';
import '../progress/progress_photos_screen.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  MeasurementType _selectedType = MeasurementType.weight;

  // Sample data
  final List<BodyMeasurement> _measurements = [
    BodyMeasurement(
      id: '1',
      date: DateTime.now().subtract(const Duration(days: 30)),
      weight: 75.0,
      bodyFat: 20.0,
      chest: 100.0,
      waist: 85.0,
      hips: 95.0,
      bicepLeft: 35.0,
      bicepRight: 35.5,
    ),
    BodyMeasurement(
      id: '2',
      date: DateTime.now().subtract(const Duration(days: 20)),
      weight: 74.2,
      bodyFat: 19.5,
      chest: 100.5,
      waist: 84.0,
      hips: 94.5,
      bicepLeft: 35.5,
      bicepRight: 36.0,
    ),
    BodyMeasurement(
      id: '3',
      date: DateTime.now().subtract(const Duration(days: 10)),
      weight: 73.5,
      bodyFat: 18.8,
      chest: 101.0,
      waist: 83.0,
      hips: 94.0,
      bicepLeft: 36.0,
      bicepRight: 36.5,
    ),
    BodyMeasurement(
      id: '4',
      date: DateTime.now(),
      weight: 72.8,
      bodyFat: 18.2,
      chest: 101.5,
      waist: 82.0,
      hips: 93.5,
      bicepLeft: 36.5,
      bicepRight: 37.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Body Measurements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: _showHistory),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Latest measurements summary
            _buildLatestSummary(),
            const SizedBox(height: 24),

            // Measurement type selector
            _buildTypeSelector(),
            const SizedBox(height: 20),

            // Progress chart
            _buildProgressChart(),
            const SizedBox(height: 24),

            // All measurements grid
            _buildMeasurementsGrid(),
            const SizedBox(height: 24),

            // Progress photos section
            _buildProgressPhotosSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMeasurement,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Measurement',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLatestSummary() {
    final latest = _measurements.isNotEmpty ? _measurements.last : null;
    final previous = _measurements.length > 1
        ? _measurements[_measurements.length - 2]
        : null;

    double? weightChange;
    if (latest?.weight != null && previous?.weight != null) {
      weightChange = latest!.weight! - previous!.weight!;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Weight',
                latest?.weight?.toStringAsFixed(1) ?? '--',
                'kg',
                weightChange,
              ),
              _buildSummaryItem(
                'Body Fat',
                latest?.bodyFat?.toStringAsFixed(1) ?? '--',
                '%',
                null,
              ),
              _buildSummaryItem(
                'Waist',
                latest?.waist?.toStringAsFixed(1) ?? '--',
                'cm',
                null,
              ),
            ],
          ),
          if (_measurements.length >= 2) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  weightChange != null && weightChange < 0
                      ? Icons.trending_down
                      : Icons.trending_up,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getProgressMessage(weightChange),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    String unit,
    double? change,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                unit,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
        if (change != null)
          Text(
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}',
            style: TextStyle(
              color: change < 0 ? Colors.greenAccent : Colors.orangeAccent,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  String _getProgressMessage(double? weightChange) {
    if (weightChange == null) return 'Keep tracking!';
    if (weightChange < -1) return 'Great progress! Keep it up!';
    if (weightChange < 0) return 'Moving in the right direction!';
    if (weightChange < 1) return 'Stay consistent!';
    return 'Review your nutrition and exercise';
  }

  Widget _buildTypeSelector() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: MeasurementType.values.map((type) {
          final isSelected = type == _selectedType;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${type.icon} ${type.displayName}'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedType = type);
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgressChart() {
    final spots = _getChartData();

    if (spots.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No data to display',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: AppColors.divider, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < _measurements.length) {
                    final date = _measurements[index].date;
                    return Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    );
                  }
                  return const Text('');
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
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withAlpha(51),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getChartData() {
    final List<FlSpot> spots = [];

    for (int i = 0; i < _measurements.length; i++) {
      final measurement = _measurements[i];
      double? value;

      switch (_selectedType) {
        case MeasurementType.weight:
          value = measurement.weight;
          break;
        case MeasurementType.bodyFat:
          value = measurement.bodyFat;
          break;
        case MeasurementType.chest:
          value = measurement.chest;
          break;
        case MeasurementType.waist:
          value = measurement.waist;
          break;
        case MeasurementType.hips:
          value = measurement.hips;
          break;
        case MeasurementType.biceps:
          value =
              (measurement.bicepLeft ?? 0) + (measurement.bicepRight ?? 0) / 2;
          break;
        case MeasurementType.thighs:
          value =
              (measurement.thighLeft ?? 0) + (measurement.thighRight ?? 0) / 2;
          break;
        case MeasurementType.calves:
          value =
              (measurement.calfLeft ?? 0) + (measurement.calfRight ?? 0) / 2;
          break;
        case MeasurementType.neck:
          value = measurement.neck;
          break;
        case MeasurementType.shoulders:
          value = measurement.shoulders;
          break;
        case MeasurementType.forearms:
          value =
              (measurement.forearmLeft ?? 0) +
              (measurement.forearmRight ?? 0) / 2;
          break;
      }

      if (value != null && value > 0) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    return spots;
  }

  Widget _buildMeasurementsGrid() {
    final latest = _measurements.isNotEmpty ? _measurements.last : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Measurements',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildMeasurementCard('Weight', latest?.weight, 'kg', '⚖️'),
            _buildMeasurementCard('Body Fat', latest?.bodyFat, '%', '📊'),
            _buildMeasurementCard('Chest', latest?.chest, 'cm', '👕'),
            _buildMeasurementCard('Waist', latest?.waist, 'cm', '📏'),
            _buildMeasurementCard('Hips', latest?.hips, 'cm', '🩳'),
            _buildMeasurementCard('Shoulders', latest?.shoulders, 'cm', '🎽'),
            _buildMeasurementCard('Bicep (L)', latest?.bicepLeft, 'cm', '💪'),
            _buildMeasurementCard('Bicep (R)', latest?.bicepRight, 'cm', '💪'),
            _buildMeasurementCard('Thigh (L)', latest?.thighLeft, 'cm', '🦵'),
          ],
        ),
      ],
    );
  }

  Widget _buildMeasurementCard(
    String label,
    double? value,
    String unit,
    String emoji,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value?.toStringAsFixed(1) ?? '--',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress Photos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _addPhoto,
              icon: const Icon(Icons.add_a_photo, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.divider,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  size: 48,
                  color: AppColors.textSecondary.withAlpha(128),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No progress photos yet',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _addPhoto,
                  child: const Text('Add your first photo'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addMeasurement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMeasurementSheet(
        onSave: (measurement) {
          setState(() {
            _measurements.add(measurement);
          });
        },
      ),
    );
  }

  void _addPhoto() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProgressPhotosScreen()),
    );
  }

  void _showHistory() {
    final history = [..._measurements]
      ..sort((a, b) => b.date.compareTo(a.date));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Measurement History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatMeasurementDate(item.date),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            'W ${item.weight?.toStringAsFixed(1) ?? '--'}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'BF ${item.bodyFat?.toStringAsFixed(1) ?? '--'}%',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
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

  String _formatMeasurementDate(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _AddMeasurementSheet extends StatefulWidget {
  final Function(BodyMeasurement) onSave;

  const _AddMeasurementSheet({required this.onSave});

  @override
  State<_AddMeasurementSheet> createState() => _AddMeasurementSheetState();
}

class _AddMeasurementSheetState extends State<_AddMeasurementSheet> {
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              'Add Measurement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Weight', 'kg', _weightController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField('Body Fat', '%', _bodyFatController),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Chest', 'cm', _chestController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField('Waist', 'cm', _waistController),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField('Hips', 'cm', _hipsController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Measurement',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String unit,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _save() {
    final measurement = BodyMeasurement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      weight: double.tryParse(_weightController.text),
      bodyFat: double.tryParse(_bodyFatController.text),
      chest: double.tryParse(_chestController.text),
      waist: double.tryParse(_waistController.text),
      hips: double.tryParse(_hipsController.text),
    );

    widget.onSave(measurement);
    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Measurement saved!')));
  }
}
