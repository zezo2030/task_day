import 'package:flutter/material.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:task_day/models/task_model.dart';

/// خدمة الحسابات الفورية - للبيانات البسيطة التي لا تحتاج تخزين
/// هذه الحسابات سريعة ومباشرة ولا تؤثر على الأداء
class QuickStatsService {
  /// حساب عدد المهام المكتملة اليوم
  static int getTodayCompletedTasks(List<TaskModel> tasks) {
    final now = DateTime.now();
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
  static int getTodayTotalTasks(List<TaskModel> tasks) {
    final now = DateTime.now();
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
  static double getTodayTasksCompletionRate(List<TaskModel> tasks) {
    final total = getTodayTotalTasks(tasks);
    if (total == 0) return 0.0;

    final completed = getTodayCompletedTasks(tasks);
    return completed / total;
  }

  /// حساب عدد العادات المكتملة اليوم
  static int getTodayCompletedHabits(List<HabitModel> habits) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return habits.where((habit) {
      // للعادات غير القابلة للقياس
      if (!habit.isMeasurable) {
        return habit.isDone == true;
      }

      // للعادات القابلة للقياس
      if (habit.targetValue != null && habit.currentValue != null) {
        return habit.currentValue! >= habit.targetValue!;
      }

      return false;
    }).length;
  }

  /// حساب معدل إنجاز العادات اليوم
  static double getTodayHabitsCompletionRate(List<HabitModel> habits) {
    if (habits.isEmpty) return 0.0;

    final completed = getTodayCompletedHabits(habits);
    return completed / habits.length;
  }

  /// حساب أطول سلسلة عادة حالية (الحساب السريع للعرض)
  static int getCurrentLongestStreak(List<HabitModel> habits) {
    if (habits.isEmpty) return 0;

    int longestStreak = 0;

    for (final habit in habits) {
      final currentStreak = _calculateCurrentStreak(habit);
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    }

    return longestStreak;
  }

  /// حساب السلسلة الحالية لعادة واحدة
  static int _calculateCurrentStreak(HabitModel habit) {
    if (habit.completedDates.isEmpty) return 0;

    final sortedDates =
        habit.completedDates.toList()
          ..sort((a, b) => b.compareTo(a)); // ترتيب تنازلي

    final now = DateTime.now();
    DateTime currentDate = DateTime(now.year, now.month, now.day);
    int streak = 0;

    // التحقق من اليوم الحالي أولاً
    bool foundToday = false;
    for (final completedDate in sortedDates) {
      final completedDay = DateTime(
        completedDate.year,
        completedDate.month,
        completedDate.day,
      );

      if (completedDay.isAtSameMomentAs(currentDate)) {
        streak++;
        foundToday = true;
        currentDate = currentDate.subtract(const Duration(days: 1));
        break;
      }
    }

    // إذا لم نجد اليوم الحالي، نتحقق من الأمس
    if (!foundToday) {
      currentDate = currentDate.subtract(const Duration(days: 1));
      for (final completedDate in sortedDates) {
        final completedDay = DateTime(
          completedDate.year,
          completedDate.month,
          completedDate.day,
        );

        if (completedDay.isAtSameMomentAs(currentDate)) {
          streak++;
          currentDate = currentDate.subtract(const Duration(days: 1));
          break;
        }
      }
    }

    // متابعة حساب باقي السلسلة
    for (final completedDate in sortedDates) {
      final completedDay = DateTime(
        completedDate.year,
        completedDate.month,
        completedDate.day,
      );

      if (completedDay.isAtSameMomentAs(currentDate)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (completedDay.isBefore(currentDate)) {
        // فجوة في السلسلة
        break;
      }
    }

    return streak;
  }

  /// حساب بيانات سريعة للعادات مع السلاسل
  static List<HabitStreakInfo> getHabitsWithStreaks(List<HabitModel> habits) {
    return habits.map((habit) {
      final currentStreak = _calculateCurrentStreak(habit);
      return HabitStreakInfo(
        id: habit.id,
        title: habit.title,
        icon: habit.icon,
        color: habit.color,
        currentStreak: currentStreak,
        isCompletedToday: _isHabitCompletedToday(habit),
        progress: habit.progress,
      );
    }).toList();
  }

  /// التحقق من إكمال العادة اليوم
  static bool _isHabitCompletedToday(HabitModel habit) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // للعادات غير القابلة للقياس
    if (!habit.isMeasurable) {
      return habit.isDone == true;
    }

    // للعادات القابلة للقياس
    if (habit.targetValue != null && habit.currentValue != null) {
      return habit.currentValue! >= habit.targetValue!;
    }

    return false;
  }

  /// حساب نقاط الإنتاجية السريعة (0-100)
  static double calculateQuickProductivityScore(
    List<TaskModel> tasks,
    List<HabitModel> habits,
  ) {
    final tasksRate = getTodayTasksCompletionRate(tasks);
    final habitsRate = getTodayHabitsCompletionRate(habits);

    // وزن المهام 60% والعادات 40%
    final score = (tasksRate * 0.6 + habitsRate * 0.4) * 100;
    return score.clamp(0.0, 100.0);
  }

  /// حساب إحصائيات سريعة شاملة
  static QuickStatsData calculateQuickStats(
    List<TaskModel> tasks,
    List<HabitModel> habits,
  ) {
    return QuickStatsData(
      todayCompletedTasks: getTodayCompletedTasks(tasks),
      todayTotalTasks: getTodayTotalTasks(tasks),
      todayTasksRate: getTodayTasksCompletionRate(tasks),
      todayCompletedHabits: getTodayCompletedHabits(habits),
      todayTotalHabits: habits.length,
      todayHabitsRate: getTodayHabitsCompletionRate(habits),
      currentLongestStreak: getCurrentLongestStreak(habits),
      productivityScore: calculateQuickProductivityScore(tasks, habits),
      habitsWithStreaks: getHabitsWithStreaks(habits),
      calculatedAt: DateTime.now(),
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
