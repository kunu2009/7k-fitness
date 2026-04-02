/// Step tracking data model
class StepData {
  final String id;
  final DateTime date;
  final int steps;
  final double distanceKm;
  final int caloriesBurned;
  final int activeMinutes;
  final List<HourlySteps> hourlyBreakdown;

  StepData({
    required this.id,
    required this.date,
    required this.steps,
    this.distanceKm = 0,
    this.caloriesBurned = 0,
    this.activeMinutes = 0,
    this.hourlyBreakdown = const [],
  });

  factory StepData.forToday() {
    return StepData(
      id: DateTime.now().toIso8601String(),
      date: DateTime.now(),
      steps: 0,
    );
  }

  double get progressToGoal => (steps / 10000).clamp(0.0, 1.0);

  StepData copyWith({
    String? id,
    DateTime? date,
    int? steps,
    double? distanceKm,
    int? caloriesBurned,
    int? activeMinutes,
    List<HourlySteps>? hourlyBreakdown,
  }) {
    return StepData(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      distanceKm: distanceKm ?? this.distanceKm,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      hourlyBreakdown: hourlyBreakdown ?? this.hourlyBreakdown,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'steps': steps,
    'distanceKm': distanceKm,
    'caloriesBurned': caloriesBurned,
    'activeMinutes': activeMinutes,
    'hourlyBreakdown': hourlyBreakdown.map((h) => h.toJson()).toList(),
  };

  factory StepData.fromJson(Map<String, dynamic> json) => StepData(
    id: json['id'],
    date: DateTime.parse(json['date']),
    steps: json['steps'],
    distanceKm: json['distanceKm']?.toDouble() ?? 0,
    caloriesBurned: json['caloriesBurned'] ?? 0,
    activeMinutes: json['activeMinutes'] ?? 0,
    hourlyBreakdown:
        (json['hourlyBreakdown'] as List?)
            ?.map((h) => HourlySteps.fromJson(h))
            .toList() ??
        [],
  );
}

class HourlySteps {
  final int hour;
  final int steps;

  HourlySteps({required this.hour, required this.steps});

  Map<String, dynamic> toJson() => {'hour': hour, 'steps': steps};

  factory HourlySteps.fromJson(Map<String, dynamic> json) =>
      HourlySteps(hour: json['hour'], steps: json['steps']);
}

class StepGoal {
  final int dailySteps;
  final double dailyDistanceKm;
  final int dailyCalories;
  final int activeMinutesGoal;

  StepGoal({
    this.dailySteps = 10000,
    this.dailyDistanceKm = 8.0,
    this.dailyCalories = 400,
    this.activeMinutesGoal = 60,
  });

  Map<String, dynamic> toJson() => {
    'dailySteps': dailySteps,
    'dailyDistanceKm': dailyDistanceKm,
    'dailyCalories': dailyCalories,
    'activeMinutesGoal': activeMinutesGoal,
  };

  factory StepGoal.fromJson(Map<String, dynamic> json) => StepGoal(
    dailySteps: json['dailySteps'] ?? 10000,
    dailyDistanceKm: json['dailyDistanceKm']?.toDouble() ?? 8.0,
    dailyCalories: json['dailyCalories'] ?? 400,
    activeMinutesGoal: json['activeMinutesGoal'] ?? 60,
  );
}

class WeeklyStepSummary {
  final List<StepData> dailyData;

  WeeklyStepSummary({required this.dailyData});

  int get totalSteps => dailyData.fold(0, (sum, d) => sum + d.steps);
  double get totalDistance =>
      dailyData.fold(0.0, (sum, d) => sum + d.distanceKm);
  int get totalCalories =>
      dailyData.fold(0, (sum, d) => sum + d.caloriesBurned);
  int get totalActiveMinutes =>
      dailyData.fold(0, (sum, d) => sum + d.activeMinutes);
  int get averageSteps =>
      dailyData.isEmpty ? 0 : totalSteps ~/ dailyData.length;
  int get daysGoalMet => dailyData.where((d) => d.steps >= 10000).length;
}
