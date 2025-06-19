import 'package:flutter/material.dart';
import 'package:task_day/controller/task_cubit/task_cubit.dart';
import 'package:task_day/core/themes/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_day/services/hive_service.dart';
import 'package:task_day/services/notification_service.dart';
import 'package:task_day/core/router/app_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_day/controller/habit_cubit/habit_cubit.dart';
import 'package:task_day/controller/status_cubit/status_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveService.init();

  // Initialize Notifications
  await NotificationService.initialize();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<HabitCubit>(
              create: (context) => HabitCubit()..getHabits(),
            ),
            BlocProvider<TaskCubit>(
              create: (context) => TaskCubit()..getTasks(),
            ),
            BlocProvider<StatusCubit>(create: (context) => StatusCubit()),
            // Add more BlocProviders here as needed
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.themeData,
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}
