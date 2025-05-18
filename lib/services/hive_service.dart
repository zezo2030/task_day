import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_day/models/habit_model.dart';

class HiveService {
  static const String habitsBoxName = 'habits';

  /// Initialize Hive and register adapters
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(HabitModelAdapter());

    // Open boxes
    await Hive.openBox<HabitModel>(habitsBoxName);

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

  /// Close Hive
  static Future<void> close() async {
    await Hive.close();
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
}
