import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sleep_data.dart';

/// Provider for managing sleep tracking data
class SleepProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  List<SleepEntry> _sleepEntries = [];
  double _sleepGoalHours = 8.0;
  bool _isInitialized = false;

  // Getters
  List<SleepEntry> get sleepEntries => _sleepEntries;
  double get sleepGoalHours => _sleepGoalHours;
  bool get isInitialized => _isInitialized;

  /// Initialize the provider
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _loadSleepGoal();
    _loadSleepEntries();
    _loadAlarmSettings();
    _isInitialized = true;
    notifyListeners();
  }

  void _loadSleepGoal() {
    _sleepGoalHours = _prefs.getDouble('sleepGoalHours') ?? 8.0;
  }

  void _loadSleepEntries() {
    final entriesJson = _prefs.getStringList('sleepEntries') ?? [];
    if (entriesJson.isNotEmpty) {
      _sleepEntries = entriesJson
          .map((json) => SleepEntry.fromJson(jsonDecode(json)))
          .toList();
      // Sort by date, most recent first
      _sleepEntries.sort((a, b) => b.wakeTime.compareTo(a.wakeTime));
    }
  }

  void _saveSleepEntries() {
    final entriesJson = _sleepEntries
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    _prefs.setStringList('sleepEntries', entriesJson);
  }

  /// Add a new sleep entry
  void addSleepEntry(SleepEntry entry) {
    _sleepEntries.insert(0, entry);
    _saveSleepEntries();
    notifyListeners();
  }

  /// Update an existing sleep entry
  void updateSleepEntry(SleepEntry entry) {
    final index = _sleepEntries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _sleepEntries[index] = entry;
      _saveSleepEntries();
      notifyListeners();
    }
  }

  /// Delete a sleep entry
  void deleteSleepEntry(String id) {
    _sleepEntries.removeWhere((e) => e.id == id);
    _saveSleepEntries();
    notifyListeners();
  }

  /// Set sleep goal
  void setSleepGoal(double hours) {
    _sleepGoalHours = hours;
    _prefs.setDouble('sleepGoalHours', hours);
    notifyListeners();
  }

  /// Get sleep entry for a specific date
  SleepEntry? getSleepForDate(DateTime date) {
    try {
      return _sleepEntries.firstWhere(
        (e) =>
            e.wakeTime.year == date.year &&
            e.wakeTime.month == date.month &&
            e.wakeTime.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get sleep entries for the last n days
  List<SleepEntry> getRecentEntries({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _sleepEntries.where((e) => e.wakeTime.isAfter(cutoff)).toList();
  }

  /// Get weekly sleep data for charts
  List<DailySleepData> getWeeklySleepData() {
    final now = DateTime.now();
    final weekData = <DailySleepData>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final entry = getSleepForDate(date);

      weekData.add(
        DailySleepData(
          date: date,
          hoursSlept: entry?.duration.inMinutes.toDouble() ?? 0 / 60,
          quality: entry?.quality ?? SleepQuality.fair,
          entry: entry,
        ),
      );
    }

    return weekData;
  }

  /// Calculate average sleep duration for the last n days
  double getAverageSleepHours({int days = 7}) {
    final entries = getRecentEntries(days: days);
    if (entries.isEmpty) return 0;

    final totalMinutes = entries.fold<int>(
      0,
      (sum, entry) => sum + entry.duration.inMinutes,
    );

    return totalMinutes / entries.length / 60;
  }

  /// Calculate sleep consistency score (0-100)
  int getSleepConsistencyScore({int days = 7}) {
    final entries = getRecentEntries(days: days);
    if (entries.length < 2) return 100;

    // Calculate standard deviation of bed times
    final bedHours = entries.map((e) {
      final hour = e.bedTime.hour + e.bedTime.minute / 60.0;
      return hour < 12 ? hour + 24 : hour; // Handle past midnight
    }).toList();

    final avgBedHour = bedHours.reduce((a, b) => a + b) / bedHours.length;
    final variance =
        bedHours.fold<double>(
          0,
          (sum, hour) => sum + (hour - avgBedHour) * (hour - avgBedHour),
        ) /
        bedHours.length;

    final stdDev = variance > 0 ? variance : 0;

    // Convert std dev to score (lower is better)
    // 0 std dev = 100 score, 2+ hours std dev = 0 score
    final score = ((2 - stdDev.clamp(0, 2)) / 2 * 100).toInt();
    return score.clamp(0, 100);
  }

  /// Get sleep quality distribution
  Map<SleepQuality, int> getQualityDistribution({int days = 30}) {
    final entries = getRecentEntries(days: days);
    final distribution = <SleepQuality, int>{};

    for (final quality in SleepQuality.values) {
      distribution[quality] = entries.where((e) => e.quality == quality).length;
    }

    return distribution;
  }

  /// Get sleep debt (hours behind goal in the last week)
  double getSleepDebt() {
    final weeklyGoal = _sleepGoalHours * 7;
    final entries = getRecentEntries(days: 7);
    final totalSlept = entries.fold<double>(
      0,
      (sum, entry) => sum + entry.duration.inMinutes / 60,
    );

    return (weeklyGoal - totalSlept).clamp(0, double.infinity);
  }

  /// Get best sleep day of the week
  String? getBestSleepDay({int weeks = 4}) {
    final entries = getRecentEntries(days: weeks * 7);
    if (entries.isEmpty) return null;

    final dayTotals = <int, List<double>>{};
    for (int i = 0; i < 7; i++) {
      dayTotals[i] = [];
    }

    for (final entry in entries) {
      final day = entry.wakeTime.weekday - 1; // 0 = Monday
      dayTotals[day]!.add(entry.duration.inMinutes / 60);
    }

    int bestDay = 0;
    double bestAvg = 0;

    for (final day in dayTotals.entries) {
      if (day.value.isNotEmpty) {
        final avg = day.value.reduce((a, b) => a + b) / day.value.length;
        if (avg > bestAvg) {
          bestAvg = avg;
          bestDay = day.key;
        }
      }
    }

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[bestDay];
  }

  /// Get total sleep entries count
  int get totalEntriesCount => _sleepEntries.length;

  /// Get current streak of meeting sleep goal
  int get sleepGoalStreak {
    int streak = 0;
    final now = DateTime.now();

    for (int i = 0; i < _sleepEntries.length; i++) {
      final targetDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final entry = getSleepForDate(targetDate);

      if (entry != null &&
          entry.duration.inMinutes / 60 >= _sleepGoalHours * 0.9) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // ==================== ADDITIONAL METHODS FOR SCREEN ====================

  /// Get sleep stats for UI
  Map<String, dynamic> get sleepStats {
    final avgHours = getAverageSleepHours();
    final avgQuality = _sleepEntries.isEmpty
        ? 3.0
        : _sleepEntries
                  .map((e) => e.quality.index + 1.0)
                  .reduce((a, b) => a + b) /
              _sleepEntries.length;
    final bestDay = getBestSleepDay() ?? 'N/A';
    final streak = sleepGoalStreak;

    return {
      'averageHours': avgHours,
      'averageQuality': avgQuality,
      'bestDay': bestDay,
      'streak': streak,
    };
  }

  /// Get sleep history (alias for sleepEntries)
  List<SleepEntry> get sleepHistory => _sleepEntries;

  /// Get weekly sleep hours for chart
  List<double> getWeeklySleepHours() {
    final weekData = getWeeklySleepData();
    return weekData.map((d) => d.hoursSlept).toList();
  }

  /// Get sleep insights
  List<Map<String, dynamic>> getSleepInsights() {
    final insights = <Map<String, dynamic>>[];
    final avgHours = getAverageSleepHours();
    final goalProgress = avgHours / _sleepGoalHours;
    final streak = sleepGoalStreak;

    // Goal progress insight
    if (goalProgress >= 0.9) {
      insights.add({
        'emoji': '🎯',
        'title': 'Sleep Goal Progress',
        'description':
            'Great job! You\'re averaging ${avgHours.toStringAsFixed(1)}h of sleep.',
        'color': 'success',
      });
    } else {
      insights.add({
        'emoji': '🎯',
        'title': 'Sleep Goal Progress',
        'description':
            'You\'re averaging ${avgHours.toStringAsFixed(1)}h. Try to get closer to your ${_sleepGoalHours}h goal.',
        'color': 'warning',
      });
    }

    // Streak insight
    if (streak >= 3) {
      insights.add({
        'emoji': '🔥',
        'title': 'Sleep Streak',
        'description': 'You\'ve met your sleep goal for $streak days in a row!',
        'color': 'success',
      });
    }

    // Consistency insight
    final consistency = getSleepConsistencyScore();
    if (consistency >= 80) {
      insights.add({
        'emoji': '📊',
        'title': 'Consistent Schedule',
        'description': 'Your bedtime is very consistent. Keep it up!',
        'color': 'success',
      });
    } else if (consistency < 60) {
      insights.add({
        'emoji': '⚠️',
        'title': 'Inconsistent Schedule',
        'description':
            'Try to maintain a more regular bedtime for better sleep quality.',
        'color': 'warning',
      });
    }

    return insights;
  }

  // ==================== ALARM/REMINDER SETTINGS ====================

  TimeOfDay _bedtimeReminder = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeAlarm = const TimeOfDay(hour: 6, minute: 30);
  bool _bedtimeReminderEnabled = false;
  bool _wakeAlarmEnabled = false;

  TimeOfDay get bedtimeReminder => _bedtimeReminder;
  TimeOfDay get wakeAlarm => _wakeAlarm;
  bool get bedtimeReminderEnabled => _bedtimeReminderEnabled;
  bool get wakeAlarmEnabled => _wakeAlarmEnabled;

  void setBedtimeReminder(TimeOfDay time) {
    _bedtimeReminder = time;
    _prefs.setInt('bedtimeReminderHour', time.hour);
    _prefs.setInt('bedtimeReminderMinute', time.minute);
    notifyListeners();
  }

  void setWakeAlarm(TimeOfDay time) {
    _wakeAlarm = time;
    _prefs.setInt('wakeAlarmHour', time.hour);
    _prefs.setInt('wakeAlarmMinute', time.minute);
    notifyListeners();
  }

  void setBedtimeReminderEnabled(bool enabled) {
    _bedtimeReminderEnabled = enabled;
    _prefs.setBool('bedtimeReminderEnabled', enabled);
    notifyListeners();
  }

  void setWakeAlarmEnabled(bool enabled) {
    _wakeAlarmEnabled = enabled;
    _prefs.setBool('wakeAlarmEnabled', enabled);
    notifyListeners();
  }

  void setSleepGoalHours(double hours) {
    setSleepGoal(hours);
  }

  void _loadAlarmSettings() {
    _bedtimeReminderEnabled = _prefs.getBool('bedtimeReminderEnabled') ?? false;
    _wakeAlarmEnabled = _prefs.getBool('wakeAlarmEnabled') ?? false;
    _bedtimeReminder = TimeOfDay(
      hour: _prefs.getInt('bedtimeReminderHour') ?? 22,
      minute: _prefs.getInt('bedtimeReminderMinute') ?? 0,
    );
    _wakeAlarm = TimeOfDay(
      hour: _prefs.getInt('wakeAlarmHour') ?? 6,
      minute: _prefs.getInt('wakeAlarmMinute') ?? 30,
    );
  }
}

/// Daily sleep data for charts
class DailySleepData {
  final DateTime date;
  final double hoursSlept;
  final SleepQuality quality;
  final SleepEntry? entry;

  DailySleepData({
    required this.date,
    required this.hoursSlept,
    required this.quality,
    this.entry,
  });

  String get dayLabel {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
