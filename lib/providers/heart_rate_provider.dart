import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/heart_rate.dart';

/// Heart rate reading record for persistence
class HeartRateRecord {
  final String id;
  final DateTime timestamp;
  final int bpm;
  final HeartRateZone zone;
  final String? notes;

  HeartRateRecord({
    required this.id,
    required this.timestamp,
    required this.bpm,
    required this.zone,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'bpm': bpm,
    'zone': zone.index,
    'notes': notes,
  };

  factory HeartRateRecord.fromJson(Map<String, dynamic> json) =>
      HeartRateRecord(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        bpm: json['bpm'] as int,
        zone: HeartRateZone.values[json['zone'] as int],
        notes: json['notes'] as String?,
      );
}

/// Provider for managing heart rate data with persistence
class HeartRateProvider extends ChangeNotifier {
  static const String _heartRateKey = 'heart_rate_records';
  static const String _restingHrKey = 'resting_heart_rate';
  static const String _maxHrKey = 'max_heart_rate';
  static const String _ageKey = 'user_age';

  List<HeartRateRecord> _records = [];
  int _restingHeartRate = 70;
  int _maxHeartRate = 190;
  int _userAge = 30;
  bool _isLoading = true;

  HeartRateProvider() {
    _loadData();
  }

  // Getters
  List<HeartRateRecord> get records => List.unmodifiable(_records);
  int get restingHeartRate => _restingHeartRate;
  int get maxHeartRate => _maxHeartRate;
  int get userAge => _userAge;
  bool get isLoading => _isLoading;

  /// Load data from SharedPreferences
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load settings
      _restingHeartRate = prefs.getInt(_restingHrKey) ?? 70;
      _maxHeartRate = prefs.getInt(_maxHrKey) ?? 190;
      _userAge = prefs.getInt(_ageKey) ?? 30;

      // Load records
      final recordsJson = prefs.getString(_heartRateKey);
      if (recordsJson != null) {
        final List<dynamic> decoded = jsonDecode(recordsJson);
        _records = decoded
            .map(
              (json) => HeartRateRecord.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        // Sort by timestamp descending (newest first)
        _records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading heart rate data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save records to SharedPreferences
  Future<void> _saveRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_records.map((r) => r.toJson()).toList());
      await prefs.setString(_heartRateKey, encoded);
    } catch (e) {
      debugPrint('Error saving heart rate records: $e');
    }
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_restingHrKey, _restingHeartRate);
      await prefs.setInt(_maxHrKey, _maxHeartRate);
      await prefs.setInt(_ageKey, _userAge);
    } catch (e) {
      debugPrint('Error saving heart rate settings: $e');
    }
  }

  /// Add a heart rate reading
  Future<void> addReading({required int bpm, String? notes}) async {
    final zone = _calculateZone(bpm);
    final record = HeartRateRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      bpm: bpm,
      zone: zone,
      notes: notes,
    );

    _records.insert(0, record);
    await _saveRecords();
    notifyListeners();
  }

  /// Delete a heart rate reading
  Future<void> deleteReading(String id) async {
    _records.removeWhere((r) => r.id == id);
    await _saveRecords();
    notifyListeners();
  }

  /// Calculate heart rate zone based on bpm
  HeartRateZone _calculateZone(int bpm) {
    final hrReserve = _maxHeartRate - _restingHeartRate;
    final percentage = (bpm - _restingHeartRate) / hrReserve;

    if (percentage < 0.5) return HeartRateZone.rest;
    if (percentage < 0.6) return HeartRateZone.warmUp;
    if (percentage < 0.7) return HeartRateZone.fatBurn;
    if (percentage < 0.8) return HeartRateZone.cardio;
    if (percentage < 0.9) return HeartRateZone.peak;
    return HeartRateZone.peak;
  }

  /// Get today's readings
  List<HeartRateRecord> get todaysReadings {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _records
        .where(
          (r) =>
              r.timestamp.isAfter(today) &&
              r.timestamp.isBefore(today.add(const Duration(days: 1))),
        )
        .toList();
  }

  /// Get weekly readings
  List<HeartRateRecord> get weeklyReadings {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _records.where((r) => r.timestamp.isAfter(weekAgo)).toList();
  }

  /// Get average heart rate for today
  int get todaysAverageBpm {
    final readings = todaysReadings;
    if (readings.isEmpty) return _restingHeartRate;
    final total = readings.fold<int>(0, (sum, r) => sum + r.bpm);
    return (total / readings.length).round();
  }

  /// Get min heart rate for today
  int get todaysMinBpm {
    final readings = todaysReadings;
    if (readings.isEmpty) return _restingHeartRate;
    return readings.map((r) => r.bpm).reduce((a, b) => a < b ? a : b);
  }

  /// Get max heart rate for today
  int get todaysMaxBpm {
    final readings = todaysReadings;
    if (readings.isEmpty) return _restingHeartRate;
    return readings.map((r) => r.bpm).reduce((a, b) => a > b ? a : b);
  }

  /// Get latest reading
  HeartRateRecord? get latestReading {
    if (_records.isEmpty) return null;
    return _records.first;
  }

  /// Get current heart rate (latest or default)
  int get currentBpm {
    return latestReading?.bpm ?? _restingHeartRate;
  }

  /// Get current zone
  HeartRateZone get currentZone {
    return latestReading?.zone ?? HeartRateZone.rest;
  }

  /// Get weekly daily averages (for chart)
  List<int> getWeeklyDailyAverages() {
    final result = <int>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayReadings = _records
          .where(
            (r) =>
                r.timestamp.isAfter(dayStart) && r.timestamp.isBefore(dayEnd),
          )
          .toList();

      if (dayReadings.isEmpty) {
        result.add(_restingHeartRate);
      } else {
        final avg =
            dayReadings.fold<int>(0, (sum, r) => sum + r.bpm) ~/
            dayReadings.length;
        result.add(avg);
      }
    }

    return result;
  }

  /// Get week day labels
  List<String> get weekDayLabels {
    final result = <String>[];
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      result.add(days[date.weekday - 1]);
    }

    return result;
  }

  /// Get heart rate statistics
  Map<String, dynamic> get heartRateStats {
    final weekly = weeklyReadings;

    int avgBpm = _restingHeartRate;
    int minBpm = _restingHeartRate;
    int maxBpm = _restingHeartRate;
    int totalReadings = weekly.length;

    if (weekly.isNotEmpty) {
      avgBpm = weekly.fold<int>(0, (sum, r) => sum + r.bpm) ~/ weekly.length;
      minBpm = weekly.map((r) => r.bpm).reduce((a, b) => a < b ? a : b);
      maxBpm = weekly.map((r) => r.bpm).reduce((a, b) => a > b ? a : b);
    }

    // Count zone distribution
    final zoneCounts = <HeartRateZone, int>{};
    for (final zone in HeartRateZone.values) {
      zoneCounts[zone] = weekly.where((r) => r.zone == zone).length;
    }

    return {
      'avgBpm': avgBpm,
      'minBpm': minBpm,
      'maxBpm': maxBpm,
      'totalReadings': totalReadings,
      'zoneCounts': zoneCounts,
      'restingHr': _restingHeartRate,
      'maxHr': _maxHeartRate,
    };
  }

  /// Get heart rate insights
  List<Map<String, dynamic>> getInsights() {
    final insights = <Map<String, dynamic>>[];
    final stats = heartRateStats;
    final avgBpm = stats['avgBpm'] as int;

    // Resting heart rate analysis
    if (avgBpm < 60) {
      insights.add({
        'emoji': '💪',
        'title': 'Excellent Fitness',
        'description':
            'Your average heart rate of $avgBpm BPM indicates excellent cardiovascular fitness!',
        'color': Colors.green,
      });
    } else if (avgBpm <= 80) {
      insights.add({
        'emoji': '✅',
        'title': 'Healthy Heart Rate',
        'description':
            'Your average heart rate of $avgBpm BPM is within the healthy range.',
        'color': Colors.green,
      });
    } else {
      insights.add({
        'emoji': '⚠️',
        'title': 'Monitor Your Heart Rate',
        'description':
            'Your average heart rate of $avgBpm BPM is elevated. Consider consulting a doctor.',
        'color': Colors.orange,
      });
    }

    // Zone distribution
    final zoneCounts = stats['zoneCounts'] as Map<HeartRateZone, int>;
    final cardioCount = zoneCounts[HeartRateZone.cardio] ?? 0;
    final fatBurnCount = zoneCounts[HeartRateZone.fatBurn] ?? 0;

    if (cardioCount >= 3) {
      insights.add({
        'emoji': '🏃',
        'title': 'Active Week',
        'description':
            'You\'ve been in the cardio zone $cardioCount times this week. Great for heart health!',
        'color': Colors.blue,
      });
    }

    if (fatBurnCount >= 5) {
      insights.add({
        'emoji': '🔥',
        'title': 'Fat Burning Mode',
        'description':
            'You\'ve spent significant time in the fat burn zone. Keep it up!',
        'color': Colors.orange,
      });
    }

    // Trend analysis
    final totalReadings = stats['totalReadings'] as int;
    if (totalReadings < 7) {
      insights.add({
        'emoji': '📊',
        'title': 'Track More',
        'description':
            'Log more heart rate readings for better insights and trends.',
        'color': Colors.purple,
      });
    }

    return insights;
  }

  /// Set user age (used for max HR calculation)
  Future<void> setUserAge(int age) async {
    _userAge = age;
    _maxHeartRate = 220 - age; // Standard formula
    await _saveSettings();
    notifyListeners();
  }

  /// Set resting heart rate
  Future<void> setRestingHeartRate(int hr) async {
    _restingHeartRate = hr;
    await _saveSettings();
    notifyListeners();
  }

  /// Set max heart rate (override calculated)
  Future<void> setMaxHeartRate(int hr) async {
    _maxHeartRate = hr;
    await _saveSettings();
    notifyListeners();
  }

  /// Clear all readings
  Future<void> clearAllReadings() async {
    _records.clear();
    await _saveRecords();
    notifyListeners();
  }
}
