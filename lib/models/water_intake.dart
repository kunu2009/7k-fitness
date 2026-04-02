library;

/// Water intake tracking model

class WaterIntake {
  final String id;
  final double amount; // in ml
  final DateTime timestamp;
  final WaterSource source;

  const WaterIntake({
    required this.id,
    required this.amount,
    required this.timestamp,
    this.source = WaterSource.water,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'timestamp': timestamp.toIso8601String(),
    'source': source.name,
  };

  factory WaterIntake.fromJson(Map<String, dynamic> json) => WaterIntake(
    id: json['id'],
    amount: (json['amount'] as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp']),
    source: WaterSource.values.firstWhere(
      (e) => e.name == json['source'],
      orElse: () => WaterSource.water,
    ),
  );
}

enum WaterSource {
  water,
  coffee,
  tea,
  juice,
  soda,
  milk,
  smoothie,
  sportsDrink,
  other,
}

extension WaterSourceExtension on WaterSource {
  String get displayName {
    switch (this) {
      case WaterSource.water:
        return 'Water';
      case WaterSource.coffee:
        return 'Coffee';
      case WaterSource.tea:
        return 'Tea';
      case WaterSource.juice:
        return 'Juice';
      case WaterSource.soda:
        return 'Soda';
      case WaterSource.milk:
        return 'Milk';
      case WaterSource.smoothie:
        return 'Smoothie';
      case WaterSource.sportsDrink:
        return 'Sports Drink';
      case WaterSource.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case WaterSource.water:
        return '💧';
      case WaterSource.coffee:
        return '☕';
      case WaterSource.tea:
        return '🍵';
      case WaterSource.juice:
        return '🧃';
      case WaterSource.soda:
        return '🥤';
      case WaterSource.milk:
        return '🥛';
      case WaterSource.smoothie:
        return '🥤';
      case WaterSource.sportsDrink:
        return '🏃';
      case WaterSource.other:
        return '🍶';
    }
  }

  /// Hydration factor (water = 1.0, coffee/tea slightly less due to caffeine)
  double get hydrationFactor {
    switch (this) {
      case WaterSource.water:
        return 1.0;
      case WaterSource.coffee:
        return 0.8;
      case WaterSource.tea:
        return 0.9;
      case WaterSource.juice:
        return 0.9;
      case WaterSource.soda:
        return 0.7;
      case WaterSource.milk:
        return 0.9;
      case WaterSource.smoothie:
        return 0.85;
      case WaterSource.sportsDrink:
        return 1.0;
      case WaterSource.other:
        return 0.8;
    }
  }
}

/// Daily water intake summary
class DailyWaterSummary {
  final DateTime date;
  final double totalIntake; // ml
  final double effectiveHydration; // ml (adjusted for hydration factor)
  final double goal; // ml
  final List<WaterIntake> entries;

  const DailyWaterSummary({
    required this.date,
    required this.totalIntake,
    required this.effectiveHydration,
    required this.goal,
    required this.entries,
  });

  double get progress => goal > 0 ? (effectiveHydration / goal).clamp(0, 1) : 0;
  bool get goalReached => effectiveHydration >= goal;
  double get remaining => (goal - effectiveHydration).clamp(0, double.infinity);

  int get glassesConsumed => (totalIntake / 250).floor(); // 250ml = 1 glass
  int get glassesGoal => (goal / 250).ceil();
}

/// Water intake goals and settings
class WaterGoalSettings {
  final double dailyGoal; // ml
  final bool reminderEnabled;
  final int reminderIntervalMinutes;
  final int reminderStartHour;
  final int reminderEndHour;
  final double defaultAmount; // ml for quick add

  const WaterGoalSettings({
    this.dailyGoal = 2500, // 2.5 liters default
    this.reminderEnabled = true,
    this.reminderIntervalMinutes = 60,
    this.reminderStartHour = 8,
    this.reminderEndHour = 22,
    this.defaultAmount = 250, // 1 glass
  });

  Map<String, dynamic> toJson() => {
    'dailyGoal': dailyGoal,
    'reminderEnabled': reminderEnabled,
    'reminderIntervalMinutes': reminderIntervalMinutes,
    'reminderStartHour': reminderStartHour,
    'reminderEndHour': reminderEndHour,
    'defaultAmount': defaultAmount,
  };

  factory WaterGoalSettings.fromJson(Map<String, dynamic> json) =>
      WaterGoalSettings(
        dailyGoal: (json['dailyGoal'] as num?)?.toDouble() ?? 2500,
        reminderEnabled: json['reminderEnabled'] ?? true,
        reminderIntervalMinutes: json['reminderIntervalMinutes'] ?? 60,
        reminderStartHour: json['reminderStartHour'] ?? 8,
        reminderEndHour: json['reminderEndHour'] ?? 22,
        defaultAmount: (json['defaultAmount'] as num?)?.toDouble() ?? 250,
      );

  WaterGoalSettings copyWith({
    double? dailyGoal,
    bool? reminderEnabled,
    int? reminderIntervalMinutes,
    int? reminderStartHour,
    int? reminderEndHour,
    double? defaultAmount,
  }) {
    return WaterGoalSettings(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderIntervalMinutes:
          reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      reminderStartHour: reminderStartHour ?? this.reminderStartHour,
      reminderEndHour: reminderEndHour ?? this.reminderEndHour,
      defaultAmount: defaultAmount ?? this.defaultAmount,
    );
  }
}
