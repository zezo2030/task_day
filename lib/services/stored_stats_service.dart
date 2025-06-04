import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:task_day/models/daily_stats_model.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/services/hive_service.dart';
import 'package:task_day/services/quick_stats_service.dart';

/// خدمة الإحصائيات المخزنة - للحسابات المعقدة والبيانات التاريخية
class StoredStatsService {
  static const String dailyStatsBoxName = 'daily_stats';
  static const String periodStatsBoxName = 'period_stats';

  /// إنشاء وفتح صناديق التخزين
  static Future<void> init() async {
    try {
      // تسجيل محولات البيانات
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(DailyStatsModelAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(PeriodStatsModelAdapter());
      }

      // فتح الصناديق
      await Hive.openBox<DailyStatsModel>(dailyStatsBoxName);
      await Hive.openBox<PeriodStatsModel>(periodStatsBoxName);

      if (kDebugMode) {
        print('StoredStatsService initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing StoredStatsService: $e');
      }
    }
  }

  /// الحصول على صندوق الإحصائيات اليومية
  static Box<DailyStatsModel> getDailyStatsBox() {
    return Hive.box<DailyStatsModel>(dailyStatsBoxName);
  }

  /// الحصول على صندوق إحصائيات الفترات
  static Box<PeriodStatsModel> getPeriodStatsBox() {
    return Hive.box<PeriodStatsModel>(periodStatsBoxName);
  }

  /// تنسيق معرف التاريخ
  static String formatDateId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Calculate streak for a habit up to a specific reference date.
  static int _calculateStreakOnDate(HabitModel habit, DateTime referenceDate) {
    if (habit.completedDates.isEmpty) return 0;

    // Normalize completed dates to DateTime objects with only year, month, day.
    final Set<DateTime> completedDays =
        habit.completedDates
            .map((d) => DateTime(d.year, d.month, d.day))
            .toSet();

    // Normalize referenceDate to just the date part.
    DateTime dayToTest = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    int currentStreak = 0;

    // Iterate backwards from referenceDate, counting consecutive completed days.
    while (completedDays.contains(dayToTest)) {
      currentStreak++;
      dayToTest = dayToTest.subtract(const Duration(days: 1));
    }
    return currentStreak;
  }

  /// تحديث الإحصائيات اليومية إذا احتجنا لذلك
  static Future<void> updateDailyStatsIfNeeded() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayId = formatDateId(today);

      final box = getDailyStatsBox();
      final existingStats = box.get(todayId);

      // التحقق من وجود إحصائيات اليوم
      if (existingStats == null) {
        await _calculateAndStoreDailyStats(today);
      } else {
        // التحقق من آخر تحديث (كل 30 دقيقة)
        final timeSinceUpdate = now.difference(existingStats.updatedAt);
        if (timeSinceUpdate.inMinutes > 30) {
          await _calculateAndStoreDailyStats(today);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating daily stats: $e');
      }
    }
  }

  /// حساب وحفظ الإحصائيات اليومية
  static Future<void> _calculateAndStoreDailyStats(DateTime date) async {
    try {
      final dateId = formatDateId(date);
      final box = getDailyStatsBox();

      // جلب البيانات الأساسية
      final tasks = await HiveService.getAllTasks();
      final habits = await HiveService.getAllHabits();

      // حساب الإحصائيات السريعة
      final quickStats = QuickStatsService.calculateQuickStats(
        tasks,
        habits,
        referenceDate: date,
      );

      // حساب السلاسل التفصيلية (المعقدة) - now using referenceDate
      final habitStreaks = _calculateDetailedHabitStreaks(habits, date);

      // حساب النقاط التفصيلية
      final productivityScore = calculateDetailedProductivityScore(
        tasks,
        habits,
        date,
      );

      // إنشاء نموذج الإحصائيات اليومية
      final dailyStats = DailyStatsModel(
        id: dateId,
        date: date,
        totalTasks: quickStats.todayTotalTasks,
        completedTasks: quickStats.todayCompletedTasks,
        tasksCompletionRate: quickStats.todayTasksRate,
        totalHabits: quickStats.todayTotalHabits,
        completedHabits: quickStats.todayCompletedHabits,
        habitsCompletionRate: quickStats.todayHabitsRate,
        habitStreaks: habitStreaks,
        longestStreak:
            habitStreaks.values.isEmpty
                ? 0
                : habitStreaks.values.reduce((a, b) => a > b ? a : b),
        productivityScore: productivityScore,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // حفظ الإحصائيات
      await box.put(dateId, dailyStats);

      if (kDebugMode) {
        print('Daily stats calculated and stored for $dateId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating daily stats: $e');
      }
    }
  }

  /// حساب السلاسل التفصيلية للعادات
  static Map<String, int> _calculateDetailedHabitStreaks(
    List<HabitModel> habits,
    DateTime referenceDate,
  ) {
    final Map<String, int> streaks = {};

    for (final habit in habits) {
      final streak = _calculateStreakOnDate(habit, referenceDate);
      streaks[habit.id] = streak;
    }

    return streaks;
  }

  /// حساب السلسلة التاريخية للعادة
  static Future<int> _calculateHabitHistoricalStreak(HabitModel habit) async {
    if (habit.completedDates.isEmpty) return 0;

    final sortedDates =
        habit.completedDates.toList()..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    DateTime currentDate = DateTime(now.year, now.month, now.day);
    int streak = 0;

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
        if (currentDate.difference(completedDay).inDays <= 1) {
          streak++;
          currentDate = completedDay.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    return streak;
  }

  /// حساب نقاط الإنتاجية التفصيلية
  static double calculateDetailedProductivityScore(
    List<TaskModel> tasks,
    List<HabitModel> habits,
    DateTime date,
  ) {
    double score = 0.0;

    // نقاط المهام (60% من المجموع)
    final taskScore = _calculateTasksScore(tasks, date);
    score += taskScore * 0.6;

    // نقاط العادات (40% من المجموع)
    final habitScore = _calculateHabitsScore(habits, date);
    score += habitScore * 0.4;

    return score.clamp(0.0, 100.0);
  }

  /// حساب نقاط المهام
  static double _calculateTasksScore(List<TaskModel> tasks, DateTime date) {
    if (tasks.isEmpty) return 0.0;

    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final dayTasks =
        tasks.where((task) {
          return task.startDate.isBefore(dayEnd) &&
              task.endDate.isAfter(dayStart);
        }).toList();

    if (dayTasks.isEmpty) return 0.0;

    double totalScore = 0.0;
    for (final task in dayTasks) {
      double taskScore = 0.0;

      if (task.isDone) {
        taskScore += 60;

        switch (task.priority) {
          case 2:
            taskScore += 30;
            break;
          case 1:
            taskScore += 20;
            break;
          case 0:
            taskScore += 10;
            break;
        }

        if (task.subTasks.isNotEmpty) {
          final completedSubTasks =
              task.subTasks.where((sub) => sub.isDone).length;
          final subTasksRate = completedSubTasks / task.subTasks.length;
          taskScore += subTasksRate * 10;
        }
      }

      totalScore += taskScore;
    }

    return totalScore / dayTasks.length;
  }

  /// حساب نقاط العادات
  static double _calculateHabitsScore(List<HabitModel> habits, DateTime date) {
    if (habits.isEmpty) return 0.0;

    double totalScore = 0.0;
    for (final habit in habits) {
      double habitScore = 0.0;

      final dayStart = DateTime(date.year, date.month, date.day);
      final isCompletedToday = habit.completedDates.any((completedDate) {
        final completedDay = DateTime(
          completedDate.year,
          completedDate.month,
          completedDate.day,
        );
        return completedDay.isAtSameMomentAs(dayStart);
      });

      if (isCompletedToday) {
        habitScore += 70;

        final streak = _calculateStreakOnDate(habit, date);
        if (streak >= 7) habitScore += 15;
        if (streak >= 30) habitScore += 15;
      }

      if (habit.isMeasurable && habit.targetValue != null) {
        final progress = habit.progress;
        habitScore += progress * 30;
      }

      totalScore += habitScore;
    }

    return totalScore / habits.length;
  }

  /// Helper to ensure daily stats exist for a given period.
  static Future<void> _ensureDailyStatsForPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final dailyBox = getDailyStatsBox();
    DateTime currentDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedEndDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );

    while (!currentDate.isAfter(normalizedEndDate)) {
      final dateId = formatDateId(currentDate);
      if (dailyBox.get(dateId) == null) {
        // If stats for this day don't exist, calculate and store them.
        // This ensures that when period progress is calculated, all days have data.
        await _calculateAndStoreDailyStats(currentDate);
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }

  /// حساب التقدم الأسبوعي المخزن
  static Future<double> calculateWeeklyProgress() async {
    try {
      final now = DateTime.now();
      // Ensure Sunday is 0, Saturday is 6 for weekday calculation if needed, Dart DateTime.weekday is 1 (Mon) to 7 (Sun)
      final startOfWeek = DateTime(now.year, now.month, now.day).subtract(
        Duration(days: now.weekday - 1),
      ); // Assuming Monday is the start
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      // Ensure daily stats for the entire week are calculated first
      await _ensureDailyStatsForPeriod(startOfWeek, endOfWeek);

      return await _calculatePeriodProgressFromDailyStats(
        startOfWeek,
        endOfWeek,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating weekly progress: $e');
      }
      return 0.0;
    }
  }

  /// حساب التقدم الشهري المخزن
  static Future<double> calculateMonthlyProgress() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(
        now.year,
        now.month + 1,
        0,
      ); // Day 0 of next month gives last day of current month

      // Ensure daily stats for the entire month are calculated first
      await _ensureDailyStatsForPeriod(startOfMonth, endOfMonth);

      return await _calculatePeriodProgressFromDailyStats(
        startOfMonth,
        endOfMonth,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating monthly progress: $e');
      }
      return 0.0;
    }
  }

  /// حساب تقدم الفترة من الإحصائيات اليومية
  static Future<double> _calculatePeriodProgressFromDailyStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final dailyBox = getDailyStatsBox();
    double totalScore = 0.0;
    int daysCount = 0;

    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
      final dateId = formatDateId(currentDate);
      final dayStats = dailyBox.get(dateId);

      if (dayStats != null) {
        totalScore += dayStats.productivityScore;
        daysCount++;
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return daysCount > 0 ? totalScore / daysCount / 100 : 0.0;
  }

  /// الحصول على الإحصائيات اليومية
  static DailyStatsModel? getDailyStats(DateTime date) {
    final dateId = formatDateId(date);
    return getDailyStatsBox().get(dateId);
  }

  /// تنظيف البيانات القديمة
  static Future<void> cleanOldData() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
      final dailyBox = getDailyStatsBox();

      final keysToDelete = <String>[];
      for (final key in dailyBox.keys) {
        final dateId = key as String;
        final dateParts = dateId.split('-');
        if (dateParts.length == 3) {
          final date = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          );
          if (date.isBefore(cutoffDate)) {
            keysToDelete.add(key);
          }
        }
      }

      for (final key in keysToDelete) {
        await dailyBox.delete(key);
      }

      if (kDebugMode) {
        print('Cleaned ${keysToDelete.length} old daily stats records');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning old data: $e');
      }
    }
  }
}
