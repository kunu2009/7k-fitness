import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// BMI Calculator utility
class BMICalculator {
  static double calculate(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static String getCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  static Color getCategoryColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.danger;
  }

  static String getHealthTip(double bmi) {
    if (bmi < 18.5) {
      return 'Consider increasing your calorie intake with nutritious foods.';
    }
    if (bmi < 25) {
      return 'Great job! Maintain your healthy lifestyle.';
    }
    if (bmi < 30) {
      return 'Consider increasing physical activity and monitoring diet.';
    }
    return 'Consult a healthcare professional for personalized advice.';
  }
}

/// Calorie Calculator utility
class CalorieCalculator {
  /// Calculate BMR using Mifflin-St Jeor Equation
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
  }) {
    if (isMale) {
      return 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      return 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }
  }

  /// Calculate TDEE (Total Daily Energy Expenditure)
  static double calculateTDEE({
    required double bmr,
    required ActivityLevel activityLevel,
  }) {
    return bmr * activityLevel.multiplier;
  }

  /// Calculate calories to reach weight goal
  static CalorieGoal calculateWeightGoal({
    required double currentWeight,
    required double targetWeight,
    required double tdee,
    required int weeksToGoal,
  }) {
    final weightDiff = targetWeight - currentWeight;
    final totalCalorieDiff = weightDiff * 7700; // ~7700 calories per kg
    final dailyCalorieDiff = totalCalorieDiff / (weeksToGoal * 7);
    final targetCalories = tdee + dailyCalorieDiff;

    return CalorieGoal(
      dailyCalories: targetCalories.round(),
      deficit: dailyCalorieDiff.round(),
      isDeficit: weightDiff < 0,
    );
  }
}

enum ActivityLevel {
  sedentary(1.2, 'Sedentary', 'Little or no exercise'),
  lightlyActive(1.375, 'Lightly Active', '1-3 days/week'),
  moderatelyActive(1.55, 'Moderately Active', '3-5 days/week'),
  veryActive(1.725, 'Very Active', '6-7 days/week'),
  extraActive(1.9, 'Extra Active', 'Very hard exercise');

  final double multiplier;
  final String label;
  final String description;

  const ActivityLevel(this.multiplier, this.label, this.description);
}

class CalorieGoal {
  final int dailyCalories;
  final int deficit;
  final bool isDeficit;

  CalorieGoal({
    required this.dailyCalories,
    required this.deficit,
    required this.isDeficit,
  });
}

/// One Rep Max Calculator
class OneRepMaxCalculator {
  /// Epley Formula
  static double calculate(double weight, int reps) {
    if (reps == 1) return weight;
    return weight * (1 + reps / 30);
  }

  /// Calculate weight for target reps
  static double weightForReps(double oneRepMax, int targetReps) {
    return oneRepMax / (1 + targetReps / 30);
  }

  /// Get percentage chart
  static Map<int, double> getPercentageChart(double oneRepMax) {
    return {
      1: oneRepMax,
      2: oneRepMax * 0.97,
      3: oneRepMax * 0.94,
      4: oneRepMax * 0.91,
      5: oneRepMax * 0.88,
      6: oneRepMax * 0.85,
      8: oneRepMax * 0.80,
      10: oneRepMax * 0.75,
      12: oneRepMax * 0.70,
      15: oneRepMax * 0.65,
    };
  }
}

/// Heart Rate Zone Calculator
class HeartRateZoneCalculator {
  static int calculateMaxHR(int age) {
    return 220 - age;
  }

  static List<HeartRateZone> calculateZones(int maxHR) {
    return [
      HeartRateZone(
        name: 'Recovery',
        minPercent: 50,
        maxPercent: 60,
        minBPM: (maxHR * 0.5).round(),
        maxBPM: (maxHR * 0.6).round(),
        color: Colors.blue,
        description: 'Very light activity, recovery',
      ),
      HeartRateZone(
        name: 'Fat Burn',
        minPercent: 60,
        maxPercent: 70,
        minBPM: (maxHR * 0.6).round(),
        maxBPM: (maxHR * 0.7).round(),
        color: Colors.green,
        description: 'Light activity, fat burning',
      ),
      HeartRateZone(
        name: 'Cardio',
        minPercent: 70,
        maxPercent: 80,
        minBPM: (maxHR * 0.7).round(),
        maxBPM: (maxHR * 0.8).round(),
        color: Colors.orange,
        description: 'Moderate activity, cardio training',
      ),
      HeartRateZone(
        name: 'Hard',
        minPercent: 80,
        maxPercent: 90,
        minBPM: (maxHR * 0.8).round(),
        maxBPM: (maxHR * 0.9).round(),
        color: Colors.deepOrange,
        description: 'Hard activity, performance training',
      ),
      HeartRateZone(
        name: 'Maximum',
        minPercent: 90,
        maxPercent: 100,
        minBPM: (maxHR * 0.9).round(),
        maxBPM: maxHR,
        color: Colors.red,
        description: 'Maximum effort, peak performance',
      ),
    ];
  }
}

class HeartRateZone {
  final String name;
  final int minPercent;
  final int maxPercent;
  final int minBPM;
  final int maxBPM;
  final Color color;
  final String description;

  HeartRateZone({
    required this.name,
    required this.minPercent,
    required this.maxPercent,
    required this.minBPM,
    required this.maxBPM,
    required this.color,
    required this.description,
  });
}

/// Body Fat Percentage Estimator (US Navy Method)
class BodyFatCalculator {
  static double calculateMale({
    required double waistCm,
    required double neckCm,
    required double heightCm,
  }) {
    final waistInch = waistCm / 2.54;
    final neckInch = neckCm / 2.54;
    final heightInch = heightCm / 2.54;

    return 495 /
            (1.0324 -
                0.19077 * _log10(waistInch - neckInch) +
                0.15456 * _log10(heightInch)) -
        450;
  }

  static double calculateFemale({
    required double waistCm,
    required double neckCm,
    required double hipCm,
    required double heightCm,
  }) {
    final waistInch = waistCm / 2.54;
    final neckInch = neckCm / 2.54;
    final hipInch = hipCm / 2.54;
    final heightInch = heightCm / 2.54;

    return 495 /
            (1.29579 -
                0.35004 * _log10(waistInch + hipInch - neckInch) +
                0.22100 * _log10(heightInch)) -
        450;
  }

  static double _log10(double x) {
    return 0.4342944819 * (x > 0 ? x : 1).toString().length.toDouble();
  }

  static String getCategory(double bodyFat, bool isMale) {
    if (isMale) {
      if (bodyFat < 6) return 'Essential';
      if (bodyFat < 14) return 'Athletic';
      if (bodyFat < 18) return 'Fitness';
      if (bodyFat < 25) return 'Average';
      return 'Obese';
    } else {
      if (bodyFat < 14) return 'Essential';
      if (bodyFat < 21) return 'Athletic';
      if (bodyFat < 25) return 'Fitness';
      if (bodyFat < 32) return 'Average';
      return 'Obese';
    }
  }
}

/// Water Intake Calculator
class WaterIntakeCalculator {
  /// Calculate recommended daily water intake in liters
  static double calculate({
    required double weightKg,
    required ActivityLevel activityLevel,
    bool isHotClimate = false,
  }) {
    // Base: 30-35ml per kg of body weight
    double baseIntake = weightKg * 0.033;

    // Adjust for activity level
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        break;
      case ActivityLevel.lightlyActive:
        baseIntake += 0.35;
        break;
      case ActivityLevel.moderatelyActive:
        baseIntake += 0.5;
        break;
      case ActivityLevel.veryActive:
        baseIntake += 0.7;
        break;
      case ActivityLevel.extraActive:
        baseIntake += 1.0;
        break;
    }

    // Adjust for climate
    if (isHotClimate) {
      baseIntake += 0.5;
    }

    return baseIntake;
  }

  /// Convert liters to glasses (250ml each)
  static int toGlasses(double liters) {
    return (liters / 0.25).round();
  }
}

/// Workout Volume Calculator
class WorkoutVolumeCalculator {
  /// Calculate total volume (sets × reps × weight)
  static double calculateVolume(List<SetData> sets) {
    return sets.fold(0.0, (sum, set) => sum + (set.reps * set.weight));
  }

  /// Calculate tonnage (total weight lifted)
  static double calculateTonnage(List<SetData> sets) {
    return calculateVolume(sets) / 1000; // Convert to tonnes
  }

  /// Calculate average intensity
  static double calculateAverageIntensity(
    List<SetData> sets,
    double oneRepMax,
  ) {
    if (sets.isEmpty || oneRepMax == 0) return 0;
    final avgWeight =
        sets.fold(0.0, (sum, set) => sum + set.weight) / sets.length;
    return (avgWeight / oneRepMax) * 100;
  }
}

class SetData {
  final int reps;
  final double weight;

  SetData({required this.reps, required this.weight});
}

/// Pace Calculator for running
class PaceCalculator {
  /// Calculate pace (min/km) from distance and time
  static Duration calculatePace(double distanceKm, Duration time) {
    if (distanceKm == 0) return Duration.zero;
    final secondsPerKm = time.inSeconds / distanceKm;
    return Duration(seconds: secondsPerKm.round());
  }

  /// Calculate time from distance and pace
  static Duration calculateTime(double distanceKm, Duration pacePerKm) {
    final totalSeconds = distanceKm * pacePerKm.inSeconds;
    return Duration(seconds: totalSeconds.round());
  }

  /// Calculate distance from time and pace
  static double calculateDistance(Duration time, Duration pacePerKm) {
    if (pacePerKm.inSeconds == 0) return 0;
    return time.inSeconds / pacePerKm.inSeconds;
  }

  /// Convert pace to speed (km/h)
  static double paceToSpeed(Duration pacePerKm) {
    if (pacePerKm.inSeconds == 0) return 0;
    return 3600 / pacePerKm.inSeconds;
  }

  /// Format pace as string (e.g., "5:30")
  static String formatPace(Duration pace) {
    final minutes = pace.inMinutes;
    final seconds = pace.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
