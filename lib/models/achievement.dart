/// Achievement categories
enum AchievementCategory {
  workout,
  streak,
  nutrition,
  social,
  milestone,
  special,
  steps,
  calories,
  water,
  weight,
}

/// Achievement rarity levels
enum AchievementRarity { common, uncommon, rare, epic, legendary }

/// Achievement definition
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final String requirementType;
  final double requirementValue;
  final int points;
  final bool isHidden;
  final String? unlockedAt;
  final double currentValue; // Track current progress

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.rarity = AchievementRarity.common,
    required this.requirementType,
    required this.requirementValue,
    this.points = 10,
    this.isHidden = false,
    this.unlockedAt,
    this.currentValue = 0,
  });

  bool get isUnlocked => unlockedAt != null;

  // Get unlockedAt as DateTime for UI
  DateTime? get unlockedAtDate =>
      unlockedAt != null ? DateTime.tryParse(unlockedAt!) : null;

  // Aliases for UI compatibility
  String get title => name;
  double get targetValue => requirementValue;
  double get progress =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'category': category.name,
      'rarity': rarity.name,
      'requirementType': requirementType,
      'requirementValue': requirementValue,
      'points': points,
      'isHidden': isHidden,
      'unlockedAt': unlockedAt,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: AchievementCategory.values.firstWhere(
        (c) => c.name == json['category'],
      ),
      rarity: AchievementRarity.values.firstWhere(
        (r) => r.name == json['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      requirementType: json['requirementType'] as String,
      requirementValue: (json['requirementValue'] as num).toDouble(),
      points: json['points'] as int? ?? 10,
      isHidden: json['isHidden'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] as String?,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0,
    );
  }

  Achievement copyWith({
    String? unlockedAt,
    double? currentValue,
    bool? isUnlocked,
  }) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      icon: icon,
      category: category,
      rarity: rarity,
      requirementType: requirementType,
      requirementValue: requirementValue,
      points: points,
      isHidden: isHidden,
      unlockedAt: isUnlocked == true
          ? DateTime.now().toIso8601String()
          : (unlockedAt ?? this.unlockedAt),
      currentValue: currentValue ?? this.currentValue,
    );
  }

  String get rarityText {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.uncommon:
        return 'Uncommon';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }
}

/// Pre-defined achievements
class AchievementDefinitions {
  // Alias for UI compatibility
  static List<Achievement> get allAchievements => all;

  static const List<Achievement> all = [
    // Workout Achievements
    Achievement(
      id: 'first_workout',
      name: 'First Steps',
      description: 'Complete your first workout',
      icon: '🎯',
      category: AchievementCategory.workout,
      rarity: AchievementRarity.common,
      requirementType: 'total_workouts',
      requirementValue: 1,
      points: 10,
    ),
    Achievement(
      id: 'workout_10',
      name: 'Getting Started',
      description: 'Complete 10 workouts',
      icon: '💪',
      category: AchievementCategory.workout,
      rarity: AchievementRarity.common,
      requirementType: 'total_workouts',
      requirementValue: 10,
      points: 25,
    ),
    Achievement(
      id: 'workout_50',
      name: 'Dedicated',
      description: 'Complete 50 workouts',
      icon: '🏋️',
      category: AchievementCategory.workout,
      rarity: AchievementRarity.uncommon,
      requirementType: 'total_workouts',
      requirementValue: 50,
      points: 50,
    ),
    Achievement(
      id: 'workout_100',
      name: 'Century Club',
      description: 'Complete 100 workouts',
      icon: '🏆',
      category: AchievementCategory.workout,
      rarity: AchievementRarity.rare,
      requirementType: 'total_workouts',
      requirementValue: 100,
      points: 100,
    ),
    Achievement(
      id: 'workout_500',
      name: 'Iron Will',
      description: 'Complete 500 workouts',
      icon: '🔥',
      category: AchievementCategory.workout,
      rarity: AchievementRarity.epic,
      requirementType: 'total_workouts',
      requirementValue: 500,
      points: 250,
    ),
    Achievement(
      id: 'workout_1000',
      name: 'Legendary Athlete',
      description: 'Complete 1000 workouts',
      icon: '👑',
      category: AchievementCategory.workout,
      rarity: AchievementRarity.legendary,
      requirementType: 'total_workouts',
      requirementValue: 1000,
      points: 500,
    ),

    // Streak Achievements
    Achievement(
      id: 'streak_3',
      name: 'On Fire',
      description: 'Maintain a 3-day workout streak',
      icon: '🔥',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.common,
      requirementType: 'workout_streak',
      requirementValue: 3,
      points: 15,
    ),
    Achievement(
      id: 'streak_7',
      name: 'Week Warrior',
      description: 'Maintain a 7-day workout streak',
      icon: '⚡',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.uncommon,
      requirementType: 'workout_streak',
      requirementValue: 7,
      points: 35,
    ),
    Achievement(
      id: 'streak_14',
      name: 'Unstoppable',
      description: 'Maintain a 14-day workout streak',
      icon: '💫',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.rare,
      requirementType: 'workout_streak',
      requirementValue: 14,
      points: 75,
    ),
    Achievement(
      id: 'streak_30',
      name: 'Monthly Master',
      description: 'Maintain a 30-day workout streak',
      icon: '🌟',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.epic,
      requirementType: 'workout_streak',
      requirementValue: 30,
      points: 150,
    ),
    Achievement(
      id: 'streak_100',
      name: 'Habit Forged',
      description: 'Maintain a 100-day workout streak',
      icon: '💎',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.legendary,
      requirementType: 'workout_streak',
      requirementValue: 100,
      points: 500,
    ),

    // Steps Achievements
    Achievement(
      id: 'steps_10k',
      name: 'Walker',
      description: 'Walk 10,000 steps in a day',
      icon: '🚶',
      category: AchievementCategory.milestone,
      rarity: AchievementRarity.common,
      requirementType: 'daily_steps',
      requirementValue: 10000,
      points: 20,
    ),
    Achievement(
      id: 'steps_15k',
      name: 'Active Mover',
      description: 'Walk 15,000 steps in a day',
      icon: '🏃',
      category: AchievementCategory.milestone,
      rarity: AchievementRarity.uncommon,
      requirementType: 'daily_steps',
      requirementValue: 15000,
      points: 35,
    ),
    Achievement(
      id: 'steps_20k',
      name: 'Marathon Walker',
      description: 'Walk 20,000 steps in a day',
      icon: '🏅',
      category: AchievementCategory.milestone,
      rarity: AchievementRarity.rare,
      requirementType: 'daily_steps',
      requirementValue: 20000,
      points: 50,
    ),

    // Calorie Achievements
    Achievement(
      id: 'calories_500',
      name: 'Burner',
      description: 'Burn 500 calories in a day',
      icon: '🔥',
      category: AchievementCategory.milestone,
      rarity: AchievementRarity.common,
      requirementType: 'daily_calories',
      requirementValue: 500,
      points: 20,
    ),
    Achievement(
      id: 'calories_1000',
      name: 'Inferno',
      description: 'Burn 1000 calories in a day',
      icon: '🌋',
      category: AchievementCategory.milestone,
      rarity: AchievementRarity.rare,
      requirementType: 'daily_calories',
      requirementValue: 1000,
      points: 75,
    ),

    // Water Achievements
    Achievement(
      id: 'water_8',
      name: 'Hydrated',
      description: 'Drink 8 glasses of water in a day',
      icon: '💧',
      category: AchievementCategory.nutrition,
      rarity: AchievementRarity.common,
      requirementType: 'daily_water',
      requirementValue: 8,
      points: 15,
    ),
    Achievement(
      id: 'water_12',
      name: 'Super Hydrated',
      description: 'Drink 12 glasses of water in a day',
      icon: '🌊',
      category: AchievementCategory.nutrition,
      rarity: AchievementRarity.uncommon,
      requirementType: 'daily_water',
      requirementValue: 12,
      points: 30,
    ),

    // Weight Achievements
    Achievement(
      id: 'weight_first',
      name: 'Tracking Progress',
      description: 'Log your weight for the first time',
      icon: '⚖️',
      category: AchievementCategory.milestone,
      rarity: AchievementRarity.common,
      requirementType: 'weight_logged',
      requirementValue: 1,
      points: 10,
    ),
    Achievement(
      id: 'weight_goal',
      name: 'Goal Crusher',
      description: 'Reach your weight goal',
      icon: '🎯',
      category: AchievementCategory.milestone,
      rarity: AchievementRarity.epic,
      requirementType: 'weight_goal_reached',
      requirementValue: 1,
      points: 200,
    ),

    // Special Achievements
    Achievement(
      id: 'early_bird',
      name: 'Early Bird',
      description: 'Complete a workout before 7 AM',
      icon: '🌅',
      category: AchievementCategory.special,
      rarity: AchievementRarity.uncommon,
      requirementType: 'workout_before_7am',
      requirementValue: 1,
      points: 25,
    ),
    Achievement(
      id: 'night_owl',
      name: 'Night Owl',
      description: 'Complete a workout after 10 PM',
      icon: '🌙',
      category: AchievementCategory.special,
      rarity: AchievementRarity.uncommon,
      requirementType: 'workout_after_10pm',
      requirementValue: 1,
      points: 25,
    ),
    Achievement(
      id: 'weekend_warrior',
      name: 'Weekend Warrior',
      description: 'Work out on both Saturday and Sunday',
      icon: '⚔️',
      category: AchievementCategory.special,
      rarity: AchievementRarity.uncommon,
      requirementType: 'weekend_workouts',
      requirementValue: 2,
      points: 30,
    ),
    Achievement(
      id: 'perfect_week',
      name: 'Perfect Week',
      description: 'Work out every day for a week',
      icon: '✨',
      category: AchievementCategory.special,
      rarity: AchievementRarity.rare,
      requirementType: 'weekly_workouts',
      requirementValue: 7,
      points: 100,
    ),

    // Volume Achievements
    Achievement(
      id: 'volume_1000',
      name: 'Getting Strong',
      description: 'Lift 1,000 kg total volume in a workout',
      icon: '💪',
      category: AchievementCategory.workout,
      rarity: AchievementRarity.uncommon,
      requirementType: 'workout_volume',
      requirementValue: 1000,
      points: 30,
    ),
    Achievement(
      id: 'volume_5000',
      name: 'Heavy Lifter',
      description: 'Lift 5,000 kg total volume in a workout',
      icon: '🏋️',
      category: AchievementCategory.workout,
      rarity: AchievementRarity.rare,
      requirementType: 'workout_volume',
      requirementValue: 5000,
      points: 75,
    ),
    Achievement(
      id: 'volume_10000',
      name: 'Beast Mode',
      description: 'Lift 10,000 kg total volume in a workout',
      icon: '🦁',
      category: AchievementCategory.workout,
      rarity: AchievementRarity.epic,
      requirementType: 'workout_volume',
      requirementValue: 10000,
      points: 150,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }

  static List<Achievement> getByRarity(AchievementRarity rarity) {
    return all.where((a) => a.rarity == rarity).toList();
  }
}

/// User's achievement progress
class UserAchievement {
  final String odayechievementId;
  final DateTime unlockedAt;
  final double progress;

  UserAchievement({
    required this.odayechievementId,
    required this.unlockedAt,
    this.progress = 1.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'achievementId': odayechievementId,
      'unlockedAt': unlockedAt.toIso8601String(),
      'progress': progress,
    };
  }

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      odayechievementId: json['achievementId'] as String,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      progress: (json['progress'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
