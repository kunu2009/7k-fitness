import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

/// Achievement badge types
enum BadgeType { bronze, silver, gold, platinum, diamond }

/// Achievement badge data
class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final BadgeType type;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progress; // 0.0 to 1.0

  const AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0.0,
  });

  Color get color {
    switch (type) {
      case BadgeType.bronze:
        return const Color(0xFFCD7F32);
      case BadgeType.silver:
        return const Color(0xFFC0C0C0);
      case BadgeType.gold:
        return const Color(0xFFFFD700);
      case BadgeType.platinum:
        return const Color(0xFFE5E4E2);
      case BadgeType.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  IconData get icon {
    switch (iconName) {
      case 'fitness':
        return Icons.fitness_center;
      case 'run':
        return Icons.directions_run;
      case 'walk':
        return Icons.directions_walk;
      case 'bike':
        return Icons.directions_bike;
      case 'swim':
        return Icons.pool;
      case 'fire':
        return Icons.local_fire_department;
      case 'star':
        return Icons.star;
      case 'trophy':
        return Icons.emoji_events;
      case 'heart':
        return Icons.favorite;
      case 'streak':
        return Icons.whatshot;
      case 'muscle':
        return Icons.sports_gymnastics;
      case 'timer':
        return Icons.timer;
      case 'calendar':
        return Icons.calendar_month;
      default:
        return Icons.military_tech;
    }
  }
}

/// Achievement Badge Widget
class AchievementBadgeWidget extends StatelessWidget {
  final AchievementBadge badge;
  final double size;
  final bool showLabel;
  final VoidCallback? onTap;

  const AchievementBadgeWidget({
    super.key,
    required this.badge,
    this.size = 80,
    this.showLabel = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Background glow for unlocked badges
              if (badge.isUnlocked)
                Container(
                  width: size + 10,
                  height: size + 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: badge.color.withAlpha(100),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

              // Progress ring for locked badges
              if (!badge.isUnlocked && badge.progress > 0)
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: badge.progress,
                    strokeWidth: 3,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(badge.color),
                  ),
                ),

              // Badge container
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: badge.isUnlocked
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            badge.color.withAlpha(230),
                            badge.color,
                            badge.color.withAlpha(179),
                          ],
                        )
                      : null,
                  color: badge.isUnlocked ? null : Colors.grey.shade300,
                  border: Border.all(
                    color: badge.isUnlocked
                        ? badge.color.withAlpha(200)
                        : Colors.grey.shade400,
                    width: 3,
                  ),
                  boxShadow: badge.isUnlocked
                      ? [
                          BoxShadow(
                            color: badge.color.withAlpha(77),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  badge.icon,
                  size: size * 0.5,
                  color: badge.isUnlocked ? Colors.white : Colors.grey.shade500,
                ),
              ),

              // Lock icon for locked badges
              if (!badge.isUnlocked)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock,
                      size: size * 0.2,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          if (showLabel) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: size + 20,
              child: Text(
                badge.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: badge.isUnlocked
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated Achievement Unlock Widget
class AchievementUnlockAnimation extends StatefulWidget {
  final AchievementBadge badge;
  final VoidCallback? onComplete;

  const AchievementUnlockAnimation({
    super.key,
    required this.badge,
    this.onComplete,
  });

  @override
  State<AchievementUnlockAnimation> createState() =>
      _AchievementUnlockAnimationState();
}

class _AchievementUnlockAnimationState extends State<AchievementUnlockAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _sparkleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_scaleController);

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_rotateController));

    _sparkleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_sparkleController);

    // Start animations
    _scaleController.forward();
    _rotateController.forward();
    _sparkleController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Achievement Unlocked!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: Listenable.merge([
                _scaleController,
                _rotateController,
                _sparkleController,
              ]),
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sparkles
                    ...List.generate(8, (index) {
                      final angle =
                          (index * math.pi / 4) + _rotateAnimation.value;
                      final radius = 80 * _sparkleAnimation.value;
                      final opacity = (1 - _sparkleAnimation.value).clamp(
                        0.0,
                        1.0,
                      );

                      return Transform.translate(
                        offset: Offset(
                          math.cos(angle) * radius,
                          math.sin(angle) * radius,
                        ),
                        child: Opacity(
                          opacity: opacity,
                          child: Icon(
                            Icons.star,
                            color: widget.badge.color,
                            size: 20,
                          ),
                        ),
                      );
                    }),

                    // Badge
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: AchievementBadgeWidget(
                        badge: widget.badge.copyWith(isUnlocked: true),
                        size: 120,
                        showLabel: false,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              widget.badge.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                widget.badge.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension for copyWith
extension AchievementBadgeCopyWith on AchievementBadge {
  AchievementBadge copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    BadgeType? type,
    bool? isUnlocked,
    DateTime? unlockedAt,
    double? progress,
  }) {
    return AchievementBadge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }
}

/// Achievement Grid Widget
class AchievementGrid extends StatelessWidget {
  final List<AchievementBadge> badges;
  final ValueChanged<AchievementBadge>? onBadgeTap;

  const AchievementGrid({super.key, required this.badges, this.onBadgeTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        mainAxisSpacing: 16,
        crossAxisSpacing: 8,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return AchievementBadgeWidget(
          badge: badge,
          size: 60,
          onTap: () => onBadgeTap?.call(badge),
        );
      },
    );
  }
}

/// Sample achievements database
class Achievements {
  static const List<AchievementBadge> all = [
    AchievementBadge(
      id: 'first_workout',
      title: 'First Step',
      description: 'Complete your first workout',
      iconName: 'fitness',
      type: BadgeType.bronze,
    ),
    AchievementBadge(
      id: 'workout_streak_7',
      title: 'Week Warrior',
      description: 'Maintain a 7-day workout streak',
      iconName: 'streak',
      type: BadgeType.silver,
    ),
    AchievementBadge(
      id: 'workout_streak_30',
      title: 'Monthly Champion',
      description: 'Maintain a 30-day workout streak',
      iconName: 'streak',
      type: BadgeType.gold,
    ),
    AchievementBadge(
      id: 'calories_1000',
      title: 'Calorie Crusher',
      description: 'Burn 1,000 calories in a single day',
      iconName: 'fire',
      type: BadgeType.silver,
    ),
    AchievementBadge(
      id: 'steps_10000',
      title: '10K Steps',
      description: 'Walk 10,000 steps in a day',
      iconName: 'walk',
      type: BadgeType.bronze,
    ),
    AchievementBadge(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Complete a workout before 6 AM',
      iconName: 'timer',
      type: BadgeType.bronze,
    ),
    AchievementBadge(
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Complete a workout after 10 PM',
      iconName: 'timer',
      type: BadgeType.bronze,
    ),
    AchievementBadge(
      id: 'workout_100',
      title: 'Century Club',
      description: 'Complete 100 workouts',
      iconName: 'trophy',
      type: BadgeType.platinum,
    ),
    AchievementBadge(
      id: 'strength_master',
      title: 'Strength Master',
      description: 'Complete 50 strength workouts',
      iconName: 'muscle',
      type: BadgeType.gold,
    ),
    AchievementBadge(
      id: 'cardio_king',
      title: 'Cardio King',
      description: 'Complete 50 cardio workouts',
      iconName: 'heart',
      type: BadgeType.gold,
    ),
    AchievementBadge(
      id: 'marathon_runner',
      title: 'Marathon Runner',
      description: 'Run a total of 42.2 km',
      iconName: 'run',
      type: BadgeType.gold,
    ),
    AchievementBadge(
      id: 'workout_365',
      title: 'Year of Fitness',
      description: 'Work out for 365 days total',
      iconName: 'calendar',
      type: BadgeType.diamond,
    ),
  ];
}
