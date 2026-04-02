import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons, IconData;
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for real water intake tracking with persistence
class WaterProvider with ChangeNotifier {
  static const String _keyWaterHistory = 'water_history';
  static const String _keyDailyGoal = 'water_daily_goal';
  static const String _keyReminderEnabled = 'water_reminder_enabled';
  static const String _keyReminderInterval = 'water_reminder_interval';

  SharedPreferences? _prefs;

  // Today's water data
  double _todayIntake = 0;
  double _dailyGoalValue = 2500; // Default 2500ml
  List<WaterEntry> _todayEntries = [];

  // History
  Map<String, DailyWaterData> _waterHistory = {};

  // Settings
  bool _reminderEnabled = false;
  int _reminderIntervalMinutes = 60;

  // Getters
  double get todayIntake => _todayIntake;
  double get dailyIntake => _todayIntake;
  double get dailyGoal => _dailyGoalValue;
  List<WaterEntry> get todayEntries => List.unmodifiable(_todayEntries);
  List<WaterEntry> get entries => _getAllEntries();
  double get progress => (_todayIntake / _dailyGoalValue).clamp(0.0, 1.5);
  bool get goalReached => _todayIntake >= _dailyGoalValue;
  bool get reminderEnabled => _reminderEnabled;
  int get reminderIntervalMinutes => _reminderIntervalMinutes;

  int get glassesConsumed => (_todayIntake / 250).floor();
  int get remainingMl =>
      (_dailyGoalValue - _todayIntake).clamp(0, _dailyGoalValue).toInt();

  /// Initialize the provider
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
    await _loadSettings();
  }

  Future<void> _loadData() async {
    if (_prefs == null) return;

    // Load history
    final historyJson = _prefs!.getString(_keyWaterHistory);
    if (historyJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(historyJson);
        _waterHistory = decoded.map(
          (key, value) => MapEntry(key, DailyWaterData.fromJson(value)),
        );
      } catch (e) {
        debugPrint('Error loading water history: $e');
      }
    }

    // Load today's data
    _loadTodayData();
  }

  void _loadTodayData() {
    final today = _getTodayKey();
    if (_waterHistory.containsKey(today)) {
      final todayData = _waterHistory[today]!;
      _todayIntake = todayData.totalIntake;
      _todayEntries = List.from(todayData.entries);
    } else {
      _todayIntake = 0;
      _todayEntries = [];
    }
  }

  Future<void> _loadSettings() async {
    if (_prefs == null) return;
    _dailyGoalValue = (_prefs!.getInt(_keyDailyGoal) ?? 2500).toDouble();
    _reminderEnabled = _prefs!.getBool(_keyReminderEnabled) ?? false;
    _reminderIntervalMinutes = _prefs!.getInt(_keyReminderInterval) ?? 60;
  }

  /// Add water intake
  Future<void> addWater(
    double amount, {
    WaterType type = WaterType.water,
  }) async {
    final entry = WaterEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: type,
      timestamp: DateTime.now(),
    );

    _todayEntries.add(entry);
    _todayIntake += amount;

    await _saveTodayData();
    notifyListeners();
  }

  /// Remove a specific water entry
  Future<void> removeEntry(String entryId) async {
    final entryIndex = _todayEntries.indexWhere((e) => e.id == entryId);
    if (entryIndex != -1) {
      final entry = _todayEntries[entryIndex];
      _todayIntake -= entry.amount;
      _todayEntries.removeAt(entryIndex);
      await _saveTodayData();
      notifyListeners();
    }
  }

  /// Reset today's water intake
  Future<void> resetToday() async {
    _todayIntake = 0;
    _todayEntries.clear();
    await _saveTodayData();
    notifyListeners();
  }

  /// Set daily goal
  Future<void> setDailyGoal(double goalMl) async {
    _dailyGoalValue = goalMl;
    await _prefs?.setInt(_keyDailyGoal, goalMl.toInt());
    notifyListeners();
  }

  /// Toggle reminders
  Future<void> setReminderEnabled(bool enabled) async {
    _reminderEnabled = enabled;
    await _prefs?.setBool(_keyReminderEnabled, enabled);
    notifyListeners();
  }

  /// Set reminder interval
  Future<void> setReminderInterval(int minutes) async {
    _reminderIntervalMinutes = minutes;
    await _prefs?.setInt(_keyReminderInterval, minutes);
    notifyListeners();
  }

  Future<void> _saveTodayData() async {
    if (_prefs == null) return;

    final today = _getTodayKey();
    _waterHistory[today] = DailyWaterData(
      date: DateTime.now(),
      totalIntake: _todayIntake,
      goal: _dailyGoalValue,
      entries: _todayEntries,
    );

    final historyJson = jsonEncode(
      _waterHistory.map((key, value) => MapEntry(key, value.toJson())),
    );
    await _prefs!.setString(_keyWaterHistory, historyJson);
  }

  /// Get all entries for history
  List<WaterEntry> _getAllEntries() {
    final allEntries = <WaterEntry>[];
    _waterHistory.forEach((_, data) {
      allEntries.addAll(data.entries);
    });
    allEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return allEntries;
  }

  /// Get entries for today (alias)
  List<WaterEntry> getTodayEntries() => _todayEntries;

  /// Add entry with beverage type string
  Future<void> addEntry(double amount, {String beverageType = 'water'}) async {
    final type = _stringToWaterType(beverageType);
    await addWater(amount, type: type);
  }

  WaterType _stringToWaterType(String type) {
    switch (type.toLowerCase()) {
      case 'water':
        return WaterType.water;
      case 'sparkling':
        return WaterType.sparkling;
      case 'tea':
        return WaterType.tea;
      case 'coffee':
        return WaterType.coffee;
      case 'juice':
        return WaterType.juice;
      case 'milk':
        return WaterType.milk;
      case 'sports_drink':
        return WaterType.other;
      case 'smoothie':
        return WaterType.other;
      default:
        return WaterType.water;
    }
  }

  /// Get weekly intake as list of doubles (Mon-Sun)
  List<double> getWeeklyIntake() {
    final weekData = getWeeklyData();
    return weekData.map((d) => d.totalIntake).toList();
  }

  /// Get insights as a map
  Map<String, dynamic> getInsights() {
    final stats = getStats();
    return {
      'averageDaily': stats.averageDaily,
      'bestDay': getWeeklyData()
          .map((d) => d.totalIntake)
          .reduce((a, b) => a > b ? a : b),
      'streak': stats.currentStreak,
      'goalsMet': stats.daysGoalMet,
    };
  }

  /// Get weekly water data
  List<DailyWaterData> getWeeklyData() {
    final List<DailyWaterData> weekData = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _getDateKey(date);

      if (_waterHistory.containsKey(key)) {
        weekData.add(_waterHistory[key]!);
      } else {
        weekData.add(
          DailyWaterData(
            date: date,
            totalIntake: 0,
            goal: _dailyGoalValue,
            entries: [],
          ),
        );
      }
    }

    return weekData;
  }

  /// Get water stats
  WaterStats getStats() {
    final weekData = getWeeklyData();
    final totalWeek = weekData.fold(0.0, (sum, d) => sum + d.totalIntake);
    final avgDaily = totalWeek / 7;
    final daysGoalMet = weekData.where((d) => d.totalIntake >= d.goal).length;

    // Find streak
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final key = _getDateKey(date);
      if (_waterHistory.containsKey(key) &&
          _waterHistory[key]!.totalIntake >= _waterHistory[key]!.goal) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    return WaterStats(
      todayIntake: _todayIntake,
      weeklyTotal: totalWeek,
      averageDaily: avgDaily,
      currentStreak: streak,
      daysGoalMet: daysGoalMet,
    );
  }

  /// Get text insights
  List<String> getTextInsights() {
    final insights = <String>[];
    final stats = getStats();

    if (stats.currentStreak >= 7) {
      insights.add('🎉 Amazing! ${stats.currentStreak} day hydration streak!');
    } else if (stats.currentStreak >= 3) {
      insights.add('💪 Great job! ${stats.currentStreak} days in a row!');
    }

    if (_todayIntake < _dailyGoalValue * 0.5 && DateTime.now().hour >= 14) {
      insights.add('⚠️ You\'re behind on hydration today. Drink up!');
    }

    if (stats.averageDaily < _dailyGoalValue * 0.8) {
      insights.add(
        '📈 Try to increase your daily water intake for better health.',
      );
    } else if (stats.averageDaily >= _dailyGoalValue) {
      insights.add('✅ You\'re consistently meeting your hydration goals!');
    }

    if (_todayEntries.isNotEmpty) {
      final lastEntry = _todayEntries.last;
      final timeSinceLast = DateTime.now().difference(lastEntry.timestamp);
      if (timeSinceLast.inHours >= 2) {
        insights.add(
          '⏰ It\'s been ${timeSinceLast.inHours}h since your last drink.',
        );
      }
    }

    return insights;
  }

  String _getTodayKey() => _getDateKey(DateTime.now());

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Single water entry
class WaterEntry {
  final String id;
  final double amount;
  final WaterType type;
  final DateTime timestamp;

  WaterEntry({
    required this.id,
    required this.amount,
    required this.type,
    required this.timestamp,
  });

  // Aliases for compatibility
  double get amountMl => amount;
  String get beverageType => type.displayName;

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'type': type.index,
    'timestamp': timestamp.toIso8601String(),
  };

  factory WaterEntry.fromJson(Map<String, dynamic> json) => WaterEntry(
    id: json['id'] as String,
    amount: (json['amount'] as num).toDouble(),
    type: WaterType.values[json['type'] as int? ?? 0],
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

/// Daily water data
class DailyWaterData {
  final DateTime date;
  final double totalIntake;
  final double goal;
  final List<WaterEntry> entries;

  DailyWaterData({
    required this.date,
    required this.totalIntake,
    required this.goal,
    required this.entries,
  });

  double get progress => (totalIntake / goal).clamp(0.0, 1.5);
  bool get goalMet => totalIntake >= goal;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'totalIntake': totalIntake,
    'goal': goal,
    'entries': entries.map((e) => e.toJson()).toList(),
  };

  factory DailyWaterData.fromJson(Map<String, dynamic> json) => DailyWaterData(
    date: DateTime.parse(json['date'] as String),
    totalIntake: (json['totalIntake'] as num).toDouble(),
    goal: (json['goal'] as num).toDouble(),
    entries:
        (json['entries'] as List?)
            ?.map((e) => WaterEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

/// Water statistics
class WaterStats {
  final double todayIntake;
  final double weeklyTotal;
  final double averageDaily;
  final int currentStreak;
  final int daysGoalMet;

  WaterStats({
    required this.todayIntake,
    required this.weeklyTotal,
    required this.averageDaily,
    required this.currentStreak,
    required this.daysGoalMet,
  });
}

/// Types of beverages
enum WaterType { water, sparkling, tea, coffee, juice, milk, other }

extension WaterTypeExtension on WaterType {
  String get displayName {
    switch (this) {
      case WaterType.water:
        return 'Water';
      case WaterType.sparkling:
        return 'Sparkling Water';
      case WaterType.tea:
        return 'Tea';
      case WaterType.coffee:
        return 'Coffee';
      case WaterType.juice:
        return 'Juice';
      case WaterType.milk:
        return 'Milk';
      case WaterType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case WaterType.water:
        return Icons.water_drop;
      case WaterType.sparkling:
        return Icons.bubble_chart;
      case WaterType.tea:
        return Icons.emoji_food_beverage;
      case WaterType.coffee:
        return Icons.coffee;
      case WaterType.juice:
        return Icons.local_drink;
      case WaterType.milk:
        return Icons.breakfast_dining;
      case WaterType.other:
        return Icons.local_bar;
    }
  }
}
