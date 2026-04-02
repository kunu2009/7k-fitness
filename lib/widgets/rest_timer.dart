import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';

/// Configurable rest timer widget
class RestTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;
  final Color? color;

  const RestTimer({
    super.key,
    required this.seconds,
    required this.onComplete,
    this.onSkip,
    this.color,
  });

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> with TickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = true;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.seconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && _isRunning) {
        setState(() {
          _remainingSeconds--;
        });
      } else if (_remainingSeconds == 0) {
        timer.cancel();
        widget.onComplete();
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _addTime(int seconds) {
    setState(() {
      _remainingSeconds += seconds;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeString {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    return _remainingSeconds / widget.seconds;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Rest Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 8,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                children: [
                  Text(
                    _timeString,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (!_isRunning)
                    const Text(
                      'PAUSED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Add 15 seconds
              IconButton(
                onPressed: () => _addTime(15),
                icon: const Icon(Icons.add),
                tooltip: '+15s',
                style: IconButton.styleFrom(backgroundColor: AppColors.divider),
              ),
              // Pause/Resume
              IconButton(
                onPressed: _togglePause,
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                tooltip: _isRunning ? 'Pause' : 'Resume',
                style: IconButton.styleFrom(
                  backgroundColor: color.withValues(alpha: 0.1),
                  foregroundColor: color,
                ),
              ),
              // Skip
              if (widget.onSkip != null)
                IconButton(
                  onPressed: () {
                    _timer?.cancel();
                    widget.onSkip!();
                  },
                  icon: const Icon(Icons.skip_next),
                  tooltip: 'Skip',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.divider,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Rest timer dialog
Future<void> showRestTimerDialog(
  BuildContext context, {
  int seconds = 60,
  VoidCallback? onComplete,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: RestTimer(
        seconds: seconds,
        onComplete: () {
          Navigator.of(context).pop();
          onComplete?.call();
        },
        onSkip: () {
          Navigator.of(context).pop();
        },
      ),
    ),
  );
}

/// Quick rest timer selection
class RestTimerSelector extends StatelessWidget {
  final int selectedSeconds;
  final ValueChanged<int> onChanged;

  const RestTimerSelector({
    super.key,
    required this.selectedSeconds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [30, 45, 60, 90, 120, 180];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((seconds) {
        final isSelected = seconds == selectedSeconds;
        return GestureDetector(
          onTap: () => onChanged(seconds),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Text(
              seconds < 60
                  ? '${seconds}s'
                  : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

