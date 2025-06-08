import 'package:flutter/material.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:task_day/models/task_model.dart';

/// خدمة الحسابات الفورية - للبيانات البسيطة التي لا تحتاج تخزين
/// هذه الحسابات سريعة ومباشرة ولا تؤثر على الأداء
class QuickStatsService {
  /// حساب عدد المهام المكتملة اليوم
  static int getTodayCompletedTasks(
    List<TaskModel> tasks, {
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return tasks.where((task) {
      if (!task.isDone) return false;

      // التحقق من أن المهمة ضمن الفترة الزمنية لليوم
      final taskStart = DateTime(
        task.startDate.year,
        task.startDate.month,
        task.startDate.day,
      );
      final taskEnd = DateTime(
        task.endDate.year,
        task.endDate.month,
        task.endDate.day,
      );

      return (taskStart.isBefore(today.add(const Duration(days: 1))) &&
          taskEnd.isAfter(today.subtract(const Duration(days: 1))));
    }).length;
  }

  /// حساب إجمالي المهام اليوم
  static int getTodayTotalTasks(
    List<TaskModel> tasks, {
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return tasks.where((task) {
      final taskStart = DateTime(
        task.startDate.year,
        task.startDate.month,
        task.startDate.day,
      );
      final taskEnd = DateTime(
        task.endDate.year,
        task.endDate.month,
        task.endDate.day,
      );

      return (taskStart.isBefore(today.add(const Duration(days: 1))) &&
          taskEnd.isAfter(today.subtract(const Duration(days: 1))));
    }).length;
  }

  /// حساب معدل إنجاز المهام اليوم
  static double getTodayTasksCompletionRate(
    List<TaskModel> tasks, {
    DateTime? referenceDate,
  }) {
    final total = getTodayTotalTasks(tasks, referenceDate: referenceDate);
    if (total == 0) return 0.0;

    final completed = getTodayCompletedTasks(
      tasks,
      referenceDate: referenceDate,
    );
    return completed / total;
  }

  /// حساب عدد العادات المكتملة اليوم
  static int getTodayCompletedHabits(
    List<HabitModel> habits, {
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return habits.where((habit) {
      // Check completion based on 'today' (which is derived from referenceDate or now)
      bool habitCompletedOnDate = false;
      if (!habit.isMeasurable) {
        // For non-measurable habits, check if it was marked done on the specific date.
        // This requires habit.completedDates to be accurate for the specific date.
        habitCompletedOnDate = habit.completedDates.any(
          (d) => DateTime(d.year, d.month, d.day).isAtSameMomentAs(today),
        );
      } else {
        // For measurable habits, this logic might need adjustment if currentValue represents accumulation up to 'now'
        // vs. value specifically on 'referenceDate'. Assuming currentValue is general or reset daily appropriately.
        // The original logic for measurable habits was:
        // if (habit.targetValue != null && habit.currentValue != null) {
        //   return habit.currentValue! >= habit.targetValue!;
        // }
        // This part might be complex if currentValue isn't snapshot daily.
        // For now, using a simplified check similar to non-measurable, if completed on the specific date.
        // This assumes `isDone` or `completedDates` accurately reflects status *on* that date.
        // A more robust solution for measurable habits on past dates might require storing historical currentValue.
        habitCompletedOnDate = habit.completedDates.any(
          (d) => DateTime(d.year, d.month, d.day).isAtSameMomentAs(today),
        );
        // If relying purely on currentValue for measurable habits for a *specific past date*:
        // This part of the logic is tricky. If currentValue is always "current right now", then using it
        // for a past referenceDate is incorrect. If habit.isDone or habit.completedDates is the source of truth
        // for completion on a specific day, then that should be used.
        // The original code for measurable habits was:
        // if (habit.targetValue != null && habit.currentValue != null) {
        //   return habit.currentValue! >= habit.targetValue!;
        // }
        // This implies currentValue is relevant. If it's meant to be for the referenceDate,
        // this logic is fine. If currentValue is always live, it's an issue for past dates.
        // Given the context, let's assume completedDates is the primary source for historical check.
      }
      return habitCompletedOnDate;
    }).length;
  }

  /// حساب معدل إنجاز العادات اليوم
  static double getTodayHabitsCompletionRate(
    List<HabitModel> habits, {
    DateTime? referenceDate,
  }) {
    if (habits.isEmpty) return 0.0;

    final completed = getTodayCompletedHabits(
      habits,
      referenceDate: referenceDate,
    );
    return completed / habits.length;
  }

  /// حساب أطول سلسلة عادة حالية (الحساب السريع للعرض)
  // This method calculates the streak *ending* on referenceDate or now.
  static int getCurrentLongestStreak(
    List<HabitModel> habits, {
    DateTime? referenceDate,
  }) {
    if (habits.isEmpty) return 0;

    int longestStreak = 0;

    for (final habit in habits) {
      final currentStreak = _calculateCurrentStreak(
        habit,
        referenceDate: referenceDate,
      );
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    }

    return longestStreak;
  }

  /// حساب السلسلة الحالية لعادة واحدة
  static int _calculateCurrentStreak(
    HabitModel habit, {
    DateTime? referenceDate,
  }) {
    if (habit.completedDates.isEmpty) return 0;

    final sortedDates =
        habit.completedDates.toList()
          ..sort((a, b) => b.compareTo(a)); // ترتيب تنازلي

    final DateTime effectiveReferenceDate = referenceDate ?? DateTime.now();
    DateTime currentDateToTest = DateTime(
      effectiveReferenceDate.year,
      effectiveReferenceDate.month,
      effectiveReferenceDate.day,
    );
    int streak = 0;

    // Iterate backwards from currentDateToTest
    for (final completedDateEntry in sortedDates) {
      final completedDay = DateTime(
        completedDateEntry.year,
        completedDateEntry.month,
        completedDateEntry.day,
      );
      if (completedDay.isAtSameMomentAs(currentDateToTest)) {
        streak++;
        currentDateToTest = currentDateToTest.subtract(const Duration(days: 1));
      } else if (completedDay.isBefore(currentDateToTest)) {
        // If there's a gap and the completed day is before the day we are testing, break.
        // This handles non-consecutive completions correctly.
        if (currentDateToTest.difference(completedDay).inDays > 0) break;
      }
      // If completedDay is after currentDateToTest, it means we are looking at future completions
      // relative to our backward counting, so we skip them until we find the one matching currentDateToTest or earlier.
    }
    return streak;
  }

  /// حساب بيانات سريعة للعادات مع السلاسل
  static List<HabitStreakInfo> getHabitsWithStreaks(
    List<HabitModel> habits, {
    DateTime? referenceDate,
  }) {
    return habits.map((habit) {
      final currentStreak = _calculateCurrentStreak(
        habit,
        referenceDate: referenceDate,
      );
      return HabitStreakInfo(
        id: habit.id,
        title: habit.title,
        icon: habit.icon,
        color: habit.color,
        currentStreak: currentStreak,
        isCompletedToday: _isHabitCompletedToday(
          habit,
          referenceDate: referenceDate,
        ),
        progress:
            habit
                .progress, // Assuming habit.progress is relevant for the reference date or general
      );
    }).toList();
  }

  /// التحقق من إكمال العادة اليوم
  static bool _isHabitCompletedToday(
    HabitModel habit, {
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if the habit was completed on 'today' (derived from referenceDate or now)
    return habit.completedDates.any(
      (d) => DateTime(d.year, d.month, d.day).isAtSameMomentAs(today),
    );
  }

  /// حساب نقاط الإنتاجية السريعة (0-100)
  static double calculateQuickProductivityScore(
    List<TaskModel> tasks,
    List<HabitModel> habits, {
    DateTime? referenceDate,
  }) {
    // Calculate total tasks for today
    final totalTasks = getTodayTotalTasks(tasks, referenceDate: referenceDate);
    final totalHabits = habits.length;
    final totalTasksAndHabits = totalTasks + totalHabits;
    final completedTasks = getTodayCompletedTasks(
      tasks,
      referenceDate: referenceDate,
    );
    final completedHabits = getTodayCompletedHabits(
      habits,
      referenceDate: referenceDate,
    );
    final completedTasksAndHabits = completedTasks + completedHabits;
    // Calculate completion rate
    final completionRate =
        totalTasksAndHabits > 0
            ? completedTasksAndHabits / totalTasksAndHabits
            : 0.0;

    // Return completion rate as a percentage
    return completionRate * 100;

    // final score = ((tasksRate + habitsRate) / 2) * 100;
    // return score.clamp(0.0, 100.0);
  }

  /// حساب إحصائيات سريعة شاملة
  static QuickStatsData calculateQuickStats(
    List<TaskModel> tasks,
    List<HabitModel> habits, {
    DateTime? referenceDate,
  }) {
    final DateTime calcDate = referenceDate ?? DateTime.now();
    return QuickStatsData(
      todayCompletedTasks: getTodayCompletedTasks(
        tasks,
        referenceDate: calcDate,
      ),
      todayTotalTasks: getTodayTotalTasks(tasks, referenceDate: calcDate),
      todayTasksRate: getTodayTasksCompletionRate(
        tasks,
        referenceDate: calcDate,
      ),
      todayCompletedHabits: getTodayCompletedHabits(
        habits,
        referenceDate: calcDate,
      ),
      todayTotalHabits: habits.length, // Total habits doesn't change with date
      todayHabitsRate: getTodayHabitsCompletionRate(
        habits,
        referenceDate: calcDate,
      ),
      currentLongestStreak: getCurrentLongestStreak(
        habits,
        referenceDate: calcDate,
      ), // Streak up to calcDate
      productivityScore: calculateQuickProductivityScore(
        tasks,
        habits,
        referenceDate: calcDate,
      ),
      habitsWithStreaks: getHabitsWithStreaks(habits, referenceDate: calcDate),
      calculatedAt:
          calcDate, // Reflects the date for which stats were calculated
    );
  }
}

/// نموذج بيانات للحسابات السريعة
class QuickStatsData {
  final int todayCompletedTasks;
  final int todayTotalTasks;
  final double todayTasksRate;
  final int todayCompletedHabits;
  final int todayTotalHabits;
  final double todayHabitsRate;
  final int currentLongestStreak;
  final double productivityScore;
  final List<HabitStreakInfo> habitsWithStreaks;
  final DateTime calculatedAt;

  QuickStatsData({
    required this.todayCompletedTasks,
    required this.todayTotalTasks,
    required this.todayTasksRate,
    required this.todayCompletedHabits,
    required this.todayTotalHabits,
    required this.todayHabitsRate,
    required this.currentLongestStreak,
    required this.productivityScore,
    required this.habitsWithStreaks,
    required this.calculatedAt,
  });
}

/// معلومات العادة مع السلسلة
class HabitStreakInfo {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final int currentStreak;
  final bool isCompletedToday;
  final double progress;

  HabitStreakInfo({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.currentStreak,
    required this.isCompletedToday,
    required this.progress,
  });
}
