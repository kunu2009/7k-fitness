import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated Circular Timer Widget
class AnimatedCircularTimer extends StatefulWidget {
  final Duration duration;
  final Duration elapsed;
  final bool isRunning;
  final VoidCallback? onComplete;
  final Color? progressColor;
  final Color? backgroundColor;
  final double size;
  final double strokeWidth;
  final Widget? child;

  const AnimatedCircularTimer({
    super.key,
    required this.duration,
    this.elapsed = Duration.zero,
    this.isRunning = false,
    this.onComplete,
    this.progressColor,
    this.backgroundColor,
    this.size = 200,
    this.strokeWidth = 12,
    this.child,
  });

  @override
  State<AnimatedCircularTimer> createState() => _AnimatedCircularTimerState();
}

class _AnimatedCircularTimerState extends State<AnimatedCircularTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    if (widget.isRunning) {
      _controller.forward(
        from: widget.elapsed.inMilliseconds / widget.duration.inMilliseconds,
      );
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedCircularTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _controller.forward();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CircularTimerPainter(
            progress: _animation.value,
            progressColor: widget.progressColor ?? AppColors.primary,
            backgroundColor: widget.backgroundColor ?? AppColors.divider,
            strokeWidth: widget.strokeWidth,
          ),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Center(child: widget.child),
          ),
        );
      },
    );
  }
}

class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularTimerPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularTimerPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        progressColor != oldDelegate.progressColor ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

/// Countdown Timer Widget
class CountdownTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback? onComplete;
  final bool autoStart;
  final Color? color;
  final double fontSize;

  const CountdownTimer({
    super.key,
    required this.seconds,
    this.onComplete,
    this.autoStart = true,
    this.color,
    this.fontSize = 48,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.seconds;
    if (widget.autoStart) {
      start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          stop();
          widget.onComplete?.call();
        }
      });
    });
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
  }

  void reset() {
    stop();
    setState(() {
      _remainingSeconds = widget.seconds;
    });
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formattedTime,
      style: TextStyle(
        fontSize: widget.fontSize,
        fontWeight: FontWeight.bold,
        color: widget.color ?? AppColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// Stopwatch Widget
class StopwatchWidget extends StatefulWidget {
  final bool autoStart;
  final Color? color;
  final double fontSize;
  final ValueChanged<Duration>? onTick;

  const StopwatchWidget({
    super.key,
    this.autoStart = false,
    this.color,
    this.fontSize = 48,
    this.onTick,
  });

  @override
  State<StopwatchWidget> createState() => StopwatchWidgetState();
}

class StopwatchWidgetState extends State<StopwatchWidget> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) {
      start();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void start() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {});
      widget.onTick?.call(_stopwatch.elapsed);
    });
  }

  void stop() {
    _stopwatch.stop();
    _timer?.cancel();
  }

  void reset() {
    stop();
    _stopwatch.reset();
    setState(() {});
  }

  Duration get elapsed => _stopwatch.elapsed;
  bool get isRunning => _stopwatch.isRunning;

  String get _formattedTime {
    final duration = _stopwatch.elapsed;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    final centiseconds = (duration.inMilliseconds % 1000) ~/ 10;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${centiseconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formattedTime,
      style: TextStyle(
        fontSize: widget.fontSize,
        fontWeight: FontWeight.bold,
        color: widget.color ?? AppColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// Interval Timer for HIIT workouts
class IntervalTimer extends StatefulWidget {
  final int workSeconds;
  final int restSeconds;
  final int rounds;
  final VoidCallback? onComplete;
  final VoidCallback? onWorkStart;
  final VoidCallback? onRestStart;

  const IntervalTimer({
    super.key,
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
    this.onComplete,
    this.onWorkStart,
    this.onRestStart,
  });

  @override
  State<IntervalTimer> createState() => _IntervalTimerState();
}

class _IntervalTimerState extends State<IntervalTimer> {
  int _currentRound = 1;
  int _remainingSeconds = 0;
  bool _isWork = true;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.workSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;

    if (_isWork) {
      widget.onWorkStart?.call();
    } else {
      widget.onRestStart?.call();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _switchPhase();
        }
      });
    });
  }

  void _switchPhase() {
    if (_isWork) {
      // Switch to rest
      _isWork = false;
      _remainingSeconds = widget.restSeconds;
      widget.onRestStart?.call();
    } else {
      // Switch to work or complete
      if (_currentRound >= widget.rounds) {
        stop();
        widget.onComplete?.call();
        return;
      }
      _currentRound++;
      _isWork = true;
      _remainingSeconds = widget.workSeconds;
      widget.onWorkStart?.call();
    }
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
  }

  void reset() {
    stop();
    setState(() {
      _currentRound = 1;
      _isWork = true;
      _remainingSeconds = widget.workSeconds;
    });
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Phase indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: _isWork ? AppColors.primary : AppColors.success,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _isWork ? 'WORK' : 'REST',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Timer display
        Text(
          _formattedTime,
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: _isWork ? AppColors.primary : AppColors.success,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 16),

        // Round indicator
        Text(
          'Round $_currentRound of ${widget.rounds}',
          style: const TextStyle(fontSize: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: reset,
              icon: const Icon(Icons.refresh, size: 32),
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: _isRunning ? stop : start,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _isWork ? AppColors.primary : AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isWork ? AppColors.primary : AppColors.success)
                          .withAlpha(100),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _isRunning ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(width: 24),
            IconButton(
              onPressed: () {
                // Skip to next phase
                _remainingSeconds = 0;
              },
              icon: const Icon(Icons.skip_next, size: 32),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ],
    );
  }
}

/// Tabata Timer (20s work, 10s rest, 8 rounds)
class TabataTimer extends StatelessWidget {
  final VoidCallback? onComplete;

  const TabataTimer({super.key, this.onComplete});

  @override
  Widget build(BuildContext context) {
    return IntervalTimer(
      workSeconds: 20,
      restSeconds: 10,
      rounds: 8,
      onComplete: onComplete,
    );
  }
}
