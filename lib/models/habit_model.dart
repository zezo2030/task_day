import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum HabitType { measurable, nonMeasurable }

class HabitModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final HabitType type;
  final int? targetValue; // For measurable habits
  final int? currentValue; // For measurable habits
  final bool? isDone; // For non-measurable habits
  final DateTime createdAt;
  final List<DateTime> completedDates;

  const HabitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    this.targetValue,
    this.currentValue,
    this.isDone,
    required this.createdAt,
    this.completedDates = const [],
  });

  double get progress {
    if (type == HabitType.measurable &&
        targetValue != null &&
        targetValue! > 0) {
      return (currentValue ?? 0) / targetValue!;
    } else if (type == HabitType.nonMeasurable) {
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
    HabitType? type,
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
    type: type ?? this.type,
    targetValue: targetValue ?? this.targetValue,
    currentValue: currentValue ?? this.currentValue,
    isDone: isDone ?? this.isDone,
    createdAt: createdAt ?? this.createdAt,
    completedDates: completedDates ?? this.completedDates,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    icon,
    color,
    type,
    targetValue,
    currentValue,
    isDone,
    createdAt,
    completedDates,
  ];
}
