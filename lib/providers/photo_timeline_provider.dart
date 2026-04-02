import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/progress_photo.dart';

/// Provider for managing progress photos
class PhotoTimelineProvider extends ChangeNotifier {
  List<ProgressPhoto> _photos = [];
  bool _isLoading = false;
  String? _error;
  PhotoPose? _filterPose;
  PhotoCategory? _filterCategory;
  bool _showFavoritesOnly = false;

  // Keys for persistence
  static const String _photosKey = 'progress_photos';

  // Getters
  List<ProgressPhoto> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PhotoPose? get filterPose => _filterPose;
  PhotoCategory? get filterCategory => _filterCategory;
  bool get showFavoritesOnly => _showFavoritesOnly;

  /// Get filtered photos based on current filters
  List<ProgressPhoto> get filteredPhotos {
    var result = List<ProgressPhoto>.from(_photos);

    if (_filterPose != null) {
      result = result.where((p) => p.pose == _filterPose).toList();
    }

    if (_filterCategory != null) {
      result = result.where((p) => p.category == _filterCategory).toList();
    }

    if (_showFavoritesOnly) {
      result = result.where((p) => p.isFavorite).toList();
    }

    // Sort by date, newest first
    result.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return result;
  }

  /// Get photos sorted by date (oldest first)
  List<ProgressPhoto> get photosByDateAscending {
    final sorted = List<ProgressPhoto>.from(_photos);
    sorted.sort((a, b) => a.takenAt.compareTo(b.takenAt));
    return sorted;
  }

  /// Get favorite photos
  List<ProgressPhoto> get favoritePhotos {
    return _photos.where((p) => p.isFavorite).toList();
  }

  /// Get photo statistics
  PhotoStats get stats => PhotoStats.fromPhotos(_photos);

  /// Get photos grouped by month
  List<PhotoTimelineGroup> get photosByMonth {
    if (_photos.isEmpty) return [];

    final groups = <String, List<ProgressPhoto>>{};
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    for (final photo in filteredPhotos) {
      final key = '${months[photo.takenAt.month - 1]} ${photo.takenAt.year}';
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(photo);
    }

    return groups.entries.map((entry) {
      final photos = entry.value;
      photos.sort((a, b) => b.takenAt.compareTo(a.takenAt));

      final firstPhoto = photos.reduce(
        (a, b) => a.takenAt.isBefore(b.takenAt) ? a : b,
      );
      final lastPhoto = photos.reduce(
        (a, b) => a.takenAt.isAfter(b.takenAt) ? a : b,
      );

      return PhotoTimelineGroup(
        label: entry.key,
        startDate: firstPhoto.takenAt,
        endDate: lastPhoto.takenAt,
        photos: photos,
      );
    }).toList()..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  /// Initialize provider and load photos
  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadPhotos();
    } catch (e) {
      _error = 'Failed to load photos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load photos from storage
  Future<void> _loadPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final photosJson = prefs.getStringList(_photosKey);

    if (photosJson != null) {
      _photos = photosJson
          .map((json) => ProgressPhoto.fromJson(jsonDecode(json)))
          .toList();
    }
  }

  /// Save photos to storage
  Future<void> _savePhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final photosJson = _photos.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_photosKey, photosJson);
  }

  /// Add a new progress photo
  Future<ProgressPhoto> addPhoto({
    required String imagePath,
    DateTime? takenAt,
    PhotoPose pose = PhotoPose.front,
    PhotoCategory category = PhotoCategory.fullBody,
    String? notes,
    double? weight,
    Map<String, double>? measurements,
    List<String> tags = const [],
  }) async {
    final photo = ProgressPhoto(
      id: const Uuid().v4(),
      imagePath: imagePath,
      takenAt: takenAt ?? DateTime.now(),
      pose: pose,
      category: category,
      notes: notes,
      weight: weight,
      measurements: measurements,
      tags: tags,
    );

    _photos.add(photo);
    await _savePhotos();
    notifyListeners();

    return photo;
  }

  /// Update an existing photo
  Future<void> updatePhoto(ProgressPhoto updatedPhoto) async {
    final index = _photos.indexWhere((p) => p.id == updatedPhoto.id);
    if (index != -1) {
      _photos[index] = updatedPhoto;
      await _savePhotos();
      notifyListeners();
    }
  }

  /// Delete a photo
  Future<void> deletePhoto(String photoId) async {
    final photo = _photos.firstWhere(
      (p) => p.id == photoId,
      orElse: () => throw Exception('Photo not found'),
    );

    // Delete the image file if it exists
    try {
      final file = File(photo.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Failed to delete image file: $e');
    }

    _photos.removeWhere((p) => p.id == photoId);
    await _savePhotos();
    notifyListeners();
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String photoId) async {
    final index = _photos.indexWhere((p) => p.id == photoId);
    if (index != -1) {
      _photos[index] = _photos[index].copyWith(
        isFavorite: !_photos[index].isFavorite,
      );
      await _savePhotos();
      notifyListeners();
    }
  }

  /// Set filter by pose
  void setFilterPose(PhotoPose? pose) {
    _filterPose = pose;
    notifyListeners();
  }

  /// Set filter by category
  void setFilterCategory(PhotoCategory? category) {
    _filterCategory = category;
    notifyListeners();
  }

  /// Toggle favorites only filter
  void toggleShowFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _filterPose = null;
    _filterCategory = null;
    _showFavoritesOnly = false;
    notifyListeners();
  }

  /// Get photos for comparison (same pose)
  List<ProgressPhoto> getPhotosForComparison(PhotoPose pose) {
    final result = _photos.where((p) => p.pose == pose).toList();
    result.sort((a, b) => a.takenAt.compareTo(b.takenAt));
    return result;
  }

  /// Create a comparison between two photos
  PhotoComparison? createComparison(String beforeId, String afterId) {
    try {
      final before = _photos.firstWhere((p) => p.id == beforeId);
      final after = _photos.firstWhere((p) => p.id == afterId);
      return PhotoComparison(before: before, after: after);
    } catch (e) {
      return null;
    }
  }

  /// Get the directory for storing photos
  Future<Directory> getPhotoDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/progress_photos');

    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }

    return photoDir;
  }

  /// Save an image to the app's photo directory
  Future<String> saveImage(File imageFile) async {
    final photoDir = await getPhotoDirectory();
    final fileName = '${const Uuid().v4()}.jpg';
    final savedPath = '${photoDir.path}/$fileName';

    await imageFile.copy(savedPath);
    return savedPath;
  }

  /// Get first and last photos for quick comparison
  PhotoComparison? get firstLastComparison {
    if (_photos.length < 2) return null;

    final sorted = photosByDateAscending;
    return PhotoComparison(before: sorted.first, after: sorted.last);
  }

  /// Get photos taken in the last N days
  List<ProgressPhoto> getRecentPhotos(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _photos.where((p) => p.takenAt.isAfter(cutoff)).toList()
      ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
  }

  /// Search photos by notes or tags
  List<ProgressPhoto> searchPhotos(String query) {
    final lowerQuery = query.toLowerCase();
    return _photos.where((p) {
      final notesMatch = p.notes?.toLowerCase().contains(lowerQuery) ?? false;
      final tagsMatch = p.tags.any((t) => t.toLowerCase().contains(lowerQuery));
      return notesMatch || tagsMatch;
    }).toList();
  }

  /// Get monthly progress (photos from each month)
  Map<String, ProgressPhoto?> getMonthlyProgress(int months) {
    final result = <String, ProgressPhoto?>{};
    final now = DateTime.now();

    for (var i = 0; i < months; i++) {
      final targetMonth = DateTime(now.year, now.month - i, 1);
      final monthKey =
          '${targetMonth.year}-${targetMonth.month.toString().padLeft(2, '0')}';

      // Find a photo from this month (prefer front pose)
      final monthPhotos = _photos.where((p) {
        return p.takenAt.year == targetMonth.year &&
            p.takenAt.month == targetMonth.month;
      }).toList();

      if (monthPhotos.isNotEmpty) {
        // Prefer front pose photos
        final frontPhoto = monthPhotos.where((p) => p.pose == PhotoPose.front);
        result[monthKey] = frontPhoto.isNotEmpty
            ? frontPhoto.first
            : monthPhotos.first;
      } else {
        result[monthKey] = null;
      }
    }

    return result;
  }
}
