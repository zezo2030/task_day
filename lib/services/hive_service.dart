import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/models/user_profile_model.dart';
import 'package:task_day/models/achievement_model.dart';
import 'package:task_day/models/reward_model.dart';
import 'package:task_day/services/stored_stats_service.dart';
import 'package:task_day/services/gamification_service.dart';

class HiveService {
  static const String habitsBoxName = 'habits';
  static const String tasksBoxName = 'tasks';
  static const String settingsBoxName = 'settings';

  /// Initialize Hive and register adapters
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(HabitModelAdapter());
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(SubTaskModelAdapter());

    // Register gamification adapters
    Hive.registerAdapter(UserProfileModelAdapter());
    Hive.registerAdapter(AchievementModelAdapter());
    Hive.registerAdapter(RewardModelAdapter());
    Hive.registerAdapter(AchievementTypeAdapter());
    Hive.registerAdapter(AchievementRarityAdapter());
    Hive.registerAdapter(RewardTypeAdapter());
    Hive.registerAdapter(RewardRarityAdapter());

    // Open boxes
    await Hive.openBox<HabitModel>(habitsBoxName);
    await Hive.openBox<TaskModel>(tasksBoxName);
    await Hive.openBox(settingsBoxName);

    // Initialize stored stats service
    await StoredStatsService.init();

    // Initialize gamification system
    await GamificationService.init();

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

      // Trigger gamification system for habit completion
      final pointsEarned = await GamificationService.onHabitCompleted(
        updatedHabit,
      );

      // Store points earned for UI display (we'll access this elsewhere)
      // This is a simple approach - you could also use a callback or stream
      await _storeEarnedPoints(
        updatedHabit.id,
        pointsEarned,
        updatedHabit.title,
      );
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

      // Handle gamification: subtract points if they were earned today
      final pointsSubtracted = await GamificationService.onHabitReset(
        updatedHabit,
      );

      // Store points subtracted for UI display (negative value)
      if (pointsSubtracted > 0) {
        await _storeEarnedPoints(
          updatedHabit.id,
          -pointsSubtracted, // Negative to indicate subtraction
          updatedHabit.title,
        );
      }
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

        // Save today as last reset date
        await box.put('lastResetDate', today.toIso8601String());

        if (kDebugMode) {
          print('Daily habits reset performed for ${today.toIso8601String()}');
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

  /// Manually trigger daily reset (for testing or manual reset)
  static Future<void> manualDailyReset() async {
    await performDailyHabitsReset();

    // Update last reset date
    final box = getSettingsBox();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await box.put('lastResetDate', today.toIso8601String());

    if (kDebugMode) {
      print('Manual daily reset performed');
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

  /// Store earned points for UI display
  static Future<void> _storeEarnedPoints(
    String habitId,
    int points,
    String habitTitle,
  ) async {
    try {
      final box = getSettingsBox();
      await box.put('lastEarnedPoints', {
        'habitId': habitId,
        'points': points,
        'habitTitle': habitTitle,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error storing earned points: $e');
      }
    }
  }

  /// Get last earned points
  static Map<String, dynamic>? getLastEarnedPoints() {
    try {
      final box = getSettingsBox();
      final data = box.get('lastEarnedPoints');
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting last earned points: $e');
      }
    }
    return null;
  }

  /// Clear earned points (after showing dialog)
  static Future<void> clearEarnedPoints() async {
    try {
      final box = getSettingsBox();
      await box.delete('lastEarnedPoints');
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing earned points: $e');
      }
    }
  }

  /// Close Hive
  static Future<void> close() async {
    await Hive.close();
  }
}
