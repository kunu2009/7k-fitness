import 'dart:async';

/// Health data types that can be synced
enum HealthDataType {
  steps,
  heartRate,
  activeCalories,
  basalCalories,
  distance,
  flightsClimbed,
  weight,
  height,
  bodyFat,
  bmi,
  water,
  sleep,
  workout,
  bloodPressure,
  bloodGlucose,
  oxygenSaturation,
}

/// Health data point model
class HealthDataPoint {
  final HealthDataType type;
  final double value;
  final String unit;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String? sourceName;
  final String? sourceId;

  HealthDataPoint({
    required this.type,
    required this.value,
    required this.unit,
    required this.dateFrom,
    required this.dateTo,
    this.sourceName,
    this.sourceId,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'value': value,
    'unit': unit,
    'dateFrom': dateFrom.toIso8601String(),
    'dateTo': dateTo.toIso8601String(),
    'sourceName': sourceName,
    'sourceId': sourceId,
  };

  factory HealthDataPoint.fromJson(Map<String, dynamic> json) {
    return HealthDataPoint(
      type: HealthDataType.values.firstWhere((e) => e.name == json['type']),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'],
      dateFrom: DateTime.parse(json['dateFrom']),
      dateTo: DateTime.parse(json['dateTo']),
      sourceName: json['sourceName'],
      sourceId: json['sourceId'],
    );
  }
}

/// Workout data from health platforms
class HealthWorkout {
  final String id;
  final String workoutType;
  final DateTime startTime;
  final DateTime endTime;
  final double? totalCalories;
  final double? totalDistance;
  final double? averageHeartRate;
  final double? maxHeartRate;
  final String? sourceName;

  HealthWorkout({
    required this.id,
    required this.workoutType,
    required this.startTime,
    required this.endTime,
    this.totalCalories,
    this.totalDistance,
    this.averageHeartRate,
    this.maxHeartRate,
    this.sourceName,
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutType': workoutType,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'totalCalories': totalCalories,
    'totalDistance': totalDistance,
    'averageHeartRate': averageHeartRate,
    'maxHeartRate': maxHeartRate,
    'sourceName': sourceName,
  };
}

/// Health sync status
enum HealthSyncStatus { notConnected, connecting, connected, syncing, error }

/// Health platform type
enum HealthPlatform { appleHealth, googleFit, samsungHealth, fitbit, garmin }

/// Health Service - integrates with Apple Health and Google Fit
/// Note: This is a mock implementation. For production, use the 'health' package.
class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  HealthSyncStatus _status = HealthSyncStatus.notConnected;
  HealthPlatform? _connectedPlatform;
  DateTime? _lastSyncTime;
  final List<HealthDataType> _authorizedTypes = [];

  final StreamController<HealthSyncStatus> _statusController =
      StreamController<HealthSyncStatus>.broadcast();
  final StreamController<List<HealthDataPoint>> _dataController =
      StreamController<List<HealthDataPoint>>.broadcast();

  Stream<HealthSyncStatus> get statusStream => _statusController.stream;
  Stream<List<HealthDataPoint>> get dataStream => _dataController.stream;
  HealthSyncStatus get status => _status;
  HealthPlatform? get connectedPlatform => _connectedPlatform;
  DateTime? get lastSyncTime => _lastSyncTime;
  List<HealthDataType> get authorizedTypes =>
      List.unmodifiable(_authorizedTypes);

  /// Check if health data is available on this device
  Future<bool> isHealthDataAvailable() async {
    // In production, check platform support
    // iOS: HealthKit available
    // Android: Google Fit / Health Connect available
    return true;
  }

  /// Request authorization for health data types
  Future<bool> requestAuthorization(List<HealthDataType> types) async {
    _updateStatus(HealthSyncStatus.connecting);

    try {
      // Simulate authorization request
      await Future.delayed(const Duration(seconds: 1));

      // In production, use health package:
      // final health = HealthFactory();
      // final types = [HealthDataType.STEPS, ...];
      // final authorized = await health.requestAuthorization(types);

      _authorizedTypes.addAll(types);
      _connectedPlatform = HealthPlatform.googleFit; // or appleHealth on iOS
      _updateStatus(HealthSyncStatus.connected);

      return true;
    } catch (e) {
      _updateStatus(HealthSyncStatus.error);
      return false;
    }
  }

  /// Check if a specific data type is authorized
  bool isAuthorized(HealthDataType type) {
    return _authorizedTypes.contains(type);
  }

  /// Sync health data for a date range
  Future<List<HealthDataPoint>> syncHealthData({
    required DateTime startDate,
    required DateTime endDate,
    List<HealthDataType>? types,
  }) async {
    if (_status == HealthSyncStatus.notConnected) {
      throw Exception('Health service not connected');
    }

    _updateStatus(HealthSyncStatus.syncing);

    try {
      final typesToSync = types ?? _authorizedTypes;
      final List<HealthDataPoint> dataPoints = [];

      // Simulate fetching data for each type
      for (final type in typesToSync) {
        final points = await _fetchDataForType(type, startDate, endDate);
        dataPoints.addAll(points);
      }

      _lastSyncTime = DateTime.now();
      _dataController.add(dataPoints);
      _updateStatus(HealthSyncStatus.connected);

      return dataPoints;
    } catch (e) {
      _updateStatus(HealthSyncStatus.error);
      rethrow;
    }
  }

  /// Get today's step count
  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final data = await syncHealthData(
      startDate: startOfDay,
      endDate: now,
      types: [HealthDataType.steps],
    );

    if (data.isEmpty) return 0;

    return data
        .where((d) => d.type == HealthDataType.steps)
        .fold<int>(0, (sum, point) => sum + point.value.toInt());
  }

  /// Get today's active calories
  Future<double> getTodayActiveCalories() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final data = await syncHealthData(
      startDate: startOfDay,
      endDate: now,
      types: [HealthDataType.activeCalories],
    );

    if (data.isEmpty) return 0;

    return data
        .where((d) => d.type == HealthDataType.activeCalories)
        .fold<double>(0, (sum, point) => sum + point.value);
  }

  /// Get heart rate data
  Future<List<HealthDataPoint>> getHeartRateData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final data = await syncHealthData(
      startDate: startDate,
      endDate: endDate,
      types: [HealthDataType.heartRate],
    );

    return data.where((d) => d.type == HealthDataType.heartRate).toList();
  }

  /// Get sleep data
  Future<List<HealthDataPoint>> getSleepData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final data = await syncHealthData(
      startDate: startDate,
      endDate: endDate,
      types: [HealthDataType.sleep],
    );

    return data.where((d) => d.type == HealthDataType.sleep).toList();
  }

  /// Get workouts from health platform
  Future<List<HealthWorkout>> getWorkouts({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // In production, fetch actual workout data
    // Returning mock data for demonstration
    return [
      HealthWorkout(
        id: 'workout_1',
        workoutType: 'Running',
        startTime: startDate.add(const Duration(hours: 7)),
        endTime: startDate.add(const Duration(hours: 7, minutes: 45)),
        totalCalories: 420,
        totalDistance: 5200,
        averageHeartRate: 145,
        maxHeartRate: 172,
        sourceName: _connectedPlatform?.name ?? 'Health App',
      ),
    ];
  }

  /// Write data to health platform
  Future<bool> writeHealthData({
    required HealthDataType type,
    required double value,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    if (!_authorizedTypes.contains(type)) {
      throw Exception('Not authorized to write $type data');
    }

    try {
      // In production, write to health platform:
      // final health = HealthFactory();
      // await health.writeHealthData(value, type, dateFrom, dateTo);

      // Simulate write operation
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Write workout to health platform
  Future<bool> writeWorkout({
    required String workoutType,
    required DateTime startTime,
    required DateTime endTime,
    double? totalCalories,
    double? totalDistance,
  }) async {
    try {
      // In production, write workout to health platform
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Disconnect from health platform
  Future<void> disconnect() async {
    _authorizedTypes.clear();
    _connectedPlatform = null;
    _lastSyncTime = null;
    _updateStatus(HealthSyncStatus.notConnected);
  }

  void _updateStatus(HealthSyncStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  Future<List<HealthDataPoint>> _fetchDataForType(
    HealthDataType type,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // In production, fetch from health platform
    // This is mock data for demonstration

    final List<HealthDataPoint> points = [];
    final days = endDate.difference(startDate).inDays + 1;

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));

      switch (type) {
        case HealthDataType.steps:
          points.add(
            HealthDataPoint(
              type: type,
              value: 5000 + (i * 500.0), // Mock: varying step count
              unit: 'steps',
              dateFrom: date,
              dateTo: date.add(const Duration(days: 1)),
              sourceName: _connectedPlatform?.name,
            ),
          );
          break;
        case HealthDataType.heartRate:
          // Multiple readings per day
          for (int j = 0; j < 24; j += 4) {
            points.add(
              HealthDataPoint(
                type: type,
                value: 60 + (j * 2.0), // Mock heart rate
                unit: 'bpm',
                dateFrom: date.add(Duration(hours: j)),
                dateTo: date.add(Duration(hours: j, minutes: 1)),
                sourceName: _connectedPlatform?.name,
              ),
            );
          }
          break;
        case HealthDataType.activeCalories:
          points.add(
            HealthDataPoint(
              type: type,
              value: 200 + (i * 50.0),
              unit: 'kcal',
              dateFrom: date,
              dateTo: date.add(const Duration(days: 1)),
              sourceName: _connectedPlatform?.name,
            ),
          );
          break;
        case HealthDataType.sleep:
          points.add(
            HealthDataPoint(
              type: type,
              value: 7 + (i % 3 - 1), // 6-8 hours
              unit: 'hours',
              dateFrom: date,
              dateTo: date.add(Duration(hours: 7 + (i % 3))),
              sourceName: _connectedPlatform?.name,
            ),
          );
          break;
        case HealthDataType.weight:
          points.add(
            HealthDataPoint(
              type: type,
              value: 70 - (i * 0.1), // Slight weight loss trend
              unit: 'kg',
              dateFrom: date,
              dateTo: date,
              sourceName: _connectedPlatform?.name,
            ),
          );
          break;
        default:
          // Add generic data point
          points.add(
            HealthDataPoint(
              type: type,
              value: 0,
              unit: 'unknown',
              dateFrom: date,
              dateTo: date,
              sourceName: _connectedPlatform?.name,
            ),
          );
      }
    }

    return points;
  }

  void dispose() {
    _statusController.close();
    _dataController.close();
  }
}

/// Extension to get display name for health data types
extension HealthDataTypeExtension on HealthDataType {
  String get displayName {
    switch (this) {
      case HealthDataType.steps:
        return 'Steps';
      case HealthDataType.heartRate:
        return 'Heart Rate';
      case HealthDataType.activeCalories:
        return 'Active Calories';
      case HealthDataType.basalCalories:
        return 'Resting Calories';
      case HealthDataType.distance:
        return 'Distance';
      case HealthDataType.flightsClimbed:
        return 'Flights Climbed';
      case HealthDataType.weight:
        return 'Weight';
      case HealthDataType.height:
        return 'Height';
      case HealthDataType.bodyFat:
        return 'Body Fat';
      case HealthDataType.bmi:
        return 'BMI';
      case HealthDataType.water:
        return 'Water';
      case HealthDataType.sleep:
        return 'Sleep';
      case HealthDataType.workout:
        return 'Workouts';
      case HealthDataType.bloodPressure:
        return 'Blood Pressure';
      case HealthDataType.bloodGlucose:
        return 'Blood Glucose';
      case HealthDataType.oxygenSaturation:
        return 'Blood Oxygen';
    }
  }

  String get icon {
    switch (this) {
      case HealthDataType.steps:
        return '👟';
      case HealthDataType.heartRate:
        return '❤️';
      case HealthDataType.activeCalories:
        return '🔥';
      case HealthDataType.basalCalories:
        return '⚡';
      case HealthDataType.distance:
        return '📏';
      case HealthDataType.flightsClimbed:
        return '🪜';
      case HealthDataType.weight:
        return '⚖️';
      case HealthDataType.height:
        return '📐';
      case HealthDataType.bodyFat:
        return '💪';
      case HealthDataType.bmi:
        return '📊';
      case HealthDataType.water:
        return '💧';
      case HealthDataType.sleep:
        return '😴';
      case HealthDataType.workout:
        return '🏋️';
      case HealthDataType.bloodPressure:
        return '🩺';
      case HealthDataType.bloodGlucose:
        return '🩸';
      case HealthDataType.oxygenSaturation:
        return '🫁';
    }
  }
}
