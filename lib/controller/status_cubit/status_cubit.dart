import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_day/models/daily_stats_model.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/services/hive_service.dart';
import 'package:task_day/services/quick_stats_service.dart';
import 'package:task_day/services/stored_stats_service.dart';

part 'status_state.dart';

/// StatusCubit مع النهج الهجين:
/// - البيانات البسيطة: حساب فوري
/// - البيانات المعقدة: حساب مخزن
class StatusCubit extends Cubit<StatusState> {
  StatusCubit() : super(StatusInitial());

  /// تحميل بيانات الحالة باستخدام النهج الهجين
  Future<void> loadStatusData() async {
    emit(StatusLoading());

    try {
      // الخطوة 1: تحديث الإحصائيات المخزنة إذا احتجنا لذلك
      await StoredStatsService.updateDailyStatsIfNeeded();

      // الخطوة 2: جلب البيانات الأساسية للحسابات الفورية
      final tasks = await HiveService.getAllTasks();
      final habits = await HiveService.getAllHabits();

      // الخطوة 3: حساب البيانات البسيطة فورياً
      final quickStats = QuickStatsService.calculateQuickStats(tasks, habits);

      // الخطوة 4: جلب البيانات المعقدة المخزنة
      final weeklyProgress = await StoredStatsService.calculateWeeklyProgress();
      final monthlyProgress =
          await StoredStatsService.calculateMonthlyProgress();

      // الخطوة 5: حساب البيانات المدمجة
      final totalItems =
          quickStats.todayTotalTasks + quickStats.todayTotalHabits;
      final completedItems =
          quickStats.todayCompletedTasks + quickStats.todayCompletedHabits;
      final combinedRate = totalItems > 0 ? (completedItems / totalItems) : 0.0;

      // الخطوة 6: حساب معدلات الأسبوع
      final weeklyRates = await getWeeklyCompletionRates();

      // الخطوة 7: دمج البيانات وإرسالها
      final statusData = StatusData(
        // البيانات الفورية
        todayCompletedTasks: quickStats.todayCompletedTasks,
        todayTotalTasks: quickStats.todayTotalTasks,
        todayTasksCompletionRate: quickStats.todayTasksRate,
        todayCompletedHabits: quickStats.todayCompletedHabits,
        todayTotalHabits: quickStats.todayTotalHabits,
        todayHabitsCompletionRate: quickStats.todayHabitsRate,
        currentLongestStreak: quickStats.currentLongestStreak,
        currentProductivityScore: quickStats.productivityScore,

        // البيانات المدمجة
        todayTotalItems: totalItems,
        todayCompletedItems: completedItems,
        todayCombinedCompletionRate: combinedRate,

        // البيانات المخزنة
        weeklyProgress: weeklyProgress,
        monthlyProgress: monthlyProgress,
        weeklyCompletionRates: weeklyRates,

        // بيانات العادات مع السلاسل
        habitsWithStreaks: quickStats.habitsWithStreaks,

        // معلومات التحديث
        lastCalculatedAt: quickStats.calculatedAt,
        dataSource: 'hybrid', // للتتبع
      );

      emit(StatusLoaded(statusData));
    } catch (e) {
      emit(StatusError('خطأ في تحميل بيانات الحالة: ${e.toString()}'));
    }
  }

  /// إعادة تحميل البيانات (للـ pull-to-refresh)
  Future<void> refreshStatusData() async {
    try {
      // فرض إعادة حساب الإحصائيات اليومية
      await _forceRecalculateDailyStats();

      // إعادة تحميل البيانات
      await loadStatusData();
    } catch (e) {
      emit(StatusError('خطأ في تحديث البيانات: ${e.toString()}'));
    }
  }

  /// فرض إعادة حساب الإحصائيات اليومية
  Future<void> _forceRecalculateDailyStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // حذف الإحصائيات الحالية لفرض إعادة الحساب
    final dailyBox = StoredStatsService.getDailyStatsBox();
    final todayId = StoredStatsService.formatDateId(today);
    await dailyBox.delete(todayId);
  }

  /// تحديث بيانات سريع (للاستخدام عند تغيير المهام/العادات)
  Future<void> quickUpdate() async {
    if (state is! StatusLoaded) return;

    try {
      final currentState = state as StatusLoaded;

      // حساب البيانات السريعة فقط
      final tasks = await HiveService.getAllTasks();
      final habits = await HiveService.getAllHabits();
      final quickStats = QuickStatsService.calculateQuickStats(tasks, habits);

      // حساب البيانات المدمجة للتحديث السريع
      final totalItems =
          quickStats.todayTotalTasks + quickStats.todayTotalHabits;
      final completedItems =
          quickStats.todayCompletedTasks + quickStats.todayCompletedHabits;
      final combinedRate = totalItems > 0 ? (completedItems / totalItems) : 0.0;

      // تحديث البيانات السريعة مع الاحتفاظ بالبيانات المخزنة
      final updatedStatusData = currentState.statusData.copyWith(
        todayCompletedTasks: quickStats.todayCompletedTasks,
        todayTotalTasks: quickStats.todayTotalTasks,
        todayTasksCompletionRate: quickStats.todayTasksRate,
        todayCompletedHabits: quickStats.todayCompletedHabits,
        todayTotalHabits: quickStats.todayTotalHabits,
        todayHabitsCompletionRate: quickStats.todayHabitsRate,
        currentLongestStreak: quickStats.currentLongestStreak,
        currentProductivityScore: quickStats.productivityScore,
        todayTotalItems: totalItems,
        todayCompletedItems: completedItems,
        todayCombinedCompletionRate: combinedRate,
        habitsWithStreaks: quickStats.habitsWithStreaks,
        lastCalculatedAt: quickStats.calculatedAt,
      );

      emit(StatusLoaded(updatedStatusData));
    } catch (e) {
      // في حالة الخطأ، نحتفظ بالحالة الحالية
      print('خطأ في التحديث السريع: $e');
    }
  }

  /// الحصول على إحصائيات يوم محدد
  Future<void> loadDayStats(DateTime date) async {
    emit(StatusLoading());

    try {
      // محاولة جلب الإحصائيات المخزنة أولاً
      final storedStats = StoredStatsService.getDailyStats(date);

      if (storedStats != null) {
        // البيانات متوفرة مخزنة
        final statusData = StatusData.fromDailyStats(storedStats);
        emit(StatusLoaded(statusData));
      } else {
        // حساب البيانات للتاريخ المحدد
        await _calculateStatsForDate(date);
      }
    } catch (e) {
      emit(StatusError('خطأ في تحميل بيانات اليوم: ${e.toString()}'));
    }
  }

  /// حساب الإحصائيات لتاريخ محدد
  Future<void> _calculateStatsForDate(DateTime date) async {
    // هذا للتواريخ السابقة أو المستقبلية
    final tasks = await HiveService.getAllTasks();
    final habits = await HiveService.getAllHabits();

    // تصفية البيانات للتاريخ المحدد
    final dayTasks = _filterTasksForDate(tasks, date);
    final dayHabits = _filterHabitsForDate(habits, date);

    // حساب الإحصائيات
    final quickStats = QuickStatsService.calculateQuickStats(
      dayTasks,
      dayHabits,
    );

    // حساب البيانات المدمجة لهذا التاريخ
    final totalItems = quickStats.todayTotalTasks + quickStats.todayTotalHabits;
    final completedItems =
        quickStats.todayCompletedTasks + quickStats.todayCompletedHabits;
    final combinedRate = totalItems > 0 ? (completedItems / totalItems) : 0.0;

    final statusData = StatusData(
      todayCompletedTasks: quickStats.todayCompletedTasks,
      todayTotalTasks: quickStats.todayTotalTasks,
      todayTasksCompletionRate: quickStats.todayTasksRate,
      todayCompletedHabits: quickStats.todayCompletedHabits,
      todayTotalHabits: quickStats.todayTotalHabits,
      todayHabitsCompletionRate: quickStats.todayHabitsRate,
      currentLongestStreak: quickStats.currentLongestStreak,
      currentProductivityScore: quickStats.productivityScore,
      todayTotalItems: totalItems,
      todayCompletedItems: completedItems,
      todayCombinedCompletionRate: combinedRate,
      weeklyProgress: 0.0, // غير متوفر للتواريخ السابقة
      monthlyProgress: 0.0, // غير متوفر للتواريخ السابقة
      weeklyCompletionRates: [], // غير متوفر للتواريخ السابقة
      habitsWithStreaks: quickStats.habitsWithStreaks,
      lastCalculatedAt: DateTime.now(),
      dataSource: 'calculated_for_date',
    );

    emit(StatusLoaded(statusData));
  }

  /// تصفية المهام لتاريخ محدد
  List<TaskModel> _filterTasksForDate(List<TaskModel> tasks, DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return tasks.where((task) {
      return task.startDate.isBefore(dayEnd) && task.endDate.isAfter(dayStart);
    }).toList();
  }

  /// تصفية العادات لتاريخ محدد
  List<HabitModel> _filterHabitsForDate(
    List<HabitModel> habits,
    DateTime date,
  ) {
    // للعادات، نعيد كل العادات ولكن نتحقق من الإكمال في التاريخ المحدد
    return habits;
  }

  /// تنظيف البيانات القديمة
  Future<void> cleanOldData() async {
    try {
      await StoredStatsService.cleanOldData();
    } catch (e) {
      print('خطأ في تنظيف البيانات: $e');
    }
  }

  //get all habits compltetd for all week days
  Future<List<HabitModel>> getHabitsCompletedForAllWeekDays() async {
    final habits = await HiveService.getAllHabits();
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    return habits.where((habit) {
      // Check if habit was completed on any day of this week
      return habit.completedDates.any((completedDate) {
        final completedDay = DateTime(
          completedDate.year,
          completedDate.month,
          completedDate.day,
        );
        return completedDay.isAfter(
              startOfWeek.subtract(const Duration(days: 1)),
            ) &&
            completedDay.isBefore(startOfWeek.add(const Duration(days: 7)));
      });
    }).toList();
  }

  //get all tasks completed for all week days
  Future<List<TaskModel>> getTasksCompletedForAllWeekDays() async {
    final tasks = await HiveService.getAllTasks();
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return tasks.where((task) {
      return task.isDone &&
          task.startDate.isBefore(endOfWeek.add(const Duration(days: 1))) &&
          task.endDate.isAfter(startOfWeek.subtract(const Duration(days: 1)));
    }).toList();
  }

  /// Calculate combined completion percentage for habits and tasks
  Future<double> getCombinedCompletionPercentage({DateTime? date}) async {
    final calcDate = date ?? DateTime.now();
    final tasks = await HiveService.getAllTasks();
    final habits = await HiveService.getAllHabits();

    // Get today's tasks and habits
    final todayTasks = _filterTasksForDate(tasks, calcDate);
    final todayHabits = habits; // All habits are available each day

    // Calculate completed items
    final completedTasks = todayTasks.where((task) => task.isDone).length;
    final completedHabits =
        habits.where((habit) {
          return habit.completedDates.any((completedDate) {
            final completedDay = DateTime(
              completedDate.year,
              completedDate.month,
              completedDate.day,
            );
            final targetDay = DateTime(
              calcDate.year,
              calcDate.month,
              calcDate.day,
            );
            return completedDay.isAtSameMomentAs(targetDay);
          });
        }).length;

    // Calculate totals
    final totalTasks = todayTasks.length;
    final totalHabits = todayHabits.length;
    final totalItems = totalTasks + totalHabits;
    final completedItems = completedTasks + completedHabits;

    // Return completion percentage
    return totalItems > 0 ? (completedItems / totalItems) : 0.0;
  }

  /// Get daily completion rates for the current week
  Future<List<double>> getWeeklyCompletionRates() async {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final weeklyRates = <double>[];

    for (int i = 0; i < 7; i++) {
      final currentDay = startOfWeek.add(Duration(days: i));
      // Only calculate for past days and today
      if (currentDay.isAfter(now)) {
        weeklyRates.add(0.0);
      } else {
        final completionRate = await getCombinedCompletionPercentage(
          date: currentDay,
        );
        weeklyRates.add(completionRate);
      }
    }

    return weeklyRates;
  }

  /// Get completion data for a specific day
  Future<Map<String, dynamic>> getDayCompletionData(DateTime date) async {
    final tasks = await HiveService.getAllTasks();
    final habits = await HiveService.getAllHabits();

    // Get day's tasks and habits
    final dayTasks = _filterTasksForDate(tasks, date);
    final dayHabits = habits;

    // Calculate completed items
    final completedTasks = dayTasks.where((task) => task.isDone).length;
    final completedHabits =
        habits.where((habit) {
          return habit.completedDates.any((completedDate) {
            final completedDay = DateTime(
              completedDate.year,
              completedDate.month,
              completedDate.day,
            );
            final targetDay = DateTime(date.year, date.month, date.day);
            return completedDay.isAtSameMomentAs(targetDay);
          });
        }).length;

    final totalTasks = dayTasks.length;
    final totalHabits = dayHabits.length;
    final totalItems = totalTasks + totalHabits;
    final completedItems = completedTasks + completedHabits;

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'totalItems': totalItems,
      'completedItems': completedItems,
      'completionRate': totalItems > 0 ? (completedItems / totalItems) : 0.0,
    };
  }
}
