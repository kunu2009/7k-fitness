import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/gamification.dart';
import '../../providers/gamification_provider.dart';
import '../../widgets/gamification_widgets.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BadgeCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Badges & Rewards'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Badges'),
            Tab(text: 'Unlocked'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: Consumer<GamificationProvider>(
        builder: (context, provider, _) {
          final allBadges = provider.getAllBadgesWithStatus();
          final unlockedBadges = allBadges
              .where((b) => b['isUnlocked'] == true)
              .toList();

          return Column(
            children: [
              // XP and Level Summary
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const XPBarWidget(),
                    const SizedBox(height: 16),
                    const GamificationQuickStats(),
                  ],
                ),
              ),

              // Category filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildCategoryChip(null, 'All', '🏆'),
                    _buildCategoryChip(BadgeCategory.workout, 'Workout', '🏋️'),
                    _buildCategoryChip(BadgeCategory.streak, 'Streak', '🔥'),
                    _buildCategoryChip(BadgeCategory.steps, 'Steps', '👟'),
                    _buildCategoryChip(
                      BadgeCategory.hydration,
                      'Hydration',
                      '💧',
                    ),
                    _buildCategoryChip(
                      BadgeCategory.nutrition,
                      'Nutrition',
                      '🥗',
                    ),
                    _buildCategoryChip(BadgeCategory.weight, 'Weight', '⚖️'),
                    _buildCategoryChip(BadgeCategory.special, 'Special', '⭐'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Badges grid
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBadgesGrid(_filterBadges(allBadges)),
                    _buildBadgesGrid(_filterBadges(unlockedBadges)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _filterBadges(List<Map<String, dynamic>> badges) {
    if (_selectedCategory == null) return badges;
    return badges.where((b) {
      final badge = b['badge'] as GamificationBadge;
      return badge.category == _selectedCategory;
    }).toList();
  }

  Widget _buildCategoryChip(
    BadgeCategory? category,
    String label,
    String emoji,
  ) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text(emoji), const SizedBox(width: 4), Text(label)],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildBadgesGrid(List<Map<String, dynamic>> badges) {
    if (badges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🔒',
              style: TextStyle(
                fontSize: 64,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No badges yet',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete activities to unlock badges!',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badgeData = badges[index];
        final badge = badgeData['badge'] as GamificationBadge;
        final isUnlocked = badgeData['isUnlocked'] as bool;

        return GestureDetector(
          onTap: () => _showBadgeDetails(badge, isUnlocked),
          child: BadgeCardWidget(badge: badge, isUnlocked: isUnlocked),
        );
      },
    );
  }

  void _showBadgeDetails(GamificationBadge badge, bool isUnlocked) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Badge icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? _getRarityColor(badge.rarity).withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked
                        ? _getRarityColor(badge.rarity)
                        : Colors.grey,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    isUnlocked ? badge.icon : '🔒',
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Badge name
              Text(
                badge.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Rarity
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? _getRarityColor(badge.rarity).withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge.rarity.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? _getRarityColor(badge.rarity)
                        : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Requirement
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isUnlocked ? Icons.check_circle : Icons.pending,
                      color: isUnlocked ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isUnlocked
                          ? 'Badge Unlocked!'
                          : _getRequirementText(badge),
                      style: TextStyle(
                        color: isUnlocked
                            ? Colors.green
                            : AppColors.textSecondary,
                        fontWeight: isUnlocked
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Color _getRarityColor(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return Colors.grey.shade600;
      case BadgeRarity.uncommon:
        return Colors.green;
      case BadgeRarity.rare:
        return Colors.blue;
      case BadgeRarity.epic:
        return Colors.purple;
      case BadgeRarity.legendary:
        return Colors.amber;
    }
  }

  String _getRequirementText(GamificationBadge badge) {
    final req = badge.requirement;
    switch (badge.requirementType) {
      case 'total_workouts':
        return 'Complete $req workouts';
      case 'workout_streak':
        return 'Maintain a $req-day streak';
      case 'daily_steps':
        return 'Walk $req steps in a day';
      case 'total_steps':
        return 'Walk ${_formatNumber(req)} total steps';
      case 'total_weight_lifted':
        return 'Lift ${_formatNumber(req)} kg total';
      case 'water_goal_days':
        return 'Hit water goal for $req days';
      case 'meals_logged':
        return 'Log $req meals';
      case 'meal_logging_days':
        return 'Log meals for $req days';
      case 'weight_logs':
        return 'Log weight $req times';
      case 'personal_records':
        return 'Set $req personal records';
      case 'level':
        return 'Reach level $req';
      default:
        return 'Requirement: $req';
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
