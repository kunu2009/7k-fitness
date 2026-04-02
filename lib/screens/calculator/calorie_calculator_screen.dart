import 'package:flutter/material.dart';

class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({super.key});

  @override
  State<CalorieCalculatorScreen> createState() =>
      _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // User Data
  bool _isMale = true;
  double _weight = 70; // kg
  double _height = 175; // cm
  int _age = 25;
  ActivityLevel _activityLevel = ActivityLevel.moderatelyActive;
  FitnessGoal _fitnessGoal = FitnessGoal.maintain;

  // Results
  double? _bmr;
  double? _tdee;
  MacroSplit? _macros;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculateAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateAll() {
    // Calculate BMR using Mifflin-St Jeor Equation
    if (_isMale) {
      _bmr = 10 * _weight + 6.25 * _height - 5 * _age + 5;
    } else {
      _bmr = 10 * _weight + 6.25 * _height - 5 * _age - 161;
    }

    // Calculate TDEE
    _tdee = _bmr! * _activityLevel.multiplier;

    // Adjust for goal
    double targetCalories = _tdee!;
    switch (_fitnessGoal) {
      case FitnessGoal.lose:
        targetCalories = _tdee! - 500; // 0.5 kg/week loss
        break;
      case FitnessGoal.loseFast:
        targetCalories = _tdee! - 750; // 0.75 kg/week loss
        break;
      case FitnessGoal.gain:
        targetCalories = _tdee! + 300; // Lean gain
        break;
      case FitnessGoal.gainFast:
        targetCalories = _tdee! + 500; // Bulk
        break;
      case FitnessGoal.maintain:
        targetCalories = _tdee!;
    }

    // Calculate Macros based on goal
    _macros = _calculateMacros(targetCalories);

    setState(() {});
  }

  MacroSplit _calculateMacros(double calories) {
    double proteinPercentage;
    double fatPercentage;
    double carbPercentage;

    switch (_fitnessGoal) {
      case FitnessGoal.lose:
      case FitnessGoal.loseFast:
        proteinPercentage = 0.35;
        fatPercentage = 0.30;
        carbPercentage = 0.35;
        break;
      case FitnessGoal.gain:
      case FitnessGoal.gainFast:
        proteinPercentage = 0.25;
        fatPercentage = 0.25;
        carbPercentage = 0.50;
        break;
      case FitnessGoal.maintain:
        proteinPercentage = 0.30;
        fatPercentage = 0.25;
        carbPercentage = 0.45;
    }

    return MacroSplit(
      calories: calories,
      protein: (calories * proteinPercentage) / 4, // 4 cal per gram
      carbs: (calories * carbPercentage) / 4,
      fat: (calories * fatPercentage) / 9, // 9 cal per gram
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Calculator'),
        centerTitle: true,
        backgroundColor: Colors.orange[600],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Calculator'),
            Tab(text: 'Results'),
            Tab(text: 'Guide'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCalculatorTab(), _buildResultsTab(), _buildGuideTab()],
      ),
    );
  }

  Widget _buildCalculatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gender Selection
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
                    'Gender',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _GenderButton(
                          label: 'Male',
                          icon: Icons.male,
                          isSelected: _isMale,
                          onTap: () {
                            setState(() => _isMale = true);
                            _calculateAll();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GenderButton(
                          label: 'Female',
                          icon: Icons.female,
                          isSelected: !_isMale,
                          onTap: () {
                            setState(() => _isMale = false);
                            _calculateAll();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Age Input
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Age',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_age years',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _age.toDouble(),
                    min: 15,
                    max: 80,
                    divisions: 65,
                    activeColor: Colors.orange,
                    onChanged: (value) {
                      setState(() => _age = value.round());
                      _calculateAll();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Height Input
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Height',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_height.round()} cm',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _height,
                    min: 120,
                    max: 220,
                    divisions: 100,
                    activeColor: Colors.orange,
                    onChanged: (value) {
                      setState(() => _height = value);
                      _calculateAll();
                    },
                  ),
                  Text(
                    '${(_height / 30.48).toStringAsFixed(1)} feet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Weight Input
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Weight',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_weight.round()} kg',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _weight,
                    min: 30,
                    max: 200,
                    divisions: 170,
                    activeColor: Colors.orange,
                    onChanged: (value) {
                      setState(() => _weight = value);
                      _calculateAll();
                    },
                  ),
                  Text(
                    '${(_weight * 2.205).toStringAsFixed(1)} lbs',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Activity Level
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
                    'Activity Level',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ...ActivityLevel.values.map((level) {
                    return _ActivityLevelTile(
                      level: level,
                      isSelected: _activityLevel == level,
                      onTap: () {
                        setState(() => _activityLevel = level);
                        _calculateAll();
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fitness Goal
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
                    'Fitness Goal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ...FitnessGoal.values.map((goal) {
                    return _GoalTile(
                      goal: goal,
                      isSelected: _fitnessGoal == goal,
                      onTap: () {
                        setState(() => _fitnessGoal = goal);
                        _calculateAll();
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // View Results Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _tabController.animateTo(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Results',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    if (_bmr == null || _tdee == null || _macros == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // BMR & TDEE Cards
          Row(
            children: [
              Expanded(
                child: _ResultCard(
                  title: 'BMR',
                  value: '${_bmr!.round()}',
                  unit: 'cal/day',
                  description: 'Basal Metabolic Rate',
                  color: Colors.blue,
                  icon: Icons.nights_stay,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultCard(
                  title: 'TDEE',
                  value: '${_tdee!.round()}',
                  unit: 'cal/day',
                  description: 'Total Daily Expenditure',
                  color: Colors.green,
                  icon: Icons.local_fire_department,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Target Calories Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[600]!, Colors.orange[800]!],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Your Daily Target',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_macros!.calories.round()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text(
                        ' calories',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _fitnessGoal.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Macros Breakdown
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Macro Breakdown',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 20),

                  // Visual breakdown
                  Row(
                    children: [
                      Expanded(
                        flex: ((_macros!.protein * 4 / _macros!.calories) * 100)
                            .round(),
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: ((_macros!.carbs * 4 / _macros!.calories) * 100)
                            .round(),
                        child: Container(height: 12, color: Colors.blue[400]),
                      ),
                      Expanded(
                        flex: ((_macros!.fat * 9 / _macros!.calories) * 100)
                            .round(),
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.amber[400],
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Macro cards
                  Row(
                    children: [
                      Expanded(
                        child: _MacroCard(
                          name: 'Protein',
                          grams: _macros!.protein.round(),
                          color: Colors.red[400]!,
                          icon: Icons.egg_alt,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MacroCard(
                          name: 'Carbs',
                          grams: _macros!.carbs.round(),
                          color: Colors.blue[400]!,
                          icon: Icons.bakery_dining,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MacroCard(
                          name: 'Fat',
                          grams: _macros!.fat.round(),
                          color: Colors.amber[400]!,
                          icon: Icons.water_drop,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // BMI Card
          _BmiCard(weight: _weight, height: _height),
          const SizedBox(height: 16),

          // Weekly Projection
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
                    'Weekly Projection',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  _buildProjection(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProjection() {
    final deficit = _tdee! - _macros!.calories;
    final weeklyChange = (deficit * 7) / 7700; // 7700 cal = 1 kg

    if (deficit.abs() < 100) {
      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.balance, color: Colors.green[600]),
        ),
        title: const Text('Maintain Weight'),
        subtitle: const Text('You\'re eating at maintenance level'),
      );
    } else if (deficit > 0) {
      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.trending_down, color: Colors.blue[600]),
        ),
        title: Text('Lose ~${weeklyChange.toStringAsFixed(2)} kg/week'),
        subtitle: Text('${deficit.round()} calorie deficit per day'),
      );
    } else {
      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.trending_up, color: Colors.orange[600]),
        ),
        title: Text('Gain ~${weeklyChange.abs().toStringAsFixed(2)} kg/week'),
        subtitle: Text('${deficit.abs().round()} calorie surplus per day'),
      );
    }
  }

  Widget _buildGuideTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuideSection(
            title: 'What is BMR?',
            icon: Icons.nights_stay,
            color: Colors.blue,
            content:
                'Basal Metabolic Rate (BMR) is the number of calories your body needs to maintain basic functions like breathing, circulation, and cell production while at complete rest.',
          ),
          _GuideSection(
            title: 'What is TDEE?',
            icon: Icons.local_fire_department,
            color: Colors.green,
            content:
                'Total Daily Energy Expenditure (TDEE) is the total number of calories you burn each day, including your BMR plus all physical activities.',
          ),
          _GuideSection(
            title: 'Understanding Macros',
            icon: Icons.pie_chart,
            color: Colors.orange,
            content:
                'Macronutrients are the three main nutrients your body needs:\n\n• Protein (4 cal/g): Essential for muscle repair and growth\n• Carbohydrates (4 cal/g): Your body\'s primary energy source\n• Fat (9 cal/g): Important for hormone production and nutrient absorption',
          ),
          _GuideSection(
            title: 'Weight Loss Tips',
            icon: Icons.trending_down,
            color: Colors.purple,
            content:
                '• Aim for a 500-750 calorie deficit for sustainable loss\n• Don\'t go below 1200 cal (women) or 1500 cal (men)\n• Prioritize protein to preserve muscle\n• Include strength training in your routine\n• Stay consistent - results take time!',
          ),
          _GuideSection(
            title: 'Weight Gain Tips',
            icon: Icons.trending_up,
            color: Colors.red,
            content:
                '• Aim for 300-500 calorie surplus for lean gains\n• Consume 1.6-2.2g protein per kg body weight\n• Progressive overload in resistance training\n• Get adequate sleep for recovery\n• Track your progress weekly',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Supporting Classes and Widgets

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extraActive,
}

extension ActivityLevelExtension on ActivityLevel {
  String get name {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
      case ActivityLevel.extraActive:
        return 'Extra Active';
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Little or no exercise, desk job';
      case ActivityLevel.lightlyActive:
        return 'Light exercise 1-3 days/week';
      case ActivityLevel.moderatelyActive:
        return 'Moderate exercise 3-5 days/week';
      case ActivityLevel.veryActive:
        return 'Hard exercise 6-7 days/week';
      case ActivityLevel.extraActive:
        return 'Very hard exercise, physical job';
    }
  }

  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.extraActive:
        return 1.9;
    }
  }
}

enum FitnessGoal { loseFast, lose, maintain, gain, gainFast }

extension FitnessGoalExtension on FitnessGoal {
  String get name {
    switch (this) {
      case FitnessGoal.loseFast:
        return 'Lose Fast';
      case FitnessGoal.lose:
        return 'Lose Weight';
      case FitnessGoal.maintain:
        return 'Maintain';
      case FitnessGoal.gain:
        return 'Lean Gain';
      case FitnessGoal.gainFast:
        return 'Bulk Up';
    }
  }

  String get description {
    switch (this) {
      case FitnessGoal.loseFast:
        return '-750 cal/day (~0.75 kg/week)';
      case FitnessGoal.lose:
        return '-500 cal/day (~0.5 kg/week)';
      case FitnessGoal.maintain:
        return 'Maintain current weight';
      case FitnessGoal.gain:
        return '+300 cal/day (lean muscle)';
      case FitnessGoal.gainFast:
        return '+500 cal/day (bulk)';
    }
  }

  IconData get icon {
    switch (this) {
      case FitnessGoal.loseFast:
        return Icons.keyboard_double_arrow_down;
      case FitnessGoal.lose:
        return Icons.arrow_downward;
      case FitnessGoal.maintain:
        return Icons.balance;
      case FitnessGoal.gain:
        return Icons.arrow_upward;
      case FitnessGoal.gainFast:
        return Icons.keyboard_double_arrow_up;
    }
  }
}

class MacroSplit {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  MacroSplit({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.orange[600] : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.orange[800] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityLevelTile extends StatelessWidget {
  final ActivityLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityLevelTile({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.orange : Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    level.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '×${level.multiplier}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final FitnessGoal goal;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalTile({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                goal.icon,
                color: isSelected ? Colors.orange[600] : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    goal.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: Colors.orange[600]),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String description;
  final Color color;
  final IconData icon;

  const _ResultCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.description,
    required this.color,
    required this.icon,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  ' $unit',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String name;
  final int grams;
  final Color color;
  final IconData icon;

  const _MacroCard({
    required this.name,
    required this.grams,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '${grams}g',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
          Text(name, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

class _BmiCard extends StatelessWidget {
  final double weight;
  final double height;

  const _BmiCard({required this.weight, required this.height});

  @override
  Widget build(BuildContext context) {
    final bmi = weight / ((height / 100) * (height / 100));
    final category = _getBmiCategory(bmi);
    final color = _getBmiColor(bmi);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Body Mass Index (BMI)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        bmi.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        'kg/m²',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getBmiAdvice(bmi),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // BMI Scale
            Row(
              children: [
                Expanded(
                  flex: 185,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 65,
                  child: Container(height: 8, color: Colors.green[400]),
                ),
                Expanded(
                  flex: 50,
                  child: Container(height: 8, color: Colors.orange[400]),
                ),
                Expanded(
                  flex: 100,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '18.5',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
                Text(
                  '25',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
                Text(
                  '30',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
                Text(
                  '40',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBmiAdvice(double bmi) {
    if (bmi < 18.5) return 'Consider gaining weight for better health.';
    if (bmi < 25) return 'You\'re in a healthy weight range!';
    if (bmi < 30) return 'Consider losing some weight for better health.';
    return 'Consult a healthcare provider for guidance.';
  }
}

class _GuideSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String content;

  const _GuideSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
