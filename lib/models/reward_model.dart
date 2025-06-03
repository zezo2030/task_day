import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'reward_model.g.dart';

@HiveType(typeId: 15)
class RewardModel extends HiveObject with EquatableMixin {
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
  final RewardType type;

  @HiveField(6)
  final int costInPoints;

  @HiveField(7)
  final RewardRarity rarity;

  @HiveField(8)
  final bool isAvailable;

  @HiveField(9)
  final bool isClaimed;

  @HiveField(10)
  final DateTime? claimedAt;

  @HiveField(11)
  final int? requiredLevel;

  @HiveField(12)
  final String? specialCondition; // Special conditions for unlocking

  @HiveField(13)
  final DateTime? expiryDate; // For limited-time rewards

  // Getters for converted properties
  IconData get icon => IconData(iconData, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required IconData icon,
    required Color color,
    required this.type,
    required this.costInPoints,
    required this.rarity,
    this.isAvailable = true,
    this.isClaimed = false,
    this.claimedAt,
    this.requiredLevel,
    this.specialCondition,
    this.expiryDate,
  }) : iconData = icon.codePoint,
       colorValue = color.value;

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool get canBeClaimed {
    return isAvailable && !isClaimed && !isExpired;
  }

  RewardModel copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    RewardType? type,
    int? costInPoints,
    RewardRarity? rarity,
    bool? isAvailable,
    bool? isClaimed,
    DateTime? claimedAt,
    int? requiredLevel,
    String? specialCondition,
    DateTime? expiryDate,
  }) {
    return RewardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      costInPoints: costInPoints ?? this.costInPoints,
      rarity: rarity ?? this.rarity,
      isAvailable: isAvailable ?? this.isAvailable,
      isClaimed: isClaimed ?? this.isClaimed,
      claimedAt: claimedAt ?? this.claimedAt,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      specialCondition: specialCondition ?? this.specialCondition,
      expiryDate: expiryDate ?? this.expiryDate,
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
    costInPoints,
    rarity,
    isAvailable,
    isClaimed,
    claimedAt,
    requiredLevel,
    specialCondition,
    expiryDate,
  ];
}

@HiveType(typeId: 16)
enum RewardType {
  @HiveField(0)
  theme, // App themes
  @HiveField(1)
  avatar, // Profile avatars
  @HiveField(2)
  badge, // Special badges
  @HiveField(3)
  title, // Profile titles
  @HiveField(4)
  feature, // App features unlock
  @HiveField(5)
  customization, // Custom colors, icons, etc.
  @HiveField(6)
  special, // Special rewards
  @HiveField(7)
  motivation, // Motivational content
}

@HiveType(typeId: 17)
enum RewardRarity {
  @HiveField(0)
  common,
  @HiveField(1)
  uncommon,
  @HiveField(2)
  rare,
  @HiveField(3)
  epic,
  @HiveField(4)
  legendary,
}
