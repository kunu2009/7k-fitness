import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../models/nutrition.dart';
import 'add_food_screen.dart';
import 'barcode_scanner_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  DateTime _selectedDate = DateTime.now();

  // Sample nutrition goals
  final NutritionGoals _goals = NutritionGoals.fromCaloriesAndSplit(
    calories: 2000,
    proteinPercent: 30,
    carbsPercent: 40,
    fatPercent: 30,
  );

  NutritionInfo _todayNutritionFor(List<FoodEntry> entries) {
    if (entries.isEmpty) return NutritionInfo.zero();
    return entries.map((e) => e.nutrition).reduce((a, b) => a + b);
  }

  // Helper to get entries for selected date
  List<FoodEntry> _getEntriesForDate(FitnessProvider provider) {
    return provider.foodEntriesForDate(_selectedDate);
  }

  // Helper to calculate calories remaining
  double _getCaloriesRemaining(NutritionInfo todayNutrition) {
    return _goals.calories - todayNutrition.calories;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (context, provider, child) {
        final entriesForDate = _getEntriesForDate(provider);
        final todayNutrition = _todayNutritionFor(entriesForDate);
        final caloriesRemaining = _getCaloriesRemaining(todayNutrition);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Nutrition'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanBarcode,
                tooltip: 'Scan Barcode',
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _selectDate,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date selector
                  _buildDateSelector(),
                  const SizedBox(height: 20),

                  // Calorie summary card
                  _buildCalorieSummaryCard(todayNutrition, caloriesRemaining),
                  const SizedBox(height: 20),

                  // Macro breakdown
                  _buildMacroBreakdown(todayNutrition),
                  const SizedBox(height: 24),

                  // Meals
                  _buildMealsSection(entriesForDate),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _addFood,
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Food',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    final isToday =
        _selectedDate.day == DateTime.now().day &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.year == DateTime.now().year;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
            });
          },
        ),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isToday
                  ? 'Today'
                  : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.add(const Duration(days: 1));
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalorieSummaryCard(
    NutritionInfo todayNutrition,
    double caloriesRemaining,
  ) {
    final progress = todayNutrition.calories / _goals.calories;
    final isOver = todayNutrition.calories > _goals.calories;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOver
              ? [Colors.red.shade400, Colors.red.shade600]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOver ? Colors.red : AppColors.primary).withAlpha(77),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCalorieColumn(
                'Eaten',
                todayNutrition.calories.toInt().toString(),
                Icons.restaurant,
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress.clamp(0, 1),
                      strokeWidth: 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          caloriesRemaining.abs().toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isOver ? 'over' : 'left',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildCalorieColumn('Burned', '0', Icons.local_fire_department),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMacroBreakdown(NutritionInfo todayNutrition) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Macros',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMacroItem(
                  'Protein',
                  todayNutrition.protein,
                  _goals.protein,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroItem(
                  'Carbs',
                  todayNutrition.carbs,
                  _goals.carbs,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroItem(
                  'Fat',
                  todayNutrition.fat,
                  _goals.fat,
                  AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Pie chart for macro distribution
          if (todayNutrition.totalMacros > 0)
            SizedBox(
              height: 150,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: [
                          PieChartSectionData(
                            value: todayNutrition.protein,
                            color: AppColors.success,
                            title: '${todayNutrition.proteinPercent.toInt()}%',
                            radius: 40,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PieChartSectionData(
                            value: todayNutrition.carbs,
                            color: AppColors.primary,
                            title: '${todayNutrition.carbsPercent.toInt()}%',
                            radius: 40,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PieChartSectionData(
                            value: todayNutrition.fat,
                            color: AppColors.warning,
                            title: '${todayNutrition.fatPercent.toInt()}%',
                            radius: 40,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Protein', AppColors.success),
                      const SizedBox(height: 8),
                      _buildLegendItem('Carbs', AppColors.primary),
                      const SizedBox(height: 8),
                      _buildLegendItem('Fat', AppColors.warning),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(
    String label,
    double current,
    double goal,
    Color color,
  ) {
    final progress = (current / goal).clamp(0.0, 1.0);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: color.withAlpha(51),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '${current.toInt()}g',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          '${goal.toInt()}g',
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMealsSection(List<FoodEntry> entriesForDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meals',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...MealType.values.map((meal) => _buildMealCard(meal, entriesForDate)),
      ],
    );
  }

  Widget _buildMealCard(MealType mealType, List<FoodEntry> entriesForDate) {
    final mealEntries = entriesForDate
        .where((e) => e.mealType == mealType)
        .toList();
    final mealCalories = mealEntries.isEmpty
        ? 0.0
        : mealEntries.map((e) => e.nutrition.calories).reduce((a, b) => a + b);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(mealType.icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          title: Text(
            mealType.displayName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Text(
            mealEntries.isEmpty
                ? 'No foods logged'
                : '${mealCalories.toInt()} cal • ${mealEntries.length} items',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            onPressed: () => _addFood(mealType: mealType),
          ),
          children: [
            if (mealEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 40,
                      color: AppColors.textSecondary.withAlpha(128),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No foods logged yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => _addFood(mealType: mealType),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Food'),
                    ),
                  ],
                ),
              )
            else
              ...mealEntries.map((entry) => _buildFoodEntryTile(entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodEntryTile(FoodEntry entry) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(entry.food.name, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        '${entry.servings} ${entry.food.servingUnit}',
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${entry.nutrition.calories.toInt()} cal',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            'P:${entry.nutrition.protein.toInt()}g C:${entry.nutrition.carbs.toInt()}g F:${entry.nutrition.fat.toInt()}g',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      onTap: () {
        // Edit entry
      },
      onLongPress: () {
        // Delete entry via provider
        final provider = Provider.of<FitnessProvider>(context, listen: false);
        provider.removeFoodEntry(entry.id);
      },
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addFood({MealType? mealType}) async {
    final result = await Navigator.push<FoodEntry>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddFoodScreen(defaultMealType: mealType ?? _getDefaultMealType()),
      ),
    );

    if (!mounted) return;
    if (result != null) {
      final provider = Provider.of<FitnessProvider>(context, listen: false);
      provider.addFoodEntry(result);
    }
  }

  MealType _getDefaultMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 21) return MealType.dinner;
    return MealType.snack;
  }

  void _scanBarcode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (!mounted) return;
    if (result != null && result is FoodItem) {
      // Create a food entry from the scanned item
      final entry = FoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        food: result,
        servings: 1.0,
        mealType: _getDefaultMealType(),
        loggedAt: DateTime.now(),
      );
      final provider = Provider.of<FitnessProvider>(context, listen: false);
      provider.addFoodEntry(entry);
    }
  }
}
