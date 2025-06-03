import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_day/view/create_habit_screen.dart';
import 'package:task_day/view/create_task_screen.dart';
import 'package:task_day/view/edit_task_screen.dart';
import 'package:task_day/view/habit_details_screen.dart';
import 'package:task_day/view/habits_screen.dart';
import 'package:task_day/view/home_screen.dart';
import 'package:task_day/view/main_view.dart';
import 'package:task_day/view/status_screen.dart';
import 'package:task_day/view/tasks_screen.dart';
import 'package:task_day/view/task_details_screen.dart';
import 'package:task_day/view/gamification_screen.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:task_day/services/hive_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_day/controller/habit_cubit/habit_cubit.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => _buildErrorPage(context, state),
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
        path: '/gamification',
        builder: (context, state) => const GamificationScreen(),
      ),
      GoRoute(
        path: '/edit-task/:taskId',
        builder: (context, state) {
          final taskId = state.pathParameters['taskId'] ?? '';

          // Try to get task from extra parameter first (for immediate navigation)
          final extraTask = state.extra as TaskModel?;
          if (extraTask != null && extraTask.id == taskId) {
            return EditTaskScreen(task: extraTask);
          }

          // Fallback to Hive storage
          final tasksBox = HiveService.getTasksBox();
          final task = tasksBox.get(taskId);

          if (task != null) {
            return EditTaskScreen(task: task);
          } else {
            // Handle case when task is not found
            return _buildNotFoundPage(context, 'Task', '/tasks');
          }
        },
      ),
      GoRoute(
        path: '/task-details/:taskId',
        builder: (context, state) {
          final taskId = state.pathParameters['taskId'] ?? '';

          // Try to get task from extra parameter first (for immediate navigation)
          final extraTask = state.extra as TaskModel?;
          if (extraTask != null && extraTask.id == taskId) {
            return TaskDetailsScreen(task: extraTask);
          }

          // Fallback to Hive storage
          final tasksBox = HiveService.getTasksBox();
          final task = tasksBox.get(taskId);

          if (task != null) {
            return TaskDetailsScreen(task: task);
          } else {
            // Handle case when task is not found
            return _buildNotFoundPage(context, 'Task', '/tasks');
          }
        },
      ),
      GoRoute(
        path: '/habit-details/:habitId',
        builder: (context, state) {
          final habitId = state.pathParameters['habitId'] ?? '';

          // Try to get habit from extra parameter first (for immediate navigation)
          final extraHabit = state.extra as HabitModel?;
          if (extraHabit != null && extraHabit.id == habitId) {
            return HabitDetailsScreen(habit: extraHabit);
          }

          // Fallback to Hive storage
          final habitsBox = HiveService.getHabitsBox();
          final habit = habitsBox.get(habitId);

          if (habit != null) {
            return HabitDetailsScreen(habit: habit);
          } else {
            // Handle case when habit is not found
            return _buildNotFoundPage(context, 'Habit', '/habits');
          }
        },
      ),
    ],
  );

  // Error page builder
  static Widget _buildErrorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      backgroundColor: const Color(0xFF191B2F),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF191B2F),
              const Color(0xFF0F1227),
              const Color(0xFF05060D),
            ],
            stops: const [0.1, 0.5, 0.9],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 80.sp,
                    color: Colors.red.shade300,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Oops! Something went wrong',
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'We encountered an error while navigating.\nPlease try again.',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (state.error != null) ...[
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Error: ${state.error}',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.red.shade300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  SizedBox(height: 32.h),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 16.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Go Home',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Not found page builder
  static Widget _buildNotFoundPage(
    BuildContext context,
    String itemType,
    String fallbackRoute,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFF191B2F),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF191B2F),
              const Color(0xFF0F1227),
              const Color(0xFF05060D),
            ],
            stops: const [0.1, 0.5, 0.9],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 80.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    '$itemType Not Found',
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'The $itemType you\'re looking for doesn\'t exist\nor may have been deleted.',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => context.go('/'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Home',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      ElevatedButton(
                        onPressed: () => context.go(fallbackRoute),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Go to ${itemType}s',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
