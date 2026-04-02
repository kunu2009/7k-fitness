import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/progress_photo.dart';
import '../../theme/app_theme.dart';

/// Screen for comparing two progress photos side by side
class PhotoComparisonScreen extends StatefulWidget {
  final PhotoComparison comparison;

  const PhotoComparisonScreen({super.key, required this.comparison});

  @override
  State<PhotoComparisonScreen> createState() => _PhotoComparisonScreenState();
}

class _PhotoComparisonScreenState extends State<PhotoComparisonScreen> {
  bool _isSliderMode = false;
  double _sliderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Compare Progress',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isSliderMode ? Icons.view_column : Icons.compare,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => _isSliderMode = !_isSliderMode);
            },
            tooltip: _isSliderMode ? 'Side by side view' : 'Slider view',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Photos section
            Expanded(
              child: _isSliderMode
                  ? _buildSliderComparison()
                  : _buildSideBySideComparison(),
            ),

            // Info section
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSideBySideComparison() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: _buildPhotoCard(
              widget.comparison.before,
              'Before',
              widget.comparison.before.formattedDate,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPhotoCard(
              widget.comparison.after,
              'After',
              widget.comparison.after.formattedDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(ProgressPhoto photo, String label, String date) {
    return Column(
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: label == 'Before'
                ? Colors.orange.withValues(alpha: 0.2)
                : Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: label == 'Before' ? Colors.orange : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Photo
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildPhotoImage(photo),
          ),
        ),
        const SizedBox(height: 8),

        // Date
        Text(date, style: const TextStyle(color: Colors.white70, fontSize: 12)),

        // Weight if available
        if (photo.weight != null)
          Text(
            '${photo.weight!.toStringAsFixed(1)} kg',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildSliderComparison() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // After photo (full)
            Positioned.fill(child: _buildPhotoImage(widget.comparison.after)),

            // Before photo (clipped)
            Positioned.fill(
              child: ClipRect(
                clipper: _SliderClipper(_sliderValue),
                child: _buildPhotoImage(widget.comparison.before),
              ),
            ),

            // Divider line
            Positioned(
              left: constraints.maxWidth * _sliderValue - 2,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: Colors.white),
            ),

            // Slider handle
            Positioned(
              left: constraints.maxWidth * _sliderValue - 20,
              top: constraints.maxHeight / 2 - 20,
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
                child: const Icon(
                  Icons.compare_arrows,
                  color: AppColors.primary,
                ),
              ),
            ),

            // Labels
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Before',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'After',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Gesture detector
            Positioned.fill(
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _sliderValue += details.delta.dx / constraints.maxWidth;
                    _sliderValue = _sliderValue.clamp(0.0, 1.0);
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoSection() {
    final comparison = widget.comparison;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time difference
          Row(
            children: [
              const Icon(Icons.timeline, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                comparison.formattedTimeDifference,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (comparison.weightChange != null) ...[
            const SizedBox(height: 12),
            _buildChangeCard(
              icon: Icons.monitor_weight,
              label: 'Weight Change',
              value: comparison.weightChangeString!,
              isPositive: comparison.weightChange! < 0,
            ),
          ],

          if (comparison.measurementChanges != null &&
              comparison.measurementChanges!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Measurement Changes',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: comparison.measurementChanges!.entries.map((entry) {
                final change = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: change < 0
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${entry.key}: ${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} cm',
                    style: TextStyle(
                      color: change < 0 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChangeCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isPositive ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                value,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoImage(ProgressPhoto photo) {
    final file = File(photo.imagePath);

    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.surface,
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.white54,
                size: 48,
              ),
            ),
          );
        },
      );
    }

    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white54, size: 48),
      ),
    );
  }
}

/// Custom clipper for slider comparison view
class _SliderClipper extends CustomClipper<Rect> {
  final double sliderValue;

  _SliderClipper(this.sliderValue);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * sliderValue, size.height);
  }

  @override
  bool shouldReclip(_SliderClipper oldClipper) {
    return sliderValue != oldClipper.sliderValue;
  }
}
