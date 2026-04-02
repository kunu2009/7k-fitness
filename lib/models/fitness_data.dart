class FitnessData {
  final DateTime date;
  final double calories;
  final int steps;
  final int waterGlasses;
  final double sleepHours;
  final int bpm;
  final double weight;

  FitnessData({
    required this.date,
    required this.calories,
    required this.steps,
    required this.waterGlasses,
    required this.sleepHours,
    required this.bpm,
    required this.weight,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'calories': calories,
      'steps': steps,
      'waterGlasses': waterGlasses,
      'sleepHours': sleepHours,
      'bpm': bpm,
      'weight': weight,
    };
  }

  factory FitnessData.fromJson(Map<String, dynamic> json) {
    return FitnessData(
      date: DateTime.parse(json['date']),
      calories: (json['calories'] as num).toDouble(),
      steps: json['steps'] as int,
      waterGlasses: json['waterGlasses'] as int,
      sleepHours: (json['sleepHours'] as num).toDouble(),
      bpm: json['bpm'] as int,
      weight: (json['weight'] as num).toDouble(),
    );
  }
}

class Exercise {
  final String name;
  final String imageUrl;
  final int reps;
  final String duration;

  Exercise({
    required this.name,
    required this.imageUrl,
    required this.reps,
    required this.duration,
  });
}

class Workout {
  final String name;
  final String category;
  final String duration;
  final double calories;
  final List<Exercise> exercises;

  Workout({
    required this.name,
    required this.category,
    required this.duration,
    required this.calories,
    required this.exercises,
  });
}

class UserProfile {
  final String name;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final String gender;
  final String activityLevel;
  final String fitnessGoal;
  final DateTime createdAt;

  UserProfile({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.activityLevel,
    required this.fitnessGoal,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate BMI
  double get bmi {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Get BMI category
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Calculate daily calorie goal based on age, weight, height, gender, and activity level
  double get dailyCalorieGoal {
    // Mifflin-St Jeor equation for BMR
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    // Activity multiplier
    double activityMultiplier;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'light':
        activityMultiplier = 1.375;
        break;
      case 'moderate':
        activityMultiplier = 1.55;
        break;
      case 'very active':
        activityMultiplier = 1.725;
        break;
      case 'extra active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.55;
    }

    return bmr * activityMultiplier;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'activityLevel': activityLevel,
      'fitnessGoal': fitnessGoal,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      age: json['age'] as int,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      gender: json['gender'] as String,
      activityLevel: json['activityLevel'] as String,
      fitnessGoal: json['fitnessGoal'] as String? ?? 'General Fitness',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
