import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_day/models/daily_routine_model.dart';

part 'weekly_review_model.g.dart';

@HiveType(typeId: 31)
class WeeklyReviewModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime weekStartDate;

  @HiveField(2)
  final DateTime weekEndDate;

  @HiveField(3)
  final int totalRoutines;

  @HiveField(4)
  final int completedRoutines;

  @HiveField(5)
  final double completionRate;

  @HiveField(6)
  final Map<String, int> dailyCompletions;

  @HiveField(7)
  final List<String> topPerformingRoutines;

  @HiveField(8)
  final List<String> needsImprovementRoutines;

  @HiveField(9)
  final Map<String, double> routineCompletionRates;

  @HiveField(10)
  final String bestDay;

  @HiveField(11)
  final String worstDay;

  @HiveField(12)
  final int totalStreaks;

  @HiveField(13)
  final DateTime createdAt;

  WeeklyReviewModel({
    required this.id,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.totalRoutines,
    required this.completedRoutines,
    required this.completionRate,
    required this.dailyCompletions,
    required this.topPerformingRoutines,
    required this.needsImprovementRoutines,
    required this.routineCompletionRates,
    required this.bestDay,
    required this.worstDay,
    required this.totalStreaks,
    required this.createdAt,
  });

  // Helper method to get day names in English
  static String getDayNameInEnglish(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }
}

// Model for individual routine performance in the week
class RoutineWeeklyPerformance {
  final String routineId;
  final String routineName;
  final int totalOccurrences;
  final int completedOccurrences;
  final double completionRate;
  final List<bool> dailyCompletions; // 7 days
  final int currentStreak;
  final int longestStreak;

  RoutineWeeklyPerformance({
    required this.routineId,
    required this.routineName,
    required this.totalOccurrences,
    required this.completedOccurrences,
    required this.completionRate,
    required this.dailyCompletions,
    required this.currentStreak,
    required this.longestStreak,
  });
}

// Model for daily summary
class DaySummary {
  final DateTime date;
  final String dayName;
  final int totalRoutines;
  final int completedRoutines;
  final double completionRate;
  final List<DailyRoutineModel> routines;

  DaySummary({
    required this.date,
    required this.dayName,
    required this.totalRoutines,
    required this.completedRoutines,
    required this.completionRate,
    required this.routines,
  });
}
