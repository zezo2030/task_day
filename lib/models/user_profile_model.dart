import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 18)
class UserProfileModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int totalPoints;

  @HiveField(3)
  final int currentLevel;

  @HiveField(4)
  final int pointsToNextLevel;

  @HiveField(5)
  final List<String> unlockedAchievements;

  @HiveField(6)
  final int currentStreak;

  @HiveField(7)
  final int longestStreak;

  @HiveField(8)
  final DateTime? lastActivityDate;

  @HiveField(9)
  final Map<String, int> weeklyProgress;

  @HiveField(10)
  final List<String> availableRewards;

  @HiveField(11)
  final List<String> claimedRewards;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime lastUpdated;

  UserProfileModel({
    required this.id,
    required this.name,
    this.totalPoints = 0,
    this.currentLevel = 1,
    this.pointsToNextLevel = 100,
    this.unlockedAchievements = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    this.weeklyProgress = const {},
    this.availableRewards = const [],
    this.claimedRewards = const [],
    required this.createdAt,
    required this.lastUpdated,
  });

  // Calculate level based on total points
  static int calculateLevel(int totalPoints) {
    if (totalPoints < 100) return 1;
    if (totalPoints < 300) return 2;
    if (totalPoints < 600) return 3;
    if (totalPoints < 1000) return 4;
    if (totalPoints < 1500) return 5;
    if (totalPoints < 2100) return 6;
    if (totalPoints < 2800) return 7;
    if (totalPoints < 3600) return 8;
    if (totalPoints < 4500) return 9;
    return 10 + ((totalPoints - 4500) ~/ 1000);
  }

  // Calculate points needed for next level
  static int calculatePointsToNextLevel(int totalPoints) {
    final currentLevel = calculateLevel(totalPoints);
    final nextLevelPoints = _getPointsRequiredForLevel(currentLevel + 1);
    return nextLevelPoints - totalPoints;
  }

  static int _getPointsRequiredForLevel(int level) {
    if (level <= 1) return 0;
    if (level == 2) return 100;
    if (level == 3) return 300;
    if (level == 4) return 600;
    if (level == 5) return 1000;
    if (level == 6) return 1500;
    if (level == 7) return 2100;
    if (level == 8) return 2800;
    if (level == 9) return 3600;
    if (level == 10) return 4500;
    return 4500 + ((level - 10) * 1000);
  }

  // Get progress percentage to next level
  double get levelProgress {
    final currentLevelPoints = _getPointsRequiredForLevel(currentLevel);
    final nextLevelPoints = _getPointsRequiredForLevel(currentLevel + 1);
    final progressPoints = totalPoints - currentLevelPoints;
    final totalNeeded = nextLevelPoints - currentLevelPoints;
    return totalNeeded > 0
        ? (progressPoints / totalNeeded).clamp(0.0, 1.0)
        : 1.0;
  }

  UserProfileModel copyWith({
    String? id,
    String? name,
    int? totalPoints,
    int? currentLevel,
    int? pointsToNextLevel,
    List<String>? unlockedAchievements,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    Map<String, int>? weeklyProgress,
    List<String>? availableRewards,
    List<String>? claimedRewards,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    final newTotalPoints = totalPoints ?? this.totalPoints;
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      totalPoints: newTotalPoints,
      currentLevel: currentLevel ?? calculateLevel(newTotalPoints),
      pointsToNextLevel:
          pointsToNextLevel ?? calculatePointsToNextLevel(newTotalPoints),
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      availableRewards: availableRewards ?? this.availableRewards,
      claimedRewards: claimedRewards ?? this.claimedRewards,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    totalPoints,
    currentLevel,
    pointsToNextLevel,
    unlockedAchievements,
    currentStreak,
    longestStreak,
    lastActivityDate,
    weeklyProgress,
    availableRewards,
    claimedRewards,
    createdAt,
    lastUpdated,
  ];
}
