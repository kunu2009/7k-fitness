import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for body measurement tracking with history and progress
class BodyMeasurementProvider with ChangeNotifier {
  static const String _keyMeasurementHistory = 'body_measurement_history';
  static const String _keyMeasurementGoals = 'body_measurement_goals';
  static const String _keyPreferredUnit = 'measurement_unit';

  SharedPreferences? _prefs;

  // Current measurements
  BodyMeasurements? _latestMeasurements;

  // History
  List<BodyMeasurementEntry> _measurementHistory = [];

  // Goals
  Map<MeasurementType, double> _goals = {};

  // Settings
  MeasurementUnit _preferredUnit = MeasurementUnit.metric;

  // Getters
  BodyMeasurements? get latestMeasurements => _latestMeasurements;
  List<BodyMeasurementEntry> get measurementHistory =>
      List.unmodifiable(_measurementHistory);
  Map<MeasurementType, double> get goals => Map.unmodifiable(_goals);
  MeasurementUnit get preferredUnit => _preferredUnit;

  /// Initialize provider
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadHistory();
    await _loadGoals();
    await _loadSettings();
  }

  Future<void> _loadHistory() async {
    if (_prefs == null) return;

    final historyJson = _prefs!.getString(_keyMeasurementHistory);
    if (historyJson != null) {
      try {
        final List decoded = jsonDecode(historyJson);
        _measurementHistory =
            decoded.map((e) => BodyMeasurementEntry.fromJson(e)).toList()
              ..sort((a, b) => b.date.compareTo(a.date));

        if (_measurementHistory.isNotEmpty) {
          _latestMeasurements = _measurementHistory.first.measurements;
        }
      } catch (e) {
        debugPrint('Error loading measurement history: $e');
      }
    }
  }

  Future<void> _loadGoals() async {
    if (_prefs == null) return;

    final goalsJson = _prefs!.getString(_keyMeasurementGoals);
    if (goalsJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(goalsJson);
        _goals = decoded.map(
          (key, value) => MapEntry(
            MeasurementType.values[int.parse(key)],
            (value as num).toDouble(),
          ),
        );
      } catch (e) {
        debugPrint('Error loading measurement goals: $e');
      }
    }
  }

  Future<void> _loadSettings() async {
    if (_prefs == null) return;
    final unitIndex = _prefs!.getInt(_keyPreferredUnit) ?? 0;
    _preferredUnit = MeasurementUnit.values[unitIndex];
  }

  /// Add new measurements
  Future<void> addMeasurements(
    BodyMeasurements measurements, {
    String? notes,
  }) async {
    final entry = BodyMeasurementEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      measurements: measurements,
      notes: notes,
    );

    _measurementHistory.insert(0, entry);
    _latestMeasurements = measurements;

    await _saveHistory();
    notifyListeners();
  }

  /// Update a specific measurement
  Future<void> updateMeasurement(MeasurementType type, double value) async {
    final current = _latestMeasurements ?? BodyMeasurements();
    final updated = current.copyWith(type: type, value: value);

    // Check if we should create a new entry or update today's
    final today = DateTime.now();
    final todayEntry =
        _measurementHistory.isNotEmpty &&
        _measurementHistory.first.date.year == today.year &&
        _measurementHistory.first.date.month == today.month &&
        _measurementHistory.first.date.day == today.day;

    if (todayEntry) {
      _measurementHistory[0] = _measurementHistory[0].copyWith(
        measurements: updated,
      );
    } else {
      _measurementHistory.insert(
        0,
        BodyMeasurementEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          measurements: updated,
        ),
      );
    }

    _latestMeasurements = updated;
    await _saveHistory();
    notifyListeners();
  }

  /// Delete a measurement entry
  Future<void> deleteEntry(String entryId) async {
    _measurementHistory.removeWhere((e) => e.id == entryId);
    if (_measurementHistory.isNotEmpty) {
      _latestMeasurements = _measurementHistory.first.measurements;
    } else {
      _latestMeasurements = null;
    }
    await _saveHistory();
    notifyListeners();
  }

  /// Set a goal for a measurement type
  Future<void> setGoal(MeasurementType type, double value) async {
    _goals[type] = value;
    await _saveGoals();
    notifyListeners();
  }

  /// Remove a goal
  Future<void> removeGoal(MeasurementType type) async {
    _goals.remove(type);
    await _saveGoals();
    notifyListeners();
  }

  /// Set preferred unit system
  Future<void> setPreferredUnit(MeasurementUnit unit) async {
    _preferredUnit = unit;
    await _prefs?.setInt(_keyPreferredUnit, unit.index);
    notifyListeners();
  }

  /// Get progress towards goal
  double? getProgressToGoal(MeasurementType type) {
    final current = _latestMeasurements?.getValue(type);
    final goal = _goals[type];

    if (current == null || goal == null || goal == 0) return null;

    // For weight/body fat, progress is inverse (lower is better typically)
    if (type == MeasurementType.weight ||
        type == MeasurementType.bodyFatPercentage) {
      if (current <= goal) return 1.0;
      final start = _measurementHistory.isNotEmpty
          ? _measurementHistory.last.measurements.getValue(type) ?? current
          : current;
      if (start == goal) return 1.0;
      return ((start - current) / (start - goal)).clamp(0.0, 1.0);
    }

    // For muscle measurements, higher is better
    return (current / goal).clamp(0.0, 1.5);
  }

  /// Get measurement history for a specific type
  List<MeasurementDataPoint> getHistoryForType(
    MeasurementType type, {
    int days = 30,
  }) {
    final cutoff = DateTime.now().subtract(Duration(days: days));

    return _measurementHistory
        .where(
          (e) =>
              e.date.isAfter(cutoff) && e.measurements.getValue(type) != null,
        )
        .map(
          (e) => MeasurementDataPoint(
            date: e.date,
            value: (e.measurements.getValue(type) ?? 0).toDouble(),
          ),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get change over period
  MeasurementChange? getChangeOverPeriod(MeasurementType type, int days) {
    final history = getHistoryForType(type, days: days);
    if (history.length < 2) return null;

    final oldest = history.first.value;
    final newest = history.last.value;
    final change = newest - oldest;
    final double percentChange = oldest != 0 ? (change / oldest) * 100 : 0.0;

    return MeasurementChange(
      absoluteChange: change,
      percentChange: percentChange,
      startValue: oldest,
      endValue: newest,
      periodDays: days,
    );
  }

  /// Get stats
  MeasurementStats getStats() {
    final entries = _measurementHistory.length;

    // Weight change in last 30 days
    final weightChange = getChangeOverPeriod(MeasurementType.weight, 30);

    // Body fat change in last 30 days
    final bodyFatChange = getChangeOverPeriod(
      MeasurementType.bodyFatPercentage,
      30,
    );

    // Days since last measurement
    int daysSinceLastMeasurement = 0;
    if (_measurementHistory.isNotEmpty) {
      daysSinceLastMeasurement = DateTime.now()
          .difference(_measurementHistory.first.date)
          .inDays;
    }

    // Goals achieved
    int goalsAchieved = 0;
    for (final goal in _goals.entries) {
      final progress = getProgressToGoal(goal.key);
      if (progress != null && progress >= 1.0) {
        goalsAchieved++;
      }
    }

    return MeasurementStats(
      totalEntries: entries,
      daysSinceLastMeasurement: daysSinceLastMeasurement,
      weightChange30Days: weightChange?.absoluteChange,
      bodyFatChange30Days: bodyFatChange?.absoluteChange,
      goalsSet: _goals.length,
      goalsAchieved: goalsAchieved,
    );
  }

  /// Get insights
  List<String> getInsights() {
    final insights = <String>[];
    final stats = getStats();

    if (stats.daysSinceLastMeasurement > 7) {
      insights.add(
        '📏 It\'s been ${stats.daysSinceLastMeasurement} days since your last measurement.',
      );
    }

    if (stats.weightChange30Days != null) {
      if (stats.weightChange30Days! < -0.5) {
        insights.add(
          '📉 You\'ve lost ${stats.weightChange30Days!.abs().toStringAsFixed(1)} kg in the last 30 days!',
        );
      } else if (stats.weightChange30Days! > 0.5) {
        insights.add(
          '📈 You\'ve gained ${stats.weightChange30Days!.toStringAsFixed(1)} kg in the last 30 days.',
        );
      } else {
        insights.add('⚖️ Your weight has been stable this month.');
      }
    }

    if (stats.bodyFatChange30Days != null && stats.bodyFatChange30Days! < -1) {
      insights.add(
        '💪 Great progress! Body fat down ${stats.bodyFatChange30Days!.abs().toStringAsFixed(1)}%',
      );
    }

    if (stats.goalsAchieved > 0) {
      insights.add(
        '🎯 You\'ve achieved ${stats.goalsAchieved} of your ${stats.goalsSet} measurement goals!',
      );
    }

    // Check specific measurements
    final chest = _latestMeasurements?.chest;
    final waist = _latestMeasurements?.waist;
    if (chest != null && waist != null && waist > 0) {
      final ratio = chest / waist;
      if (ratio > 1.3) {
        insights.add(
          '💪 Excellent chest-to-waist ratio: ${ratio.toStringAsFixed(2)}',
        );
      }
    }

    return insights;
  }

  Future<void> _saveHistory() async {
    if (_prefs == null) return;
    final json = jsonEncode(
      _measurementHistory.map((e) => e.toJson()).toList(),
    );
    await _prefs!.setString(_keyMeasurementHistory, json);
  }

  Future<void> _saveGoals() async {
    if (_prefs == null) return;
    final json = jsonEncode(
      _goals.map((key, value) => MapEntry(key.index.toString(), value)),
    );
    await _prefs!.setString(_keyMeasurementGoals, json);
  }
}

/// Body measurement types
enum MeasurementType {
  weight,
  bodyFatPercentage,
  muscleMass,
  chest,
  waist,
  hips,
  leftBicep,
  rightBicep,
  leftThigh,
  rightThigh,
  leftCalf,
  rightCalf,
  shoulders,
  neck,
  leftForearm,
  rightForearm,
}

extension MeasurementTypeExtension on MeasurementType {
  String get displayName {
    switch (this) {
      case MeasurementType.weight:
        return 'Weight';
      case MeasurementType.bodyFatPercentage:
        return 'Body Fat %';
      case MeasurementType.muscleMass:
        return 'Muscle Mass';
      case MeasurementType.chest:
        return 'Chest';
      case MeasurementType.waist:
        return 'Waist';
      case MeasurementType.hips:
        return 'Hips';
      case MeasurementType.leftBicep:
        return 'Left Bicep';
      case MeasurementType.rightBicep:
        return 'Right Bicep';
      case MeasurementType.leftThigh:
        return 'Left Thigh';
      case MeasurementType.rightThigh:
        return 'Right Thigh';
      case MeasurementType.leftCalf:
        return 'Left Calf';
      case MeasurementType.rightCalf:
        return 'Right Calf';
      case MeasurementType.shoulders:
        return 'Shoulders';
      case MeasurementType.neck:
        return 'Neck';
      case MeasurementType.leftForearm:
        return 'Left Forearm';
      case MeasurementType.rightForearm:
        return 'Right Forearm';
    }
  }

  String get unit {
    switch (this) {
      case MeasurementType.weight:
        return 'kg';
      case MeasurementType.bodyFatPercentage:
        return '%';
      case MeasurementType.muscleMass:
        return 'kg';
      default:
        return 'cm';
    }
  }

  String get icon {
    switch (this) {
      case MeasurementType.weight:
        return '⚖️';
      case MeasurementType.bodyFatPercentage:
        return '📊';
      case MeasurementType.muscleMass:
        return '💪';
      case MeasurementType.chest:
        return '👕';
      case MeasurementType.waist:
        return '👖';
      case MeasurementType.hips:
        return '🩳';
      case MeasurementType.leftBicep:
      case MeasurementType.rightBicep:
        return '💪';
      case MeasurementType.leftThigh:
      case MeasurementType.rightThigh:
        return '🦵';
      case MeasurementType.leftCalf:
      case MeasurementType.rightCalf:
        return '🦶';
      case MeasurementType.shoulders:
        return '🤷';
      case MeasurementType.neck:
        return '👔';
      case MeasurementType.leftForearm:
      case MeasurementType.rightForearm:
        return '🤚';
    }
  }
}

/// Unit system
enum MeasurementUnit { metric, imperial }

/// Body measurements data
class BodyMeasurements {
  final double? weight;
  final double? bodyFatPercentage;
  final double? muscleMass;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? leftBicep;
  final double? rightBicep;
  final double? leftThigh;
  final double? rightThigh;
  final double? leftCalf;
  final double? rightCalf;
  final double? shoulders;
  final double? neck;
  final double? leftForearm;
  final double? rightForearm;

  BodyMeasurements({
    this.weight,
    this.bodyFatPercentage,
    this.muscleMass,
    this.chest,
    this.waist,
    this.hips,
    this.leftBicep,
    this.rightBicep,
    this.leftThigh,
    this.rightThigh,
    this.leftCalf,
    this.rightCalf,
    this.shoulders,
    this.neck,
    this.leftForearm,
    this.rightForearm,
  });

  double? getValue(MeasurementType type) {
    switch (type) {
      case MeasurementType.weight:
        return weight;
      case MeasurementType.bodyFatPercentage:
        return bodyFatPercentage;
      case MeasurementType.muscleMass:
        return muscleMass;
      case MeasurementType.chest:
        return chest;
      case MeasurementType.waist:
        return waist;
      case MeasurementType.hips:
        return hips;
      case MeasurementType.leftBicep:
        return leftBicep;
      case MeasurementType.rightBicep:
        return rightBicep;
      case MeasurementType.leftThigh:
        return leftThigh;
      case MeasurementType.rightThigh:
        return rightThigh;
      case MeasurementType.leftCalf:
        return leftCalf;
      case MeasurementType.rightCalf:
        return rightCalf;
      case MeasurementType.shoulders:
        return shoulders;
      case MeasurementType.neck:
        return neck;
      case MeasurementType.leftForearm:
        return leftForearm;
      case MeasurementType.rightForearm:
        return rightForearm;
    }
  }

  BodyMeasurements copyWith({MeasurementType? type, double? value}) {
    return BodyMeasurements(
      weight: type == MeasurementType.weight ? value : weight,
      bodyFatPercentage: type == MeasurementType.bodyFatPercentage
          ? value
          : bodyFatPercentage,
      muscleMass: type == MeasurementType.muscleMass ? value : muscleMass,
      chest: type == MeasurementType.chest ? value : chest,
      waist: type == MeasurementType.waist ? value : waist,
      hips: type == MeasurementType.hips ? value : hips,
      leftBicep: type == MeasurementType.leftBicep ? value : leftBicep,
      rightBicep: type == MeasurementType.rightBicep ? value : rightBicep,
      leftThigh: type == MeasurementType.leftThigh ? value : leftThigh,
      rightThigh: type == MeasurementType.rightThigh ? value : rightThigh,
      leftCalf: type == MeasurementType.leftCalf ? value : leftCalf,
      rightCalf: type == MeasurementType.rightCalf ? value : rightCalf,
      shoulders: type == MeasurementType.shoulders ? value : shoulders,
      neck: type == MeasurementType.neck ? value : neck,
      leftForearm: type == MeasurementType.leftForearm ? value : leftForearm,
      rightForearm: type == MeasurementType.rightForearm ? value : rightForearm,
    );
  }

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'bodyFatPercentage': bodyFatPercentage,
    'muscleMass': muscleMass,
    'chest': chest,
    'waist': waist,
    'hips': hips,
    'leftBicep': leftBicep,
    'rightBicep': rightBicep,
    'leftThigh': leftThigh,
    'rightThigh': rightThigh,
    'leftCalf': leftCalf,
    'rightCalf': rightCalf,
    'shoulders': shoulders,
    'neck': neck,
    'leftForearm': leftForearm,
    'rightForearm': rightForearm,
  };

  factory BodyMeasurements.fromJson(Map<String, dynamic> json) =>
      BodyMeasurements(
        weight: (json['weight'] as num?)?.toDouble(),
        bodyFatPercentage: (json['bodyFatPercentage'] as num?)?.toDouble(),
        muscleMass: (json['muscleMass'] as num?)?.toDouble(),
        chest: (json['chest'] as num?)?.toDouble(),
        waist: (json['waist'] as num?)?.toDouble(),
        hips: (json['hips'] as num?)?.toDouble(),
        leftBicep: (json['leftBicep'] as num?)?.toDouble(),
        rightBicep: (json['rightBicep'] as num?)?.toDouble(),
        leftThigh: (json['leftThigh'] as num?)?.toDouble(),
        rightThigh: (json['rightThigh'] as num?)?.toDouble(),
        leftCalf: (json['leftCalf'] as num?)?.toDouble(),
        rightCalf: (json['rightCalf'] as num?)?.toDouble(),
        shoulders: (json['shoulders'] as num?)?.toDouble(),
        neck: (json['neck'] as num?)?.toDouble(),
        leftForearm: (json['leftForearm'] as num?)?.toDouble(),
        rightForearm: (json['rightForearm'] as num?)?.toDouble(),
      );
}

/// Measurement entry with date
class BodyMeasurementEntry {
  final String id;
  final DateTime date;
  final BodyMeasurements measurements;
  final String? notes;

  BodyMeasurementEntry({
    required this.id,
    required this.date,
    required this.measurements,
    this.notes,
  });

  BodyMeasurementEntry copyWith({
    BodyMeasurements? measurements,
    String? notes,
  }) => BodyMeasurementEntry(
    id: id,
    date: date,
    measurements: measurements ?? this.measurements,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'measurements': measurements.toJson(),
    'notes': notes,
  };

  factory BodyMeasurementEntry.fromJson(Map<String, dynamic> json) =>
      BodyMeasurementEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        measurements: BodyMeasurements.fromJson(
          json['measurements'] as Map<String, dynamic>,
        ),
        notes: json['notes'] as String?,
      );
}

/// Data point for charts
class MeasurementDataPoint {
  final DateTime date;
  final double value;

  MeasurementDataPoint({required this.date, required this.value});
}

/// Measurement change over period
class MeasurementChange {
  final double absoluteChange;
  final double percentChange;
  final double startValue;
  final double endValue;
  final int periodDays;

  MeasurementChange({
    required this.absoluteChange,
    required this.percentChange,
    required this.startValue,
    required this.endValue,
    required this.periodDays,
  });
}

/// Measurement statistics
class MeasurementStats {
  final int totalEntries;
  final int daysSinceLastMeasurement;
  final double? weightChange30Days;
  final double? bodyFatChange30Days;
  final int goalsSet;
  final int goalsAchieved;

  MeasurementStats({
    required this.totalEntries,
    required this.daysSinceLastMeasurement,
    this.weightChange30Days,
    this.bodyFatChange30Days,
    required this.goalsSet,
    required this.goalsAchieved,
  });
}
