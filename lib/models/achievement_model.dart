import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 12)
class AchievementModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int iconData;

  @HiveField(4)
  final int colorValue;

  @HiveField(5)
  final AchievementType type;

  @HiveField(6)
  final int targetValue;

  @HiveField(7)
  final int pointsReward;

  @HiveField(8)
  final AchievementRarity rarity;

  @HiveField(9)
  final bool isUnlocked;

  @HiveField(10)
  final DateTime? unlockedAt;

  @HiveField(11)
  final int currentProgress;

  @HiveField(12)
  final bool isHidden; // Hidden achievements revealed only when unlocked

  // Getters for converted properties
  IconData get icon => IconData(iconData, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required IconData icon,
    required Color color,
    required this.type,
    required this.targetValue,
    required this.pointsReward,
    required this.rarity,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
    this.isHidden = false,
  }) : iconData = icon.codePoint,
       colorValue = color.value;

  double get progressPercentage {
    if (targetValue <= 0) return 0.0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  bool get isCompleted => currentProgress >= targetValue;

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    AchievementType? type,
    int? targetValue,
    int? pointsReward,
    AchievementRarity? rarity,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
    bool? isHidden,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      pointsReward: pointsReward ?? this.pointsReward,
      rarity: rarity ?? this.rarity,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    iconData,
    colorValue,
    type,
    targetValue,
    pointsReward,
    rarity,
    isUnlocked,
    unlockedAt,
    currentProgress,
    isHidden,
  ];
}

@HiveType(typeId: 13)
enum AchievementType {
  @HiveField(0)
  habitsCompleted,
  @HiveField(1)
  streakDays,
  @HiveField(2)
  totalPoints,
  @HiveField(3)
  perfectWeeks,
  @HiveField(4)
  earlyBird, // Complete habits before specific time
  @HiveField(5)
  consistency, // Complete habits X days in a row
  @HiveField(6)
  variety, // Complete different types of habits
  @HiveField(7)
  dedication, // Use app for X days
  @HiveField(8)
  challenger, // Complete weekly challenges
  @HiveField(9)
  social, // Share achievements
}

@HiveType(typeId: 14)
enum AchievementRarity {
  @HiveField(0)
  common,
  @HiveField(1)
  rare,
  @HiveField(2)
  epic,
  @HiveField(3)
  legendary,
}
