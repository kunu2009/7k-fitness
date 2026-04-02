import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing step tracking data
class StepProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  Map<String, DailyStepData> _stepHistory = {};
  int _dailyGoal = 10000;
  bool _isInitialized = false;

  // Getters
  int get dailyGoal => _dailyGoal;
  bool get isInitialized => _isInitialized;
  Map<String, DailyStepData> get stepHistory => _stepHistory;

  /// Initialize the provider
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _loadDailyGoal();
    _loadStepHistory();
    _isInitialized = true;
    notifyListeners();
  }

  void _loadDailyGoal() {
    _dailyGoal = _prefs.getInt('stepDailyGoal') ?? 10000;
  }

  void _loadStepHistory() {
    final historyJson = _prefs.getString('stepHistory');
    if (historyJson != null) {
      final Map<String, dynamic> data = jsonDecode(historyJson);
      _stepHistory = data.map(
        (key, value) => MapEntry(key, DailyStepData.fromJson(value)),
      );
    }
  }

  void _saveStepHistory() {
    final historyJson = jsonEncode(
      _stepHistory.map((key, value) => MapEntry(key, value.toJson())),
    );
    _prefs.setString('stepHistory', historyJson);
  }

  /// Get date key for storage
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get today's step data
  DailyStepData get todayData {
    final key = _getDateKey(DateTime.now());
    return _stepHistory[key] ??
        DailyStepData(date: DateTime.now(), steps: 0, goal: _dailyGoal);
  }

  /// Get steps for today
  int get todaySteps => todayData.steps;

  /// Update today's steps
  void updateSteps(int steps) {
    final key = _getDateKey(DateTime.now());
    _stepHistory[key] = DailyStepData(
      date: DateTime.now(),
      steps: steps,
      goal: _dailyGoal,
      caloriesBurned: _calculateCalories(steps),
      distanceKm: _calculateDistance(steps),
    );
    _saveStepHistory();
    notifyListeners();
  }

  /// Add steps to today's count
  void addSteps(int stepsToAdd) {
    updateSteps(todaySteps + stepsToAdd);
  }

  /// Set daily goal
  void setDailyGoal(int goal) {
    _dailyGoal = goal;
    _prefs.setInt('stepDailyGoal', goal);
    notifyListeners();
  }

  /// Get step data for a specific date
  DailyStepData? getStepsForDate(DateTime date) {
    final key = _getDateKey(date);
    return _stepHistory[key];
  }

  /// Get weekly step data
  List<DailyStepData> getWeeklyData() {
    final now = DateTime.now();
    final data = <DailyStepData>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final key = _getDateKey(date);
      data.add(
        _stepHistory[key] ??
            DailyStepData(date: date, steps: 0, goal: _dailyGoal),
      );
    }

    return data;
  }

  /// Get monthly step data
  List<DailyStepData> getMonthlyData() {
    final now = DateTime.now();
    final data = <DailyStepData>[];

    for (int i = 29; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final key = _getDateKey(date);
      data.add(
        _stepHistory[key] ??
            DailyStepData(date: date, steps: 0, goal: _dailyGoal),
      );
    }

    return data;
  }

  /// Calculate calories burned from steps
  double _calculateCalories(int steps) {
    // Rough estimate: ~0.04 calories per step
    return steps * 0.04;
  }

  /// Calculate distance from steps (assuming 0.75m per step)
  double _calculateDistance(int steps) {
    return steps * 0.75 / 1000; // km
  }

  /// Get average steps for the last n days
  int getAverageSteps({int days = 7}) {
    final now = DateTime.now();
    int totalSteps = 0;
    int daysWithData = 0;

    for (int i = 0; i < days; i++) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final data = getStepsForDate(date);
      if (data != null && data.steps > 0) {
        totalSteps += data.steps;
        daysWithData++;
      }
    }

    return daysWithData > 0 ? totalSteps ~/ daysWithData : 0;
  }

  /// Get total steps for the week
  int getWeeklyTotal() {
    return getWeeklyData().fold(0, (sum, data) => sum + data.steps);
  }

  /// Get total distance for the week (km)
  double getWeeklyDistance() {
    return getWeeklyData().fold(0.0, (sum, data) => sum + data.distanceKm);
  }

  /// Get total calories burned for the week
  double getWeeklyCalories() {
    return getWeeklyData().fold(0.0, (sum, data) => sum + data.caloriesBurned);
  }

  /// Get current streak of meeting daily goal
  int get goalStreak {
    int streak = 0;
    final now = DateTime.now();

    for (int i = 1; i <= 365; i++) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final data = getStepsForDate(date);

      if (data != null && data.steps >= data.goal) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get best day (most steps) in the last n days
  DailyStepData? getBestDay({int days = 30}) {
    final now = DateTime.now();
    DailyStepData? best;

    for (int i = 0; i < days; i++) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final data = getStepsForDate(date);

      if (data != null && (best == null || data.steps > best.steps)) {
        best = data;
      }
    }

    return best;
  }

  /// Get progress percentage for today
  double get todayProgress {
    return (todaySteps / _dailyGoal * 100).clamp(0, 100);
  }

  /// Check if today's goal is met
  bool get todayGoalMet => todaySteps >= _dailyGoal;

  /// Get days where goal was met in the last n days
  int getDaysGoalMet({int days = 30}) {
    final now = DateTime.now();
    int count = 0;

    for (int i = 0; i < days; i++) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final data = getStepsForDate(date);

      if (data != null && data.steps >= data.goal) {
        count++;
      }
    }

    return count;
  }

  // ==================== ALIAS METHODS FOR UI COMPATIBILITY ====================

  /// Get step goal (alias for dailyGoal)
  int get stepGoal => _dailyGoal;

  /// Set step goal (alias for setDailyGoal)
  void setStepGoal(int goal) {
    setDailyGoal(goal);
  }

  /// Get weekly steps as list of integers
  List<int> getWeeklySteps() {
    return getWeeklyData().map((d) => d.steps).toList();
  }

  /// Get step history as list (for history sheet)
  List<DailyStepData> get stepHistoryList {
    final sortedKeys = _stepHistory.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    return sortedKeys.map((key) => _stepHistory[key]!).toList();
  }
}

/// Data class for daily step information
class DailyStepData {
  final DateTime date;
  final int steps;
  final int goal;
  final double caloriesBurned;
  final double distanceKm;
  final int activeMinutes;

  DailyStepData({
    required this.date,
    required this.steps,
    required this.goal,
    this.caloriesBurned = 0,
    this.distanceKm = 0,
    this.activeMinutes = 0,
  });

  double get progress => (steps / goal * 100).clamp(0, 100);
  bool get goalMet => steps >= goal;

  String get dayLabel {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'steps': steps,
    'goal': goal,
    'caloriesBurned': caloriesBurned,
    'distanceKm': distanceKm,
    'activeMinutes': activeMinutes,
  };

  factory DailyStepData.fromJson(Map<String, dynamic> json) => DailyStepData(
    date: DateTime.parse(json['date']),
    steps: json['steps'] ?? 0,
    goal: json['goal'] ?? 10000,
    caloriesBurned: (json['caloriesBurned'] ?? 0).toDouble(),
    distanceKm: (json['distanceKm'] ?? 0).toDouble(),
    activeMinutes: json['activeMinutes'] ?? 0,
  );
}
