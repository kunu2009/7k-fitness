import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for real nutrition/meal tracking with persistence
class NutritionProvider with ChangeNotifier {
  static const String _keyMealHistory = 'meal_history';
  static const String _keyCalorieGoal = 'calorie_goal';
  static const String _keyProteinGoal = 'protein_goal';
  static const String _keyCarbsGoal = 'carbs_goal';
  static const String _keyFatGoal = 'fat_goal';
  static const String _keyFavoriteFoods = 'favorite_foods';
  static const String _keyRecentFoods = 'recent_foods';

  SharedPreferences? _prefs;

  // Daily goals
  int _calorieGoal = 2000;
  int _proteinGoal = 150; // grams
  int _carbsGoal = 250; // grams
  int _fatGoal = 65; // grams

  // Today's data
  List<MealEntry> _todayMeals = [];
  NutritionSummary _todaySummary = NutritionSummary.empty();

  // History
  Map<String, DailyNutrition> _nutritionHistory = {};

  // Favorites and recent
  List<FoodItem> _favoriteFoods = [];
  List<FoodItem> _recentFoods = [];

  // Getters
  int get calorieGoal => _calorieGoal;
  int get proteinGoal => _proteinGoal;
  int get carbsGoal => _carbsGoal;
  int get fatGoal => _fatGoal;

  List<MealEntry> get todayMeals => List.unmodifiable(_todayMeals);
  NutritionSummary get todaySummary => _todaySummary;
  List<FoodItem> get favoriteFoods => List.unmodifiable(_favoriteFoods);
  List<FoodItem> get recentFoods => List.unmodifiable(_recentFoods);

  double get calorieProgress =>
      (_todaySummary.calories / _calorieGoal).clamp(0.0, 1.5);
  double get proteinProgress =>
      (_todaySummary.protein / _proteinGoal).clamp(0.0, 1.5);
  double get carbsProgress =>
      (_todaySummary.carbs / _carbsGoal).clamp(0.0, 1.5);
  double get fatProgress => (_todaySummary.fat / _fatGoal).clamp(0.0, 1.5);

  int get remainingCalories =>
      (_calorieGoal - _todaySummary.calories).clamp(0, _calorieGoal);

  /// Initialize the provider
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadGoals();
    await _loadHistory();
    await _loadFavorites();
    _loadTodayData();
  }

  Future<void> _loadGoals() async {
    if (_prefs == null) return;
    _calorieGoal = _prefs!.getInt(_keyCalorieGoal) ?? 2000;
    _proteinGoal = _prefs!.getInt(_keyProteinGoal) ?? 150;
    _carbsGoal = _prefs!.getInt(_keyCarbsGoal) ?? 250;
    _fatGoal = _prefs!.getInt(_keyFatGoal) ?? 65;
  }

  Future<void> _loadHistory() async {
    if (_prefs == null) return;

    final historyJson = _prefs!.getString(_keyMealHistory);
    if (historyJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(historyJson);
        _nutritionHistory = decoded.map(
          (key, value) => MapEntry(key, DailyNutrition.fromJson(value)),
        );
      } catch (e) {
        debugPrint('Error loading nutrition history: $e');
      }
    }
  }

  Future<void> _loadFavorites() async {
    if (_prefs == null) return;

    final favJson = _prefs!.getString(_keyFavoriteFoods);
    if (favJson != null) {
      try {
        final List decoded = jsonDecode(favJson);
        _favoriteFoods = decoded.map((e) => FoodItem.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error loading favorites: $e');
      }
    }

    final recentJson = _prefs!.getString(_keyRecentFoods);
    if (recentJson != null) {
      try {
        final List decoded = jsonDecode(recentJson);
        _recentFoods = decoded.map((e) => FoodItem.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error loading recent foods: $e');
      }
    }
  }

  void _loadTodayData() {
    final today = _getTodayKey();
    if (_nutritionHistory.containsKey(today)) {
      final data = _nutritionHistory[today]!;
      _todayMeals = List.from(data.meals);
      _calculateTodaySummary();
    } else {
      _todayMeals = [];
      _todaySummary = NutritionSummary.empty();
    }
  }

  void _calculateTodaySummary() {
    double calories = 0, protein = 0, carbs = 0, fat = 0, fiber = 0, sugar = 0;

    for (final meal in _todayMeals) {
      calories += meal.totalCalories;
      protein += meal.totalProtein;
      carbs += meal.totalCarbs;
      fat += meal.totalFat;
      fiber += meal.totalFiber;
      sugar += meal.totalSugar;
    }

    _todaySummary = NutritionSummary(
      calories: calories.toInt(),
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
    );
  }

  /// Add a meal
  Future<void> addMeal(MealEntry meal) async {
    _todayMeals.add(meal);
    _calculateTodaySummary();

    // Add foods to recent
    for (final food in meal.foods) {
      _addToRecent(food);
    }

    await _saveTodayData();
    await _saveRecent();
    notifyListeners();
  }

  /// Add a quick food item to a meal type
  Future<void> addFood(FoodItem food, MealType mealType) async {
    // Find or create meal for this type
    var mealIndex = _todayMeals.indexWhere((m) => m.type == mealType);

    if (mealIndex >= 0) {
      final existingMeal = _todayMeals[mealIndex];
      final updatedFoods = [...existingMeal.foods, food];
      _todayMeals[mealIndex] = existingMeal.copyWith(foods: updatedFoods);
    } else {
      _todayMeals.add(
        MealEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: mealType,
          foods: [food],
          loggedAt: DateTime.now(),
        ),
      );
    }

    _addToRecent(food);
    _calculateTodaySummary();
    await _saveTodayData();
    await _saveRecent();
    notifyListeners();
  }

  /// Remove a food from a meal
  Future<void> removeFood(String mealId, String foodId) async {
    final mealIndex = _todayMeals.indexWhere((m) => m.id == mealId);
    if (mealIndex >= 0) {
      final meal = _todayMeals[mealIndex];
      final updatedFoods = meal.foods.where((f) => f.id != foodId).toList();

      if (updatedFoods.isEmpty) {
        _todayMeals.removeAt(mealIndex);
      } else {
        _todayMeals[mealIndex] = meal.copyWith(foods: updatedFoods);
      }

      _calculateTodaySummary();
      await _saveTodayData();
      notifyListeners();
    }
  }

  /// Delete entire meal
  Future<void> deleteMeal(String mealId) async {
    _todayMeals.removeWhere((m) => m.id == mealId);
    _calculateTodaySummary();
    await _saveTodayData();
    notifyListeners();
  }

  /// Toggle favorite
  Future<void> toggleFavorite(FoodItem food) async {
    final index = _favoriteFoods.indexWhere((f) => f.id == food.id);
    if (index >= 0) {
      _favoriteFoods.removeAt(index);
    } else {
      _favoriteFoods.insert(0, food);
      if (_favoriteFoods.length > 50) {
        _favoriteFoods = _favoriteFoods.take(50).toList();
      }
    }
    await _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String foodId) {
    return _favoriteFoods.any((f) => f.id == foodId);
  }

  void _addToRecent(FoodItem food) {
    _recentFoods.removeWhere((f) => f.id == food.id);
    _recentFoods.insert(0, food);
    if (_recentFoods.length > 20) {
      _recentFoods = _recentFoods.take(20).toList();
    }
  }

  /// Set goals
  Future<void> setCalorieGoal(int goal) async {
    _calorieGoal = goal;
    await _prefs?.setInt(_keyCalorieGoal, goal);
    notifyListeners();
  }

  Future<void> setMacroGoals({int? protein, int? carbs, int? fat}) async {
    if (protein != null) {
      _proteinGoal = protein;
      await _prefs?.setInt(_keyProteinGoal, protein);
    }
    if (carbs != null) {
      _carbsGoal = carbs;
      await _prefs?.setInt(_keyCarbsGoal, carbs);
    }
    if (fat != null) {
      _fatGoal = fat;
      await _prefs?.setInt(_keyFatGoal, fat);
    }
    notifyListeners();
  }

  Future<void> _saveTodayData() async {
    if (_prefs == null) return;

    final today = _getTodayKey();
    _nutritionHistory[today] = DailyNutrition(
      date: DateTime.now(),
      meals: _todayMeals,
      calorieGoal: _calorieGoal,
    );

    final historyJson = jsonEncode(
      _nutritionHistory.map((key, value) => MapEntry(key, value.toJson())),
    );
    await _prefs!.setString(_keyMealHistory, historyJson);
  }

  Future<void> _saveFavorites() async {
    if (_prefs == null) return;
    final json = jsonEncode(_favoriteFoods.map((f) => f.toJson()).toList());
    await _prefs!.setString(_keyFavoriteFoods, json);
  }

  Future<void> _saveRecent() async {
    if (_prefs == null) return;
    final json = jsonEncode(_recentFoods.map((f) => f.toJson()).toList());
    await _prefs!.setString(_keyRecentFoods, json);
  }

  /// Get weekly nutrition data
  List<DailyNutrition> getWeeklyData() {
    final List<DailyNutrition> weekData = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _getDateKey(date);

      if (_nutritionHistory.containsKey(key)) {
        weekData.add(_nutritionHistory[key]!);
      } else {
        weekData.add(
          DailyNutrition(date: date, meals: [], calorieGoal: _calorieGoal),
        );
      }
    }

    return weekData;
  }

  /// Get nutrition stats
  NutritionStats getStats() {
    final weekData = getWeeklyData();

    int totalCalories = 0;
    double totalProtein = 0, totalCarbs = 0, totalFat = 0;
    int daysLogged = 0;
    int daysGoalMet = 0;

    for (final day in weekData) {
      final dayCalories = day.totalCalories;
      if (dayCalories > 0) {
        daysLogged++;
        totalCalories += dayCalories;
        totalProtein += day.totalProtein;
        totalCarbs += day.totalCarbs;
        totalFat += day.totalFat;

        if (dayCalories <= day.calorieGoal * 1.1 &&
            dayCalories >= day.calorieGoal * 0.9) {
          daysGoalMet++;
        }
      }
    }

    final avgCalories = daysLogged > 0 ? totalCalories ~/ daysLogged : 0;
    final avgProtein = daysLogged > 0 ? totalProtein / daysLogged : 0;
    final avgCarbs = daysLogged > 0 ? totalCarbs / daysLogged : 0;
    final avgFat = daysLogged > 0 ? totalFat / daysLogged : 0;

    return NutritionStats(
      averageCalories: avgCalories,
      averageProtein: (avgProtein).toDouble(),
      averageCarbs: (avgCarbs).toDouble(),
      averageFat: (avgFat).toDouble(),
      daysLogged: daysLogged,
      daysGoalMet: daysGoalMet,
      totalMealsLogged: weekData.fold(0, (sum, d) => sum + d.meals.length),
    );
  }

  /// Get insights
  List<String> getInsights() {
    final insights = <String>[];
    final stats = getStats();

    if (_todaySummary.calories == 0 && DateTime.now().hour >= 10) {
      insights.add('🍳 Don\'t forget to log your breakfast!');
    }

    if (_todaySummary.protein < _proteinGoal * 0.5 &&
        DateTime.now().hour >= 14) {
      insights.add('💪 Consider adding more protein to reach your goal.');
    }

    if (stats.averageCalories > _calorieGoal * 1.2) {
      insights.add('📊 You\'ve been exceeding your calorie goal recently.');
    } else if (stats.averageCalories < _calorieGoal * 0.8 &&
        stats.daysLogged >= 3) {
      insights.add('⚠️ You might be under-eating. Make sure to fuel properly!');
    }

    if (stats.daysGoalMet >= 5) {
      insights.add(
        '🎉 Great consistency! ${stats.daysGoalMet}/7 days on target this week.',
      );
    }

    if (_todaySummary.fiber < 25 && _todaySummary.calories > 1500) {
      insights.add('🥬 Try adding more fiber-rich foods to your diet.');
    }

    return insights;
  }

  /// Get meals by type for today
  MealEntry? getMealByType(MealType type) {
    try {
      return _todayMeals.firstWhere((m) => m.type == type);
    } catch (_) {
      return null;
    }
  }

  String _getTodayKey() => _getDateKey(DateTime.now());

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Meal types
enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get icon {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }
}

/// Single food item
class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double servingSize;
  final String servingUnit;
  final String? barcode;
  final String? brand;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
    this.sugar = 0,
    this.servingSize = 100,
    this.servingUnit = 'g',
    this.barcode,
    this.brand,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'fiber': fiber,
    'sugar': sugar,
    'servingSize': servingSize,
    'servingUnit': servingUnit,
    'barcode': barcode,
    'brand': brand,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'] as String,
    name: json['name'] as String,
    calories: (json['calories'] as num).toDouble(),
    protein: (json['protein'] as num?)?.toDouble() ?? 0,
    carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
    fat: (json['fat'] as num?)?.toDouble() ?? 0,
    fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
    sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
    servingSize: (json['servingSize'] as num?)?.toDouble() ?? 100,
    servingUnit: json['servingUnit'] as String? ?? 'g',
    barcode: json['barcode'] as String?,
    brand: json['brand'] as String?,
  );

  FoodItem copyWith({double? servingSize}) {
    final ratio = (servingSize ?? this.servingSize) / this.servingSize;
    return FoodItem(
      id: id,
      name: name,
      calories: calories * ratio,
      protein: protein * ratio,
      carbs: carbs * ratio,
      fat: fat * ratio,
      fiber: fiber * ratio,
      sugar: sugar * ratio,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit,
      barcode: barcode,
      brand: brand,
    );
  }
}

/// Meal entry with multiple foods
class MealEntry {
  final String id;
  final MealType type;
  final List<FoodItem> foods;
  final DateTime loggedAt;
  final String? notes;

  MealEntry({
    required this.id,
    required this.type,
    required this.foods,
    required this.loggedAt,
    this.notes,
  });

  double get totalCalories => foods.fold(0, (sum, f) => sum + f.calories);
  double get totalProtein => foods.fold(0, (sum, f) => sum + f.protein);
  double get totalCarbs => foods.fold(0, (sum, f) => sum + f.carbs);
  double get totalFat => foods.fold(0, (sum, f) => sum + f.fat);
  double get totalFiber => foods.fold(0, (sum, f) => sum + f.fiber);
  double get totalSugar => foods.fold(0, (sum, f) => sum + f.sugar);

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'foods': foods.map((f) => f.toJson()).toList(),
    'loggedAt': loggedAt.toIso8601String(),
    'notes': notes,
  };

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
    id: json['id'] as String,
    type: MealType.values[json['type'] as int],
    foods: (json['foods'] as List).map((f) => FoodItem.fromJson(f)).toList(),
    loggedAt: DateTime.parse(json['loggedAt'] as String),
    notes: json['notes'] as String?,
  );

  MealEntry copyWith({List<FoodItem>? foods, String? notes}) => MealEntry(
    id: id,
    type: type,
    foods: foods ?? this.foods,
    loggedAt: loggedAt,
    notes: notes ?? this.notes,
  );
}

/// Daily nutrition data
class DailyNutrition {
  final DateTime date;
  final List<MealEntry> meals;
  final int calorieGoal;

  DailyNutrition({
    required this.date,
    required this.meals,
    required this.calorieGoal,
  });

  int get totalCalories =>
      meals.fold(0, (sum, m) => sum + m.totalCalories.toInt());
  double get totalProtein => meals.fold(0.0, (sum, m) => sum + m.totalProtein);
  double get totalCarbs => meals.fold(0.0, (sum, m) => sum + m.totalCarbs);
  double get totalFat => meals.fold(0.0, (sum, m) => sum + m.totalFat);

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'meals': meals.map((m) => m.toJson()).toList(),
    'calorieGoal': calorieGoal,
  };

  factory DailyNutrition.fromJson(Map<String, dynamic> json) => DailyNutrition(
    date: DateTime.parse(json['date'] as String),
    meals: (json['meals'] as List).map((m) => MealEntry.fromJson(m)).toList(),
    calorieGoal: json['calorieGoal'] as int? ?? 2000,
  );
}

/// Nutrition summary
class NutritionSummary {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;

  NutritionSummary({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
  });

  factory NutritionSummary.empty() => NutritionSummary(
    calories: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
    fiber: 0,
    sugar: 0,
  );
}

/// Nutrition statistics
class NutritionStats {
  final int averageCalories;
  final double averageProtein;
  final double averageCarbs;
  final double averageFat;
  final int daysLogged;
  final int daysGoalMet;
  final int totalMealsLogged;

  NutritionStats({
    required this.averageCalories,
    required this.averageProtein,
    required this.averageCarbs,
    required this.averageFat,
    required this.daysLogged,
    required this.daysGoalMet,
    required this.totalMealsLogged,
  });
}
