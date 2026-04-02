/// Heart rate tracking data model
class HeartRateEntry {
  final String id;
  final DateTime timestamp;
  final int bpm;
  final HeartRateType type;
  final String? note;

  HeartRateEntry({
    required this.id,
    required this.timestamp,
    required this.bpm,
    this.type = HeartRateType.manual,
    this.note,
  });

  HeartRateZone get zone {
    if (bpm < 100) return HeartRateZone.rest;
    if (bpm < 120) return HeartRateZone.warmUp;
    if (bpm < 140) return HeartRateZone.fatBurn;
    if (bpm < 160) return HeartRateZone.cardio;
    if (bpm < 180) return HeartRateZone.peak;
    return HeartRateZone.max;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'bpm': bpm,
    'type': type.name,
    'note': note,
  };

  factory HeartRateEntry.fromJson(Map<String, dynamic> json) => HeartRateEntry(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    bpm: json['bpm'],
    type: HeartRateType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => HeartRateType.manual,
    ),
    note: json['note'],
  );
}

enum HeartRateType { manual, resting, postWorkout, duringWorkout, sleep, auto }

enum HeartRateZone { rest, warmUp, fatBurn, cardio, peak, max }

extension HeartRateZoneExtension on HeartRateZone {
  String get name {
    switch (this) {
      case HeartRateZone.rest:
        return 'Rest';
      case HeartRateZone.warmUp:
        return 'Warm Up';
      case HeartRateZone.fatBurn:
        return 'Fat Burn';
      case HeartRateZone.cardio:
        return 'Cardio';
      case HeartRateZone.peak:
        return 'Peak';
      case HeartRateZone.max:
        return 'Max';
    }
  }

  String get description {
    switch (this) {
      case HeartRateZone.rest:
        return 'Light activity or rest';
      case HeartRateZone.warmUp:
        return 'Easy exercise, recovery';
      case HeartRateZone.fatBurn:
        return 'Light to moderate, fat burning';
      case HeartRateZone.cardio:
        return 'Moderate to high, endurance';
      case HeartRateZone.peak:
        return 'High intensity, performance';
      case HeartRateZone.max:
        return 'Maximum effort';
    }
  }

  double get minPercentage {
    switch (this) {
      case HeartRateZone.rest:
        return 0;
      case HeartRateZone.warmUp:
        return 50;
      case HeartRateZone.fatBurn:
        return 60;
      case HeartRateZone.cardio:
        return 70;
      case HeartRateZone.peak:
        return 80;
      case HeartRateZone.max:
        return 90;
    }
  }

  double get maxPercentage {
    switch (this) {
      case HeartRateZone.rest:
        return 50;
      case HeartRateZone.warmUp:
        return 60;
      case HeartRateZone.fatBurn:
        return 70;
      case HeartRateZone.cardio:
        return 80;
      case HeartRateZone.peak:
        return 90;
      case HeartRateZone.max:
        return 100;
    }
  }
}

class HeartRateStats {
  final int restingBpm;
  final int maxBpm;
  final int averageBpm;
  final int minBpm;
  final DateTime lastUpdated;

  HeartRateStats({
    required this.restingBpm,
    required this.maxBpm,
    required this.averageBpm,
    required this.minBpm,
    required this.lastUpdated,
  });

  /// Calculate max heart rate based on age
  static int calculateMaxHeartRate(int age) {
    return 220 - age;
  }

  /// Get target heart rate range for a zone
  static (int min, int max) getZoneRange(int maxHr, HeartRateZone zone) {
    final minBpm = (maxHr * zone.minPercentage / 100).round();
    final maxBpm = (maxHr * zone.maxPercentage / 100).round();
    return (minBpm, maxBpm);
  }

  Map<String, dynamic> toJson() => {
    'restingBpm': restingBpm,
    'maxBpm': maxBpm,
    'averageBpm': averageBpm,
    'minBpm': minBpm,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory HeartRateStats.fromJson(Map<String, dynamic> json) => HeartRateStats(
    restingBpm: json['restingBpm'],
    maxBpm: json['maxBpm'],
    averageBpm: json['averageBpm'],
    minBpm: json['minBpm'],
    lastUpdated: DateTime.parse(json['lastUpdated']),
  );
}

class DailyHeartRateSummary {
  final DateTime date;
  final int restingBpm;
  final int peakBpm;
  final int averageBpm;
  final List<HeartRateEntry> entries;
  final Map<HeartRateZone, Duration> timeInZones;

  DailyHeartRateSummary({
    required this.date,
    required this.restingBpm,
    required this.peakBpm,
    required this.averageBpm,
    required this.entries,
    this.timeInZones = const {},
  });
}
