import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// User friend model
class Friend {
  final String id;
  final String name;
  final String? avatarUrl;
  final int level;
  final int xp;
  final int workoutsThisWeek;
  final int currentStreak;
  final DateTime? lastActive;
  final FriendStatus status;

  Friend({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.level = 1,
    this.xp = 0,
    this.workoutsThisWeek = 0,
    this.currentStreak = 0,
    this.lastActive,
    this.status = FriendStatus.accepted,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
    'level': level,
    'xp': xp,
    'workoutsThisWeek': workoutsThisWeek,
    'currentStreak': currentStreak,
    'lastActive': lastActive?.toIso8601String(),
    'status': status.index,
  };

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      workoutsThisWeek: json['workoutsThisWeek'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      status: FriendStatus.values[json['status'] ?? 0],
    );
  }
}

enum FriendStatus { pending, accepted, blocked }

/// Challenge model
class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final DateTime startDate;
  final DateTime endDate;
  final double targetValue;
  final String targetUnit;
  final int xpReward;
  final String? badgeId;
  final List<ChallengeParticipant> participants;
  final String creatorId;
  final bool isPublic;
  final ChallengeStatus status;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.targetValue,
    required this.targetUnit,
    this.xpReward = 100,
    this.badgeId,
    this.participants = const [],
    required this.creatorId,
    this.isPublic = true,
    this.status = ChallengeStatus.active,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  Duration get timeRemaining {
    return endDate.difference(DateTime.now());
  }

  int get daysRemaining => timeRemaining.inDays;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'type': type.index,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'targetValue': targetValue,
    'targetUnit': targetUnit,
    'xpReward': xpReward,
    'badgeId': badgeId,
    'participants': participants.map((p) => p.toJson()).toList(),
    'creatorId': creatorId,
    'isPublic': isPublic,
    'status': status.index,
  };

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ChallengeType.values[json['type']],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      targetValue: (json['targetValue'] as num).toDouble(),
      targetUnit: json['targetUnit'],
      xpReward: json['xpReward'] ?? 100,
      badgeId: json['badgeId'],
      participants:
          (json['participants'] as List?)
              ?.map((p) => ChallengeParticipant.fromJson(p))
              .toList() ??
          [],
      creatorId: json['creatorId'],
      isPublic: json['isPublic'] ?? true,
      status: ChallengeStatus.values[json['status'] ?? 0],
    );
  }
}

enum ChallengeType {
  steps,
  workouts,
  calories,
  distance,
  streak,
  weightLoss,
  custom,
}

enum ChallengeStatus { upcoming, active, completed, cancelled }

class ChallengeParticipant {
  final String oderId;
  final String name;
  final String? avatarUrl;
  final double currentProgress;
  final int rank;
  final DateTime joinedAt;

  ChallengeParticipant({
    required this.oderId,
    required this.name,
    this.avatarUrl,
    this.currentProgress = 0,
    this.rank = 0,
    required this.joinedAt,
  });

  double progressPercent(double target) =>
      target > 0 ? (currentProgress / target * 100).clamp(0, 100) : 0;

  Map<String, dynamic> toJson() => {
    'userId': oderId,
    'name': name,
    'avatarUrl': avatarUrl,
    'currentProgress': currentProgress,
    'rank': rank,
    'joinedAt': joinedAt.toIso8601String(),
  };

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipant(
      oderId: json['userId'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      currentProgress: (json['currentProgress'] as num?)?.toDouble() ?? 0,
      rank: json['rank'] ?? 0,
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }
}

/// Leaderboard entry
class LeaderboardEntry {
  final String oderId;
  final String name;
  final String? avatarUrl;
  final int rank;
  final double value;
  final String unit;
  final int level;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.oderId,
    required this.name,
    this.avatarUrl,
    required this.rank,
    required this.value,
    required this.unit,
    this.level = 1,
    this.isCurrentUser = false,
  });

  Map<String, dynamic> toJson() => {
    'userId': oderId,
    'name': name,
    'avatarUrl': avatarUrl,
    'rank': rank,
    'value': value,
    'unit': unit,
    'level': level,
    'isCurrentUser': isCurrentUser,
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      oderId: json['userId'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      rank: json['rank'],
      value: (json['value'] as num).toDouble(),
      unit: json['unit'],
      level: json['level'] ?? 1,
      isCurrentUser: json['isCurrentUser'] ?? false,
    );
  }
}

enum LeaderboardType { weekly, monthly, allTime }

enum LeaderboardCategory { steps, workouts, calories, streak, xp }

/// Activity feed item
class ActivityFeedItem {
  final String id;
  final String oderId;
  final String userName;
  final String? userAvatar;
  final ActivityType type;
  final String title;
  final String? description;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final List<String> likes;
  final List<ActivityComment> comments;

  ActivityFeedItem({
    required this.id,
    required this.oderId,
    required this.userName,
    this.userAvatar,
    required this.type,
    required this.title,
    this.description,
    required this.timestamp,
    this.data,
    this.likes = const [],
    this.comments = const [],
  });

  int get likeCount => likes.length;
  int get commentCount => comments.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': oderId,
    'userName': userName,
    'userAvatar': userAvatar,
    'type': type.index,
    'title': title,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'data': data,
    'likes': likes,
    'comments': comments.map((c) => c.toJson()).toList(),
  };

  factory ActivityFeedItem.fromJson(Map<String, dynamic> json) {
    return ActivityFeedItem(
      id: json['id'],
      oderId: json['userId'],
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      type: ActivityType.values[json['type']],
      title: json['title'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      data: json['data'],
      likes: List<String>.from(json['likes'] ?? []),
      comments:
          (json['comments'] as List?)
              ?.map((c) => ActivityComment.fromJson(c))
              .toList() ??
          [],
    );
  }
}

enum ActivityType {
  workout,
  achievement,
  challenge,
  streak,
  goal,
  weightUpdate,
  friendJoined,
}

class ActivityComment {
  final String id;
  final String oderId;
  final String userName;
  final String text;
  final DateTime timestamp;

  ActivityComment({
    required this.id,
    required this.oderId,
    required this.userName,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': oderId,
    'userName': userName,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ActivityComment.fromJson(Map<String, dynamic> json) {
    return ActivityComment(
      id: json['id'],
      oderId: json['userId'],
      userName: json['userName'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Social Service - handles friends, challenges, and leaderboards
/// Note: This is a mock implementation. For production, use Firebase or similar.
class SocialService {
  static final SocialService _instance = SocialService._internal();
  factory SocialService() => _instance;
  SocialService._internal();

  final List<Friend> _friends = [];
  final List<Challenge> _challenges = [];
  final List<ActivityFeedItem> _activityFeed = [];

  List<Friend> get friends => List.unmodifiable(_friends);
  List<Challenge> get challenges => List.unmodifiable(_challenges);
  List<Challenge> get activeChallenges =>
      _challenges.where((c) => c.isActive).toList();
  List<ActivityFeedItem> get activityFeed => List.unmodifiable(_activityFeed);

  /// Initialize with mock data
  Future<void> initialize() async {
    await _loadFromStorage();
    if (_friends.isEmpty) {
      _loadMockData();
    }
  }

  /// Load data from storage
  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final friendsJson = prefs.getString('social_friends');
    if (friendsJson != null) {
      final list = jsonDecode(friendsJson) as List;
      _friends.clear();
      _friends.addAll(list.map((f) => Friend.fromJson(f)));
    }

    final challengesJson = prefs.getString('social_challenges');
    if (challengesJson != null) {
      final list = jsonDecode(challengesJson) as List;
      _challenges.clear();
      _challenges.addAll(list.map((c) => Challenge.fromJson(c)));
    }
  }

  /// Save data to storage
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'social_friends',
      jsonEncode(_friends.map((f) => f.toJson()).toList()),
    );
    await prefs.setString(
      'social_challenges',
      jsonEncode(_challenges.map((c) => c.toJson()).toList()),
    );
  }

  /// Load mock data for demonstration
  void _loadMockData() {
    _friends.addAll([
      Friend(
        id: 'friend_1',
        name: 'Alex Johnson',
        level: 15,
        xp: 4500,
        workoutsThisWeek: 5,
        currentStreak: 12,
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Friend(
        id: 'friend_2',
        name: 'Sarah Williams',
        level: 22,
        xp: 8200,
        workoutsThisWeek: 6,
        currentStreak: 30,
        lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Friend(
        id: 'friend_3',
        name: 'Mike Chen',
        level: 8,
        xp: 2100,
        workoutsThisWeek: 3,
        currentStreak: 5,
        lastActive: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Friend(
        id: 'friend_4',
        name: 'Emma Davis',
        level: 18,
        xp: 5800,
        workoutsThisWeek: 4,
        currentStreak: 21,
        lastActive: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Friend(
        id: 'friend_5',
        name: 'James Wilson',
        level: 12,
        xp: 3400,
        workoutsThisWeek: 4,
        currentStreak: 8,
        lastActive: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ]);

    final now = DateTime.now();
    _challenges.addAll([
      Challenge(
        id: 'challenge_1',
        title: '10K Steps Daily',
        description: 'Walk 10,000 steps every day for a week',
        type: ChallengeType.steps,
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 4)),
        targetValue: 70000,
        targetUnit: 'steps',
        xpReward: 500,
        creatorId: 'friend_1',
        participants: [
          ChallengeParticipant(
            oderId: 'current_user',
            name: 'You',
            currentProgress: 32500,
            rank: 2,
            joinedAt: now.subtract(const Duration(days: 3)),
          ),
          ChallengeParticipant(
            oderId: 'friend_1',
            name: 'Alex Johnson',
            currentProgress: 38000,
            rank: 1,
            joinedAt: now.subtract(const Duration(days: 3)),
          ),
          ChallengeParticipant(
            oderId: 'friend_2',
            name: 'Sarah Williams',
            currentProgress: 28000,
            rank: 3,
            joinedAt: now.subtract(const Duration(days: 2)),
          ),
        ],
      ),
      Challenge(
        id: 'challenge_2',
        title: 'Workout Warrior',
        description: 'Complete 20 workouts this month',
        type: ChallengeType.workouts,
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        targetValue: 20,
        targetUnit: 'workouts',
        xpReward: 1000,
        creatorId: 'friend_2',
        participants: [
          ChallengeParticipant(
            oderId: 'current_user',
            name: 'You',
            currentProgress: 12,
            rank: 3,
            joinedAt: DateTime(now.year, now.month, 1),
          ),
          ChallengeParticipant(
            oderId: 'friend_2',
            name: 'Sarah Williams',
            currentProgress: 15,
            rank: 1,
            joinedAt: DateTime(now.year, now.month, 1),
          ),
          ChallengeParticipant(
            oderId: 'friend_4',
            name: 'Emma Davis',
            currentProgress: 14,
            rank: 2,
            joinedAt: DateTime(now.year, now.month, 2),
          ),
        ],
      ),
      Challenge(
        id: 'challenge_3',
        title: 'Calorie Crusher',
        description: 'Burn 5000 calories through workouts',
        type: ChallengeType.calories,
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now.add(const Duration(days: 7)),
        targetValue: 5000,
        targetUnit: 'kcal',
        xpReward: 750,
        creatorId: 'current_user',
        participants: [
          ChallengeParticipant(
            oderId: 'current_user',
            name: 'You',
            currentProgress: 2800,
            rank: 1,
            joinedAt: now.subtract(const Duration(days: 7)),
          ),
          ChallengeParticipant(
            oderId: 'friend_3',
            name: 'Mike Chen',
            currentProgress: 2200,
            rank: 2,
            joinedAt: now.subtract(const Duration(days: 6)),
          ),
        ],
      ),
    ]);

    _activityFeed.addAll([
      ActivityFeedItem(
        id: 'activity_1',
        oderId: 'friend_2',
        userName: 'Sarah Williams',
        type: ActivityType.workout,
        title: 'Completed a workout',
        description: 'Morning HIIT Session - 45 mins, 450 kcal burned',
        timestamp: now.subtract(const Duration(minutes: 45)),
        likes: ['friend_1', 'friend_4'],
      ),
      ActivityFeedItem(
        id: 'activity_2',
        oderId: 'friend_1',
        userName: 'Alex Johnson',
        type: ActivityType.achievement,
        title: 'Earned a new badge!',
        description: '🏆 Week Warrior - Worked out every day this week',
        timestamp: now.subtract(const Duration(hours: 2)),
        likes: ['current_user', 'friend_2', 'friend_3'],
      ),
      ActivityFeedItem(
        id: 'activity_3',
        oderId: 'friend_4',
        userName: 'Emma Davis',
        type: ActivityType.streak,
        title: 'Hit a 21-day streak! 🔥',
        description: '3 weeks of consistent workouts!',
        timestamp: now.subtract(const Duration(hours: 5)),
        likes: ['friend_1', 'friend_2', 'friend_5'],
      ),
      ActivityFeedItem(
        id: 'activity_4',
        oderId: 'friend_3',
        userName: 'Mike Chen',
        type: ActivityType.goal,
        title: 'Achieved daily step goal',
        description: 'Walked 12,500 steps today 👟',
        timestamp: now.subtract(const Duration(hours: 8)),
        likes: ['friend_4'],
      ),
      ActivityFeedItem(
        id: 'activity_5',
        oderId: 'friend_5',
        userName: 'James Wilson',
        type: ActivityType.challenge,
        title: 'Joined a challenge',
        description: 'Joined "10K Steps Daily" challenge',
        timestamp: now.subtract(const Duration(hours: 12)),
        likes: [],
      ),
    ]);
  }

  // Friend management
  Future<void> addFriend(Friend friend) async {
    _friends.add(friend);
    await _saveToStorage();
  }

  Future<void> removeFriend(String friendId) async {
    _friends.removeWhere((f) => f.id == friendId);
    await _saveToStorage();
  }

  Future<void> sendFriendRequest(String userId) async {
    // In production, send request via API
  }

  Future<void> acceptFriendRequest(String userId) async {
    final index = _friends.indexWhere((f) => f.id == userId);
    if (index != -1) {
      // Update status to accepted
      await _saveToStorage();
    }
  }

  // Challenge management
  Future<void> createChallenge(Challenge challenge) async {
    _challenges.add(challenge);
    await _saveToStorage();
  }

  Future<void> joinChallenge(String challengeId) async {
    // In production, add current user to challenge via API
  }

  Future<void> leaveChallenge(String challengeId) async {
    // In production, remove current user from challenge via API
  }

  Future<void> updateChallengeProgress(
    String challengeId,
    double progress,
  ) async {
    // In production, update via API
  }

  // Leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({
    required LeaderboardCategory category,
    LeaderboardType type = LeaderboardType.weekly,
    int limit = 50,
  }) async {
    // Mock leaderboard data
    final entries = [
      LeaderboardEntry(
        oderId: 'friend_2',
        name: 'Sarah Williams',
        rank: 1,
        value: _getValueForCategory(category, 1),
        unit: _getUnitForCategory(category),
        level: 22,
      ),
      LeaderboardEntry(
        oderId: 'current_user',
        name: 'You',
        rank: 2,
        value: _getValueForCategory(category, 2),
        unit: _getUnitForCategory(category),
        level: 10,
        isCurrentUser: true,
      ),
      LeaderboardEntry(
        oderId: 'friend_4',
        name: 'Emma Davis',
        rank: 3,
        value: _getValueForCategory(category, 3),
        unit: _getUnitForCategory(category),
        level: 18,
      ),
      LeaderboardEntry(
        oderId: 'friend_1',
        name: 'Alex Johnson',
        rank: 4,
        value: _getValueForCategory(category, 4),
        unit: _getUnitForCategory(category),
        level: 15,
      ),
      LeaderboardEntry(
        oderId: 'friend_5',
        name: 'James Wilson',
        rank: 5,
        value: _getValueForCategory(category, 5),
        unit: _getUnitForCategory(category),
        level: 12,
      ),
    ];

    return entries.take(limit).toList();
  }

  double _getValueForCategory(LeaderboardCategory category, int rank) {
    final baseValues = {
      LeaderboardCategory.steps: 80000.0,
      LeaderboardCategory.workouts: 7.0,
      LeaderboardCategory.calories: 3500.0,
      LeaderboardCategory.streak: 30.0,
      LeaderboardCategory.xp: 5000.0,
    };
    return baseValues[category]! - (rank - 1) * (baseValues[category]! * 0.1);
  }

  String _getUnitForCategory(LeaderboardCategory category) {
    return {
      LeaderboardCategory.steps: 'steps',
      LeaderboardCategory.workouts: 'workouts',
      LeaderboardCategory.calories: 'kcal',
      LeaderboardCategory.streak: 'days',
      LeaderboardCategory.xp: 'XP',
    }[category]!;
  }

  // Activity feed
  Future<void> postActivity(ActivityFeedItem item) async {
    _activityFeed.insert(0, item);
    // In production, post to server
  }

  Future<void> likeActivity(String activityId, String oderId) async {
    final index = _activityFeed.indexWhere((a) => a.id == activityId);
    if (index != -1) {
      final activity = _activityFeed[index];
      if (!activity.likes.contains(oderId)) {
        activity.likes.add(oderId);
      }
    }
  }

  Future<void> commentOnActivity(
    String activityId,
    ActivityComment comment,
  ) async {
    final index = _activityFeed.indexWhere((a) => a.id == activityId);
    if (index != -1) {
      _activityFeed[index].comments.add(comment);
    }
  }

  // Search users
  Future<List<Friend>> searchUsers(String query) async {
    // In production, search via API
    return _friends
        .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

/// Extension methods for challenge types
extension ChallengeTypeExtension on ChallengeType {
  String get displayName {
    switch (this) {
      case ChallengeType.steps:
        return 'Steps Challenge';
      case ChallengeType.workouts:
        return 'Workout Challenge';
      case ChallengeType.calories:
        return 'Calorie Challenge';
      case ChallengeType.distance:
        return 'Distance Challenge';
      case ChallengeType.streak:
        return 'Streak Challenge';
      case ChallengeType.weightLoss:
        return 'Weight Loss Challenge';
      case ChallengeType.custom:
        return 'Custom Challenge';
    }
  }

  String get icon {
    switch (this) {
      case ChallengeType.steps:
        return '👟';
      case ChallengeType.workouts:
        return '🏋️';
      case ChallengeType.calories:
        return '🔥';
      case ChallengeType.distance:
        return '🏃';
      case ChallengeType.streak:
        return '🔥';
      case ChallengeType.weightLoss:
        return '⚖️';
      case ChallengeType.custom:
        return '🎯';
    }
  }
}
