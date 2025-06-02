import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/models/habit_model.dart';

/// Navigation helper class for consistent and centralized navigation
class NavigationHelper {
  /// Private constructor to prevent instantiation
  NavigationHelper._();

  // Route constants
  static const String home = '/';
  static const String tasks = '/tasks';
  static const String habits = '/habits';
  static const String status = '/status';
  static const String createTask = '/create-task';
  static const String createHabit = '/create-habit';

  // Navigation with tab support
  static void goToHomeWithTab(BuildContext context, int tabIndex) {
    context.go('/?tab=$tabIndex');
  }

  // Main navigation methods
  static void goHome(BuildContext context) {
    context.go(home);
  }

  static void goToTasks(BuildContext context) {
    context.go(tasks);
  }

  static void goToHabits(BuildContext context) {
    context.go(habits);
  }

  static void goToStatus(BuildContext context) {
    context.go(status);
  }

  static void goToCreateTask(BuildContext context) {
    context.push(createTask);
  }

  static void goToCreateHabit(BuildContext context) {
    context.push(createHabit);
  }

  // Task navigation
  static void goToTaskDetails(BuildContext context, TaskModel task) {
    context.push('/task-details/${task.id}', extra: task);
  }

  // Habit navigation
  static void goToHabitDetails(BuildContext context, HabitModel habit) {
    context.push('/habit-details/${habit.id}', extra: habit);
  }

  // Smart back navigation
  static void goBack(BuildContext context, {String? fallbackRoute}) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackRoute ?? home);
    }
  }

  // Back with result
  static void goBackWithResult<T>(
    BuildContext context,
    T result, {
    String? fallbackRoute,
  }) {
    if (context.canPop()) {
      context.pop(result);
    } else {
      context.go(fallbackRoute ?? home);
    }
  }

  // Replace current route
  static void replaceWith(BuildContext context, String route) {
    context.pushReplacement(route);
  }

  // Clear stack and go to route
  static void clearStackAndGoTo(BuildContext context, String route) {
    context.go(route);
  }

  // Tab navigation helper
  static void switchTab(BuildContext context, int tabIndex) {
    context.go('/?tab=$tabIndex');
  }

  // Get current route
  static String getCurrentRoute(BuildContext context) {
    return GoRouterState.of(context).fullPath ?? home;
  }

  // Check if can go back
  static bool canGoBack(BuildContext context) {
    return context.canPop();
  }

  // Show modal and navigate
  static Future<void> showCreateOptionsModal(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF191B2F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Create New",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        goToCreateTask(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.task,
                              size: 32,
                              color: Colors.deepPurpleAccent,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Task",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        goToCreateHabit(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 32,
                              color: Colors.purpleAccent,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Habit",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
