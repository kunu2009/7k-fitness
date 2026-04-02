library;

/// Sleep tracking model

class SleepEntry {
  final String id;
  final DateTime bedTime;
  final DateTime wakeTime;
  final SleepQuality quality;
  final List<SleepPhase> phases;
  final String? notes;
  final List<SleepFactor> factors;

  const SleepEntry({
    required this.id,
    required this.bedTime,
    required this.wakeTime,
    this.quality = SleepQuality.fair,
    this.phases = const [],
    this.notes,
    this.factors = const [],
  });

  Duration get duration => wakeTime.difference(bedTime);
  double get durationHours => duration.inMinutes / 60;

  Map<String, dynamic> toJson() => {
    'id': id,
    'bedTime': bedTime.toIso8601String(),
    'wakeTime': wakeTime.toIso8601String(),
    'quality': quality.name,
    'phases': phases.map((p) => p.toJson()).toList(),
    'notes': notes,
    'factors': factors.map((f) => f.name).toList(),
  };

  factory SleepEntry.fromJson(Map<String, dynamic> json) => SleepEntry(
    id: json['id'],
    bedTime: DateTime.parse(json['bedTime']),
    wakeTime: DateTime.parse(json['wakeTime']),
    quality: SleepQuality.values.firstWhere(
      (e) => e.name == json['quality'],
      orElse: () => SleepQuality.fair,
    ),
    phases:
        (json['phases'] as List?)
            ?.map((p) => SleepPhase.fromJson(p))
            .toList() ??
        [],
    notes: json['notes'],
    factors:
        (json['factors'] as List?)
            ?.map(
              (f) => SleepFactor.values.firstWhere(
                (e) => e.name == f,
                orElse: () => SleepFactor.none,
              ),
            )
            .toList() ??
        [],
  );
}

enum SleepQuality { terrible, poor, fair, good, excellent }

extension SleepQualityExtension on SleepQuality {
  String get displayName {
    switch (this) {
      case SleepQuality.terrible:
        return 'Terrible';
      case SleepQuality.poor:
        return 'Poor';
      case SleepQuality.fair:
        return 'Fair';
      case SleepQuality.good:
        return 'Good';
      case SleepQuality.excellent:
        return 'Excellent';
    }
  }

  String get emoji {
    switch (this) {
      case SleepQuality.terrible:
        return '😫';
      case SleepQuality.poor:
        return '😔';
      case SleepQuality.fair:
        return '😐';
      case SleepQuality.good:
        return '😊';
      case SleepQuality.excellent:
        return '😴';
    }
  }

  int get score {
    switch (this) {
      case SleepQuality.terrible:
        return 1;
      case SleepQuality.poor:
        return 2;
      case SleepQuality.fair:
        return 3;
      case SleepQuality.good:
        return 4;
      case SleepQuality.excellent:
        return 5;
    }
  }
}

enum SleepFactor {
  none,
  stress,
  caffeine,
  alcohol,
  lateNight,
  exercise,
  screenTime,
  heavyMeal,
  noise,
  temperature,
  travel,
  illness,
}

extension SleepFactorExtension on SleepFactor {
  String get displayName {
    switch (this) {
      case SleepFactor.none:
        return 'None';
      case SleepFactor.stress:
        return 'Stress';
      case SleepFactor.caffeine:
        return 'Caffeine';
      case SleepFactor.alcohol:
        return 'Alcohol';
      case SleepFactor.lateNight:
        return 'Late Night';
      case SleepFactor.exercise:
        return 'Exercise';
      case SleepFactor.screenTime:
        return 'Screen Time';
      case SleepFactor.heavyMeal:
        return 'Heavy Meal';
      case SleepFactor.noise:
        return 'Noise';
      case SleepFactor.temperature:
        return 'Temperature';
      case SleepFactor.travel:
        return 'Travel';
      case SleepFactor.illness:
        return 'Illness';
    }
  }

  String get icon {
    switch (this) {
      case SleepFactor.none:
        return '✓';
      case SleepFactor.stress:
        return '😰';
      case SleepFactor.caffeine:
        return '☕';
      case SleepFactor.alcohol:
        return '🍷';
      case SleepFactor.lateNight:
        return '🌙';
      case SleepFactor.exercise:
        return '🏃';
      case SleepFactor.screenTime:
        return '📱';
      case SleepFactor.heavyMeal:
        return '🍔';
      case SleepFactor.noise:
        return '🔊';
      case SleepFactor.temperature:
        return '🌡️';
      case SleepFactor.travel:
        return '✈️';
      case SleepFactor.illness:
        return '🤒';
    }
  }
}

class SleepPhase {
  final SleepPhaseType type;
  final DateTime startTime;
  final Duration duration;

  const SleepPhase({
    required this.type,
    required this.startTime,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'startTime': startTime.toIso8601String(),
    'durationMinutes': duration.inMinutes,
  };

  factory SleepPhase.fromJson(Map<String, dynamic> json) => SleepPhase(
    type: SleepPhaseType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => SleepPhaseType.light,
    ),
    startTime: DateTime.parse(json['startTime']),
    duration: Duration(minutes: json['durationMinutes']),
  );
}

enum SleepPhaseType { awake, light, deep, rem }

extension SleepPhaseTypeExtension on SleepPhaseType {
  String get displayName {
    switch (this) {
      case SleepPhaseType.awake:
        return 'Awake';
      case SleepPhaseType.light:
        return 'Light Sleep';
      case SleepPhaseType.deep:
        return 'Deep Sleep';
      case SleepPhaseType.rem:
        return 'REM Sleep';
    }
  }

  int get colorValue {
    switch (this) {
      case SleepPhaseType.awake:
        return 0xFFFF6B35;
      case SleepPhaseType.light:
        return 0xFF42A5F5;
      case SleepPhaseType.deep:
        return 0xFF1565C0;
      case SleepPhaseType.rem:
        return 0xFF7E57C2;
    }
  }
}

/// Sleep goal settings
class SleepGoalSettings {
  final double targetHours;
  final int targetBedTimeHour;
  final int targetBedTimeMinute;
  final int targetWakeTimeHour;
  final int targetWakeTimeMinute;
  final bool bedtimeReminderEnabled;
  final int bedtimeReminderMinutesBefore;

  const SleepGoalSettings({
    this.targetHours = 8,
    this.targetBedTimeHour = 22,
    this.targetBedTimeMinute = 30,
    this.targetWakeTimeHour = 6,
    this.targetWakeTimeMinute = 30,
    this.bedtimeReminderEnabled = true,
    this.bedtimeReminderMinutesBefore = 30,
  });

  Map<String, dynamic> toJson() => {
    'targetHours': targetHours,
    'targetBedTimeHour': targetBedTimeHour,
    'targetBedTimeMinute': targetBedTimeMinute,
    'targetWakeTimeHour': targetWakeTimeHour,
    'targetWakeTimeMinute': targetWakeTimeMinute,
    'bedtimeReminderEnabled': bedtimeReminderEnabled,
    'bedtimeReminderMinutesBefore': bedtimeReminderMinutesBefore,
  };

  factory SleepGoalSettings.fromJson(Map<String, dynamic> json) =>
      SleepGoalSettings(
        targetHours: (json['targetHours'] as num?)?.toDouble() ?? 8,
        targetBedTimeHour: json['targetBedTimeHour'] ?? 22,
        targetBedTimeMinute: json['targetBedTimeMinute'] ?? 30,
        targetWakeTimeHour: json['targetWakeTimeHour'] ?? 6,
        targetWakeTimeMinute: json['targetWakeTimeMinute'] ?? 30,
        bedtimeReminderEnabled: json['bedtimeReminderEnabled'] ?? true,
        bedtimeReminderMinutesBefore:
            json['bedtimeReminderMinutesBefore'] ?? 30,
      );

  SleepGoalSettings copyWith({
    double? targetHours,
    int? targetBedTimeHour,
    int? targetBedTimeMinute,
    int? targetWakeTimeHour,
    int? targetWakeTimeMinute,
    bool? bedtimeReminderEnabled,
    int? bedtimeReminderMinutesBefore,
  }) {
    return SleepGoalSettings(
      targetHours: targetHours ?? this.targetHours,
      targetBedTimeHour: targetBedTimeHour ?? this.targetBedTimeHour,
      targetBedTimeMinute: targetBedTimeMinute ?? this.targetBedTimeMinute,
      targetWakeTimeHour: targetWakeTimeHour ?? this.targetWakeTimeHour,
      targetWakeTimeMinute: targetWakeTimeMinute ?? this.targetWakeTimeMinute,
      bedtimeReminderEnabled:
          bedtimeReminderEnabled ?? this.bedtimeReminderEnabled,
      bedtimeReminderMinutesBefore:
          bedtimeReminderMinutesBefore ?? this.bedtimeReminderMinutesBefore,
    );
  }
}

/// Weekly sleep analysis
class WeeklySleepAnalysis {
  final DateTime weekStart;
  final List<SleepEntry> entries;
  final double averageDuration;
  final double averageQuality;
  final Duration totalSleep;
  final Map<SleepFactor, int> factorFrequency;

  const WeeklySleepAnalysis({
    required this.weekStart,
    required this.entries,
    required this.averageDuration,
    required this.averageQuality,
    required this.totalSleep,
    required this.factorFrequency,
  });

  String get sleepDebtStatus {
    final idealWeeklySleep = 56; // 8 hours * 7 days
    final actualHours = totalSleep.inMinutes / 60;
    final debt = idealWeeklySleep - actualHours;

    if (debt <= 0) return 'On track!';
    if (debt < 5) return 'Slight deficit';
    if (debt < 10) return 'Moderate deficit';
    return 'Significant deficit';
  }
}
