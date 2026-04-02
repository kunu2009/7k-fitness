import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/social_service.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SocialService _socialService = SocialService();
  bool _isLoading = true;
  LeaderboardCategory _selectedLeaderboardCategory = LeaderboardCategory.xp;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await _socialService.initialize();
    setState(() => _isLoading = false);
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
        title: const Text('Social'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.feed), text: 'Feed'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Challenges'),
            Tab(icon: Icon(Icons.leaderboard), text: 'Leaderboard'),
            Tab(icon: Icon(Icons.people), text: 'Friends'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddFriendDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActivityFeed(),
                _buildChallenges(),
                _buildLeaderboard(),
                _buildFriendsList(),
              ],
            ),
    );
  }

  Widget _buildActivityFeed() {
    final feed = _socialService.activityFeed;

    if (feed.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feed_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No activity yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add friends to see their activity!',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: feed.length,
        itemBuilder: (context, index) {
          final item = feed[index];
          return _buildActivityCard(item);
        },
      ),
    );
  }

  Widget _buildActivityCard(ActivityFeedItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    item.userName[0].toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _getTimeAgo(item.timestamp),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _getActivityIcon(item.type),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            Text(
              item.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (item.description != null) ...[
              const SizedBox(height: 4),
              Text(
                item.description!,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],

            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _likeActivity(item.id),
                  icon: Icon(
                    item.likes.contains('current_user')
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 20,
                  ),
                  label: Text('${item.likeCount}'),
                ),
                TextButton.icon(
                  onPressed: () => _showComments(item),
                  icon: const Icon(Icons.comment_outlined, size: 20),
                  label: Text('${item.commentCount}'),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallenges() {
    final challenges = _socialService.challenges;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Active challenges
        Text(
          'Active Challenges',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...challenges.where((c) => c.isActive).map(_buildChallengeCard),

        const SizedBox(height: 24),

        // Create challenge button
        OutlinedButton.icon(
          onPressed: _showCreateChallengeDialog,
          icon: const Icon(Icons.add),
          label: const Text('Create Challenge'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),

        const SizedBox(height: 24),

        // Upcoming challenges
        Text(
          'Upcoming',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...challenges
            .where((c) => c.status == ChallengeStatus.upcoming)
            .map(_buildChallengeCard),

        if (challenges
            .where((c) => c.status == ChallengeStatus.upcoming)
            .isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No upcoming challenges',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final participant = challenge.participants.firstWhere(
      (p) => p.oderId == 'current_user',
      orElse: () => ChallengeParticipant(
        oderId: 'current_user',
        name: 'You',
        joinedAt: DateTime.now(),
      ),
    );
    final progress = participant.currentProgress / challenge.targetValue;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    challenge.type.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${challenge.participants.length} participants',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${challenge.daysRemaining}d left',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Progress',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      '${participant.currentProgress.toInt()} / ${challenge.targetValue.toInt()} ${challenge.targetUnit}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Top participants
            Text(
              'Leaderboard',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...challenge.participants
                .take(3)
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _getRankColor(p.rank),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${p.rank}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            p.name,
                            style: TextStyle(
                              fontWeight: p.oderId == 'current_user'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        Text(
                          '${p.currentProgress.toInt()} ${challenge.targetUnit}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),

            const SizedBox(height: 12),

            // XP reward
            Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${challenge.xpReward} XP reward',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard() {
    return FutureBuilder<List<LeaderboardEntry>>(
      future: _socialService.getLeaderboard(
        category: _selectedLeaderboardCategory,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final entries = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Category selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: LeaderboardCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_getCategoryLabel(category)),
                      selected: category == _selectedLeaderboardCategory,
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(() {
                          _selectedLeaderboardCategory = category;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Top 3 podium
            if (entries.length >= 3) _buildPodium(entries.take(3).toList()),

            const SizedBox(height: 24),

            // Full list
            Card(
              child: Column(
                children: entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildLeaderboardTile(
                    item,
                    index == entries.length - 1,
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> top3) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place
        _buildPodiumPlace(top3[1], 2, 80),
        const SizedBox(width: 8),
        // 1st place
        _buildPodiumPlace(top3[0], 1, 100),
        const SizedBox(width: 8),
        // 3rd place
        _buildPodiumPlace(top3[2], 3, 60),
      ],
    );
  }

  Widget _buildPodiumPlace(LeaderboardEntry entry, int rank, double height) {
    return Column(
      children: [
        CircleAvatar(
          radius: rank == 1 ? 32 : 24,
          backgroundColor: _getRankColor(rank).withValues(alpha: 0.2),
          child: Text(
            entry.name[0].toUpperCase(),
            style: TextStyle(
              color: _getRankColor(rank),
              fontWeight: FontWeight.bold,
              fontSize: rank == 1 ? 20 : 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: rank == 1 ? 14 : 12,
          ),
        ),
        Text(
          '${entry.value.toInt()} ${entry.unit}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: _getRankColor(rank),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          alignment: Alignment.center,
          child: Text(
            _getRankMedal(rank),
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntry entry, bool isLast) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey[200]!)),
        color: entry.isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.1)
            : null,
      ),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: entry.rank <= 3
                ? _getRankColor(entry.rank)
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Text(
            entry.rank <= 3 ? _getRankMedal(entry.rank) : '${entry.rank}',
            style: TextStyle(
              color: entry.rank <= 3 ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: entry.rank <= 3 ? 16 : 12,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              entry.name,
              style: TextStyle(
                fontWeight: entry.isCurrentUser
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            if (entry.isCurrentUser) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text('Level ${entry.level}'),
        trailing: Text(
          '${entry.value.toInt()} ${entry.unit}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    final friends = _socialService.friends;

    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No friends yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _showAddFriendDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Friends'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return _buildFriendCard(friend);
      },
    );
  }

  Widget _buildFriendCard(Friend friend) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                friend.name[0].toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_isOnline(friend.lastActive))
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          friend.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Text('Level ${friend.level}'),
            const SizedBox(width: 8),
            const Text('•'),
            const SizedBox(width: 8),
            Text('🔥 ${friend.currentStreak} streak'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${friend.workoutsThisWeek} workouts',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              'this week',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        onTap: () => _showFriendProfile(friend),
      ),
    );
  }

  // Helper methods
  Widget _getActivityIcon(ActivityType type) {
    final iconData = {
      ActivityType.workout: Icons.fitness_center,
      ActivityType.achievement: Icons.emoji_events,
      ActivityType.challenge: Icons.flag,
      ActivityType.streak: Icons.local_fire_department,
      ActivityType.goal: Icons.track_changes,
      ActivityType.weightUpdate: Icons.monitor_weight,
      ActivityType.friendJoined: Icons.person_add,
    };
    return Icon(iconData[type] ?? Icons.circle, color: AppColors.primary);
  }

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.grey;
    }
  }

  String _getRankMedal(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }

  String _getCategoryLabel(LeaderboardCategory category) {
    return {
      LeaderboardCategory.steps: '👟 Steps',
      LeaderboardCategory.workouts: '💪 Workouts',
      LeaderboardCategory.calories: '🔥 Calories',
      LeaderboardCategory.streak: '🔥 Streak',
      LeaderboardCategory.xp: '⭐ XP',
    }[category]!;
  }

  bool _isOnline(DateTime? lastActive) {
    if (lastActive == null) return false;
    return DateTime.now().difference(lastActive).inMinutes < 15;
  }

  void _likeActivity(String activityId) {
    _socialService.likeActivity(activityId, 'current_user');
    setState(() {});
  }

  void _showComments(ActivityFeedItem item) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: item.comments.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'No comments yet. Start the conversation!',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: item.comments.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 16),
                              itemBuilder: (context, index) {
                                final comment = item.comments[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.15),
                                    child: Text(
                                      comment.userName[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  title: Text(comment.userName),
                                  subtitle: Text(comment.text),
                                  trailing: Text(
                                    _getTimeAgo(comment.timestamp),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          color: AppColors.primary,
                          onPressed: () async {
                            final text = commentController.text.trim();
                            if (text.isEmpty) return;

                            final comment = ActivityComment(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              oderId: 'current_user',
                              userName: 'You',
                              text: text,
                              timestamp: DateTime.now(),
                            );

                            await _socialService.commentOnActivity(
                              item.id,
                              comment,
                            );
                            commentController.clear();
                            setModalState(() {});
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(commentController.dispose);
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Friend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Username or Email',
                hintText: 'Enter friend\'s username',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Or share your invite code:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '7KFIT-ABC123',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.copy), onPressed: () {}),
                ],
              ),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Friend request sent!')),
              );
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  void _showCreateChallengeDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Create Challenge',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Challenge Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text('Challenge Type'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ChallengeType.values.take(5).map((type) {
                  return ChoiceChip(
                    label: Text(
                      '${type.icon} ${type.displayName.split(' ')[0]}',
                    ),
                    selected: type == ChallengeType.steps,
                    onSelected: (selected) {},
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Target',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Duration (days)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Challenge created!')),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Create Challenge'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFriendProfile(Friend friend) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                friend.name[0].toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              friend.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Level ${friend.level} • ${friend.xp} XP',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('🔥', '${friend.currentStreak}', 'Streak'),
                _buildStatColumn(
                  '💪',
                  '${friend.workoutsThisWeek}',
                  'This Week',
                ),
                _buildStatColumn('⭐', '${friend.xp}', 'Total XP'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.flag),
                    label: const Text('Challenge'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message),
                    label: const Text('Message'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
