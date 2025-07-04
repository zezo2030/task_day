import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_day/core/utils/time_of_day_adapter.dart';
import 'package:task_day/models/daily_routine_model.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/services/stored_stats_service.dart';

class HiveService {
  static const String habitsBoxName = 'habits';
  static const String tasksBoxName = 'tasks';
  static const String settingsBoxName = 'settings';
  static const String dailyRoutineBoxName = 'daily_routine';

  /// Initialize Hive and register adapters
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(HabitModelAdapter());
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(SubTaskModelAdapter());
    Hive.registerAdapter(DailyRoutineModelAdapter());
    Hive.registerAdapter(TimeOfDayAdapter());
    // Open boxes
    await Hive.openBox<HabitModel>(habitsBoxName);
    await Hive.openBox<TaskModel>(tasksBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox<DailyRoutineModel>(dailyRoutineBoxName);
    // Initialize stored stats service
    await StoredStatsService.init();

    // Check and perform daily reset if needed
    await checkAndPerformDailyReset();

    if (kDebugMode) {
      print('Hive initialized successfully');
    }
  }

  /// Get habits box
  static Box<HabitModel> getHabitsBox() {
    return Hive.box<HabitModel>(habitsBoxName);
  }

  /// Add a habit
  static Future<void> addHabit(HabitModel habit) async {
    final box = getHabitsBox();
    await box.put(habit.id, habit);
  }

  /// Get all habits
  static Future<List<HabitModel>> getAllHabits() async {
    final box = getHabitsBox();
    return box.values.toList();
  }

  /// Update a habit
  static Future<void> updateHabit(HabitModel habit) async {
    final box = getHabitsBox();
    await box.put(habit.id, habit);
  }

  /// Delete a habit
  static Future<void> deleteHabit(String id) async {
    final box = getHabitsBox();
    await box.delete(id);
  }

  /// Clear all habits
  static Future<void> clearAllHabits() async {
    final box = getHabitsBox();
    await box.clear();
  }

  /// Complete a habit
  static Future<void> completeHabit(String id) async {
    final box = getHabitsBox();
    final habit = box.get(id);
    if (habit != null) {
      final DateTime now = DateTime.now();

      // Create a new habit model with updated properties
      HabitModel updatedHabit;

      if (habit.isMeasurable) {
        // For measurable habits, increment the current value
        int newValue = (habit.currentValue ?? 0) + 1;
        // Don't exceed the target value
        if (habit.targetValue != null) {
          newValue = newValue.clamp(0, habit.targetValue!);
        }

        // Check if this increment completes the habit (reached target)
        bool isCompleted = newValue >= (habit.targetValue ?? 0);

        // Only add to completedDates if habit is now completed
        List<DateTime> updatedCompletedDates = List.from(habit.completedDates);
        if (isCompleted) {
          // Check if we already marked completion for today
          bool alreadyCompletedToday = habit.completedDates.any(
            (date) =>
                date.year == now.year &&
                date.month == now.month &&
                date.day == now.day,
          );

          if (!alreadyCompletedToday) {
            updatedCompletedDates.add(now);
          }
        }

        updatedHabit = habit.copyWith(
          currentValue: newValue,
          completedDates: updatedCompletedDates,
        );
      } else {
        // For non-measurable habits, toggle isDone to true
        updatedHabit = habit.copyWith(
          isDone: true,
          completedDates: [...habit.completedDates, now],
        );
      }

      // Save the updated habit
      await box.put(id, updatedHabit);
    }
  }

  /// Reset a habit completion status
  static Future<void> resetHabit(String id) async {
    final box = getHabitsBox();
    final habit = box.get(id);
    if (habit != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Remove today's date from completedDates
      List<DateTime> updatedCompletedDates =
          habit.completedDates.where((date) {
            final habitDate = DateTime(date.year, date.month, date.day);
            return !habitDate.isAtSameMomentAs(today);
          }).toList();

      HabitModel updatedHabit;
      if (habit.isMeasurable) {
        // Reset currentValue to 0 and update completedDates
        updatedHabit = habit.copyWith(
          currentValue: 0,
          completedDates: updatedCompletedDates,
        );
      } else {
        // Reset isDone to false and update completedDates
        updatedHabit = habit.copyWith(
          isDone: false,
          completedDates: updatedCompletedDates,
        );
      }

      await box.put(id, updatedHabit);
    }
  }

  /// Get tasks box
  static Box<TaskModel> getTasksBox() {
    return Hive.box<TaskModel>(tasksBoxName);
  }

  /// Add a task
  static Future<void> addTask(TaskModel task) async {
    final box = getTasksBox();
    await box.put(task.id, task);
  }

  /// Get all tasks
  static Future<List<TaskModel>> getAllTasks() async {
    final box = getTasksBox();
    return box.values.toList();
  }

  /// Get tasks by date range
  static Future<List<TaskModel>> getTasksByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final box = getTasksBox();
    print('HiveService: getTasksByDateRange called with range: $start to $end');
    print('HiveService: Total tasks in box: ${box.length}');

    final filteredTasks =
        box.values.where((task) {
          // Task is within date range if:
          // 1. Start date is between the range or
          // 2. End date is between the range or
          // 3. Start date is before the range and end date is after the range
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
          final rangeStart = DateTime(start.year, start.month, start.day);
          final rangeEnd = DateTime(end.year, end.month, end.day);

          final isInRange =
              ((taskStart.isAtSameMomentAs(rangeStart) ||
                      taskStart.isAfter(rangeStart)) &&
                  (taskStart.isAtSameMomentAs(rangeEnd) ||
                      taskStart.isBefore(rangeEnd))) ||
              ((taskEnd.isAtSameMomentAs(rangeStart) ||
                      taskEnd.isAfter(rangeStart)) &&
                  (taskEnd.isAtSameMomentAs(rangeEnd) ||
                      taskEnd.isBefore(rangeEnd))) ||
              (taskStart.isBefore(rangeStart) && taskEnd.isAfter(rangeEnd));

          if (isInRange) {
            print(
              'HiveService: Task "${task.title}" ($taskStart to $taskEnd) matches range',
            );
          }

          return isInRange;
        }).toList();

    print('HiveService: Filtered ${filteredTasks.length} tasks for range');
    return filteredTasks;
  }

  /// Get tasks for today
  static Future<List<TaskModel>> getTodayTasks() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime endOfToday = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    );

    print('HiveService: Getting today tasks for range: $today to $endOfToday');
    final tasks = await getTasksByDateRange(today, endOfToday);
    print('HiveService: Found ${tasks.length} tasks for today');

    return tasks;
  }

  /// Get tasks by priority
  static Future<List<TaskModel>> getTasksByPriority(int priority) async {
    final box = getTasksBox();
    return box.values.where((task) => task.priority == priority).toList();
  }

  /// Update a task
  static Future<void> updateTask(TaskModel task) async {
    final box = getTasksBox();
    await box.put(task.id, task);
  }

  /// Delete a task
  static Future<void> deleteTask(String id) async {
    final box = getTasksBox();
    await box.delete(id);
  }

  /// Clear all tasks
  static Future<void> clearAllTasks() async {
    final box = getTasksBox();
    await box.clear();
  }

  /// Toggle task completion status
  static Future<void> toggleTaskCompletion(String id) async {
    final box = getTasksBox();
    final task = box.get(id);
    if (task != null) {
      // Toggle isDone status
      final updatedTask = task.copyWith(isDone: !task.isDone);
      await box.put(id, updatedTask);
    }
  }

  /// Toggle subtask completion
  static Future<void> toggleSubtaskCompletion(
    String taskId,
    String subtaskId,
  ) async {
    final box = getTasksBox();
    final task = box.get(taskId);

    if (task != null) {
      // Find the subtask and toggle its status
      final updatedSubtasks = List<SubTaskModel>.from(task.subTasks);
      final subtaskIndex = updatedSubtasks.indexWhere(
        (subtask) => subtask.id == subtaskId,
      );

      if (subtaskIndex != -1) {
        final subtask = updatedSubtasks[subtaskIndex];
        updatedSubtasks[subtaskIndex] = subtask.copyWith(
          isDone: !subtask.isDone,
        );

        // Update the task with new subtasks list
        final updatedTask = task.copyWith(subTasks: updatedSubtasks);
        await box.put(taskId, updatedTask);
      }
    }
  }

  /// Add a subtask to a task
  static Future<void> addSubtask(String taskId, SubTaskModel subtask) async {
    final box = getTasksBox();
    final task = box.get(taskId);

    if (task != null) {
      // Add the new subtask
      final updatedSubtasks = List<SubTaskModel>.from(task.subTasks)
        ..add(subtask);
      final updatedTask = task.copyWith(subTasks: updatedSubtasks);
      await box.put(taskId, updatedTask);
    }
  }

  /// Delete a subtask from a task
  static Future<void> deleteSubtask(String taskId, String subtaskId) async {
    final box = getTasksBox();
    final task = box.get(taskId);

    if (task != null) {
      // Remove the subtask
      final updatedSubtasks =
          List<SubTaskModel>.from(
            task.subTasks,
          ).where((subtask) => subtask.id != subtaskId).toList();

      final updatedTask = task.copyWith(subTasks: updatedSubtasks);
      await box.put(taskId, updatedTask);
    }
  }

  /// Get settings box
  static Box getSettingsBox() {
    return Hive.box(settingsBoxName);
  }

  /// Check and perform daily reset if needed
  static Future<void> checkAndPerformDailyReset() async {
    try {
      final box = getSettingsBox();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get last reset date
      final lastResetDateString = box.get('lastResetDate');
      DateTime? lastResetDate;

      if (lastResetDateString != null) {
        lastResetDate = DateTime.tryParse(lastResetDateString);
      }

      // If never reset or last reset was before today, perform reset
      if (lastResetDate == null || lastResetDate.isBefore(today)) {
        await performDailyHabitsReset();
        await performDailyRoutineReset();

        // Save today as last reset date
        await box.put('lastResetDate', today.toIso8601String());

        if (kDebugMode) {
          print(
            'Daily habits and routines reset performed for ${today.toIso8601String()}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in daily reset check: $e');
      }
    }
  }

  /// Perform daily reset for all habits
  static Future<void> performDailyHabitsReset() async {
    try {
      final box = getHabitsBox();
      final allHabits = await getAllHabits();

      for (final habit in allHabits) {
        HabitModel updatedHabit;

        if (habit.isMeasurable) {
          // Reset currentValue to 0 for measurable habits
          updatedHabit = habit.copyWith(currentValue: 0);
        } else {
          // Reset isDone to false for non-measurable habits
          updatedHabit = habit.copyWith(isDone: false);
        }

        // Save updated habit
        await box.put(habit.id, updatedHabit);
      }

      if (kDebugMode) {
        print('Daily reset completed for ${allHabits.length} habits');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error performing daily habits reset: $e');
      }
    }
  }

  /// Perform daily reset for all daily routines
  static Future<void> performDailyRoutineReset() async {
    try {
      final box = getDailyRoutineBox();
      final allRoutines = await getAllDailyRoutines();
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      for (final routine in allRoutines) {
        // Only reset recurring daily routines
        if (routine.isRecurringDaily) {
          final routineDate = DateTime(
            routine.dateTime.year,
            routine.dateTime.month,
            routine.dateTime.day,
          );

          // If this routine is from today, reset it
          if (routineDate.isAtSameMomentAs(todayDate)) {
            final updatedRoutine = routine.copyWith(isCompleted: false);
            await box.put(routine.id, updatedRoutine);
          }
          // If this routine is from a previous day and is recurring,
          // create a new instance for today
          else if (routineDate.isBefore(todayDate)) {
            // Check if we already have a routine for today with the same name and times
            final todayRoutineExists = allRoutines.any((r) {
              final rDate = DateTime(
                r.dateTime.year,
                r.dateTime.month,
                r.dateTime.day,
              );
              return rDate.isAtSameMomentAs(todayDate) &&
                  r.name == routine.name &&
                  r.startTime == routine.startTime &&
                  r.endTime == routine.endTime;
            });

            if (!todayRoutineExists) {
              // Create new routine for today
              final newRoutine = routine.copyWith(
                id: '${routine.id}_${todayDate.millisecondsSinceEpoch}',
                dateTime: todayDate,
                isCompleted: false,
              );
              await box.put(newRoutine.id, newRoutine);
            }
          }
        }
      }

      if (kDebugMode) {
        print(
          'Daily reset completed for ${allRoutines.where((r) => r.isRecurringDaily).length} recurring daily routines',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error performing daily routine reset: $e');
      }
    }
  }

  /// Manually trigger daily reset (for testing or manual reset)
  static Future<void> manualDailyReset() async {
    await performDailyHabitsReset();
    await performDailyRoutineReset();

    // Update last reset date
    final box = getSettingsBox();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await box.put('lastResetDate', today.toIso8601String());

    if (kDebugMode) {
      print('Manual daily reset performed for habits and routines');
    }
  }

  /// Get last reset date
  static DateTime? getLastResetDate() {
    try {
      final box = getSettingsBox();
      final lastResetDateString = box.get('lastResetDate');
      if (lastResetDateString != null) {
        return DateTime.tryParse(lastResetDateString);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting last reset date: $e');
      }
    }
    return null;
  }

  /// Get daily routine box
  static Box<DailyRoutineModel> getDailyRoutineBox() {
    return Hive.box<DailyRoutineModel>(dailyRoutineBoxName);
  }

  /// Add a daily routine
  static Future<void> addDailyRoutine(DailyRoutineModel dailyRoutine) async {
    final box = getDailyRoutineBox();
    await box.put(dailyRoutine.id, dailyRoutine);
  }

  /// Get all daily routines
  static Future<List<DailyRoutineModel>> getAllDailyRoutines() async {
    final box = getDailyRoutineBox();
    return box.values.toList();
  }

  /// Get today's daily routines
  static Future<List<DailyRoutineModel>> getTodayDailyRoutines() async {
    final box = getDailyRoutineBox();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return box.values.where((routine) {
      final routineDate = DateTime(
        routine.dateTime.year,
        routine.dateTime.month,
        routine.dateTime.day,
      );
      return routineDate.isAtSameMomentAs(todayDate);
    }).toList();
  }

  /// Get daily routine by date
  static Future<DailyRoutineModel?> getDailyRoutineByDate(DateTime date) async {
    final box = getDailyRoutineBox();
    return box.values.firstWhere((routine) => routine.dateTime == date);
  }

  /// Update a daily routine
  static Future<void> updateDailyRoutine(DailyRoutineModel dailyRoutine) async {
    final box = getDailyRoutineBox();
    await box.put(dailyRoutine.id, dailyRoutine);
  }

  /// Delete a daily routine
  static Future<void> deleteDailyRoutine(String id) async {
    final box = getDailyRoutineBox();
    await box.delete(id);
  }

  /// Clear all daily routines
  static Future<void> clearAllDailyRoutines() async {
    final box = getDailyRoutineBox();
    await box.clear();
  }

  /// Close Hive
  static Future<void> close() async {
    await Hive.close();
  }
}
