import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';

class ProgressPhotosScreen extends StatefulWidget {
  const ProgressPhotosScreen({super.key});

  @override
  State<ProgressPhotosScreen> createState() => _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState extends State<ProgressPhotosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ProgressPhoto> _photos = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  bool _isCompareMode = false;
  ProgressPhoto? _comparePhoto1;
  ProgressPhoto? _comparePhoto2;

  final List<String> _categories = [
    'All',
    'Front',
    'Back',
    'Side',
    'Flex',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPhotos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final photosJson = prefs.getStringList('progress_photos') ?? [];
      _photos = photosJson
          .map((json) => ProgressPhoto.fromJson(jsonDecode(json)))
          .toList();
      _photos.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('Error loading photos: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _savePhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photosJson = _photos.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList('progress_photos', photosJson);
    } catch (e) {
      debugPrint('Error saving photos: $e');
    }
  }

  List<ProgressPhoto> get _filteredPhotos {
    if (_selectedCategory == 'All') return _photos;
    return _photos.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildCategoryFilter(),
                if (_isCompareMode) _buildCompareSection(),
              ],
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredPhotos.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColors.primary,
                      tabs: const [
                        Tab(text: 'Gallery'),
                        Tab(text: 'Timeline'),
                        Tab(text: 'Stats'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildGalleryView(),
                          _buildTimelineView(),
                          _buildStatsView(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPhoto,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Add Photo'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Progress Photos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isCompareMode ? Icons.compare : Icons.compare_outlined),
          tooltip: 'Compare Photos',
          onPressed: () {
            setState(() {
              _isCompareMode = !_isCompareMode;
              if (!_isCompareMode) {
                _comparePhoto1 = null;
                _comparePhoto2 = null;
              }
            });
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'export':
                _exportPhotos();
                break;
              case 'settings':
                _showPhotoSettings();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20),
                  SizedBox(width: 12),
                  Text('Export Collection'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 12),
                  Text('Photo Settings'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          final count = category == 'All'
              ? _photos.length
              : _photos.where((p) => p.category == category).length;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('$category ($count)'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompareSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Compare Mode',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isCompareMode = false;
                    _comparePhoto1 = null;
                    _comparePhoto2 = null;
                  });
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCompareSlot(
                  photo: _comparePhoto1,
                  label: 'Before',
                  onTap: () => _selectComparePhoto(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompareSlot(
                  photo: _comparePhoto2,
                  label: 'After',
                  onTap: () => _selectComparePhoto(2),
                ),
              ),
            ],
          ),
          if (_comparePhoto1 != null && _comparePhoto2 != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showFullComparison,
                icon: const Icon(Icons.fullscreen),
                label: const Text('View Full Comparison'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompareSlot({
    ProgressPhoto? photo,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: photo != null ? Colors.blue : Colors.grey[300]!,
            width: photo != null ? 2 : 1,
          ),
        ),
        child: photo != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildPhotoThumbnail(photo),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat('MMM d').format(photo.date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    color: Colors.grey[400],
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select $label',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Progress Photos Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start documenting your fitness journey by taking regular progress photos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addPhoto,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Take Your First Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredPhotos.length,
      itemBuilder: (context, index) {
        final photo = _filteredPhotos[index];
        return _buildPhotoCard(photo);
      },
    );
  }

  Widget _buildPhotoCard(ProgressPhoto photo) {
    final isSelected =
        _isCompareMode && (photo == _comparePhoto1 || photo == _comparePhoto2);

    return GestureDetector(
      onTap: () {
        if (_isCompareMode) {
          _handleCompareSelection(photo);
        } else {
          _showPhotoDetail(photo);
        }
      },
      onLongPress: () => _showPhotoOptions(photo),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.blue, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildPhotoThumbnail(photo),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('MMM d, y').format(photo.date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (photo.weight != null)
                      Text(
                        '${photo.weight?.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    photo.category,
                  ).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  photo.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineView() {
    if (_filteredPhotos.isEmpty) {
      return const Center(child: Text('No photos to display'));
    }

    // Group photos by month
    final groupedPhotos = <String, List<ProgressPhoto>>{};
    for (final photo in _filteredPhotos) {
      final monthKey = DateFormat('MMMM yyyy').format(photo.date);
      groupedPhotos.putIfAbsent(monthKey, () => []).add(photo);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedPhotos.length,
      itemBuilder: (context, index) {
        final month = groupedPhotos.keys.elementAt(index);
        final photos = groupedPhotos[month]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    month,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${photos.length} photos',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                itemBuilder: (context, photoIndex) {
                  final photo = photos[photoIndex];
                  return GestureDetector(
                    onTap: () => _showPhotoDetail(photo),
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 8),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildPhotoThumbnail(photo),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d MMM').format(photo.date),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildStatsView() {
    if (_photos.isEmpty) {
      return const Center(child: Text('Add photos to see statistics'));
    }

    final photosByCategory = <String, int>{};
    for (final photo in _photos) {
      photosByCategory[photo.category] =
          (photosByCategory[photo.category] ?? 0) + 1;
    }

    final photosWithWeight = _photos.where((p) => p.weight != null).toList();
    photosWithWeight.sort((a, b) => a.date.compareTo(b.date));

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStatCard(
            icon: Icons.photo_library,
            title: 'Total Photos',
            value: '${_photos.length}',
            subtitle:
                'Since ${DateFormat('MMM d, yyyy').format(_photos.last.date)}',
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            icon: Icons.calendar_today,
            title: 'Tracking Duration',
            value: _getTrackingDuration(),
            subtitle: 'Keep it up!',
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          if (photosWithWeight.length >= 2) ...[
            _buildWeightChangeCard(photosWithWeight),
            const SizedBox(height: 12),
          ],
          _buildCategoryBreakdown(photosByCategory),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChangeCard(List<ProgressPhoto> photosWithWeight) {
    final first = photosWithWeight.first;
    final last = photosWithWeight.last;
    final change = last.weight! - first.weight!;
    final isGain = change > 0;
    final color = isGain ? Colors.orange : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGain ? Icons.trending_up : Icons.trending_down,
                color: color,
              ),
              const SizedBox(width: 8),
              const Text(
                'Weight Progress',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeightPoint(
                'Starting',
                '${first.weight?.toStringAsFixed(1)} kg',
                DateFormat('MMM d').format(first.date),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey[400]),
              _buildWeightPoint(
                'Current',
                '${last.weight?.toStringAsFixed(1)} kg',
                DateFormat('MMM d').format(last.date),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${isGain ? '+' : ''}${change.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightPoint(String label, String value, String date) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
      ],
    );
  }

  Widget _buildCategoryBreakdown(Map<String, int> photosByCategory) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Photos by Category',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...photosByCategory.entries.map((entry) {
            final percentage = (entry.value / _photos.length * 100).toInt();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(entry.key),
                  const Spacer(),
                  Text(
                    '${entry.value} ($percentage%)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail(ProgressPhoto photo) {
    // Check if it's a file path or placeholder
    if (photo.imagePath.startsWith('/') ||
        photo.imagePath.startsWith('file://')) {
      final file = File(photo.imagePath.replaceFirst('file://', ''));
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    // Placeholder for demo
    return Container(
      color: _getCategoryColor(photo.category).withValues(alpha: 0.3),
      child: Center(
        child: Icon(
          Icons.person,
          size: 40,
          color: _getCategoryColor(photo.category),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Front':
        return Colors.blue;
      case 'Back':
        return Colors.green;
      case 'Side':
        return Colors.orange;
      case 'Flex':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getTrackingDuration() {
    if (_photos.length < 2) return '0 days';
    final first = _photos.last.date;
    final last = _photos.first.date;
    final difference = last.difference(first);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      final months = ((difference.inDays % 365) / 30).floor();
      return '$years year${years > 1 ? 's' : ''} ${months}mo';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      return '${difference.inDays} days';
    }
  }

  void _handleCompareSelection(ProgressPhoto photo) {
    setState(() {
      if (_comparePhoto1 == photo) {
        _comparePhoto1 = null;
      } else if (_comparePhoto2 == photo) {
        _comparePhoto2 = null;
      } else if (_comparePhoto1 == null) {
        _comparePhoto1 = photo;
      } else if (_comparePhoto2 == null) {
        _comparePhoto2 = photo;
      } else {
        _comparePhoto1 = photo;
        _comparePhoto2 = null;
      }
    });
  }

  void _selectComparePhoto(int slot) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select ${slot == 1 ? 'Before' : 'After'} Photo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  final photo = _photos[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (slot == 1) {
                          _comparePhoto1 = photo;
                        } else {
                          _comparePhoto2 = photo;
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildPhotoThumbnail(photo),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullComparison() {
    if (_comparePhoto1 == null || _comparePhoto2 == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoComparisonScreen(
          photo1: _comparePhoto1!,
          photo2: _comparePhoto2!,
        ),
      ),
    );
  }

  void _addPhoto() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddPhotoSheet(
        categories: _categories.where((c) => c != 'All').toList(),
        onPhotoAdded: (photo) {
          setState(() {
            _photos.insert(0, photo);
          });
          _savePhotos();
        },
      ),
    );
  }

  void _showPhotoDetail(ProgressPhoto photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoDetailScreen(
          photo: photo,
          onDelete: () {
            setState(() {
              _photos.remove(photo);
            });
            _savePhotos();
            Navigator.pop(context);
          },
          onUpdate: (updatedPhoto) {
            final index = _photos.indexOf(photo);
            if (index != -1) {
              setState(() {
                _photos[index] = updatedPhoto;
              });
              _savePhotos();
            }
          },
        ),
      ),
    );
  }

  void _showPhotoOptions(ProgressPhoto photo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Details'),
              onTap: () {
                Navigator.pop(context);
                _showPhotoDetail(photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _sharePhoto(photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(photo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(ProgressPhoto photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _photos.remove(photo);
              });
              _savePhotos();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _sharePhoto(ProgressPhoto photo) {
    final message = StringBuffer()
      ..writeln('Progress Photo')
      ..writeln('Category: ${photo.category}')
      ..writeln('Date: ${DateFormat('MMM d, yyyy').format(photo.date)}')
      ..writeln(
        'Weight: ${photo.weight != null ? '${photo.weight!.toStringAsFixed(1)} kg' : 'N/A'}',
      );
    if (photo.notes != null && photo.notes!.isNotEmpty) {
      message.writeln('Notes: ${photo.notes}');
    }

    Clipboard.setData(ClipboardData(text: message.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo details copied to clipboard.')),
    );
  }

  void _exportPhotos() {
    final exportPayload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'count': _photos.length,
      'photos': _photos.map((p) => p.toJson()).toList(),
    };

    Clipboard.setData(ClipboardData(text: jsonEncode(exportPayload)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${_photos.length} photos to clipboard (JSON).'),
      ),
    );
  }

  void _showPhotoSettings() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Photo Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable Compare Mode by Default'),
                value: _isCompareMode,
                onChanged: (value) {
                  setDialogState(() {});
                  setState(() {
                    _isCompareMode = value;
                    if (!value) {
                      _comparePhoto1 = null;
                      _comparePhoto2 = null;
                    }
                  });
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.clear_all),
                title: const Text('Clear Compare Selection'),
                onTap: () {
                  setState(() {
                    _comparePhoto1 = null;
                    _comparePhoto2 = null;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Model
class ProgressPhoto {
  final String id;
  final String imagePath;
  final DateTime date;
  final String category;
  final double? weight;
  final String? notes;
  final Map<String, double>? measurements;

  ProgressPhoto({
    required this.id,
    required this.imagePath,
    required this.date,
    required this.category,
    this.weight,
    this.notes,
    this.measurements,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'date': date.toIso8601String(),
    'category': category,
    'weight': weight,
    'notes': notes,
    'measurements': measurements,
  };

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) => ProgressPhoto(
    id: json['id'],
    imagePath: json['imagePath'],
    date: DateTime.parse(json['date']),
    category: json['category'],
    weight: json['weight']?.toDouble(),
    notes: json['notes'],
    measurements: json['measurements'] != null
        ? Map<String, double>.from(json['measurements'])
        : null,
  );
}

// Add Photo Sheet
class AddPhotoSheet extends StatefulWidget {
  final List<String> categories;
  final Function(ProgressPhoto) onPhotoAdded;

  const AddPhotoSheet({
    super.key,
    required this.categories,
    required this.onPhotoAdded,
  });

  @override
  State<AddPhotoSheet> createState() => _AddPhotoSheetState();
}

class _AddPhotoSheetState extends State<AddPhotoSheet> {
  String _selectedCategory = 'Front';
  DateTime _selectedDate = DateTime.now();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Progress Photo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Photo Source Selection
            Row(
              children: [
                Expanded(
                  child: _buildSourceButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => _selectPhotoSource('camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSourceButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => _selectPhotoSource('gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category Selection
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = category);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Date Selection
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(DateFormat('MMMM d, yyyy').format(_selectedDate)),
              onTap: _selectDate,
            ),

            // Weight Input
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Current Weight (kg)',
                prefixIcon: Icon(Icons.monitor_weight),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Photo'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _selectPhotoSource(String source) {
    // In a real app, this would use image_picker
    // For now, we'll create a placeholder entry
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${source == 'camera' ? 'Camera' : 'Gallery'} would open here',
        ),
      ),
    );
  }

  void _savePhoto() {
    final photo = ProgressPhoto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: 'placeholder_${_selectedCategory.toLowerCase()}',
      date: _selectedDate,
      category: _selectedCategory,
      weight: double.tryParse(_weightController.text),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    widget.onPhotoAdded(photo);
    Navigator.pop(context);
  }
}

// Photo Detail Screen
class PhotoDetailScreen extends StatelessWidget {
  final ProgressPhoto photo;
  final VoidCallback onDelete;
  final Function(ProgressPhoto) onUpdate;

  const PhotoDetailScreen({
    super.key,
    required this.photo,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editPhoto(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: _buildPhotoView())),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM d, yyyy').format(photo.date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          photo.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (photo.weight != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.monitor_weight,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${photo.weight?.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (photo.notes != null && photo.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      photo.notes!,
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoView() {
    if (photo.imagePath.startsWith('/') ||
        photo.imagePath.startsWith('file://')) {
      final file = File(photo.imagePath.replaceFirst('file://', ''));
      if (file.existsSync()) {
        return InteractiveViewer(child: Image.file(file, fit: BoxFit.contain));
      }
    }

    // Placeholder
    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.person, size: 80, color: Colors.white54),
      ),
    );
  }

  void _editPhoto(BuildContext context) {
    final weightController = TextEditingController(
      text: photo.weight?.toStringAsFixed(1) ?? '',
    );
    final notesController = TextEditingController(text: photo.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Photo Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                hintText: 'e.g. 72.5',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Add notes about this photo',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final updated = ProgressPhoto(
                    id: photo.id,
                    imagePath: photo.imagePath,
                    date: photo.date,
                    category: photo.category,
                    weight: double.tryParse(weightController.text.trim()),
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                    measurements: photo.measurements,
                  );
                  onUpdate(updated);
                  Navigator.pop(sheetContext);
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      weightController.dispose();
      notesController.dispose();
    });
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Photo Comparison Screen
class PhotoComparisonScreen extends StatefulWidget {
  final ProgressPhoto photo1;
  final ProgressPhoto photo2;

  const PhotoComparisonScreen({
    super.key,
    required this.photo1,
    required this.photo2,
  });

  @override
  State<PhotoComparisonScreen> createState() => _PhotoComparisonScreenState();
}

class _PhotoComparisonScreenState extends State<PhotoComparisonScreen> {
  double _sliderValue = 0.5;
  bool _isSliderMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Compare'),
        actions: [
          IconButton(
            icon: Icon(_isSliderMode ? Icons.view_column : Icons.compare),
            onPressed: () => setState(() => _isSliderMode = !_isSliderMode),
            tooltip: _isSliderMode ? 'Side by Side' : 'Slider Mode',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isSliderMode ? _buildSliderView() : _buildSideBySideView(),
          ),
          _buildInfoBar(),
        ],
      ),
    );
  }

  Widget _buildSliderView() {
    return Stack(
      children: [
        // After photo (full width)
        Positioned.fill(child: _buildPhoto(widget.photo2)),
        // Before photo (clipped)
        Positioned.fill(
          child: ClipRect(
            clipper: _PhotoClipper(_sliderValue),
            child: _buildPhoto(widget.photo1),
          ),
        ),
        // Slider line
        Positioned(
          left: MediaQuery.of(context).size.width * _sliderValue - 2,
          top: 0,
          bottom: 0,
          child: Container(width: 4, color: Colors.white),
        ),
        // Slider handle
        Positioned(
          left: MediaQuery.of(context).size.width * _sliderValue - 20,
          top: MediaQuery.of(context).size.height * 0.3,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _sliderValue +=
                    details.delta.dx / MediaQuery.of(context).size.width;
                _sliderValue = _sliderValue.clamp(0.1, 0.9);
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.compare_arrows, color: Colors.black),
            ),
          ),
        ),
        // Labels
        Positioned(
          left: 16,
          top: 16,
          child: _buildLabel('BEFORE', widget.photo1.date),
        ),
        Positioned(
          right: 16,
          top: 16,
          child: _buildLabel('AFTER', widget.photo2.date),
        ),
      ],
    );
  }

  Widget _buildSideBySideView() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildLabel('BEFORE', widget.photo1.date),
              Expanded(child: _buildPhoto(widget.photo1)),
            ],
          ),
        ),
        Container(width: 2, color: Colors.white),
        Expanded(
          child: Column(
            children: [
              _buildLabel('AFTER', widget.photo2.date),
              Expanded(child: _buildPhoto(widget.photo2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoto(ProgressPhoto photo) {
    if (photo.imagePath.startsWith('/') ||
        photo.imagePath.startsWith('file://')) {
      final file = File(photo.imagePath.replaceFirst('file://', ''));
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.person, size: 60, color: Colors.white54),
      ),
    );
  }

  Widget _buildLabel(String label, DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            DateFormat('MMM d, y').format(date),
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar() {
    final daysDiff = widget.photo2.date.difference(widget.photo1.date).inDays;
    double? weightDiff;
    if (widget.photo1.weight != null && widget.photo2.weight != null) {
      weightDiff = widget.photo2.weight! - widget.photo1.weight!;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(
              'Time Difference',
              '$daysDiff days',
              Icons.calendar_today,
            ),
            if (weightDiff != null)
              _buildInfoItem(
                'Weight Change',
                '${weightDiff >= 0 ? '+' : ''}${weightDiff.toStringAsFixed(1)} kg',
                weightDiff >= 0 ? Icons.trending_up : Icons.trending_down,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }
}

// Custom clipper for slider effect
class _PhotoClipper extends CustomClipper<Rect> {
  final double percentage;

  _PhotoClipper(this.percentage);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * percentage, size.height);
  }

  @override
  bool shouldReclip(_PhotoClipper oldClipper) {
    return oldClipper.percentage != percentage;
  }
}
