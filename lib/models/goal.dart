/// Goal types
enum GoalType {
  weightLoss,
  weightGain,
  muscle,
  strength,
  steps,
  calories,
  water,
  workout,
  habit,
  custom,
  // Aliases for UI compatibility
  weight, // alias for weightLoss/weightGain
  workouts, // alias for workout
  activeMinutes,
  distance,
  sleep,
  bodyFat,
}

/// Goal frequency
enum GoalFrequency {
  daily,
  weekly,
  monthly,
  total,
  custom, // For custom period goals
}

/// A fitness goal
class FitnessGoal {
  final String id;
  final String title;
  final String? description;
  final GoalType type;
  final GoalFrequency frequency;
  final double targetValue;
  final double currentValue;
  final String unit;
  final DateTime startDate;
  final DateTime? targetDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? icon;
  final int priority; // 1 = high, 2 = medium, 3 = low

  FitnessGoal({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.frequency = GoalFrequency.total,
    required this.targetValue,
    this.currentValue = 0,
    required this.unit,
    required this.startDate,
    this.targetDate,
    this.isCompleted = false,
    this.completedAt,
    this.icon,
    this.priority = 2,
  });

  double get progress {
    if (targetValue <= 0) return 0;
    return (currentValue / targetValue).clamp(0, 1);
  }

  double get progressPercent => progress * 100;

  bool get isOverdue {
    if (targetDate == null) return false;
    return DateTime.now().isAfter(targetDate!) && !isCompleted;
  }

  int? get daysRemaining {
    if (targetDate == null) return null;
    return targetDate!.difference(DateTime.now()).inDays;
  }

  // Alias for UI compatibility
  int? get remainingDays => daysRemaining;

  // Check if goal is currently active (not completed)
  bool get isActive => !isCompleted;

  String get statusText {
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'Overdue';
    if (daysRemaining != null && daysRemaining! <= 7) {
      return '$daysRemaining days left';
    }
    return 'In Progress';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'frequency': frequency.name,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'icon': icon,
      'priority': priority,
    };
  }

  factory FitnessGoal.fromJson(Map<String, dynamic> json) {
    return FitnessGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: GoalType.values.firstWhere((t) => t.name == json['type']),
      frequency: GoalFrequency.values.firstWhere(
        (f) => f.name == json['frequency'],
        orElse: () => GoalFrequency.total,
      ),
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      icon: json['icon'] as String?,
      priority: json['priority'] as int? ?? 2,
    );
  }

  FitnessGoal copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    GoalFrequency? frequency,
    double? targetValue,
    double? currentValue,
    String? unit,
    DateTime? startDate,
    DateTime? targetDate,
    bool? isCompleted,
    DateTime? completedAt,
    String? icon,
    int? priority,
  }) {
    return FitnessGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      icon: icon ?? this.icon,
      priority: priority ?? this.priority,
    );
  }
}

/// Goal templates for quick creation
class GoalTemplates {
  static List<FitnessGoal> getTemplates() {
    final now = DateTime.now();
    return [
      FitnessGoal(
        id: 'template_weight_loss',
        title: 'Lose Weight',
        description: 'Reach your target weight',
        type: GoalType.weightLoss,
        frequency: GoalFrequency.total,
        targetValue: 5,
        unit: 'kg',
        startDate: now,
        targetDate: now.add(const Duration(days: 90)),
        icon: '⚖️',
      ),
      FitnessGoal(
        id: 'template_steps_daily',
        title: 'Daily Steps Goal',
        description: 'Walk 10,000 steps every day',
        type: GoalType.steps,
        frequency: GoalFrequency.daily,
        targetValue: 10000,
        unit: 'steps',
        startDate: now,
        icon: '🚶',
      ),
      FitnessGoal(
        id: 'template_water_daily',
        title: 'Stay Hydrated',
        description: 'Drink 8 glasses of water daily',
        type: GoalType.water,
        frequency: GoalFrequency.daily,
        targetValue: 8,
        unit: 'glasses',
        startDate: now,
        icon: '💧',
      ),
      FitnessGoal(
        id: 'template_workouts_weekly',
        title: 'Weekly Workouts',
        description: 'Complete 4 workouts per week',
        type: GoalType.workout,
        frequency: GoalFrequency.weekly,
        targetValue: 4,
        unit: 'workouts',
        startDate: now,
        icon: '💪',
      ),
      FitnessGoal(
        id: 'template_calories_daily',
        title: 'Calorie Burn',
        description: 'Burn 500 calories daily',
        type: GoalType.calories,
        frequency: GoalFrequency.daily,
        targetValue: 500,
        unit: 'kcal',
        startDate: now,
        icon: '🔥',
      ),
      FitnessGoal(
        id: 'template_muscle_gain',
        title: 'Build Muscle',
        description: 'Gain 2kg of muscle mass',
        type: GoalType.muscle,
        frequency: GoalFrequency.total,
        targetValue: 2,
        unit: 'kg',
        startDate: now,
        targetDate: now.add(const Duration(days: 120)),
        icon: '💪',
      ),
    ];
  }

  // Individual template getters for backward compatibility
  static FitnessGoal dailySteps() {
    final now = DateTime.now();
    return FitnessGoal(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Daily Steps Goal',
      description: 'Walk 10,000 steps every day',
      type: GoalType.steps,
      frequency: GoalFrequency.daily,
      targetValue: 10000,
      unit: 'steps',
      startDate: now,
      icon: '🚶',
    );
  }

  static FitnessGoal dailyCalories() {
    final now = DateTime.now();
    return FitnessGoal(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Calorie Burn',
      description: 'Burn 500 calories daily',
      type: GoalType.calories,
      frequency: GoalFrequency.daily,
      targetValue: 500,
      unit: 'kcal',
      startDate: now,
      icon: '🔥',
    );
  }

  static FitnessGoal dailyWater() {
    final now = DateTime.now();
    return FitnessGoal(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Stay Hydrated',
      description: 'Drink 8 glasses of water daily',
      type: GoalType.water,
      frequency: GoalFrequency.daily,
      targetValue: 8,
      unit: 'glasses',
      startDate: now,
      icon: '💧',
    );
  }

  static FitnessGoal weeklyWorkouts() {
    final now = DateTime.now();
    return FitnessGoal(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Weekly Workouts',
      description: 'Complete 4 workouts per week',
      type: GoalType.workout,
      frequency: GoalFrequency.weekly,
      targetValue: 4,
      unit: 'workouts',
      startDate: now,
      icon: '💪',
    );
  }
}

/// Streak tracking
class Streak {
  final String id;
  final String type; // workout, logging, steps, water
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final List<DateTime> activityDates;

  Streak({
    required this.id,
    required this.type,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    this.activityDates = const [],
  });

  bool get isActiveToday {
    if (lastActivityDate == null) return false;
    final now = DateTime.now();
    return lastActivityDate!.year == now.year &&
        lastActivityDate!.month == now.month &&
        lastActivityDate!.day == now.day;
  }

  bool get willExpireTomorrow {
    if (lastActivityDate == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return lastActivityDate!.year == yesterday.year &&
        lastActivityDate!.month == yesterday.month &&
        lastActivityDate!.day == yesterday.day;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
      'activityDates': activityDates.map((d) => d.toIso8601String()).toList(),
    };
  }

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      id: json['id'] as String,
      type: json['type'] as String,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'] as String)
          : null,
      activityDates:
          (json['activityDates'] as List?)
              ?.map((d) => DateTime.parse(d as String))
              .toList() ??
          [],
    );
  }

  Streak copyWith({
    String? id,
    String? type,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    List<DateTime>? activityDates,
  }) {
    return Streak(
      id: id ?? this.id,
      type: type ?? this.type,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      activityDates: activityDates ?? this.activityDates,
    );
  }

  /// Update streak with new activity
  Streak recordActivity(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Check if already recorded today
    if (activityDates.any(
      (d) =>
          d.year == normalizedDate.year &&
          d.month == normalizedDate.month &&
          d.day == normalizedDate.day,
    )) {
      return this;
    }

    final newActivityDates = [...activityDates, normalizedDate];
    int newCurrentStreak = currentStreak;

    if (lastActivityDate == null) {
      newCurrentStreak = 1;
    } else {
      final daysSinceLastActivity = normalizedDate
          .difference(
            DateTime(
              lastActivityDate!.year,
              lastActivityDate!.month,
              lastActivityDate!.day,
            ),
          )
          .inDays;

      if (daysSinceLastActivity == 1) {
        // Consecutive day
        newCurrentStreak = currentStreak + 1;
      } else if (daysSinceLastActivity > 1) {
        // Streak broken
        newCurrentStreak = 1;
      }
      // daysSinceLastActivity == 0 means same day, no change
    }

    final newLongestStreak = newCurrentStreak > longestStreak
        ? newCurrentStreak
        : longestStreak;

    return copyWith(
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      lastActivityDate: normalizedDate,
      activityDates: newActivityDates,
    );
  }
}
