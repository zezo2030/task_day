import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile_model.dart';
import '../models/achievement_model.dart';
import '../models/reward_model.dart';
import '../models/habit_model.dart';

class GamificationService {
  static const String userProfileBoxName = 'user_profile';
  static const String achievementsBoxName = 'achievements';
  static const String rewardsBoxName = 'rewards';

  static const _uuid = Uuid();

  // Initialize gamification system
  static Future<void> init() async {
    await _createUserProfileIfNotExists();
    await _initializeAchievements();
    await _initializeRewards();
    await _cleanupOldDailyPoints(); // Clean old daily points tracking
  }

  // User Profile Methods
  static Future<UserProfileModel?> getUserProfile() async {
    final box = await Hive.openBox<UserProfileModel>(userProfileBoxName);
    return box.get('profile');
  }

  static Future<void> saveUserProfile(UserProfileModel profile) async {
    final box = await Hive.openBox<UserProfileModel>(userProfileBoxName);
    await box.put('profile', profile);
  }

  static Future<void> _createUserProfileIfNotExists() async {
    final profile = await getUserProfile();
    if (profile == null) {
      final newProfile = UserProfileModel(
        id: _uuid.v4(),
        name: 'User',
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      await saveUserProfile(newProfile);
    }
  }

  // Points and Level Management
  static Future<void> addPoints(int points, {String? reason}) async {
    final profile = await getUserProfile();
    if (profile != null) {
      final updatedProfile = profile.copyWith(
        totalPoints: profile.totalPoints + points,
        lastActivityDate: DateTime.now(),
      );
      await saveUserProfile(updatedProfile);

      // Check for level up
      await _checkLevelUp(profile.currentLevel, updatedProfile.currentLevel);

      // Check achievements after adding points
      await _checkAchievements(updatedProfile);
    }
  }

  static Future<void> _checkLevelUp(int oldLevel, int newLevel) async {
    if (newLevel > oldLevel) {
      // Trigger level up celebration
      await _unlockLevelRewards(newLevel);
      // You can add notification/animation logic here
    }
  }

  static Future<void> _unlockLevelRewards(int level) async {
    final box = await Hive.openBox<RewardModel>(rewardsBoxName);
    final rewards = box.values.toList();

    for (final reward in rewards) {
      if (reward.requiredLevel != null &&
          reward.requiredLevel! <= level &&
          !reward.isAvailable) {
        final updatedReward = reward.copyWith(isAvailable: true);
        await box.put(reward.id, updatedReward);
      }
    }
  }

  // NEW: Subtract points function
  static Future<void> subtractPoints(int points, {String? reason}) async {
    final profile = await getUserProfile();
    if (profile != null) {
      final newTotalPoints =
          (profile.totalPoints - points).clamp(0, double.infinity).toInt();
      final updatedProfile = profile.copyWith(
        totalPoints: newTotalPoints,
        lastActivityDate: DateTime.now(),
      );
      await saveUserProfile(updatedProfile);

      // Check achievements after subtracting points
      await _checkAchievements(updatedProfile);
    }
  }

  // NEW: Track daily habit completions to prevent point exploitation
  static const String dailyHabitPointsBoxName = 'daily_habit_points';

  static Future<bool> hasEarnedPointsToday(String habitId) async {
    final box = await Hive.openBox(dailyHabitPointsBoxName);
    final today = DateTime.now();
    final key = '${habitId}_${today.year}_${today.month}_${today.day}';
    return box.get(key, defaultValue: false) as bool;
  }

  static Future<void> markPointsEarnedToday(String habitId, int points) async {
    final box = await Hive.openBox(dailyHabitPointsBoxName);
    final today = DateTime.now();
    final key = '${habitId}_${today.year}_${today.month}_${today.day}';
    await box.put(key, true);
    await box.put('${key}_points', points);
  }

  static Future<int?> getPointsEarnedToday(String habitId) async {
    final box = await Hive.openBox(dailyHabitPointsBoxName);
    final today = DateTime.now();
    final key = '${habitId}_${today.year}_${today.month}_${today.day}_points';
    return box.get(key) as int?;
  }

  static Future<void> removePointsEarnedToday(String habitId) async {
    final box = await Hive.openBox(dailyHabitPointsBoxName);
    final today = DateTime.now();
    final key = '${habitId}_${today.year}_${today.month}_${today.day}';
    final pointsKey = '${key}_points';
    await box.delete(key);
    await box.delete(pointsKey);
  }

  // Habit Completion Points System
  static Future<int> onHabitCompleted(HabitModel habit) async {
    // Check if points were already earned today for this habit
    if (await hasEarnedPointsToday(habit.id)) {
      return 0; // No points earned, already completed today
    }

    int points = _calculateHabitPoints(habit);
    await addPoints(points, reason: 'Habit completed: ${habit.title}');

    // Mark that points were earned today for this habit
    await markPointsEarnedToday(habit.id, points);

    // Update streak
    await _updateStreak();

    // Check for habit-specific achievements
    await _checkHabitAchievements(habit);

    return points; // Return points earned for UI display
  }

  // NEW: Handle habit reset (uncomplete)
  static Future<int> onHabitReset(HabitModel habit) async {
    // Check if points were earned today for this habit
    final pointsEarned = await getPointsEarnedToday(habit.id);

    if (pointsEarned != null && pointsEarned > 0) {
      // Subtract the points that were earned today
      await subtractPoints(pointsEarned, reason: 'Habit reset: ${habit.title}');

      // Remove the daily tracking
      await removePointsEarnedToday(habit.id);

      return pointsEarned; // Return points that were subtracted
    }

    return 0; // No points to subtract
  }

  static int _calculateHabitPoints(HabitModel habit) {
    int basePoints = 10;

    // Bonus for measurable habits based on progress
    if (habit.isMeasurable &&
        habit.targetValue != null &&
        habit.currentValue != null) {
      double progress = habit.currentValue! / habit.targetValue!;
      if (progress >= 1.0) {
        basePoints += 5; // Bonus for completing measurable habit
      }
    }

    // Bonus based on habit difficulty (could be added to habit model)
    // For now, using description length as a simple difficulty indicator
    if (habit.description.length > 50) {
      basePoints += 3; // Complex habits get more points
    }

    return basePoints;
  }

  // Streak Management
  static Future<void> _updateStreak() async {
    final profile = await getUserProfile();
    if (profile == null) return;

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    bool hadActivityYesterday =
        profile.lastActivityDate != null &&
        _isSameDay(profile.lastActivityDate!, yesterday);

    bool hadActivityToday =
        profile.lastActivityDate != null &&
        _isSameDay(profile.lastActivityDate!, today);

    int newStreak = profile.currentStreak;

    if (hadActivityToday) {
      if (hadActivityYesterday || profile.currentStreak == 0) {
        newStreak = profile.currentStreak + 1;
      }
    } else {
      newStreak = 1; // Starting new streak
    }

    final updatedProfile = profile.copyWith(
      currentStreak: newStreak,
      longestStreak:
          newStreak > profile.longestStreak ? newStreak : profile.longestStreak,
      lastActivityDate: today,
    );

    await saveUserProfile(updatedProfile);
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Achievement System
  static Future<List<AchievementModel>> getAllAchievements() async {
    final box = await Hive.openBox<AchievementModel>(achievementsBoxName);
    return box.values.toList();
  }

  static Future<void> _checkAchievements(UserProfileModel profile) async {
    final achievements = await getAllAchievements();

    for (final achievement in achievements) {
      if (!achievement.isUnlocked) {
        await _checkSpecificAchievement(achievement, profile);
      }
    }
  }

  static Future<void> _checkSpecificAchievement(
    AchievementModel achievement,
    UserProfileModel profile,
  ) async {
    bool shouldUnlock = false;
    int currentProgress = 0;

    switch (achievement.type) {
      case AchievementType.totalPoints:
        currentProgress = profile.totalPoints;
        shouldUnlock = profile.totalPoints >= achievement.targetValue;
        break;
      case AchievementType.streakDays:
        currentProgress = profile.currentStreak;
        shouldUnlock = profile.currentStreak >= achievement.targetValue;
        break;
      case AchievementType.dedication:
        final daysSinceCreation =
            DateTime.now().difference(profile.createdAt).inDays;
        currentProgress = daysSinceCreation;
        shouldUnlock = daysSinceCreation >= achievement.targetValue;
        break;
      // Add more achievement types as needed
      default:
        break;
    }

    // Update achievement progress
    final box = await Hive.openBox<AchievementModel>(achievementsBoxName);
    final updatedAchievement = achievement.copyWith(
      currentProgress: currentProgress,
      isUnlocked: shouldUnlock,
      unlockedAt: shouldUnlock ? DateTime.now() : null,
    );
    await box.put(achievement.id, updatedAchievement);

    if (shouldUnlock && !achievement.isUnlocked) {
      await _onAchievementUnlocked(updatedAchievement);
    }
  }

  static Future<void> _onAchievementUnlocked(
    AchievementModel achievement,
  ) async {
    // Add points for unlocking achievement
    await addPoints(
      achievement.pointsReward,
      reason: 'Achievement unlocked: ${achievement.title}',
    );

    // Update user's unlocked achievements
    final profile = await getUserProfile();
    if (profile != null) {
      final updatedAchievements = [
        ...profile.unlockedAchievements,
        achievement.id,
      ];
      await saveUserProfile(
        profile.copyWith(unlockedAchievements: updatedAchievements),
      );
    }

    // Trigger achievement celebration UI
    // You can add notification logic here
  }

  static Future<void> _checkHabitAchievements(HabitModel habit) async {
    final achievements = await getAllAchievements();
    final profile = await getUserProfile();
    if (profile == null) return;

    // Get total habits completed today
    // This would require tracking daily habit completions
    // For now, we'll use a simplified approach

    for (final achievement in achievements) {
      if (achievement.type == AchievementType.habitsCompleted &&
          !achievement.isUnlocked) {
        // You would implement actual habit counting logic here
        // For example: count completed habits from Hive
      }
    }
  }

  // Reward System
  static Future<List<RewardModel>> getAvailableRewards() async {
    final box = await Hive.openBox<RewardModel>(rewardsBoxName);
    return box.values.where((reward) => reward.canBeClaimed).toList();
  }

  static Future<bool> claimReward(String rewardId) async {
    final profile = await getUserProfile();
    if (profile == null) return false;

    final box = await Hive.openBox<RewardModel>(rewardsBoxName);
    final reward = box.get(rewardId);

    if (reward == null || !reward.canBeClaimed) return false;

    // Check if user has enough points
    if (profile.totalPoints < reward.costInPoints) return false;

    // Check level requirement
    if (reward.requiredLevel != null &&
        profile.currentLevel < reward.requiredLevel!)
      return false;

    // Claim the reward
    final updatedReward = reward.copyWith(
      isClaimed: true,
      claimedAt: DateTime.now(),
    );
    await box.put(rewardId, updatedReward);

    // Deduct points
    final updatedProfile = profile.copyWith(
      totalPoints: profile.totalPoints - reward.costInPoints,
      claimedRewards: [...profile.claimedRewards, rewardId],
    );
    await saveUserProfile(updatedProfile);

    return true;
  }

  // Initialize default achievements
  static Future<void> _initializeAchievements() async {
    final box = await Hive.openBox<AchievementModel>(achievementsBoxName);

    if (box.isEmpty) {
      final defaultAchievements = _getDefaultAchievements();
      for (final achievement in defaultAchievements) {
        await box.put(achievement.id, achievement);
      }
    }
  }

  static List<AchievementModel> _getDefaultAchievements() {
    return [
      // Point-based achievements
      AchievementModel(
        id: 'first_100_points',
        title: 'نقاطي الأولى',
        description: 'احصل على 100 نقطة',
        icon: Icons.stars,
        color: Colors.amber,
        type: AchievementType.totalPoints,
        targetValue: 100,
        pointsReward: 20,
        rarity: AchievementRarity.common,
      ),
      AchievementModel(
        id: 'point_collector',
        title: 'جامع النقاط',
        description: 'احصل على 500 نقطة',
        icon: Icons.star,
        color: Colors.blue,
        type: AchievementType.totalPoints,
        targetValue: 500,
        pointsReward: 50,
        rarity: AchievementRarity.rare,
      ),
      AchievementModel(
        id: 'point_master',
        title: 'سيد النقاط',
        description: 'احصل على 1000 نقطة',
        icon: Icons.military_tech,
        color: Colors.purple,
        type: AchievementType.totalPoints,
        targetValue: 1000,
        pointsReward: 100,
        rarity: AchievementRarity.epic,
      ),

      // Streak achievements
      AchievementModel(
        id: 'week_warrior',
        title: 'محارب الأسبوع',
        description: 'استمر لمدة 7 أيام متتالية',
        icon: Icons.local_fire_department,
        color: Colors.orange,
        type: AchievementType.streakDays,
        targetValue: 7,
        pointsReward: 30,
        rarity: AchievementRarity.common,
      ),
      AchievementModel(
        id: 'month_champion',
        title: 'بطل الشهر',
        description: 'استمر لمدة 30 يوماً متتالية',
        icon: Icons.emoji_events,
        color: Colors.red,
        type: AchievementType.streakDays,
        targetValue: 30,
        pointsReward: 100,
        rarity: AchievementRarity.epic,
      ),

      // Dedication achievements
      AchievementModel(
        id: 'newcomer',
        title: 'وافد جديد',
        description: 'استخدم التطبيق لمدة 3 أيام',
        icon: Icons.waving_hand,
        color: Colors.green,
        type: AchievementType.dedication,
        targetValue: 3,
        pointsReward: 15,
        rarity: AchievementRarity.common,
      ),
      AchievementModel(
        id: 'regular_user',
        title: 'مستخدم منتظم',
        description: 'استخدم التطبيق لمدة 14 يوماً',
        icon: Icons.schedule,
        color: Colors.teal,
        type: AchievementType.dedication,
        targetValue: 14,
        pointsReward: 40,
        rarity: AchievementRarity.rare,
      ),
    ];
  }

  // Initialize default rewards
  static Future<void> _initializeRewards() async {
    final box = await Hive.openBox<RewardModel>(rewardsBoxName);

    if (box.isEmpty) {
      final defaultRewards = _getDefaultRewards();
      for (final reward in defaultRewards) {
        await box.put(reward.id, reward);
      }
    }
  }

  static List<RewardModel> _getDefaultRewards() {
    return [
      // Theme rewards
      RewardModel(
        id: 'dark_theme',
        title: 'المظهر الداكن',
        description: 'افتح المظهر الداكن الأنيق',
        icon: Icons.dark_mode,
        color: Colors.indigo,
        type: RewardType.theme,
        costInPoints: 50,
        rarity: RewardRarity.common,
      ),
      RewardModel(
        id: 'gradient_theme',
        title: 'مظهر متدرج',
        description: 'افتح المظهر المتدرج الجميل',
        icon: Icons.gradient,
        color: Colors.purple,
        type: RewardType.theme,
        costInPoints: 100,
        rarity: RewardRarity.uncommon,
        requiredLevel: 3,
      ),

      // Avatar rewards
      RewardModel(
        id: 'gold_avatar',
        title: 'صورة ذهبية',
        description: 'إطار ذهبي لصورتك الشخصية',
        icon: Icons.account_circle,
        color: Colors.amber,
        type: RewardType.avatar,
        costInPoints: 150,
        rarity: RewardRarity.rare,
        requiredLevel: 5,
      ),

      // Badge rewards
      RewardModel(
        id: 'motivation_master',
        title: 'سيد التحفيز',
        description: 'شارة خاصة للمتحفزين',
        icon: Icons.psychology,
        color: Colors.green,
        type: RewardType.badge,
        costInPoints: 200,
        rarity: RewardRarity.epic,
        requiredLevel: 7,
      ),

      // Feature rewards
      RewardModel(
        id: 'custom_colors',
        title: 'ألوان مخصصة',
        description: 'خصص ألوان العادات بحرية',
        icon: Icons.palette,
        color: Colors.pink,
        type: RewardType.feature,
        costInPoints: 75,
        rarity: RewardRarity.uncommon,
        requiredLevel: 2,
      ),
    ];
  }

  // Weekly Challenge System
  static Future<Map<String, dynamic>> getWeeklyChallenge() async {
    // This would implement weekly challenges
    // For now, return a simple challenge
    return {
      'title': 'تحدي الأسبوع',
      'description': 'أكمل 5 عادات كل يوم لمدة أسبوع',
      'progress': 0,
      'target': 35, // 5 habits * 7 days
      'reward': 150,
      'expiresAt': DateTime.now().add(const Duration(days: 7)),
    };
  }

  // Statistics and Analytics
  static Future<Map<String, dynamic>> getGamificationStats() async {
    final profile = await getUserProfile();
    final achievements = await getAllAchievements();
    final rewards = await getAvailableRewards();

    if (profile == null) return {};

    final unlockedAchievements = achievements.where((a) => a.isUnlocked).length;
    final totalAchievements = achievements.length;

    return {
      'totalPoints': profile.totalPoints,
      'currentLevel': profile.currentLevel,
      'levelProgress': profile.levelProgress,
      'currentStreak': profile.currentStreak,
      'longestStreak': profile.longestStreak,
      'unlockedAchievements': unlockedAchievements,
      'totalAchievements': totalAchievements,
      'availableRewards': rewards.length,
      'claimedRewards': profile.claimedRewards.length,
    };
  }

  // NEW: Clean up old daily points tracking (keep only last 7 days)
  static Future<void> _cleanupOldDailyPoints() async {
    try {
      final box = await Hive.openBox(dailyHabitPointsBoxName);
      final now = DateTime.now();
      final cutoffDate = now.subtract(const Duration(days: 7));

      final keysToDelete = <String>[];

      for (final key in box.keys) {
        if (key is String && key.contains('_')) {
          // Parse date from key (format: habitId_year_month_day)
          final parts = key.split('_');
          if (parts.length >= 4) {
            try {
              final year = int.parse(parts[parts.length - 3]);
              final month = int.parse(parts[parts.length - 2]);
              final day = int.parse(
                parts[parts.length - 1].replaceAll('_points', ''),
              );

              final keyDate = DateTime(year, month, day);
              if (keyDate.isBefore(cutoffDate)) {
                keysToDelete.add(key);
              }
            } catch (e) {
              // Invalid key format, skip
            }
          }
        }
      }

      // Delete old keys
      for (final key in keysToDelete) {
        await box.delete(key);
      }
    } catch (e) {
      // Handle cleanup errors silently
    }
  }
}
