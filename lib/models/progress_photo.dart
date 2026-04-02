/// Progress photo model for tracking visual transformation over time
library;

import 'dart:convert';

/// Body part/pose for progress photos
enum PhotoPose { front, back, sideLeft, sideRight, flexFront, flexBack, custom }

/// Photo category for organization
enum PhotoCategory {
  fullBody,
  upperBody,
  lowerBody,
  arms,
  abs,
  back,
  legs,
  other,
}

/// Extension to provide display names for poses
extension PhotoPoseExtension on PhotoPose {
  String get displayName {
    switch (this) {
      case PhotoPose.front:
        return 'Front';
      case PhotoPose.back:
        return 'Back';
      case PhotoPose.sideLeft:
        return 'Left Side';
      case PhotoPose.sideRight:
        return 'Right Side';
      case PhotoPose.flexFront:
        return 'Front Flex';
      case PhotoPose.flexBack:
        return 'Back Flex';
      case PhotoPose.custom:
        return 'Custom';
    }
  }

  String get icon {
    switch (this) {
      case PhotoPose.front:
        return '🧍';
      case PhotoPose.back:
        return '🧍';
      case PhotoPose.sideLeft:
        return '👈';
      case PhotoPose.sideRight:
        return '👉';
      case PhotoPose.flexFront:
        return '💪';
      case PhotoPose.flexBack:
        return '💪';
      case PhotoPose.custom:
        return '📷';
    }
  }
}

/// Extension to provide display names for categories
extension PhotoCategoryExtension on PhotoCategory {
  String get displayName {
    switch (this) {
      case PhotoCategory.fullBody:
        return 'Full Body';
      case PhotoCategory.upperBody:
        return 'Upper Body';
      case PhotoCategory.lowerBody:
        return 'Lower Body';
      case PhotoCategory.arms:
        return 'Arms';
      case PhotoCategory.abs:
        return 'Abs';
      case PhotoCategory.back:
        return 'Back';
      case PhotoCategory.legs:
        return 'Legs';
      case PhotoCategory.other:
        return 'Other';
    }
  }
}

/// A progress photo with metadata
class ProgressPhoto {
  final String id;
  final String imagePath;
  final DateTime takenAt;
  final PhotoPose pose;
  final PhotoCategory category;
  final String? notes;
  final double? weight; // Weight at time of photo
  final Map<String, double>? measurements; // Body measurements at time
  final List<String> tags;
  final bool isFavorite;

  ProgressPhoto({
    required this.id,
    required this.imagePath,
    required this.takenAt,
    this.pose = PhotoPose.front,
    this.category = PhotoCategory.fullBody,
    this.notes,
    this.weight,
    this.measurements,
    this.tags = const [],
    this.isFavorite = false,
  });

  /// Create a copy with updated fields
  ProgressPhoto copyWith({
    String? id,
    String? imagePath,
    DateTime? takenAt,
    PhotoPose? pose,
    PhotoCategory? category,
    String? notes,
    double? weight,
    Map<String, double>? measurements,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return ProgressPhoto(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      takenAt: takenAt ?? this.takenAt,
      pose: pose ?? this.pose,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      weight: weight ?? this.weight,
      measurements: measurements ?? this.measurements,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'takenAt': takenAt.toIso8601String(),
      'pose': pose.index,
      'category': category.index,
      'notes': notes,
      'weight': weight,
      'measurements': measurements,
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }

  /// Create from JSON
  factory ProgressPhoto.fromJson(Map<String, dynamic> json) {
    return ProgressPhoto(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      takenAt: DateTime.parse(json['takenAt'] as String),
      pose: PhotoPose.values[json['pose'] as int? ?? 0],
      category: PhotoCategory.values[json['category'] as int? ?? 0],
      notes: json['notes'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      measurements: json['measurements'] != null
          ? Map<String, double>.from(
              (json['measurements'] as Map).map(
                (key, value) =>
                    MapEntry(key as String, (value as num).toDouble()),
              ),
            )
          : null,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// Encode to JSON string
  String encode() => jsonEncode(toJson());

  /// Decode from JSON string
  static ProgressPhoto decode(String json) =>
      ProgressPhoto.fromJson(jsonDecode(json));

  /// Get formatted date
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[takenAt.month - 1]} ${takenAt.day}, ${takenAt.year}';
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(takenAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return 'Just now';
    }
  }
}

/// A comparison between two progress photos
class PhotoComparison {
  final ProgressPhoto before;
  final ProgressPhoto after;
  final Duration timeDifference;
  final double? weightChange;
  final Map<String, double>? measurementChanges;

  PhotoComparison({required this.before, required this.after})
    : timeDifference = after.takenAt.difference(before.takenAt),
      weightChange = (before.weight != null && after.weight != null)
          ? after.weight! - before.weight!
          : null,
      measurementChanges = _calculateMeasurementChanges(
        before.measurements,
        after.measurements,
      );

  static Map<String, double>? _calculateMeasurementChanges(
    Map<String, double>? before,
    Map<String, double>? after,
  ) {
    if (before == null || after == null) return null;

    final changes = <String, double>{};
    for (final key in after.keys) {
      if (before.containsKey(key)) {
        changes[key] = after[key]! - before[key]!;
      }
    }
    return changes.isEmpty ? null : changes;
  }

  /// Get formatted time difference
  String get formattedTimeDifference {
    if (timeDifference.inDays > 365) {
      final years = (timeDifference.inDays / 365).floor();
      final months = ((timeDifference.inDays % 365) / 30).floor();
      if (months > 0) {
        return '$years ${years == 1 ? 'year' : 'years'}, $months ${months == 1 ? 'month' : 'months'}';
      }
      return '$years ${years == 1 ? 'year' : 'years'}';
    } else if (timeDifference.inDays > 30) {
      final months = (timeDifference.inDays / 30).floor();
      final weeks = ((timeDifference.inDays % 30) / 7).floor();
      if (weeks > 0) {
        return '$months ${months == 1 ? 'month' : 'months'}, $weeks ${weeks == 1 ? 'week' : 'weeks'}';
      }
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else if (timeDifference.inDays > 7) {
      final weeks = (timeDifference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else {
      return '${timeDifference.inDays} ${timeDifference.inDays == 1 ? 'day' : 'days'}';
    }
  }

  /// Get weight change string
  String? get weightChangeString {
    if (weightChange == null) return null;
    final sign = weightChange! >= 0 ? '+' : '';
    return '$sign${weightChange!.toStringAsFixed(1)} kg';
  }
}

/// Group photos by time period
class PhotoTimelineGroup {
  final String label;
  final DateTime startDate;
  final DateTime endDate;
  final List<ProgressPhoto> photos;

  PhotoTimelineGroup({
    required this.label,
    required this.startDate,
    required this.endDate,
    required this.photos,
  });

  /// Get the count of photos in this group
  int get count => photos.length;

  /// Check if group is empty
  bool get isEmpty => photos.isEmpty;

  /// Check if group is not empty
  bool get isNotEmpty => photos.isNotEmpty;
}

/// Statistics about progress photos
class PhotoStats {
  final int totalPhotos;
  final int totalFavorites;
  final Map<PhotoPose, int> photosByPose;
  final Map<PhotoCategory, int> photosByCategory;
  final DateTime? firstPhotoDate;
  final DateTime? lastPhotoDate;
  final Duration? journeyDuration;

  PhotoStats({
    required this.totalPhotos,
    required this.totalFavorites,
    required this.photosByPose,
    required this.photosByCategory,
    this.firstPhotoDate,
    this.lastPhotoDate,
  }) : journeyDuration = (firstPhotoDate != null && lastPhotoDate != null)
           ? lastPhotoDate.difference(firstPhotoDate)
           : null;

  /// Create stats from a list of photos
  factory PhotoStats.fromPhotos(List<ProgressPhoto> photos) {
    if (photos.isEmpty) {
      return PhotoStats(
        totalPhotos: 0,
        totalFavorites: 0,
        photosByPose: {},
        photosByCategory: {},
      );
    }

    final sorted = List<ProgressPhoto>.from(photos)
      ..sort((a, b) => a.takenAt.compareTo(b.takenAt));

    final poseCount = <PhotoPose, int>{};
    final categoryCount = <PhotoCategory, int>{};
    int favorites = 0;

    for (final photo in photos) {
      poseCount[photo.pose] = (poseCount[photo.pose] ?? 0) + 1;
      categoryCount[photo.category] = (categoryCount[photo.category] ?? 0) + 1;
      if (photo.isFavorite) favorites++;
    }

    return PhotoStats(
      totalPhotos: photos.length,
      totalFavorites: favorites,
      photosByPose: poseCount,
      photosByCategory: categoryCount,
      firstPhotoDate: sorted.first.takenAt,
      lastPhotoDate: sorted.last.takenAt,
    );
  }

  /// Get journey duration as a formatted string
  String? get journeyDurationString {
    if (journeyDuration == null) return null;

    final days = journeyDuration!.inDays;
    if (days > 365) {
      final years = (days / 365).floor();
      final months = ((days % 365) / 30).floor();
      return '$years ${years == 1 ? 'year' : 'years'}${months > 0 ? ', $months ${months == 1 ? 'month' : 'months'}' : ''}';
    } else if (days > 30) {
      final months = (days / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'}';
    } else if (days > 7) {
      final weeks = (days / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else {
      return '$days ${days == 1 ? 'day' : 'days'}';
    }
  }
}
