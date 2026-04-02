/// Food and nutrition data models for the fitness tracker app
library;

/// Represents a food item in the database
class FoodItem {
  final String id;
  final String name;
  final String? brand;
  final String? barcode;
  final double servingSize;
  final String servingUnit;
  final NutritionInfo nutrition;
  final FoodCategory category;
  final bool isCustom;

  const FoodItem({
    required this.id,
    required this.name,
    this.brand,
    this.barcode,
    required this.servingSize,
    required this.servingUnit,
    required this.nutrition,
    required this.category,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'barcode': barcode,
    'servingSize': servingSize,
    'servingUnit': servingUnit,
    'nutrition': nutrition.toJson(),
    'category': category.name,
    'isCustom': isCustom,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'],
    name: json['name'],
    brand: json['brand'],
    barcode: json['barcode'],
    servingSize: (json['servingSize'] as num).toDouble(),
    servingUnit: json['servingUnit'],
    nutrition: NutritionInfo.fromJson(json['nutrition']),
    category: FoodCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => FoodCategory.other,
    ),
    isCustom: json['isCustom'] ?? false,
  );

  FoodItem copyWith({
    String? id,
    String? name,
    String? brand,
    String? barcode,
    double? servingSize,
    String? servingUnit,
    NutritionInfo? nutrition,
    FoodCategory? category,
    bool? isCustom,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      nutrition: nutrition ?? this.nutrition,
      category: category ?? this.category,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

/// Nutrition information for a food item
class NutritionInfo {
  final double calories;
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams
  final double? fiber; // grams
  final double? sugar; // grams
  final double? sodium; // mg
  final double? cholesterol; // mg
  final double? saturatedFat; // grams
  final double? transFat; // grams
  final double? potassium; // mg
  final double? vitaminA; // % daily value
  final double? vitaminC; // % daily value
  final double? calcium; // % daily value
  final double? iron; // % daily value

  const NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.cholesterol,
    this.saturatedFat,
    this.transFat,
    this.potassium,
    this.vitaminA,
    this.vitaminC,
    this.calcium,
    this.iron,
  });

  /// Calculate total macros in grams
  double get totalMacros => protein + carbs + fat;

  /// Calculate protein percentage
  double get proteinPercent =>
      totalMacros > 0 ? (protein / totalMacros) * 100 : 0;

  /// Calculate carbs percentage
  double get carbsPercent => totalMacros > 0 ? (carbs / totalMacros) * 100 : 0;

  /// Calculate fat percentage
  double get fatPercent => totalMacros > 0 ? (fat / totalMacros) * 100 : 0;

  /// Scale nutrition by servings
  NutritionInfo scale(double servings) {
    return NutritionInfo(
      calories: calories * servings,
      protein: protein * servings,
      carbs: carbs * servings,
      fat: fat * servings,
      fiber: fiber != null ? fiber! * servings : null,
      sugar: sugar != null ? sugar! * servings : null,
      sodium: sodium != null ? sodium! * servings : null,
      cholesterol: cholesterol != null ? cholesterol! * servings : null,
      saturatedFat: saturatedFat != null ? saturatedFat! * servings : null,
      transFat: transFat != null ? transFat! * servings : null,
      potassium: potassium != null ? potassium! * servings : null,
      vitaminA: vitaminA != null ? vitaminA! * servings : null,
      vitaminC: vitaminC != null ? vitaminC! * servings : null,
      calcium: calcium != null ? calcium! * servings : null,
      iron: iron != null ? iron! * servings : null,
    );
  }

  /// Add two nutrition infos together
  NutritionInfo operator +(NutritionInfo other) {
    return NutritionInfo(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
      fiber: (fiber ?? 0) + (other.fiber ?? 0),
      sugar: (sugar ?? 0) + (other.sugar ?? 0),
      sodium: (sodium ?? 0) + (other.sodium ?? 0),
      cholesterol: (cholesterol ?? 0) + (other.cholesterol ?? 0),
      saturatedFat: (saturatedFat ?? 0) + (other.saturatedFat ?? 0),
      transFat: (transFat ?? 0) + (other.transFat ?? 0),
      potassium: (potassium ?? 0) + (other.potassium ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'fiber': fiber,
    'sugar': sugar,
    'sodium': sodium,
    'cholesterol': cholesterol,
    'saturatedFat': saturatedFat,
    'transFat': transFat,
    'potassium': potassium,
    'vitaminA': vitaminA,
    'vitaminC': vitaminC,
    'calcium': calcium,
    'iron': iron,
  };

  factory NutritionInfo.fromJson(Map<String, dynamic> json) => NutritionInfo(
    calories: (json['calories'] as num).toDouble(),
    protein: (json['protein'] as num).toDouble(),
    carbs: (json['carbs'] as num).toDouble(),
    fat: (json['fat'] as num).toDouble(),
    fiber: json['fiber']?.toDouble(),
    sugar: json['sugar']?.toDouble(),
    sodium: json['sodium']?.toDouble(),
    cholesterol: json['cholesterol']?.toDouble(),
    saturatedFat: json['saturatedFat']?.toDouble(),
    transFat: json['transFat']?.toDouble(),
    potassium: json['potassium']?.toDouble(),
    vitaminA: json['vitaminA']?.toDouble(),
    vitaminC: json['vitaminC']?.toDouble(),
    calcium: json['calcium']?.toDouble(),
    iron: json['iron']?.toDouble(),
  );

  factory NutritionInfo.zero() =>
      const NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0);
}

/// Food categories
enum FoodCategory {
  fruits,
  vegetables,
  grains,
  protein,
  dairy,
  fats,
  snacks,
  beverages,
  fastFood,
  restaurant,
  homemade,
  supplements,
  other,
}

extension FoodCategoryExtension on FoodCategory {
  String get displayName {
    switch (this) {
      case FoodCategory.fruits:
        return 'Fruits';
      case FoodCategory.vegetables:
        return 'Vegetables';
      case FoodCategory.grains:
        return 'Grains & Cereals';
      case FoodCategory.protein:
        return 'Protein Foods';
      case FoodCategory.dairy:
        return 'Dairy';
      case FoodCategory.fats:
        return 'Fats & Oils';
      case FoodCategory.snacks:
        return 'Snacks';
      case FoodCategory.beverages:
        return 'Beverages';
      case FoodCategory.fastFood:
        return 'Fast Food';
      case FoodCategory.restaurant:
        return 'Restaurant';
      case FoodCategory.homemade:
        return 'Homemade';
      case FoodCategory.supplements:
        return 'Supplements';
      case FoodCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case FoodCategory.fruits:
        return '🍎';
      case FoodCategory.vegetables:
        return '🥬';
      case FoodCategory.grains:
        return '🌾';
      case FoodCategory.protein:
        return '🍗';
      case FoodCategory.dairy:
        return '🥛';
      case FoodCategory.fats:
        return '🥑';
      case FoodCategory.snacks:
        return '🍪';
      case FoodCategory.beverages:
        return '🥤';
      case FoodCategory.fastFood:
        return '🍔';
      case FoodCategory.restaurant:
        return '🍽️';
      case FoodCategory.homemade:
        return '👨‍🍳';
      case FoodCategory.supplements:
        return '💊';
      case FoodCategory.other:
        return '🍴';
    }
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
        return '🍿';
    }
  }

  String get timeRange {
    switch (this) {
      case MealType.breakfast:
        return '6:00 AM - 10:00 AM';
      case MealType.lunch:
        return '11:00 AM - 2:00 PM';
      case MealType.dinner:
        return '5:00 PM - 9:00 PM';
      case MealType.snack:
        return 'Any time';
    }
  }
}

/// A logged food entry
class FoodEntry {
  final String id;
  final FoodItem food;
  final double servings;
  final MealType mealType;
  final DateTime loggedAt;
  final String? notes;

  const FoodEntry({
    required this.id,
    required this.food,
    required this.servings,
    required this.mealType,
    required this.loggedAt,
    this.notes,
  });

  /// Get nutrition for this entry (scaled by servings)
  NutritionInfo get nutrition => food.nutrition.scale(servings);

  Map<String, dynamic> toJson() => {
    'id': id,
    'food': food.toJson(),
    'servings': servings,
    'mealType': mealType.name,
    'loggedAt': loggedAt.toIso8601String(),
    'notes': notes,
  };

  factory FoodEntry.fromJson(Map<String, dynamic> json) => FoodEntry(
    id: json['id'],
    food: FoodItem.fromJson(json['food']),
    servings: (json['servings'] as num).toDouble(),
    mealType: MealType.values.firstWhere(
      (e) => e.name == json['mealType'],
      orElse: () => MealType.snack,
    ),
    loggedAt: DateTime.parse(json['loggedAt']),
    notes: json['notes'],
  );
}

/// Daily nutrition summary
class DailyNutrition {
  final DateTime date;
  final List<FoodEntry> entries;
  final NutritionGoals? goals;

  const DailyNutrition({required this.date, required this.entries, this.goals});

  /// Get total nutrition for the day
  NutritionInfo get totalNutrition {
    if (entries.isEmpty) return NutritionInfo.zero();
    return entries.map((e) => e.nutrition).reduce((a, b) => a + b);
  }

  /// Get entries by meal type
  List<FoodEntry> entriesForMeal(MealType meal) {
    return entries.where((e) => e.mealType == meal).toList();
  }

  /// Get nutrition for a specific meal
  NutritionInfo nutritionForMeal(MealType meal) {
    final mealEntries = entriesForMeal(meal);
    if (mealEntries.isEmpty) return NutritionInfo.zero();
    return mealEntries.map((e) => e.nutrition).reduce((a, b) => a + b);
  }

  /// Calculate remaining calories
  double get remainingCalories {
    if (goals == null) return 0;
    return goals!.calories - totalNutrition.calories;
  }

  /// Check if calorie goal is exceeded
  bool get isCalorieGoalExceeded {
    if (goals == null) return false;
    return totalNutrition.calories > goals!.calories;
  }
}

/// Nutrition goals for a user
class NutritionGoals {
  final double calories;
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams
  final double? fiber; // grams
  final double? sodium; // mg
  final double? sugar; // grams

  const NutritionGoals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sodium,
    this.sugar,
  });

  /// Create goals based on calorie target and macro split
  factory NutritionGoals.fromCaloriesAndSplit({
    required double calories,
    double proteinPercent = 30,
    double carbsPercent = 40,
    double fatPercent = 30,
  }) {
    // Protein: 4 cal/g, Carbs: 4 cal/g, Fat: 9 cal/g
    final proteinCals = calories * (proteinPercent / 100);
    final carbsCals = calories * (carbsPercent / 100);
    final fatCals = calories * (fatPercent / 100);

    return NutritionGoals(
      calories: calories,
      protein: proteinCals / 4,
      carbs: carbsCals / 4,
      fat: fatCals / 9,
      fiber: 25, // general recommendation
      sodium: 2300, // mg, general recommendation
      sugar: 50, // g, general recommendation
    );
  }

  /// Create goals for weight loss
  factory NutritionGoals.forWeightLoss({
    required double tdee, // Total Daily Energy Expenditure
    double deficit = 500, // calorie deficit
  }) {
    final targetCalories = tdee - deficit;
    return NutritionGoals.fromCaloriesAndSplit(
      calories: targetCalories,
      proteinPercent: 35, // higher protein for satiety
      carbsPercent: 35,
      fatPercent: 30,
    );
  }

  /// Create goals for muscle building
  factory NutritionGoals.forMuscleBuilding({
    required double tdee,
    double surplus = 300, // calorie surplus
  }) {
    final targetCalories = tdee + surplus;
    return NutritionGoals.fromCaloriesAndSplit(
      calories: targetCalories,
      proteinPercent: 30,
      carbsPercent: 45, // more carbs for energy
      fatPercent: 25,
    );
  }

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'fiber': fiber,
    'sodium': sodium,
    'sugar': sugar,
  };

  factory NutritionGoals.fromJson(Map<String, dynamic> json) => NutritionGoals(
    calories: (json['calories'] as num).toDouble(),
    protein: (json['protein'] as num).toDouble(),
    carbs: (json['carbs'] as num).toDouble(),
    fat: (json['fat'] as num).toDouble(),
    fiber: json['fiber']?.toDouble(),
    sodium: json['sodium']?.toDouble(),
    sugar: json['sugar']?.toDouble(),
  );
}

/// Water intake entry
class WaterEntry {
  final String id;
  final double amount; // ml
  final DateTime loggedAt;

  const WaterEntry({
    required this.id,
    required this.amount,
    required this.loggedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'loggedAt': loggedAt.toIso8601String(),
  };

  factory WaterEntry.fromJson(Map<String, dynamic> json) => WaterEntry(
    id: json['id'],
    amount: (json['amount'] as num).toDouble(),
    loggedAt: DateTime.parse(json['loggedAt']),
  );
}
