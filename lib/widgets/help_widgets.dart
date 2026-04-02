import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A help tooltip button that shows contextual help when tapped
class HelpTooltip extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? color;
  final double iconSize;

  const HelpTooltip({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.help_outline,
    this.color,
    this.iconSize = 20,
  });

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message, style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: iconSize),
      color: color ?? Colors.grey[400],
      onPressed: () => _showHelp(context),
      tooltip: 'Help',
    );
  }
}

/// An inline help widget with icon and expandable content
class InlineHelp extends StatefulWidget {
  final String helpText;
  final Color? color;

  const InlineHelp({super.key, required this.helpText, this.color});

  @override
  State<InlineHelp> createState() => _InlineHelpState();
}

class _InlineHelpState extends State<InlineHelp> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (widget.color ?? Colors.blue).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isExpanded ? Icons.info : Icons.info_outline,
                  size: 16,
                  color: widget.color ?? Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  _isExpanded ? 'Hide help' : 'Need help?',
                  style: TextStyle(
                    color: widget.color ?? Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: widget.color ?? Colors.blue,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber[700],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.helpText,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

/// A feature spotlight overlay for first-time users
class FeatureSpotlight extends StatefulWidget {
  final Widget child;
  final String title;
  final String description;
  final String spotlightKey;
  final VoidCallback? onDismiss;
  final bool enabled;

  const FeatureSpotlight({
    super.key,
    required this.child,
    required this.title,
    required this.description,
    required this.spotlightKey,
    this.onDismiss,
    this.enabled = true,
  });

  @override
  State<FeatureSpotlight> createState() => _FeatureSpotlightState();
}

class _FeatureSpotlightState extends State<FeatureSpotlight> {
  bool _showSpotlight = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkIfShouldShow();
      });
    }
  }

  Future<void> _checkIfShouldShow() async {
    // Implementation would check SharedPreferences
    // For now, we'll keep it simple
    setState(() => _showSpotlight = false);
  }

  void _dismiss() {
    setState(() => _showSpotlight = false);
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showSpotlight)
          Positioned.fill(
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _dismiss,
                          child: const Text('Got it!'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Quick tip banner that can be dismissed
class QuickTipBanner extends StatefulWidget {
  final String tip;
  final IconData icon;
  final Color color;
  final String? dismissKey;

  const QuickTipBanner({
    super.key,
    required this.tip,
    this.icon = Icons.tips_and_updates,
    this.color = Colors.amber,
    this.dismissKey,
  });

  @override
  State<QuickTipBanner> createState() => _QuickTipBannerState();
}

class _QuickTipBannerState extends State<QuickTipBanner> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(widget.icon, color: widget.color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.tip,
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.grey[400],
            onPressed: () => setState(() => _isDismissed = true),
          ),
        ],
      ),
    );
  }
}

/// Info card for explaining concepts
class InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;
  final bool expandable;

  const InfoCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
    this.expandable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(color: Colors.grey[700], height: 1.5)),
        ],
      ),
    );
  }
}

/// Contextual help data for different screens
class ContextualHelp {
  static const Map<String, Map<String, String>> screenHelp = {
    'home': {
      'calories':
          'This shows your daily calorie intake vs your goal. Green means you\'re on track!',
      'water': 'Tap to quickly log water. Aim for 8+ glasses (2000ml) daily.',
      'steps': 'Steps are synced from your device or can be entered manually.',
      'quick_actions':
          'Quick access to frequently used features. Customize in Settings.',
    },
    'nutrition': {
      'meal_logging':
          'Tap + to add food. Log meals right after eating for accuracy.',
      'macros':
          'Protein builds muscle, carbs provide energy, fat supports hormones.',
      'calories_remaining':
          'Negative means you\'ve exceeded your goal for the day.',
    },
    'workout': {
      'templates': 'Pre-built workout routines to get started quickly.',
      'programs': 'Multi-week training plans with progressive overload.',
      'logging': 'Track sets, reps, and weight to monitor your progress.',
    },
    'progress': {
      'weight_chart':
          'Focus on the trend, not daily fluctuations. Weight can vary 2-4 lbs daily.',
      'measurements': 'Take measurements same time each week for accuracy.',
      'photos': 'Progress photos are often more telling than the scale!',
    },
  };

  static String? getHelp(String screen, String element) {
    return screenHelp[screen]?[element];
  }
}
