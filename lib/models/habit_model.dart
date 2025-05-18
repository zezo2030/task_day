import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// This part file will be generated after running build_runner
part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int iconData; // Storing as int since IconData isn't directly serializable

  @HiveField(4)
  final int colorValue; // Storing as int since Color isn't directly serializable

  @HiveField(5)
  final bool isMeasurable;

  @HiveField(6)
  final int? targetValue; // For measurable habits

  @HiveField(7)
  final int? currentValue; // For measurable habits

  @HiveField(8)
  final bool? isDone; // For non-measurable habits

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final List<DateTime> completedDates;

  // Getters for converted properties
  IconData get icon => IconData(iconData, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  HabitModel({
    required this.id,
    required this.title,
    required this.description,
    required IconData icon,
    required Color color,
    required this.isMeasurable,
    this.targetValue,
    this.currentValue,
    this.isDone,
    required this.createdAt,
    this.completedDates = const [],
  }) : iconData = icon.codePoint,
       colorValue = color.value;

  double get progress {
    if (isMeasurable && targetValue != null && targetValue! > 0) {
      return (currentValue ?? 0) / targetValue!;
    } else if (!isMeasurable) {
      return isDone == true ? 1.0 : 0.0;
    }
    return 0.0;
  }

  HabitModel copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    bool? isMeasurable,
    int? targetValue,
    int? currentValue,
    bool? isDone,
    DateTime? createdAt,
    List<DateTime>? completedDates,
  }) => HabitModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    isMeasurable: isMeasurable ?? this.isMeasurable,
    targetValue: targetValue ?? this.targetValue,
    currentValue: currentValue ?? this.currentValue,
    isDone: isDone ?? this.isDone,
    createdAt: createdAt ?? this.createdAt,
    completedDates: completedDates ?? this.completedDates,
  );

  // Factory constructor to create HabitModel from IconData and Color objects
  factory HabitModel.fromRaw({
    required String id,
    required String title,
    required String description,
    required int iconData,
    required int colorValue,
    required bool isMeasurable,
    int? targetValue,
    int? currentValue,
    bool? isDone,
    required DateTime createdAt,
    List<DateTime> completedDates = const [],
  }) {
    return HabitModel(
      id: id,
      title: title,
      description: description,
      icon: IconData(iconData, fontFamily: 'MaterialIcons'),
      color: Color(colorValue),
      isMeasurable: isMeasurable,
      targetValue: targetValue,
      currentValue: currentValue,
      isDone: isDone,
      createdAt: createdAt,
      completedDates: completedDates,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    iconData,
    colorValue,
    isMeasurable,
    targetValue,
    currentValue,
    isDone,
    createdAt,
    completedDates,
  ];
}
