import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class WorkoutTimerScreen extends StatefulWidget {
  const WorkoutTimerScreen({super.key});

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen>
    with TickerProviderStateMixin {
  // Timer States
  TimerMode _currentMode = TimerMode.stopwatch;
  TimerState _timerState = TimerState.stopped;

  // Stopwatch
  int _stopwatchMilliseconds = 0;
  final List<int> _lapTimes = [];

  // Countdown Timer
  int _countdownSeconds = 60;
  int _countdownRemaining = 60;

  // Interval Timer (HIIT/Tabata)
  int _workSeconds = 30;
  int _restSeconds = 10;
  int _rounds = 8;
  int _currentRound = 1;
  bool _isWorkPhase = true;
  int _intervalRemaining = 0;

  // Timers
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _intervalRemaining = _workSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Workout Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mode Selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<TimerMode>(
                segments: const [
                  ButtonSegment(
                    value: TimerMode.stopwatch,
                    label: Text('Stopwatch'),
                    icon: Icon(Icons.timer),
                  ),
                  ButtonSegment(
                    value: TimerMode.countdown,
                    label: Text('Timer'),
                    icon: Icon(Icons.hourglass_empty),
                  ),
                  ButtonSegment(
                    value: TimerMode.interval,
                    label: Text('Interval'),
                    icon: Icon(Icons.repeat),
                  ),
                ],
                selected: {_currentMode},
                onSelectionChanged: _timerState == TimerState.stopped
                    ? (value) {
                        setState(() {
                          _currentMode = value.first;
                          _resetTimer();
                        });
                      }
                    : null,
              ),
            ),

            // Timer Display
            Expanded(child: _buildTimerDisplay()),

            // Controls
            Padding(padding: const EdgeInsets.all(24), child: _buildControls()),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (_timerState == TimerState.stopped) {
      return Theme.of(context).scaffoldBackgroundColor;
    }

    if (_currentMode == TimerMode.interval) {
      return _isWorkPhase
          ? Colors.green.withAlpha(30)
          : Colors.red.withAlpha(30);
    }

    return Theme.of(context).scaffoldBackgroundColor;
  }

  Widget _buildTimerDisplay() {
    switch (_currentMode) {
      case TimerMode.stopwatch:
        return _buildStopwatchDisplay();
      case TimerMode.countdown:
        return _buildCountdownDisplay();
      case TimerMode.interval:
        return _buildIntervalDisplay();
    }
  }

  Widget _buildStopwatchDisplay() {
    final hours = (_stopwatchMilliseconds ~/ 3600000).toString().padLeft(
      2,
      '0',
    );
    final minutes = ((_stopwatchMilliseconds ~/ 60000) % 60).toString().padLeft(
      2,
      '0',
    );
    final seconds = ((_stopwatchMilliseconds ~/ 1000) % 60).toString().padLeft(
      2,
      '0',
    );
    final milliseconds = ((_stopwatchMilliseconds % 1000) ~/ 10)
        .toString()
        .padLeft(2, '0');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, size: 48, color: AppColors.primary),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$hours:$minutes:$seconds',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w200,
                  fontFamily: 'monospace',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '.$milliseconds',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w200,
                    fontFamily: 'monospace',
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _timerState == TimerState.running ? 'Running' : 'Ready',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          if (_lapTimes.isNotEmpty)
            SizedBox(
              height: 180,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _lapTimes.length,
                separatorBuilder: (_, __) => const Divider(height: 8),
                itemBuilder: (context, index) {
                  final lapIndex = _lapTimes.length - index;
                  final lapMs = _lapTimes[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lap $lapIndex',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      Text(
                        _formatStopwatchTime(lapMs),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCountdownDisplay() {
    final progress = _countdownRemaining / _countdownSeconds;
    final minutes = (_countdownRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_countdownRemaining % 60).toString().padLeft(2, '0');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.withAlpha(50),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _countdownRemaining <= 10
                          ? Colors.red
                          : AppColors.primary,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$minutes:$seconds',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w200,
                        fontFamily: 'monospace',
                        color: _countdownRemaining <= 10 ? Colors.red : null,
                      ),
                    ),
                    if (_timerState == TimerState.stopped)
                      TextButton(
                        onPressed: _showTimePickerDialog,
                        child: const Text('Set Time'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalDisplay() {
    final currentSeconds = _isWorkPhase ? _workSeconds : _restSeconds;
    final progress = _intervalRemaining / currentSeconds;
    final minutes = (_intervalRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_intervalRemaining % 60).toString().padLeft(2, '0');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Phase Indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: _isWorkPhase ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isWorkPhase ? 'WORK' : 'REST',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Timer Circle
          ScaleTransition(
            scale: _pulseAnimation,
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.withAlpha(50),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isWorkPhase ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$minutes:$seconds',
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w200,
                          fontFamily: 'monospace',
                          color: _isWorkPhase ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Round Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Round ', style: TextStyle(fontSize: 18)),
              Text(
                '$_currentRound',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                ' / $_rounds',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Interval Settings Display
          if (_timerState == TimerState.stopped)
            TextButton(
              onPressed: _showIntervalSettingsDialog,
              child: Text(
                'Work ${_workSeconds}s • Rest ${_restSeconds}s • $_rounds rounds',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset Button
        if (_timerState != TimerState.stopped || _getTimerValue() > 0)
          Container(
            margin: const EdgeInsets.only(right: 24),
            child: FloatingActionButton(
              heroTag: 'reset',
              onPressed: _resetTimer,
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.grey[800],
              child: const Icon(Icons.refresh),
            ),
          ),

        // Start/Pause Button
        FloatingActionButton.large(
          heroTag: 'playPause',
          onPressed: _toggleTimer,
          backgroundColor: _timerState == TimerState.running
              ? Colors.orange
              : AppColors.primary,
          child: Icon(
            _timerState == TimerState.running ? Icons.pause : Icons.play_arrow,
            size: 48,
          ),
        ),

        // Lap Button (for stopwatch only)
        if (_currentMode == TimerMode.stopwatch &&
            _timerState == TimerState.running)
          Container(
            margin: const EdgeInsets.only(left: 24),
            child: FloatingActionButton(
              heroTag: 'lap',
              onPressed: _recordLap,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.flag),
            ),
          ),
      ],
    );
  }

  int _getTimerValue() {
    switch (_currentMode) {
      case TimerMode.stopwatch:
        return _stopwatchMilliseconds;
      case TimerMode.countdown:
        return _countdownSeconds - _countdownRemaining;
      case TimerMode.interval:
        return (_currentRound - 1) * (_workSeconds + _restSeconds);
    }
  }

  void _toggleTimer() {
    if (_timerState == TimerState.running) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() {
      _timerState = TimerState.running;
    });

    if (_currentMode == TimerMode.interval &&
        _timerState == TimerState.stopped) {
      _pulseController.repeat(reverse: true);
    }

    switch (_currentMode) {
      case TimerMode.stopwatch:
        _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
          setState(() {
            _stopwatchMilliseconds += 10;
          });
        });
        break;
      case TimerMode.countdown:
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (_countdownRemaining > 0) {
              _countdownRemaining--;
              if (_countdownRemaining <= 3 && _countdownRemaining > 0) {
                HapticFeedback.lightImpact();
              }
              if (_countdownRemaining == 0) {
                _onTimerComplete();
              }
            }
          });
        });
        break;
      case TimerMode.interval:
        _pulseController.repeat(reverse: true);
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (_intervalRemaining > 0) {
              _intervalRemaining--;
              if (_intervalRemaining <= 3 && _intervalRemaining > 0) {
                HapticFeedback.mediumImpact();
              }
              if (_intervalRemaining == 0) {
                _onIntervalComplete();
              }
            }
          });
        });
        break;
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _timerState = TimerState.paused;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _timerState = TimerState.stopped;
      _stopwatchMilliseconds = 0;
      _lapTimes.clear();
      _countdownRemaining = _countdownSeconds;
      _currentRound = 1;
      _isWorkPhase = true;
      _intervalRemaining = _workSeconds;
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      _timerState = TimerState.stopped;
    });
    _showCompletionDialog('Timer Complete!');
  }

  void _onIntervalComplete() {
    HapticFeedback.heavyImpact();

    if (_isWorkPhase) {
      // Switch to rest
      setState(() {
        _isWorkPhase = false;
        _intervalRemaining = _restSeconds;
      });
    } else {
      // Check if all rounds complete
      if (_currentRound >= _rounds) {
        _timer?.cancel();
        _pulseController.stop();
        setState(() {
          _timerState = TimerState.stopped;
        });
        _showCompletionDialog('Workout Complete!\n$_rounds rounds finished');
      } else {
        // Next round
        setState(() {
          _currentRound++;
          _isWorkPhase = true;
          _intervalRemaining = _workSeconds;
        });
      }
    }
  }

  void _recordLap() {
    setState(() {
      _lapTimes.insert(0, _stopwatchMilliseconds);
    });
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Lap ${_lapTimes.length}: ${_formatStopwatchTime(_stopwatchMilliseconds)}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatStopwatchTime(int milliseconds) {
    final minutes = (milliseconds ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((milliseconds ~/ 1000) % 60).toString().padLeft(2, '0');
    final ms = ((milliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$ms';
  }

  void _showCompletionDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Done!'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTimePickerDialog() {
    int minutes = _countdownSeconds ~/ 60;
    int seconds = _countdownSeconds % 60;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Set Timer'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minutes
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: () => setDialogState(() {
                      if (minutes < 59) minutes++;
                    }),
                  ),
                  Text(
                    minutes.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: () => setDialogState(() {
                      if (minutes > 0) minutes--;
                    }),
                  ),
                  const Text('min'),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(':', style: TextStyle(fontSize: 48)),
              ),
              // Seconds
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up),
                    onPressed: () => setDialogState(() {
                      if (seconds < 59) seconds += 5;
                      if (seconds > 59) seconds = 59;
                    }),
                  ),
                  Text(
                    seconds.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: () => setDialogState(() {
                      if (seconds > 0) seconds -= 5;
                      if (seconds < 0) seconds = 0;
                    }),
                  ),
                  const Text('sec'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _countdownSeconds = minutes * 60 + seconds;
                  _countdownRemaining = _countdownSeconds;
                });
                Navigator.pop(context);
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );
  }

  void _showIntervalSettingsDialog() {
    int workSec = _workSeconds;
    int restSec = _restSeconds;
    int numRounds = _rounds;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Interval Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Work Time
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.green,
                    ),
                  ),
                  title: const Text('Work Time'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setDialogState(() {
                          if (workSec > 5) workSec -= 5;
                        }),
                      ),
                      Text(
                        '${workSec}s',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setDialogState(() {
                          if (workSec < 300) workSec += 5;
                        }),
                      ),
                    ],
                  ),
                ),
                // Rest Time
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.pause_circle_outline,
                      color: Colors.red,
                    ),
                  ),
                  title: const Text('Rest Time'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setDialogState(() {
                          if (restSec > 5) restSec -= 5;
                        }),
                      ),
                      Text(
                        '${restSec}s',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setDialogState(() {
                          if (restSec < 120) restSec += 5;
                        }),
                      ),
                    ],
                  ),
                ),
                // Rounds
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.repeat, color: AppColors.primary),
                  ),
                  title: const Text('Rounds'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setDialogState(() {
                          if (numRounds > 1) numRounds--;
                        }),
                      ),
                      Text(
                        '$numRounds',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setDialogState(() {
                          if (numRounds < 50) numRounds++;
                        }),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Presets
                const Text(
                  'Quick Presets',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Tabata'),
                      onPressed: () => setDialogState(() {
                        workSec = 20;
                        restSec = 10;
                        numRounds = 8;
                      }),
                    ),
                    ActionChip(
                      label: const Text('HIIT 30/30'),
                      onPressed: () => setDialogState(() {
                        workSec = 30;
                        restSec = 30;
                        numRounds = 10;
                      }),
                    ),
                    ActionChip(
                      label: const Text('EMOM'),
                      onPressed: () => setDialogState(() {
                        workSec = 40;
                        restSec = 20;
                        numRounds = 10;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Total Time
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Total: ${_formatTotalTime(workSec, restSec, numRounds)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _workSeconds = workSec;
                  _restSeconds = restSec;
                  _rounds = numRounds;
                  _intervalRemaining = _workSeconds;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTotalTime(int workSec, int restSec, int rounds) {
    final totalSeconds = (workSec + restSec) * rounds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  void _showSettingsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timer Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Sound Effects'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            ListTile(
              leading: const Icon(Icons.vibration),
              title: const Text('Haptic Feedback'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            ListTile(
              leading: const Icon(Icons.screen_lock_portrait),
              title: const Text('Keep Screen On'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

enum TimerMode { stopwatch, countdown, interval }

enum TimerState { stopped, running, paused }
