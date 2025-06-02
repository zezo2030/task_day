import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/models/habit_model.dart';

/// Navigation extensions for BuildContext to make navigation easier
extension NavigationExtensions on BuildContext {
  // Basic navigation
  void goHome([int? tab]) {
    if (tab != null) {
      go('/?tab=$tab');
    } else {
      go('/');
    }
  }

  void goToTasks() => go('/tasks');
  void goToHabits() => go('/habits');
  void goToStatus() => go('/status');

  // Push navigation
  void pushCreateTask() => push('/create-task');
  void pushCreateHabit() => push('/create-habit');

  // Task navigation
  void pushTaskDetails(TaskModel task) {
    push('/task-details/${task.id}', extra: task);
  }

  // Habit navigation
  void pushHabitDetails(HabitModel habit) {
    push('/habit-details/${habit.id}', extra: habit);
  }

  // Smart back navigation
  void smartPop({String? fallbackRoute}) {
    if (canPop()) {
      pop();
    } else {
      go(fallbackRoute ?? '/');
    }
  }

  // Back with result
  void smartPopWithResult<T>(T result, {String? fallbackRoute}) {
    if (canPop()) {
      pop(result);
    } else {
      go(fallbackRoute ?? '/');
    }
  }

  // Tab switching
  void switchToTab(int tabIndex) {
    go('/?tab=$tabIndex');
  }

  // Replace current route
  void replaceWithRoute(String route) {
    pushReplacement(route);
  }

  // Current route info
  String get currentRoute => GoRouterState.of(this).fullPath ?? '/';

  // Navigation validation
  bool get canNavigateBack => canPop();
}
