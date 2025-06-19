import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'daily_routine_model.g.dart';

@HiveType(typeId: 30)
class DailyRoutineModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final TimeOfDay startTime;
  @HiveField(3)
  final TimeOfDay endTime;
  @HiveField(4)
  final bool isCompleted;
  @HiveField(5)
  final int counterReperter;
  @HiveField(6)
  final DateTime dateTime;
  @HiveField(7)
  final bool isRecurringDaily;

  DailyRoutineModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.isCompleted,
    required this.counterReperter,
    required this.dateTime,
    this.isRecurringDaily = false,
  });

  // Helper methods for TimeOfDay conversion
  static int timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  static TimeOfDay minutesToTimeOfDay(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }

  // Convert TimeOfDay to String (alternative approach)
  static String timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static TimeOfDay stringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
