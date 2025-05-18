import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_day/view/create_habit_screen.dart';
import 'package:task_day/view/create_task_screen.dart';
import 'package:task_day/view/habit_details_screen.dart';
import 'package:task_day/view/habits_screen.dart';
import 'package:task_day/view/home_screen.dart';
import 'package:task_day/view/main_view.dart';
import 'package:task_day/view/status_screen.dart';
import 'package:task_day/view/tasks_screen.dart';
import 'package:task_day/services/hive_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_day/controller/cubit/habit_cubit.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          // Get tab parameter from URL
          final tab = state.uri.queryParameters['tab'];
          return MainScreen(tab: tab);
        },
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/tasks', builder: (context, state) => const TasksScreen()),
      GoRoute(
        path: '/habits',
        builder:
            (context, state) => BlocProvider(
              create: (context) => HabitCubit()..getHabits(),
              child: const HabitsScreen(),
            ),
      ),
      GoRoute(
        path: '/status',
        builder: (context, state) => const StatusScreen(),
      ),
      GoRoute(
        path: '/create-task',
        builder: (context, state) => const CreateTaskScreen(),
      ),
      GoRoute(
        path: '/create-habit',
        builder:
            (context, state) => BlocProvider(
              create: (context) => HabitCubit(),
              child: const CreateHabitScreen(),
            ),
      ),
      GoRoute(
        path: '/habit-details/:habitId',
        builder: (context, state) {
          final habitId = state.pathParameters['habitId'] ?? '';
          // Get habit from Hive storage
          final habitsBox = HiveService.getHabitsBox();
          final habit = habitsBox.get(habitId);

          if (habit != null) {
            return HabitDetailsScreen(habit: habit);
          } else {
            // Handle case when habit is not found
            return Scaffold(body: Center(child: Text('Habit not found')));
          }
        },
      ),
    ],
  );
}
