import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/achievement.dart';
import '../../providers/fitness_provider.dart';
import '../../widgets/achievement_widgets.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AchievementCategory? _selectedCategory;

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
      appBar: AppBar(
        title: const Text('Achievements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unlocked'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: Consumer<FitnessProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Summary card
              Padding(
                padding: const EdgeInsets.all(16),
                child: AchievementSummary(achievements: provider.achievements),
              ),

              // Category filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildCategoryChip(null, 'All'),
                    ...AchievementCategory.values.map((category) {
                      return _buildCategoryChip(
                        category,
                        category.name[0].toUpperCase() +
                            category.name.substring(1),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Achievements list
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAchievementsList(provider.achievements),
                    _buildAchievementsList(provider.unlockedAchievements),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(AchievementCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildAchievementsList(List<Achievement> achievements) {
    var filteredAchievements = achievements;
    if (_selectedCategory != null) {
      filteredAchievements = achievements
          .where((a) => a.category == _selectedCategory)
          .toList();
    }

    if (filteredAchievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _tabController.index == 1
                  ? 'No achievements unlocked yet'
                  : 'No achievements in this category',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Keep working out to earn achievements!',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // Group by rarity
    final grouped = <AchievementRarity, List<Achievement>>{};
    for (final achievement in filteredAchievements) {
      grouped.putIfAbsent(achievement.rarity, () => []);
      grouped[achievement.rarity]!.add(achievement);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Legendary first
        if (grouped[AchievementRarity.legendary]?.isNotEmpty ?? false)
          _buildRaritySection(
            'Legendary',
            grouped[AchievementRarity.legendary]!,
            Colors.orange,
          ),
        if (grouped[AchievementRarity.epic]?.isNotEmpty ?? false)
          _buildRaritySection(
            'Epic',
            grouped[AchievementRarity.epic]!,
            Colors.purple,
          ),
        if (grouped[AchievementRarity.rare]?.isNotEmpty ?? false)
          _buildRaritySection(
            'Rare',
            grouped[AchievementRarity.rare]!,
            Colors.blue,
          ),
        if (grouped[AchievementRarity.uncommon]?.isNotEmpty ?? false)
          _buildRaritySection(
            'Uncommon',
            grouped[AchievementRarity.uncommon]!,
            Colors.green,
          ),
        if (grouped[AchievementRarity.common]?.isNotEmpty ?? false)
          _buildRaritySection(
            'Common',
            grouped[AchievementRarity.common]!,
            Colors.grey,
          ),
      ],
    );
  }

  Widget _buildRaritySection(
    String title,
    List<Achievement> achievements,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${achievements.length})',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ...achievements.map((achievement) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AchievementProgressCard(
              achievement: achievement,
              onTap: () => _showAchievementDetail(achievement),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showAchievementDetail(Achievement achievement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            AchievementBadge(
              achievement: achievement,
              size: 100,
              showLabel: false,
            ),
            const SizedBox(height: 16),
            Text(
              achievement.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDetailChip(
                  Icons.star,
                  '${achievement.points} points',
                  AppColors.primary,
                ),
                const SizedBox(width: 12),
                _buildDetailChip(
                  Icons.diamond,
                  achievement.rarity.name,
                  _getRarityColor(achievement.rarity),
                ),
              ],
            ),
            if (!achievement.isUnlocked) ...[
              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${achievement.currentValue.toInt()} / ${achievement.targetValue.toInt()}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: achievement.progress,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getRarityColor(achievement.rarity),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ],
            if (achievement.isUnlocked &&
                achievement.unlockedAtDate != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Unlocked on ${_formatDate(achievement.unlockedAtDate!)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.uncommon:
        return Colors.green;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
