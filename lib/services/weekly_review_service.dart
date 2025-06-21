import 'dart:math' as math;
import 'package:task_day/models/daily_routine_model.dart';
import 'package:task_day/models/weekly_review_model.dart';
import 'package:task_day/services/hive_service.dart';
import 'package:uuid/uuid.dart';

class WeeklyReviewService {
  static const Uuid _uuid = Uuid();

  /// Generate weekly review for a specific week
  static Future<WeeklyReviewModel> generateWeeklyReview(
    DateTime weekStart,
  ) async {
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Get all routines for the week
    final weekRoutines = await _getRoutinesForWeek(weekStart, weekEnd);

    // Calculate overall statistics
    final totalRoutines = weekRoutines.length;
    final completedRoutines = weekRoutines.where((r) => r.isCompleted).length;
    final completionRate =
        totalRoutines > 0 ? (completedRoutines / totalRoutines) * 100 : 0.0;

    // Calculate daily completions
    final dailyCompletions = <String, int>{};
    final daySummaries = <DaySummary>[];

    for (int i = 0; i < 7; i++) {
      final currentDate = weekStart.add(Duration(days: i));
      final dayName = WeeklyReviewModel.getDayNameInEnglish(currentDate);
      final dayRoutines =
          weekRoutines
              .where((r) => _isSameDay(r.dateTime, currentDate))
              .toList();

      final dayCompleted = dayRoutines.where((r) => r.isCompleted).length;
      final dayTotal = dayRoutines.length;
      final dayCompletionRate =
          dayTotal > 0 ? (dayCompleted / dayTotal) * 100 : 0.0;

      dailyCompletions[dayName] = dayCompleted;
      daySummaries.add(
        DaySummary(
          date: currentDate,
          dayName: dayName,
          totalRoutines: dayTotal,
          completedRoutines: dayCompleted,
          completionRate: dayCompletionRate,
          routines: dayRoutines,
        ),
      );
    }

    // Find best and worst days
    final bestDay = _getBestDay(daySummaries);
    final worstDay = _getWorstDay(daySummaries);

    // Calculate routine-specific performance
    final routinePerformances = _calculateRoutinePerformances(
      weekRoutines,
      weekStart,
    );

    // Get top performing and needs improvement routines
    final topPerforming = _getTopPerformingRoutines(routinePerformances);
    final needsImprovement = _getNeedsImprovementRoutines(routinePerformances);

    // Calculate routine completion rates
    final routineCompletionRates = <String, double>{};
    for (final performance in routinePerformances) {
      routineCompletionRates[performance.routineName] =
          performance.completionRate;
    }

    // Calculate total streaks
    final totalStreaks = routinePerformances.fold<int>(
      0,
      (sum, performance) => sum + performance.currentStreak,
    );

    return WeeklyReviewModel(
      id: _uuid.v4(),
      weekStartDate: weekStart,
      weekEndDate: weekEnd,
      totalRoutines: totalRoutines,
      completedRoutines: completedRoutines,
      completionRate: completionRate,
      dailyCompletions: dailyCompletions,
      topPerformingRoutines: topPerforming,
      needsImprovementRoutines: needsImprovement,
      routineCompletionRates: routineCompletionRates,
      bestDay: bestDay,
      worstDay: worstDay,
      totalStreaks: totalStreaks,
      createdAt: DateTime.now(),
    );
  }

  /// Get all routines for a specific week
  static Future<List<DailyRoutineModel>> _getRoutinesForWeek(
    DateTime weekStart,
    DateTime weekEnd,
  ) async {
    final allRoutines = await HiveService.getAllDailyRoutines();

    return allRoutines.where((routine) {
      return routine.dateTime.isAfter(
            weekStart.subtract(const Duration(days: 1)),
          ) &&
          routine.dateTime.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
  }

  /// Check if two dates are the same day
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get the best performing day
  static String _getBestDay(List<DaySummary> daySummaries) {
    if (daySummaries.isEmpty) return 'None';

    daySummaries.sort((a, b) => b.completionRate.compareTo(a.completionRate));
    return daySummaries.first.dayName;
  }

  /// Get the worst performing day
  static String _getWorstDay(List<DaySummary> daySummaries) {
    if (daySummaries.isEmpty) return 'None';

    final nonEmptyDays =
        daySummaries.where((day) => day.totalRoutines > 0).toList();
    if (nonEmptyDays.isEmpty) return 'None';

    nonEmptyDays.sort((a, b) => a.completionRate.compareTo(b.completionRate));
    return nonEmptyDays.first.dayName;
  }

  /// Calculate performance for each routine
  static List<RoutineWeeklyPerformance> _calculateRoutinePerformances(
    List<DailyRoutineModel> weekRoutines,
    DateTime weekStart,
  ) {
    final routineGroups = <String, List<DailyRoutineModel>>{};

    // Group routines by name
    for (final routine in weekRoutines) {
      if (!routineGroups.containsKey(routine.name)) {
        routineGroups[routine.name] = [];
      }
      routineGroups[routine.name]!.add(routine);
    }

    final performances = <RoutineWeeklyPerformance>[];

    for (final entry in routineGroups.entries) {
      final routineName = entry.key;
      final routines = entry.value;

      final totalOccurrences = routines.length;
      final completedOccurrences = routines.where((r) => r.isCompleted).length;
      final completionRate =
          totalOccurrences > 0
              ? (completedOccurrences / totalOccurrences) * 100
              : 0.0;

      // Calculate daily completions for the week
      final dailyCompletions = <bool>[];
      for (int i = 0; i < 7; i++) {
        final currentDate = weekStart.add(Duration(days: i));
        final dayRoutines =
            routines.where((r) => _isSameDay(r.dateTime, currentDate)).toList();

        final hasCompleted = dayRoutines.any((r) => r.isCompleted);
        dailyCompletions.add(hasCompleted);
      }

      // Calculate streaks
      final currentStreak = _calculateCurrentStreak(dailyCompletions);
      final longestStreak = _calculateLongestStreak(dailyCompletions);

      performances.add(
        RoutineWeeklyPerformance(
          routineId: routines.first.id,
          routineName: routineName,
          totalOccurrences: totalOccurrences,
          completedOccurrences: completedOccurrences,
          completionRate: completionRate,
          dailyCompletions: dailyCompletions,
          currentStreak: currentStreak,
          longestStreak: longestStreak,
        ),
      );
    }

    return performances;
  }

  /// Calculate current streak from daily completions
  static int _calculateCurrentStreak(List<bool> dailyCompletions) {
    int streak = 0;
    for (int i = dailyCompletions.length - 1; i >= 0; i--) {
      if (dailyCompletions[i]) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Calculate longest streak from daily completions
  static int _calculateLongestStreak(List<bool> dailyCompletions) {
    int longestStreak = 0;
    int currentStreak = 0;

    for (final completed in dailyCompletions) {
      if (completed) {
        currentStreak++;
        longestStreak = math.max(longestStreak, currentStreak);
      } else {
        currentStreak = 0;
      }
    }

    return longestStreak;
  }

  /// Get top performing routines (completion rate >= 80%)
  static List<String> _getTopPerformingRoutines(
    List<RoutineWeeklyPerformance> performances,
  ) {
    return performances
        .where((p) => p.completionRate >= 80.0)
        .map((p) => p.routineName)
        .toList();
  }

  /// Get routines that need improvement (completion rate < 50%)
  static List<String> _getNeedsImprovementRoutines(
    List<RoutineWeeklyPerformance> performances,
  ) {
    return performances
        .where((p) => p.completionRate < 50.0)
        .map((p) => p.routineName)
        .toList();
  }

  /// Get week start date (Monday) for any given date
  static DateTime getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  /// Get current week start date
  static DateTime getCurrentWeekStart() {
    return getWeekStart(DateTime.now());
  }

  /// Get previous week start date
  static DateTime getPreviousWeekStart() {
    final currentWeekStart = getCurrentWeekStart();
    return currentWeekStart.subtract(const Duration(days: 7));
  }

  /// Get suggestions based on weekly performance
  static List<String> generateSuggestions(WeeklyReviewModel review) {
    final suggestions = <String>[];

    // Overall performance suggestions
    if (review.completionRate >= 80) {
      suggestions.add('🎉 Excellent performance! Keep up this amazing level');
    } else if (review.completionRate >= 60) {
      suggestions.add('👍 Good performance! You can improve it further');
    } else {
      suggestions.add(
        '💪 There\'s room for improvement, start with basic routines',
      );
    }

    // Best day encouragement
    if (review.bestDay != 'None') {
      suggestions.add(
        '⭐ ${review.bestDay} was your best day, try to apply the same pattern',
      );
    }

    // Improvement areas
    if (review.needsImprovementRoutines.isNotEmpty) {
      suggestions.add(
        '🎯 Focus on improving: ${review.needsImprovementRoutines.join(', ')}',
      );
    }

    // Streak motivation
    if (review.totalStreaks > 0) {
      suggestions.add(
        '🔥 You have ${review.totalStreaks} success streaks, keep them going!',
      );
    }

    // Weekly consistency
    final consistentDays =
        review.dailyCompletions.values.where((v) => v > 0).length;
    if (consistentDays < 5) {
      suggestions.add('📅 Try to be more consistent throughout the week');
    }

    return suggestions;
  }
}
