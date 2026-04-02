import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage user settings including unit preferences
class SettingsService extends ChangeNotifier {
  static const String _keyWeightUnit = 'weight_unit';
  static const String _keyHeightUnit = 'height_unit';
  static const String _keyDistanceUnit = 'distance_unit';
  static const String _keyWaterUnit = 'water_unit';
  static const String _keyEnergyUnit = 'energy_unit';
  static const String _keyTutorialCompleted = 'tutorial_completed';
  static const String _keyProfileSetup = 'profile_setup_completed';
  static const String _keyDailyCalorieGoal = 'daily_calorie_goal';
  static const String _keyDailyProteinGoal = 'daily_protein_goal';
  static const String _keyDailyCarbsGoal = 'daily_carbs_goal';
  static const String _keyDailyFatGoal = 'daily_fat_goal';
  static const String _keyDailyWaterGoal = 'daily_water_goal';
  static const String _keyDailyStepsGoal = 'daily_steps_goal';

  // User Profile keys
  static const String _keyUserName = 'user_name';
  static const String _keyUserAge = 'user_age';
  static const String _keyUserGender = 'user_gender';
  static const String _keyUserHeight = 'user_height'; // stored in cm
  static const String _keyUserWeight = 'user_weight'; // stored in kg
  static const String _keyActivityLevel = 'activity_level';
  static const String _keyFitnessGoal = 'fitness_goal';

  SharedPreferences? _prefs;

  // Current settings
  WeightUnit _weightUnit = WeightUnit.kg;
  HeightUnit _heightUnit = HeightUnit.cm;
  DistanceUnit _distanceUnit = DistanceUnit.km;
  WaterUnit _waterUnit = WaterUnit.ml;
  EnergyUnit _energyUnit = EnergyUnit.kcal;

  bool _tutorialCompleted = false;
  bool _profileSetupCompleted = false;

  // Goals
  int _dailyCalorieGoal = 2000;
  int _dailyProteinGoal = 150;
  int _dailyCarbsGoal = 200;
  int _dailyFatGoal = 65;
  int _dailyWaterGoal = 2500; // ml
  int _dailyStepsGoal = 10000;

  // User profile
  String _userName = '';
  int _userAge = 25;
  Gender _userGender = Gender.male;
  double _userHeight = 170.0; // cm
  double _userWeight = 70.0; // kg
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  FitnessGoal _fitnessGoal = FitnessGoal.maintain;

  // Getters
  WeightUnit get weightUnit => _weightUnit;
  HeightUnit get heightUnit => _heightUnit;
  DistanceUnit get distanceUnit => _distanceUnit;
  WaterUnit get waterUnit => _waterUnit;
  EnergyUnit get energyUnit => _energyUnit;

  bool get tutorialCompleted => _tutorialCompleted;
  bool get profileSetupCompleted => _profileSetupCompleted;

  int get dailyCalorieGoal => _dailyCalorieGoal;
  int get dailyProteinGoal => _dailyProteinGoal;
  int get dailyCarbsGoal => _dailyCarbsGoal;
  int get dailyFatGoal => _dailyFatGoal;
  int get dailyWaterGoal => _dailyWaterGoal;
  int get dailyStepsGoal => _dailyStepsGoal;

  String get userName => _userName;
  int get userAge => _userAge;
  Gender get userGender => _userGender;
  double get userHeight => _userHeight;
  double get userWeight => _userWeight;
  ActivityLevel get activityLevel => _activityLevel;
  FitnessGoal get fitnessGoal => _fitnessGoal;

  /// Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (_prefs == null) return;

    // Load units
    _weightUnit = WeightUnit.values[_prefs!.getInt(_keyWeightUnit) ?? 0];
    _heightUnit = HeightUnit.values[_prefs!.getInt(_keyHeightUnit) ?? 0];
    _distanceUnit = DistanceUnit.values[_prefs!.getInt(_keyDistanceUnit) ?? 0];
    _waterUnit = WaterUnit.values[_prefs!.getInt(_keyWaterUnit) ?? 0];
    _energyUnit = EnergyUnit.values[_prefs!.getInt(_keyEnergyUnit) ?? 0];

    // Load flags
    _tutorialCompleted = _prefs!.getBool(_keyTutorialCompleted) ?? false;
    _profileSetupCompleted = _prefs!.getBool(_keyProfileSetup) ?? false;

    // Load goals
    _dailyCalorieGoal = _prefs!.getInt(_keyDailyCalorieGoal) ?? 2000;
    _dailyProteinGoal = _prefs!.getInt(_keyDailyProteinGoal) ?? 150;
    _dailyCarbsGoal = _prefs!.getInt(_keyDailyCarbsGoal) ?? 200;
    _dailyFatGoal = _prefs!.getInt(_keyDailyFatGoal) ?? 65;
    _dailyWaterGoal = _prefs!.getInt(_keyDailyWaterGoal) ?? 2500;
    _dailyStepsGoal = _prefs!.getInt(_keyDailyStepsGoal) ?? 10000;

    // Load profile
    _userName = _prefs!.getString(_keyUserName) ?? '';
    _userAge = _prefs!.getInt(_keyUserAge) ?? 25;
    _userGender = Gender.values[_prefs!.getInt(_keyUserGender) ?? 0];
    _userHeight = _prefs!.getDouble(_keyUserHeight) ?? 170.0;
    _userWeight = _prefs!.getDouble(_keyUserWeight) ?? 70.0;
    _activityLevel =
        ActivityLevel.values[_prefs!.getInt(_keyActivityLevel) ?? 2];
    _fitnessGoal = FitnessGoal.values[_prefs!.getInt(_keyFitnessGoal) ?? 1];

    notifyListeners();
  }

  // Unit setters
  Future<void> setWeightUnit(WeightUnit unit) async {
    _weightUnit = unit;
    await _prefs?.setInt(_keyWeightUnit, unit.index);
    notifyListeners();
  }

  Future<void> setHeightUnit(HeightUnit unit) async {
    _heightUnit = unit;
    await _prefs?.setInt(_keyHeightUnit, unit.index);
    notifyListeners();
  }

  Future<void> setDistanceUnit(DistanceUnit unit) async {
    _distanceUnit = unit;
    await _prefs?.setInt(_keyDistanceUnit, unit.index);
    notifyListeners();
  }

  Future<void> setWaterUnit(WaterUnit unit) async {
    _waterUnit = unit;
    await _prefs?.setInt(_keyWaterUnit, unit.index);
    notifyListeners();
  }

  Future<void> setEnergyUnit(EnergyUnit unit) async {
    _energyUnit = unit;
    await _prefs?.setInt(_keyEnergyUnit, unit.index);
    notifyListeners();
  }

  // Flag setters
  Future<void> setTutorialCompleted(bool completed) async {
    _tutorialCompleted = completed;
    await _prefs?.setBool(_keyTutorialCompleted, completed);
    notifyListeners();
  }

  Future<void> setProfileSetupCompleted(bool completed) async {
    _profileSetupCompleted = completed;
    await _prefs?.setBool(_keyProfileSetup, completed);
    notifyListeners();
  }

  // Goal setters
  Future<void> setDailyCalorieGoal(int goal) async {
    _dailyCalorieGoal = goal;
    await _prefs?.setInt(_keyDailyCalorieGoal, goal);
    notifyListeners();
  }

  Future<void> setDailyProteinGoal(int goal) async {
    _dailyProteinGoal = goal;
    await _prefs?.setInt(_keyDailyProteinGoal, goal);
    notifyListeners();
  }

  Future<void> setDailyCarbsGoal(int goal) async {
    _dailyCarbsGoal = goal;
    await _prefs?.setInt(_keyDailyCarbsGoal, goal);
    notifyListeners();
  }

  Future<void> setDailyFatGoal(int goal) async {
    _dailyFatGoal = goal;
    await _prefs?.setInt(_keyDailyFatGoal, goal);
    notifyListeners();
  }

  Future<void> setDailyWaterGoal(int goal) async {
    _dailyWaterGoal = goal;
    await _prefs?.setInt(_keyDailyWaterGoal, goal);
    notifyListeners();
  }

  Future<void> setDailyStepsGoal(int goal) async {
    _dailyStepsGoal = goal;
    await _prefs?.setInt(_keyDailyStepsGoal, goal);
    notifyListeners();
  }

  // Profile setters
  Future<void> setUserName(String name) async {
    _userName = name;
    await _prefs?.setString(_keyUserName, name);
    notifyListeners();
  }

  Future<void> setUserAge(int age) async {
    _userAge = age;
    await _prefs?.setInt(_keyUserAge, age);
    notifyListeners();
  }

  Future<void> setUserGender(Gender gender) async {
    _userGender = gender;
    await _prefs?.setInt(_keyUserGender, gender.index);
    notifyListeners();
  }

  Future<void> setUserHeight(double height) async {
    _userHeight = height;
    await _prefs?.setDouble(_keyUserHeight, height);
    notifyListeners();
  }

  Future<void> setUserWeight(double weight) async {
    _userWeight = weight;
    await _prefs?.setDouble(_keyUserWeight, weight);
    notifyListeners();
  }

  Future<void> setActivityLevel(ActivityLevel level) async {
    _activityLevel = level;
    await _prefs?.setInt(_keyActivityLevel, level.index);
    notifyListeners();
  }

  Future<void> setFitnessGoal(FitnessGoal goal) async {
    _fitnessGoal = goal;
    await _prefs?.setInt(_keyFitnessGoal, goal.index);
    notifyListeners();
  }

  /// Save full profile and calculate goals
  Future<void> saveProfile({
    required String name,
    required int age,
    required Gender gender,
    required double height, // always in cm
    required double weight, // always in kg
    required ActivityLevel activityLevel,
    required FitnessGoal fitnessGoal,
  }) async {
    await setUserName(name);
    await setUserAge(age);
    await setUserGender(gender);
    await setUserHeight(height);
    await setUserWeight(weight);
    await setActivityLevel(activityLevel);
    await setFitnessGoal(fitnessGoal);

    // Calculate and save calorie goals
    final goals = calculateCalorieGoals(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
      fitnessGoal: fitnessGoal,
    );

    await setDailyCalorieGoal(goals['calories']!);
    await setDailyProteinGoal(goals['protein']!);
    await setDailyCarbsGoal(goals['carbs']!);
    await setDailyFatGoal(goals['fat']!);

    await setProfileSetupCompleted(true);
  }

  /// Calculate BMR using Mifflin-St Jeor equation
  double calculateBMR({
    required double weight, // kg
    required double height, // cm
    required int age,
    required Gender gender,
  }) {
    if (gender == Gender.male) {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  /// Calculate TDEE (Total Daily Energy Expenditure)
  double calculateTDEE({
    required double bmr,
    required ActivityLevel activityLevel,
  }) {
    final multipliers = {
      ActivityLevel.sedentary: 1.2,
      ActivityLevel.light: 1.375,
      ActivityLevel.moderate: 1.55,
      ActivityLevel.active: 1.725,
      ActivityLevel.veryActive: 1.9,
    };
    return bmr * (multipliers[activityLevel] ?? 1.55);
  }

  /// Calculate all calorie and macro goals
  Map<String, int> calculateCalorieGoals({
    required double weight,
    required double height,
    required int age,
    required Gender gender,
    required ActivityLevel activityLevel,
    required FitnessGoal fitnessGoal,
  }) {
    final bmr = calculateBMR(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
    );

    final tdee = calculateTDEE(bmr: bmr, activityLevel: activityLevel);

    // Adjust calories based on goal
    int targetCalories;
    switch (fitnessGoal) {
      case FitnessGoal.lose:
        targetCalories = (tdee - 500).round(); // 500 cal deficit
        break;
      case FitnessGoal.maintain:
        targetCalories = tdee.round();
        break;
      case FitnessGoal.gain:
        targetCalories = (tdee + 300).round(); // 300 cal surplus
        break;
    }

    // Calculate macros
    // Protein: 1.6-2.2g per kg for active individuals
    int proteinGrams = (weight * 2.0).round();

    // Fat: 25-35% of calories (using 30%)
    int fatGrams = ((targetCalories * 0.30) / 9).round();

    // Carbs: remaining calories
    int carbGrams = ((targetCalories - (proteinGrams * 4) - (fatGrams * 9)) / 4)
        .round();
    if (carbGrams < 0) carbGrams = 100; // minimum carbs

    return {
      'calories': targetCalories,
      'protein': proteinGrams,
      'carbs': carbGrams,
      'fat': fatGrams,
      'bmr': bmr.round(),
      'tdee': tdee.round(),
    };
  }

  // ============ UNIT CONVERSION HELPERS ============

  /// Convert weight to display unit
  double convertWeightToDisplay(double weightInKg) {
    if (_weightUnit == WeightUnit.lbs) {
      return weightInKg * 2.20462;
    }
    return weightInKg;
  }

  /// Convert weight from display unit to kg
  double convertWeightToKg(double weight) {
    if (_weightUnit == WeightUnit.lbs) {
      return weight / 2.20462;
    }
    return weight;
  }

  /// Get weight unit label
  String get weightUnitLabel => _weightUnit == WeightUnit.kg ? 'kg' : 'lbs';

  /// Convert height to display unit
  Map<String, int> convertHeightToDisplay(double heightInCm) {
    if (_heightUnit == HeightUnit.ftIn) {
      final totalInches = heightInCm / 2.54;
      final feet = (totalInches / 12).floor();
      final inches = (totalInches % 12).round();
      return {'feet': feet, 'inches': inches};
    }
    return {'cm': heightInCm.round()};
  }

  /// Convert height from feet/inches to cm
  double convertHeightToCm(int feet, int inches) {
    final totalInches = (feet * 12) + inches;
    return totalInches * 2.54;
  }

  /// Format height for display
  String formatHeight(double heightInCm) {
    if (_heightUnit == HeightUnit.ftIn) {
      final result = convertHeightToDisplay(heightInCm);
      return "${result['feet']}'${result['inches']}\"";
    }
    return '${heightInCm.round()} cm';
  }

  /// Get height unit label
  String get heightUnitLabel => _heightUnit == HeightUnit.cm ? 'cm' : 'ft/in';

  /// Convert distance to display unit
  double convertDistanceToDisplay(double distanceInKm) {
    if (_distanceUnit == DistanceUnit.miles) {
      return distanceInKm * 0.621371;
    }
    return distanceInKm;
  }

  /// Get distance unit label
  String get distanceUnitLabel =>
      _distanceUnit == DistanceUnit.km ? 'km' : 'mi';

  /// Convert water to display unit
  double convertWaterToDisplay(double waterInMl) {
    if (_waterUnit == WaterUnit.oz) {
      return waterInMl / 29.5735;
    }
    return waterInMl;
  }

  /// Convert water from display to ml
  double convertWaterToMl(double water) {
    if (_waterUnit == WaterUnit.oz) {
      return water * 29.5735;
    }
    return water;
  }

  /// Get water unit label
  String get waterUnitLabel => _waterUnit == WaterUnit.ml ? 'ml' : 'oz';

  /// Format weight for display
  String formatWeight(double weightInKg) {
    final converted = convertWeightToDisplay(weightInKg);
    return '${converted.toStringAsFixed(1)} $weightUnitLabel';
  }

  /// Format distance for display
  String formatDistance(double distanceInKm) {
    final converted = convertDistanceToDisplay(distanceInKm);
    return '${converted.toStringAsFixed(2)} $distanceUnitLabel';
  }

  /// Format water for display
  String formatWater(double waterInMl) {
    final converted = convertWaterToDisplay(waterInMl);
    return '${converted.round()} $waterUnitLabel';
  }

  /// Reset tutorial to show again
  Future<void> resetTutorial() async {
    await setTutorialCompleted(false);
  }

  /// Reset all settings
  Future<void> resetAllSettings() async {
    await _prefs?.clear();
    await _loadSettings();
  }
}

// ============ ENUMS ============

enum WeightUnit { kg, lbs }

enum HeightUnit { cm, ftIn }

enum DistanceUnit { km, miles }

enum WaterUnit { ml, oz }

enum EnergyUnit { kcal, kj }

enum Gender { male, female, other }

enum ActivityLevel {
  sedentary, // Little or no exercise
  light, // Light exercise 1-3 days/week
  moderate, // Moderate exercise 3-5 days/week
  active, // Hard exercise 6-7 days/week
  veryActive, // Very hard exercise & physical job
}

enum FitnessGoal {
  lose, // Lose weight
  maintain, // Maintain weight
  gain, // Gain muscle/weight
}

// Extension for display labels
extension GenderExtension on Gender {
  String get label {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}

extension ActivityLevelExtension on ActivityLevel {
  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.light:
        return 'Lightly Active';
      case ActivityLevel.moderate:
        return 'Moderately Active';
      case ActivityLevel.active:
        return 'Very Active';
      case ActivityLevel.veryActive:
        return 'Extra Active';
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Little or no exercise';
      case ActivityLevel.light:
        return 'Light exercise 1-3 days/week';
      case ActivityLevel.moderate:
        return 'Moderate exercise 3-5 days/week';
      case ActivityLevel.active:
        return 'Hard exercise 6-7 days/week';
      case ActivityLevel.veryActive:
        return 'Very hard exercise & physical job';
    }
  }
}

extension FitnessGoalExtension on FitnessGoal {
  String get label {
    switch (this) {
      case FitnessGoal.lose:
        return 'Lose Weight';
      case FitnessGoal.maintain:
        return 'Maintain Weight';
      case FitnessGoal.gain:
        return 'Gain Muscle';
    }
  }

  String get description {
    switch (this) {
      case FitnessGoal.lose:
        return 'Create a calorie deficit to lose fat';
      case FitnessGoal.maintain:
        return 'Stay at your current weight';
      case FitnessGoal.gain:
        return 'Build muscle with a calorie surplus';
    }
  }

  IconData get icon {
    switch (this) {
      case FitnessGoal.lose:
        return Icons.trending_down;
      case FitnessGoal.maintain:
        return Icons.trending_flat;
      case FitnessGoal.gain:
        return Icons.trending_up;
    }
  }
}
