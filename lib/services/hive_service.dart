import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:task_day/models/task_model.dart';

class HiveService {
  static const String habitsBoxName = 'habits';
  static const String tasksBoxName = 'tasks';

  /// Initialize Hive and register adapters
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(HabitModelAdapter());
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(SubTaskModelAdapter());

    // Open boxes
    await Hive.openBox<HabitModel>(habitsBoxName);
    await Hive.openBox<TaskModel>(tasksBoxName);

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
      HabitModel updatedHabit;

      if (habit.isMeasurable) {
        // Reset currentValue to 0
        updatedHabit = habit.copyWith(currentValue: 0);
      } else {
        // Reset isDone to false
        updatedHabit = habit.copyWith(isDone: false);
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
    return box.values.where((task) {
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

      return (taskStart.isAtSameMomentAs(rangeStart) ||
                  taskStart.isAfter(rangeStart)) &&
              (taskStart.isAtSameMomentAs(rangeEnd) ||
                  taskStart.isBefore(rangeEnd)) ||
          (taskEnd.isAtSameMomentAs(rangeStart) ||
                  taskEnd.isAfter(rangeStart)) &&
              (taskEnd.isAtSameMomentAs(rangeEnd) ||
                  taskEnd.isBefore(rangeEnd)) ||
          (taskStart.isBefore(rangeStart) && taskEnd.isAfter(rangeEnd));
    }).toList();
  }

  /// Get tasks for today
  static Future<List<TaskModel>> getTodayTasks() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime tomorrow = today.add(const Duration(days: 1));

    return getTasksByDateRange(today, tomorrow);
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

  /// Close Hive
  static Future<void> close() async {
    await Hive.close();
  }
}
