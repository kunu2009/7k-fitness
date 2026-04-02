import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Export format options
enum ExportFormat { json, csv }

/// Export data types
enum ExportDataType {
  workouts,
  nutrition,
  measurements,
  goals,
  achievements,
  all,
}

/// Export result
class ExportResult {
  final bool success;
  final String? filePath;
  final String? data;
  final String? error;
  final DateTime exportedAt;
  final ExportFormat format;
  final List<ExportDataType> dataTypes;

  ExportResult({
    required this.success,
    this.filePath,
    this.data,
    this.error,
    required this.exportedAt,
    required this.format,
    required this.dataTypes,
  });
}

/// Backup metadata
class BackupMetadata {
  final String id;
  final DateTime createdAt;
  final int sizeBytes;
  final String appVersion;
  final List<String> includedData;

  BackupMetadata({
    required this.id,
    required this.createdAt,
    required this.sizeBytes,
    required this.appVersion,
    required this.includedData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'sizeBytes': sizeBytes,
    'appVersion': appVersion,
    'includedData': includedData,
  };

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      sizeBytes: json['sizeBytes'],
      appVersion: json['appVersion'],
      includedData: List<String>.from(json['includedData']),
    );
  }
}

/// Export/Backup Service - handles data export and backup
class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  static const String _appVersion = '1.0.0';

  /// Export user data
  Future<ExportResult> exportData({
    required List<ExportDataType> dataTypes,
    ExportFormat format = ExportFormat.json,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> exportData = {
        'exportedAt': DateTime.now().toIso8601String(),
        'appVersion': _appVersion,
        'dataTypes': dataTypes.map((t) => t.name).toList(),
      };

      // Collect data based on requested types
      if (dataTypes.contains(ExportDataType.all) ||
          dataTypes.contains(ExportDataType.workouts)) {
        exportData['workouts'] = _getWorkoutData(prefs);
      }

      if (dataTypes.contains(ExportDataType.all) ||
          dataTypes.contains(ExportDataType.nutrition)) {
        exportData['nutrition'] = _getNutritionData(prefs);
      }

      if (dataTypes.contains(ExportDataType.all) ||
          dataTypes.contains(ExportDataType.measurements)) {
        exportData['measurements'] = _getMeasurementData(prefs);
      }

      if (dataTypes.contains(ExportDataType.all) ||
          dataTypes.contains(ExportDataType.goals)) {
        exportData['goals'] = _getGoalData(prefs);
      }

      if (dataTypes.contains(ExportDataType.all) ||
          dataTypes.contains(ExportDataType.achievements)) {
        exportData['achievements'] = _getAchievementData(prefs);
      }

      // User profile data
      exportData['profile'] = _getProfileData(prefs);

      String outputData;
      if (format == ExportFormat.json) {
        outputData = const JsonEncoder.withIndent('  ').convert(exportData);
      } else {
        outputData = _convertToCSV(exportData);
      }

      return ExportResult(
        success: true,
        data: outputData,
        exportedAt: DateTime.now(),
        format: format,
        dataTypes: dataTypes,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        error: e.toString(),
        exportedAt: DateTime.now(),
        format: format,
        dataTypes: dataTypes,
      );
    }
  }

  /// Create a full backup
  Future<ExportResult> createBackup() async {
    return exportData(dataTypes: [ExportDataType.all]);
  }

  /// Restore from backup
  Future<bool> restoreFromBackup(String backupData) async {
    try {
      final data = jsonDecode(backupData) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();

      // Restore profile
      if (data.containsKey('profile')) {
        final profile = data['profile'] as Map<String, dynamic>;
        await prefs.setString('user_name', profile['name'] ?? '');
        await prefs.setInt('user_age', profile['age'] ?? 25);
        await prefs.setDouble('user_weight', profile['weight'] ?? 70.0);
        await prefs.setDouble('user_height', profile['height'] ?? 170.0);
        await prefs.setString('user_gender', profile['gender'] ?? 'male');
      }

      // Restore workouts
      if (data.containsKey('workouts')) {
        await prefs.setString('workout_history', jsonEncode(data['workouts']));
      }

      // Restore nutrition
      if (data.containsKey('nutrition')) {
        await prefs.setString('food_entries', jsonEncode(data['nutrition']));
      }

      // Restore measurements
      if (data.containsKey('measurements')) {
        await prefs.setString(
          'body_measurements',
          jsonEncode(data['measurements']),
        );
      }

      // Restore goals
      if (data.containsKey('goals')) {
        await prefs.setString('user_goals', jsonEncode(data['goals']));
      }

      // Restore achievements
      if (data.containsKey('achievements')) {
        await prefs.setString('achievements', jsonEncode(data['achievements']));
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete all user data
  Future<bool> deleteAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Keep only essential app settings
      final keysToKeep = ['dark_mode', 'onboarding_completed', 'app_language'];
      final allKeys = prefs.getKeys().toList();

      for (final key in allKeys) {
        if (!keysToKeep.contains(key)) {
          await prefs.remove(key);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get storage usage info
  Future<Map<String, int>> getStorageUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final usage = <String, int>{};

    for (final key in prefs.getKeys()) {
      final value = prefs.get(key);
      if (value != null) {
        usage[key] = value.toString().length;
      }
    }

    return usage;
  }

  /// Get total data size in bytes (approximate)
  Future<int> getTotalDataSize() async {
    final usage = await getStorageUsage();
    return usage.values.fold<int>(0, (int sum, int size) => sum + size);
  }

  // Helper methods to get data from SharedPreferences
  Map<String, dynamic> _getWorkoutData(SharedPreferences prefs) {
    final workoutsJson = prefs.getString('workout_history');
    if (workoutsJson != null) {
      return {'history': jsonDecode(workoutsJson)};
    }
    return {'history': []};
  }

  Map<String, dynamic> _getNutritionData(SharedPreferences prefs) {
    final nutritionJson = prefs.getString('food_entries');
    if (nutritionJson != null) {
      return {'entries': jsonDecode(nutritionJson)};
    }
    return {'entries': []};
  }

  Map<String, dynamic> _getMeasurementData(SharedPreferences prefs) {
    final measurementsJson = prefs.getString('body_measurements');
    if (measurementsJson != null) {
      return {'measurements': jsonDecode(measurementsJson)};
    }
    return {'measurements': []};
  }

  Map<String, dynamic> _getGoalData(SharedPreferences prefs) {
    final goalsJson = prefs.getString('user_goals');
    if (goalsJson != null) {
      return {'goals': jsonDecode(goalsJson)};
    }
    return {'goals': []};
  }

  Map<String, dynamic> _getAchievementData(SharedPreferences prefs) {
    final achievementsJson = prefs.getString('achievements');
    if (achievementsJson != null) {
      return {'unlocked': jsonDecode(achievementsJson)};
    }
    return {'unlocked': []};
  }

  Map<String, dynamic> _getProfileData(SharedPreferences prefs) {
    return {
      'name': prefs.getString('user_name') ?? '',
      'age': prefs.getInt('user_age') ?? 25,
      'weight': prefs.getDouble('user_weight') ?? 70.0,
      'height': prefs.getDouble('user_height') ?? 170.0,
      'gender': prefs.getString('user_gender') ?? 'male',
      'dailyCalorieGoal': prefs.getInt('daily_calorie_goal') ?? 2000,
      'dailyStepGoal': prefs.getInt('daily_step_goal') ?? 10000,
      'dailyWaterGoal': prefs.getDouble('daily_water_goal') ?? 2.0,
    };
  }

  String _convertToCSV(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    // Add header
    buffer.writeln('7K Fit Data Export');
    buffer.writeln('Exported: ${data['exportedAt']}');
    buffer.writeln('App Version: ${data['appVersion']}');
    buffer.writeln('');

    // Profile section
    if (data.containsKey('profile')) {
      buffer.writeln('=== Profile ===');
      final profile = data['profile'] as Map<String, dynamic>;
      profile.forEach((key, value) {
        buffer.writeln('$key,$value');
      });
      buffer.writeln('');
    }

    // Workouts section
    if (data.containsKey('workouts')) {
      buffer.writeln('=== Workouts ===');
      buffer.writeln('date,type,duration,calories,notes');
      final workouts = data['workouts']['history'] as List? ?? [];
      for (final workout in workouts) {
        if (workout is Map<String, dynamic>) {
          buffer.writeln(
            '${workout['date'] ?? ''},${workout['type'] ?? ''},${workout['duration'] ?? ''},${workout['calories'] ?? ''},${workout['notes'] ?? ''}',
          );
        }
      }
      buffer.writeln('');
    }

    // Nutrition section
    if (data.containsKey('nutrition')) {
      buffer.writeln('=== Nutrition ===');
      buffer.writeln('date,food,calories,protein,carbs,fat');
      final entries = data['nutrition']['entries'] as List? ?? [];
      for (final entry in entries) {
        if (entry is Map<String, dynamic>) {
          buffer.writeln(
            '${entry['date'] ?? ''},${entry['foodName'] ?? ''},${entry['calories'] ?? ''},${entry['protein'] ?? ''},${entry['carbs'] ?? ''},${entry['fat'] ?? ''}',
          );
        }
      }
      buffer.writeln('');
    }

    // Measurements section
    if (data.containsKey('measurements')) {
      buffer.writeln('=== Body Measurements ===');
      buffer.writeln('date,weight,bodyFat,chest,waist,hips');
      final measurements = data['measurements']['measurements'] as List? ?? [];
      for (final m in measurements) {
        if (m is Map<String, dynamic>) {
          buffer.writeln(
            '${m['date'] ?? ''},${m['weight'] ?? ''},${m['bodyFat'] ?? ''},${m['chest'] ?? ''},${m['waist'] ?? ''},${m['hips'] ?? ''}',
          );
        }
      }
      buffer.writeln('');
    }

    // Goals section
    if (data.containsKey('goals')) {
      buffer.writeln('=== Goals ===');
      buffer.writeln('name,target,current,deadline');
      final goals = data['goals']['goals'] as List? ?? [];
      for (final goal in goals) {
        if (goal is Map<String, dynamic>) {
          buffer.writeln(
            '${goal['name'] ?? ''},${goal['target'] ?? ''},${goal['current'] ?? ''},${goal['deadline'] ?? ''}',
          );
        }
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}

/// Share helper for exporting data
class ShareHelper {
  /// Generate a shareable workout summary
  static String generateWorkoutSummary({
    required String workoutName,
    required Duration duration,
    required int caloriesBurned,
    required int exerciseCount,
    String? personalRecord,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('💪 Workout Complete!');
    buffer.writeln('');
    buffer.writeln('🏋️ $workoutName');
    buffer.writeln('⏱️ ${_formatDuration(duration)}');
    buffer.writeln('🔥 $caloriesBurned kcal burned');
    buffer.writeln('💯 $exerciseCount exercises');
    if (personalRecord != null) {
      buffer.writeln('🏆 New PR: $personalRecord');
    }
    buffer.writeln('');
    buffer.writeln('#7KFit #Fitness #Workout');

    return buffer.toString();
  }

  /// Generate a shareable achievement
  static String generateAchievementShare({
    required String achievementName,
    required String description,
    int? xpEarned,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🏆 Achievement Unlocked!');
    buffer.writeln('');
    buffer.writeln(achievementName);
    buffer.writeln(description);
    if (xpEarned != null) {
      buffer.writeln('+$xpEarned XP');
    }
    buffer.writeln('');
    buffer.writeln('#7KFit #Achievement #Fitness');

    return buffer.toString();
  }

  /// Generate a shareable progress update
  static String generateProgressShare({
    required int daysStreak,
    required int totalWorkouts,
    required double weightChange,
    String? topAchievement,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('📊 My 7K Fit Progress');
    buffer.writeln('');
    buffer.writeln('🔥 $daysStreak day streak');
    buffer.writeln('💪 $totalWorkouts total workouts');
    if (weightChange != 0) {
      final sign = weightChange > 0 ? '+' : '';
      buffer.writeln('⚖️ $sign${weightChange.toStringAsFixed(1)} kg');
    }
    if (topAchievement != null) {
      buffer.writeln('🏆 $topAchievement');
    }
    buffer.writeln('');
    buffer.writeln('#7KFit #FitnessJourney #Progress');

    return buffer.toString();
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
