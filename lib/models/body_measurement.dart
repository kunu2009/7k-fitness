library;

/// Body measurement model for tracking physical measurements over time

class BodyMeasurement {
  final String id;
  final DateTime date;
  final double? weight; // kg
  final double? bodyFat; // percentage
  final double? bodyFatPercentage; // alias for bodyFat
  final double? muscleMass; // kg
  final double? bmi; // body mass index
  final double? chest; // cm
  final double? waist; // cm
  final double? hips; // cm
  final double? hip; // alias for hips
  final double? bicepLeft; // cm
  final double? bicepRight; // cm
  final double? thighLeft; // cm
  final double? thighRight; // cm
  final double? calfLeft; // cm
  final double? calfRight; // cm
  final double? neck; // cm
  final double? shoulders; // cm
  final double? forearmLeft; // cm
  final double? forearmRight; // cm
  final String? notes;
  final String? photoPath;

  const BodyMeasurement({
    required this.id,
    required this.date,
    this.weight,
    this.bodyFat,
    this.bodyFatPercentage,
    this.muscleMass,
    this.bmi,
    this.chest,
    this.waist,
    this.hips,
    this.hip,
    this.bicepLeft,
    this.bicepRight,
    this.thighLeft,
    this.thighRight,
    this.calfLeft,
    this.calfRight,
    this.neck,
    this.shoulders,
    this.forearmLeft,
    this.forearmRight,
    this.notes,
    this.photoPath,
  });

  /// Calculate waist-to-hip ratio
  double? get waistToHipRatio {
    if (waist == null || hips == null || hips == 0) return null;
    return waist! / hips!;
  }

  /// Evaluate waist-to-hip ratio health
  String? get waistToHipRatioCategory {
    final ratio = waistToHipRatio;
    if (ratio == null) return null;

    // These are general guidelines - varies by gender
    if (ratio < 0.80) return 'Low Risk';
    if (ratio < 0.85) return 'Moderate Risk';
    if (ratio < 0.90) return 'High Risk';
    return 'Very High Risk';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'weight': weight,
    'bodyFat': bodyFat,
    'bodyFatPercentage': bodyFatPercentage,
    'muscleMass': muscleMass,
    'bmi': bmi,
    'chest': chest,
    'waist': waist,
    'hips': hips,
    'hip': hip,
    'bicepLeft': bicepLeft,
    'bicepRight': bicepRight,
    'thighLeft': thighLeft,
    'thighRight': thighRight,
    'calfLeft': calfLeft,
    'calfRight': calfRight,
    'neck': neck,
    'shoulders': shoulders,
    'forearmLeft': forearmLeft,
    'forearmRight': forearmRight,
    'notes': notes,
    'photoPath': photoPath,
  };

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) =>
      BodyMeasurement(
        id: json['id'],
        date: DateTime.parse(json['date']),
        weight: json['weight']?.toDouble(),
        bodyFat: json['bodyFat']?.toDouble(),
        bodyFatPercentage: json['bodyFatPercentage']?.toDouble(),
        muscleMass: json['muscleMass']?.toDouble(),
        bmi: json['bmi']?.toDouble(),
        chest: json['chest']?.toDouble(),
        waist: json['waist']?.toDouble(),
        hips: json['hips']?.toDouble(),
        hip: json['hip']?.toDouble(),
        bicepLeft: json['bicepLeft']?.toDouble(),
        bicepRight: json['bicepRight']?.toDouble(),
        thighLeft: json['thighLeft']?.toDouble(),
        thighRight: json['thighRight']?.toDouble(),
        calfLeft: json['calfLeft']?.toDouble(),
        calfRight: json['calfRight']?.toDouble(),
        neck: json['neck']?.toDouble(),
        shoulders: json['shoulders']?.toDouble(),
        forearmLeft: json['forearmLeft']?.toDouble(),
        forearmRight: json['forearmRight']?.toDouble(),
        notes: json['notes'],
        photoPath: json['photoPath'],
      );

  BodyMeasurement copyWith({
    String? id,
    DateTime? date,
    double? weight,
    double? bodyFat,
    double? bodyFatPercentage,
    double? muscleMass,
    double? bmi,
    double? chest,
    double? waist,
    double? hips,
    double? hip,
    double? bicepLeft,
    double? bicepRight,
    double? thighLeft,
    double? thighRight,
    double? calfLeft,
    double? calfRight,
    double? neck,
    double? shoulders,
    double? forearmLeft,
    double? forearmRight,
    String? notes,
    String? photoPath,
  }) {
    return BodyMeasurement(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      bodyFat: bodyFat ?? this.bodyFat,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      muscleMass: muscleMass ?? this.muscleMass,
      bmi: bmi ?? this.bmi,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      hip: hip ?? this.hip,
      bicepLeft: bicepLeft ?? this.bicepLeft,
      bicepRight: bicepRight ?? this.bicepRight,
      thighLeft: thighLeft ?? this.thighLeft,
      thighRight: thighRight ?? this.thighRight,
      calfLeft: calfLeft ?? this.calfLeft,
      calfRight: calfRight ?? this.calfRight,
      neck: neck ?? this.neck,
      shoulders: shoulders ?? this.shoulders,
      forearmLeft: forearmLeft ?? this.forearmLeft,
      forearmRight: forearmRight ?? this.forearmRight,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

/// Measurement type enum for UI
enum MeasurementType {
  weight,
  bodyFat,
  chest,
  waist,
  hips,
  biceps,
  thighs,
  calves,
  neck,
  shoulders,
  forearms,
}

extension MeasurementTypeExtension on MeasurementType {
  String get displayName {
    switch (this) {
      case MeasurementType.weight:
        return 'Weight';
      case MeasurementType.bodyFat:
        return 'Body Fat';
      case MeasurementType.chest:
        return 'Chest';
      case MeasurementType.waist:
        return 'Waist';
      case MeasurementType.hips:
        return 'Hips';
      case MeasurementType.biceps:
        return 'Biceps';
      case MeasurementType.thighs:
        return 'Thighs';
      case MeasurementType.calves:
        return 'Calves';
      case MeasurementType.neck:
        return 'Neck';
      case MeasurementType.shoulders:
        return 'Shoulders';
      case MeasurementType.forearms:
        return 'Forearms';
    }
  }

  String get unit {
    switch (this) {
      case MeasurementType.weight:
        return 'kg';
      case MeasurementType.bodyFat:
        return '%';
      default:
        return 'cm';
    }
  }

  String get icon {
    switch (this) {
      case MeasurementType.weight:
        return '⚖️';
      case MeasurementType.bodyFat:
        return '📊';
      case MeasurementType.chest:
        return '👕';
      case MeasurementType.waist:
        return '📏';
      case MeasurementType.hips:
        return '🩳';
      case MeasurementType.biceps:
        return '💪';
      case MeasurementType.thighs:
        return '🦵';
      case MeasurementType.calves:
        return '🦶';
      case MeasurementType.neck:
        return '👔';
      case MeasurementType.shoulders:
        return '🎽';
      case MeasurementType.forearms:
        return '🤲';
    }
  }
}

/// Progress photo for tracking visual changes
class ProgressPhoto {
  final String id;
  final DateTime date;
  final String imagePath;
  final PhotoAngle angle;
  final String? notes;
  final double? weight;

  const ProgressPhoto({
    required this.id,
    required this.date,
    required this.imagePath,
    required this.angle,
    this.notes,
    this.weight,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'imagePath': imagePath,
    'angle': angle.name,
    'notes': notes,
    'weight': weight,
  };

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) => ProgressPhoto(
    id: json['id'],
    date: DateTime.parse(json['date']),
    imagePath: json['imagePath'],
    angle: PhotoAngle.values.firstWhere(
      (e) => e.name == json['angle'],
      orElse: () => PhotoAngle.front,
    ),
    notes: json['notes'],
    weight: json['weight']?.toDouble(),
  );
}

enum PhotoAngle { front, side, back }

extension PhotoAngleExtension on PhotoAngle {
  String get displayName {
    switch (this) {
      case PhotoAngle.front:
        return 'Front';
      case PhotoAngle.side:
        return 'Side';
      case PhotoAngle.back:
        return 'Back';
    }
  }
}
