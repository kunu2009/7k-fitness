import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../models/body_measurement.dart';

class BodyCompositionScreen extends StatefulWidget {
  const BodyCompositionScreen({super.key});

  @override
  State<BodyCompositionScreen> createState() => _BodyCompositionScreenState();
}

class _BodyCompositionScreenState extends State<BodyCompositionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // BMI Calculator inputs
  double _height = 170; // cm
  double _weight = 70; // kg
  bool _isMetric = true;
  String _gender = 'male';
  int _age = 30;

  // Body Fat Calculator inputs
  double _waist = 80; // cm
  double _neck = 38; // cm
  double _hip = 95; // cm (for females)

  // Sample history data
  final List<BodyMeasurement> _measurementHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generateSampleHistory();
  }

  void _generateSampleHistory() {
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      _measurementHistory.add(
        BodyMeasurement(
          id: 'bm_$i',
          date: now.subtract(Duration(days: i * 30)),
          weight: 70 - (i * 0.5),
          bodyFatPercentage: 20 - (i * 0.3),
          muscleMass: 30 + (i * 0.2),
          bmi: 24.2 - (i * 0.2),
          waist: 80 - (i * 0.5),
          chest: 95,
          hip: 95,
          neck: 38,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Composition'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'BMI', icon: Icon(Icons.accessibility_new)),
            Tab(text: 'Body Fat', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Progress', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBMICalculator(),
          _buildBodyFatCalculator(),
          _buildProgressTracker(),
        ],
      ),
    );
  }

  Widget _buildBMICalculator() {
    final bmi = _calculateBMI();
    final category = _getBMICategory(bmi);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unit Toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Units:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Metric')),
                      ButtonSegment(value: false, label: Text('Imperial')),
                    ],
                    selected: {_isMetric},
                    onSelectionChanged: (value) {
                      setState(() => _isMetric = value.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Height Input
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.height, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Height: ${_isMetric ? '${_height.toInt()} cm' : '${(_height / 2.54).toStringAsFixed(1)} in'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _height,
                    min: 100,
                    max: 250,
                    divisions: 150,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() => _height = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Weight Input
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.monitor_weight,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Weight: ${_isMetric ? '${_weight.toInt()} kg' : '${(_weight * 2.205).toStringAsFixed(1)} lbs'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _weight,
                    min: 30,
                    max: 200,
                    divisions: 170,
                    activeColor: AppColors.secondary,
                    onChanged: (value) {
                      setState(() => _weight = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // BMI Result
          _buildBMIResultCard(bmi, category),
          const SizedBox(height: 16),

          // BMI Scale
          _buildBMIScale(bmi),
          const SizedBox(height: 16),

          // Health Info
          _buildHealthInfoCard(category),
        ],
      ),
    );
  }

  Widget _buildBMIResultCard(double bmi, BMICategory category) {
    return Card(
      color: _getCategoryColor(category).withAlpha(25),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Your BMI',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              bmi.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: _getCategoryColor(category),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getCategoryColor(category),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIScale(double bmi) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BMI Scale',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  _buildScaleSegment(Colors.blue, 'Underweight', 18.5, bmi),
                  _buildScaleSegment(Colors.green, 'Normal', 24.9 - 18.5, bmi),
                  _buildScaleSegment(
                    Colors.orange,
                    'Overweight',
                    29.9 - 24.9,
                    bmi,
                  ),
                  _buildScaleSegment(Colors.red, 'Obese', 10, bmi),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('< 18.5', style: TextStyle(fontSize: 10)),
                Text('18.5-24.9', style: TextStyle(fontSize: 10)),
                Text('25-29.9', style: TextStyle(fontSize: 10)),
                Text('30+', style: TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleSegment(
    Color color,
    String label,
    double flex,
    double currentBmi,
  ) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildHealthInfoCard(BMICategory category) {
    String advice;
    IconData icon;

    switch (category) {
      case BMICategory.underweight:
        advice =
            'Consider increasing your caloric intake with nutritious foods. Focus on protein-rich meals and strength training to build muscle mass.';
        icon = Icons.restaurant;
        break;
      case BMICategory.normal:
        advice =
            'Great job! Maintain your healthy weight with a balanced diet and regular exercise. Keep up the good work!';
        icon = Icons.thumb_up;
        break;
      case BMICategory.overweight:
        advice =
            'Consider a balanced diet with reduced caloric intake and increased physical activity. Aim for 150 minutes of moderate exercise per week.';
        icon = Icons.directions_run;
        break;
      case BMICategory.obese:
        advice =
            'Consult with a healthcare provider for personalized advice. Focus on sustainable lifestyle changes including diet and exercise.';
        icon = Icons.medical_services;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _getCategoryColor(category)),
                const SizedBox(width: 8),
                const Text(
                  'Health Advice',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              advice,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyFatCalculator() {
    final bodyFat = _calculateBodyFat();
    final category = _getBodyFatCategory(bodyFat);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gender Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Gender:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'male', label: Text('Male')),
                      ButtonSegment(value: 'female', label: Text('Female')),
                    ],
                    selected: {_gender},
                    onSelectionChanged: (value) {
                      setState(() => _gender = value.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Age Input
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cake, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Age: $_age years',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _age.toDouble(),
                    min: 18,
                    max: 80,
                    divisions: 62,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() => _age = value.toInt());
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Measurements Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Body Measurements (cm)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildMeasurementSlider(
                    'Waist',
                    _waist,
                    Icons.straighten,
                    60,
                    150,
                    Colors.orange,
                    (value) => setState(() => _waist = value),
                  ),
                  const SizedBox(height: 12),
                  _buildMeasurementSlider(
                    'Neck',
                    _neck,
                    Icons.accessibility,
                    25,
                    55,
                    Colors.blue,
                    (value) => setState(() => _neck = value),
                  ),
                  if (_gender == 'female') ...[
                    const SizedBox(height: 12),
                    _buildMeasurementSlider(
                      'Hip',
                      _hip,
                      Icons.accessibility_new,
                      60,
                      150,
                      Colors.purple,
                      (value) => setState(() => _hip = value),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildMeasurementSlider(
                    'Height',
                    _height,
                    Icons.height,
                    100,
                    250,
                    Colors.green,
                    (value) => setState(() => _height = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Body Fat Result
          _buildBodyFatResultCard(bodyFat, category),
          const SizedBox(height: 16),

          // Body Fat Ranges
          _buildBodyFatRangesCard(),
        ],
      ),
    );
  }

  Widget _buildMeasurementSlider(
    String label,
    double value,
    IconData icon,
    double min,
    double max,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              '$label: ${value.toInt()} cm',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildBodyFatResultCard(double bodyFat, String category) {
    Color categoryColor;
    switch (category) {
      case 'Essential':
        categoryColor = Colors.red;
        break;
      case 'Athletes':
        categoryColor = Colors.blue;
        break;
      case 'Fitness':
        categoryColor = Colors.green;
        break;
      case 'Average':
        categoryColor = Colors.orange;
        break;
      default:
        categoryColor = Colors.red;
    }

    return Card(
      color: categoryColor.withAlpha(25),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Estimated Body Fat',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  bodyFat.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Using US Navy Method',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyFatRangesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Body Fat Categories',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildCategoryRow(
              'Essential',
              _gender == 'male' ? '2-5%' : '10-13%',
              Colors.red,
            ),
            _buildCategoryRow(
              'Athletes',
              _gender == 'male' ? '6-13%' : '14-20%',
              Colors.blue,
            ),
            _buildCategoryRow(
              'Fitness',
              _gender == 'male' ? '14-17%' : '21-24%',
              Colors.green,
            ),
            _buildCategoryRow(
              'Average',
              _gender == 'male' ? '18-24%' : '25-31%',
              Colors.orange,
            ),
            _buildCategoryRow(
              'Obese',
              _gender == 'male' ? '25%+' : '32%+',
              Colors.red[800]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String name, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          Text(range, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProgressTracker() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Weight',
                  '${_weight.toInt()} kg',
                  Icons.monitor_weight,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'BMI',
                  _calculateBMI().toStringAsFixed(1),
                  Icons.accessibility,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Body Fat',
                  '${_calculateBodyFat().toStringAsFixed(1)}%',
                  Icons.pie_chart,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Muscle',
                  '30.5 kg',
                  Icons.fitness_center,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weight Progress Chart
          _buildProgressChart(
            'Weight Progress',
            _getWeightData(),
            'kg',
            Colors.blue,
          ),
          const SizedBox(height: 24),

          // Body Fat Progress Chart
          _buildProgressChart(
            'Body Fat Progress',
            _getBodyFatData(),
            '%',
            Colors.orange,
          ),
          const SizedBox(height: 24),

          // Measurement History
          _buildMeasurementHistoryCard(),
          const SizedBox(height: 16),

          // Add Measurement Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddMeasurementDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add New Measurement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart(
    String title,
    List<FlSpot> data,
    String unit,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withAlpha(50),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}$unit',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                          ];
                          if (value.toInt() < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                months[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: color,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withAlpha(50),
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

  List<FlSpot> _getWeightData() {
    return List.generate(
      7,
      (index) => FlSpot(index.toDouble(), 73 - (index * 0.5)),
    );
  }

  List<FlSpot> _getBodyFatData() {
    return List.generate(
      7,
      (index) => FlSpot(index.toDouble(), 22 - (index * 0.3)),
    );
  }

  Widget _buildMeasurementHistoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Recent Measurements',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 8),
            ..._measurementHistory.take(3).map((m) => _buildMeasurementRow(m)),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementRow(BodyMeasurement measurement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(measurement.date),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${measurement.weight?.toStringAsFixed(1)} kg • BMI ${measurement.bmi?.toStringAsFixed(1)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          if (measurement.bodyFatPercentage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${measurement.bodyFatPercentage?.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showAddMeasurementDialog() {
    double dialogWeight = _weight;
    double dialogWaist = _waist;
    double dialogChest = 95;
    double dialogHip = _hip;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Add Measurement',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDialogSlider(
                'Weight',
                dialogWeight,
                'kg',
                30,
                200,
                AppColors.primary,
                (value) => setDialogState(() => dialogWeight = value),
              ),
              _buildDialogSlider(
                'Waist',
                dialogWaist,
                'cm',
                50,
                150,
                Colors.orange,
                (value) => setDialogState(() => dialogWaist = value),
              ),
              _buildDialogSlider(
                'Chest',
                dialogChest,
                'cm',
                60,
                150,
                Colors.blue,
                (value) => setDialogState(() => dialogChest = value),
              ),
              _buildDialogSlider(
                'Hip',
                dialogHip,
                'cm',
                60,
                150,
                Colors.purple,
                (value) => setDialogState(() => dialogHip = value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _weight = dialogWeight;
                      _waist = dialogWaist;
                      _hip = dialogHip;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Measurement saved!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Measurement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogSlider(
    String label,
    double value,
    String unit,
    double min,
    double max,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              '${value.toInt()} $unit',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Calculation methods
  double _calculateBMI() {
    final heightM = _height / 100;
    return _weight / (heightM * heightM);
  }

  BMICategory _getBMICategory(double bmi) {
    if (bmi < 18.5) return BMICategory.underweight;
    if (bmi < 25) return BMICategory.normal;
    if (bmi < 30) return BMICategory.overweight;
    return BMICategory.obese;
  }

  Color _getCategoryColor(BMICategory category) {
    switch (category) {
      case BMICategory.underweight:
        return Colors.blue;
      case BMICategory.normal:
        return Colors.green;
      case BMICategory.overweight:
        return Colors.orange;
      case BMICategory.obese:
        return Colors.red;
    }
  }

  double _calculateBodyFat() {
    // US Navy Method
    if (_gender == 'male') {
      return 495 /
              (1.0324 -
                  0.19077 * _log10(_waist - _neck) +
                  0.15456 * _log10(_height)) -
          450;
    } else {
      return 495 /
              (1.29579 -
                  0.35004 * _log10(_waist + _hip - _neck) +
                  0.22100 * _log10(_height)) -
          450;
    }
  }

  double _log10(double x) => x > 0 ? (x.toString().length - 1) / 0.301 : 0;

  String _getBodyFatCategory(double bodyFat) {
    if (_gender == 'male') {
      if (bodyFat < 6) return 'Essential';
      if (bodyFat < 14) return 'Athletes';
      if (bodyFat < 18) return 'Fitness';
      if (bodyFat < 25) return 'Average';
      return 'Obese';
    } else {
      if (bodyFat < 14) return 'Essential';
      if (bodyFat < 21) return 'Athletes';
      if (bodyFat < 25) return 'Fitness';
      if (bodyFat < 32) return 'Average';
      return 'Obese';
    }
  }
}

enum BMICategory {
  underweight,
  normal,
  overweight,
  obese;

  String get name {
    switch (this) {
      case BMICategory.underweight:
        return 'Underweight';
      case BMICategory.normal:
        return 'Normal';
      case BMICategory.overweight:
        return 'Overweight';
      case BMICategory.obese:
        return 'Obese';
    }
  }
}
