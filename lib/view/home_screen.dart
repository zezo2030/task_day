import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_day/core/extensions/widget_extensions.dart';
import 'package:task_day/core/themes/app_theme.dart';
import 'package:task_day/widgets/habit_card.dart';

import 'package:task_day/controller/task_cubit/task_cubit.dart';
import 'package:task_day/controller/habit_cubit/habit_cubit.dart';
import 'package:task_day/controller/status_cubit/status_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:task_day/core/router/navigation_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Load data when screen initializes
    context.read<TaskCubit>().getTodayTasks();
    context.read<HabitCubit>().getHabits();
    context.read<StatusCubit>().loadStatusData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Get motivational quotes based on time of day
  String _getTimeBasedQuote() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Start your morning with intention, and watch magic unfold throughout your day.";
    } else if (hour < 18) {
      return "Your afternoon efforts are building the extraordinary future you deserve.";
    } else {
      return "Evening reflection: every small step you took today matters more than you know.";
    }
  }

  // Get greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  // Get greeting icon based on time of day
  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return Icons.wb_sunny_outlined;
    } else if (hour < 17) {
      return Icons.wb_sunny;
    } else {
      return Icons.nights_stay_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(DateTime.now());
    return Theme(
      data: AppTheme.darkTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colorScheme.surface, colorScheme.surface],
                ),
              ),
              child: SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Enhanced Header Section
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.surface,
                              colorScheme.surface.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),

                            // Welcome Section
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    (1 - _animationController.value) * -50,
                                    0,
                                  ),
                                  child: Opacity(
                                    opacity: _animationController.value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Greeting with Icon
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: Icon(
                                          _getGreetingIcon(),
                                          color: colorScheme.primary,
                                          size: 20.sp,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        _getGreeting(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 12.h),

                                  // Main Welcome Text
                                  ShaderMask(
                                    shaderCallback:
                                        (bounds) => LinearGradient(
                                          colors: [
                                            Colors.white,
                                            colorScheme.secondary,
                                            colorScheme.primary,
                                          ],
                                          stops: [0.0, 0.5, 1.0],
                                        ).createShader(bounds),
                                    child: Text(
                                      "Welcome Back, Zoz!",
                                      style: GoogleFonts.poppins(
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 8.h),

                                  // Date with better styling
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          color: colorScheme.secondary,
                                          size: 14.sp,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          formattedDate,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12.sp,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Progress Overview Card
                    SliverToBoxAdapter(
                      child: BlocBuilder<StatusCubit, StatusState>(
                        builder: (context, state) {
                          if (state is StatusLoaded) {
                            return AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    0,
                                    (1 - _animationController.value) * 30,
                                  ),
                                  child: Opacity(
                                    opacity: _animationController.value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 16.h,
                                ),
                                padding: EdgeInsets.all(20.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary.withOpacity(0.8),
                                      colorScheme.secondary.withOpacity(0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(
                                        0.2,
                                      ),
                                      blurRadius: 15,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Today's Progress",
                                            style: GoogleFonts.poppins(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            "${state.statusData.todayCompletedTasks}/${state.statusData.todayTotalTasks} Tasks",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14.sp,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          Text(
                                            "${state.statusData.todayCompletedHabits}/${state.statusData.todayTotalHabits} Habits",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14.sp,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 60.w,
                                      height: 60.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${state.statusData.currentProductivityScore.toInt()}%",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                    ),

                    // Daily Tasks Card
                    SliverToBoxAdapter(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              (1 - _animationController.value) * 30,
                            ),
                            child: Opacity(
                              opacity: _animationController.value,
                              child: child,
                            ),
                          );
                        },
                        child: GestureDetector(
                          onTap: () => context.push('/daily-tasks'),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 16.h,
                            ),
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6366F1).withOpacity(0.8),
                                  const Color(0xFF8B5CF6).withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60.w,
                                  height: 60.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: Icon(
                                    Icons.today_outlined,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Daily Tasks",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "Manage your daily routines",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Weekly Review Card
                    SliverToBoxAdapter(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              (1 - _animationController.value) * 30,
                            ),
                            child: Opacity(
                              opacity: _animationController.value,
                              child: child,
                            ),
                          );
                        },
                        child: GestureDetector(
                          onTap: () => context.push('/weekly-review'),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 16.h,
                            ),
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF10B981).withOpacity(0.8),
                                  const Color(0xFF059669).withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60.w,
                                  height: 60.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: Icon(
                                    Icons.analytics,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Weekly Review",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "Analyze your weekly progress",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Magical Quote
                    // SliverToBoxAdapter(
                    //   child: AnimatedBuilder(
                    //     animation: _animationController,
                    //     builder: (context, child) {
                    //       return Transform.translate(
                    //         offset: Offset(
                    //           0,
                    //           (1 - _animationController.value) * 30,
                    //         ),
                    //         child: Opacity(
                    //           opacity: _animationController.value,
                    //           child: child,
                    //         ),
                    //       );
                    //     },
                    //     child: Container(
                    //       margin: EdgeInsets.symmetric(
                    //         horizontal: 20.w,
                    //         vertical: 16.h,
                    //       ),
                    //       padding: EdgeInsets.all(20.w),
                    //       decoration: BoxDecoration(
                    //         gradient: LinearGradient(
                    //           colors: [
                    //             colorScheme.primary.withOpacity(0.7),
                    //             colorScheme.surface.withOpacity(0.7),
                    //           ],
                    //         ),
                    //         borderRadius: BorderRadius.circular(20.r),
                    //         boxShadow: [
                    //           BoxShadow(
                    //             color: colorScheme.primary.withOpacity(0.2),
                    //             blurRadius: 15,
                    //             spreadRadius: 5,
                    //           ),
                    //         ],
                    //       ),
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Row(
                    //             children: [
                    //               Icon(
                    //                 Icons.auto_awesome,
                    //                 color: Colors.amber,
                    //                 size: 22.sp,
                    //               ),
                    //               SizedBox(width: 8.w),
                    //               Text(
                    //                 "Magical Thought",
                    //                 style: GoogleFonts.poppins(
                    //                   fontSize: 16.sp,
                    //                   fontWeight: FontWeight.bold,
                    //                   color: Colors.white,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //           SizedBox(height: 10.h),
                    //           Text(
                    //             _getTimeBasedQuote(),
                    //             style: GoogleFonts.poppins(
                    //               fontSize: 14.sp,
                    //               color: Colors.white,
                    //               height: 1.5,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // Today's Tasks Headerhk
                    SliverToBoxAdapter(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              (1 - _animationController.value) * 20,
                              0,
                            ),
                            child: Opacity(
                              opacity: _animationController.value,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 20.w,
                            right: 20.w,
                            top: 20.h,
                            bottom: 10.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Today's Tasks",
                                style: theme.textTheme.headlineMedium,
                              ),
                              GestureDetector(
                                onTap: () => context.push('/create-task'),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondary.withOpacity(
                                      0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: colorScheme.secondary,
                                        size: 18.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        "Add New",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          color: colorScheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Tasks List with Real Data
                    BlocConsumer<TaskCubit, TaskState>(
                      listener: (context, state) {
                        if (state is TaskError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${state.message}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is TaskLoading) {
                          return SliverToBoxAdapter(
                            child: SizedBox(
                              height: 200.h,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          );
                        }

                        if (state is TaskLoaded) {
                          final todayTasks =
                              state.tasks.where((task) {
                                final today = DateTime.now();
                                final todayDate = DateTime(
                                  today.year,
                                  today.month,
                                  today.day,
                                );
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

                                // Task should be shown if today is between start and end dates
                                return (taskStart.isBefore(
                                      todayDate.add(const Duration(days: 1)),
                                    ) &&
                                    taskEnd.isAfter(
                                      todayDate.subtract(
                                        const Duration(days: 1),
                                      ),
                                    ));
                              }).toList();

                          if (todayTasks.isEmpty) {
                            return SliverToBoxAdapter(
                              child: AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      (1 - _animationController.value) * 30,
                                    ),
                                    child: Opacity(
                                      opacity: _animationController.value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 20.h,
                                  ),
                                  padding: EdgeInsets.all(40.w),
                                  decoration: BoxDecoration(
                                    color: theme.cardTheme.color,
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.task_alt,
                                        size: 48.sp,
                                        color: colorScheme.primary.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        "No tasks for today",
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(color: Colors.white70),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Start by adding your first task!",
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index >= todayTasks.length) return null;

                                final task = todayTasks[index];
                                final itemAnimation = Tween<double>(
                                  begin: 0.0,
                                  end: 1.0,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(
                                      0.1 + 0.1 * index,
                                      0.6 + 0.1 * index,
                                      curve: Curves.easeOutQuart,
                                    ),
                                  ),
                                );

                                final completedColor = Colors.green;

                                return AnimatedBuilder(
                                  animation: itemAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(
                                        0,
                                        (1 - itemAnimation.value) * 50,
                                      ),
                                      child: Opacity(
                                        opacity: itemAnimation.value,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.cardTheme.color,
                                      borderRadius: BorderRadius.circular(16.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      leading: Container(
                                        height: 48.h,
                                        width: 48.w,
                                        decoration: BoxDecoration(
                                          color:
                                              task.isDone
                                                  ? completedColor.withOpacity(
                                                    0.1,
                                                  )
                                                  : colorScheme.primary
                                                      .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: Icon(
                                          task.isDone
                                              ? Icons.check_circle
                                              : Icons.task,
                                          color:
                                              task.isDone
                                                  ? completedColor
                                                  : colorScheme.primary,
                                          size: 24.sp,
                                        ),
                                      ),
                                      title: Text(
                                        task.title,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color: Colors.white.withOpacity(
                                                task.isDone ? 0.6 : 1,
                                              ),
                                              decoration:
                                                  task.isDone
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null,
                                            ),
                                      ),
                                      subtitle: Text(
                                        task.description.isNotEmpty
                                            ? task.description
                                            : "No description",
                                        style: theme.textTheme.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: GestureDetector(
                                        onTap:
                                            () => context
                                                .read<TaskCubit>()
                                                .toggleTask(task),
                                        child: Container(
                                          height: 24.h,
                                          width: 24.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                task.isDone
                                                    ? completedColor
                                                    : Colors.transparent,
                                            border:
                                                task.isDone
                                                    ? null
                                                    : Border.all(
                                                      color: Colors.white30,
                                                      width: 2,
                                                    ),
                                          ),
                                          child:
                                              task.isDone
                                                  ? Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 16.sp,
                                                  )
                                                  : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount:
                                  todayTasks.length > 3 ? 3 : todayTasks.length,
                            ),
                          );
                        }

                        return SliverToBoxAdapter(child: Container());
                      },
                    ),

                    // // View All Tasks Link
                    // BlocBuilder<TaskCubit, TaskState>(
                    //   builder: (context, state) {
                    //     if (state is TaskLoaded && state.tasks.isNotEmpty) {
                    //       return SliverToBoxAdapter(
                    //         child: AnimatedBuilder(
                    //           animation: _animationController,
                    //           builder: (context, child) {
                    //             return Transform.translate(
                    //               offset: Offset(
                    //                 (1 - _animationController.value) * 20,
                    //                 0,
                    //               ),
                    //               child: Opacity(
                    //                 opacity: _animationController.value,
                    //                 child: child,
                    //               ),
                    //             );
                    //           },
                    //           child: GestureDetector(
                    //             onTap:
                    //                 () => NavigationHelper.goToHomeWithTab(
                    //                   context,
                    //                   2,
                    //                 ),
                    //             child: Container(
                    //               margin: EdgeInsets.symmetric(
                    //                 horizontal: 20.w,
                    //               ),
                    //               padding: EdgeInsets.symmetric(vertical: 12.h),
                    //               child: Row(
                    //                 mainAxisAlignment: MainAxisAlignment.center,
                    //                 children: [
                    //                   Text(
                    //                     "View All Tasks",
                    //                     style: GoogleFonts.poppins(
                    //                       fontSize: 14.sp,
                    //                       color: colorScheme.primary,
                    //                       fontWeight: FontWeight.w500,
                    //                     ),
                    //                   ),
                    //                   SizedBox(width: 8.w),
                    //                   Icon(
                    //                     Icons.arrow_forward_ios,
                    //                     size: 14.sp,
                    //                     color: colorScheme.primary,
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       );
                    //     }
                    //     return SliverToBoxAdapter(child: Container());
                    //   },
                    // ),

                    // Habits Header
                    SliverToBoxAdapter(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              (1 - _animationController.value) * 20,
                              0,
                            ),
                            child: Opacity(
                              opacity: _animationController.value,
                              child: child,
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Magic Habits",
                              style: theme.textTheme.headlineMedium,
                            ),
                            GestureDetector(
                              onTap: () => context.go('/habits'),
                              child: Row(
                                children: [
                                  Text(
                                    "View All",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.auto_awesome_mosaic,
                                    color: Colors.amberAccent,
                                    size: 20.sp,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ).paddingOnly(
                          left: 20.w,
                          right: 20.w,
                          top: 30.h,
                          bottom: 16.h,
                        ),
                      ),
                    ),

                    // Habits Grid with Real Data
                    BlocBuilder<HabitCubit, HabitState>(
                      builder: (context, state) {
                        if (state is HabitsLoaded) {
                          if (state.habits.isEmpty) {
                            return SliverToBoxAdapter(
                              child: AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      (1 - _animationController.value) * 30,
                                    ),
                                    child: Opacity(
                                      opacity: _animationController.value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 20.h,
                                  ),
                                  padding: EdgeInsets.all(40.w),
                                  decoration: BoxDecoration(
                                    color: theme.cardTheme.color,
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.auto_awesome_mosaic,
                                        size: 48.sp,
                                        color: Colors.amberAccent.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        "No habits yet",
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(color: Colors.white70),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Create your first magical habit!",
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return SliverToBoxAdapter(
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _animationController.value,
                                  child: Opacity(
                                    opacity: _animationController.value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                height: 140.h,
                                margin: EdgeInsets.only(
                                  left: 20.w,
                                  bottom: 20.h,
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount:
                                      state.habits.length > 4
                                          ? 4
                                          : state.habits.length,
                                  itemBuilder: (context, index) {
                                    final habit = state.habits[index];

                                    // Calculate progress based on today's completion
                                    final today = DateTime.now();
                                    final todayCompletion =
                                        habit.completedDates
                                            .where(
                                              (completion) =>
                                                  completion.year ==
                                                      today.year &&
                                                  completion.month ==
                                                      today.month &&
                                                  completion.day == today.day,
                                            )
                                            .isNotEmpty;

                                    final progress = habit.progress;

                                    // Staggered animation for each habit card
                                    final itemAnimation = Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: _animationController,
                                        curve: Interval(
                                          0.3 + 0.1 * index,
                                          0.7 + 0.1 * index,
                                          curve: Curves.easeOutQuart,
                                        ),
                                      ),
                                    );

                                    return AnimatedBuilder(
                                      animation: itemAnimation,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(
                                            (1 - itemAnimation.value) * 60,
                                            0,
                                          ),
                                          child: Opacity(
                                            opacity: itemAnimation.value,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: GestureDetector(
                                        onTap: () {
                                          // Navigate to habit details page
                                          NavigationHelper.goToHabitDetails(
                                            context,
                                            habit,
                                          );
                                        },
                                        child: HabitCard(
                                          icon: habit.icon,
                                          title: habit.title,
                                          progress: progress,
                                          color: habit.color,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverToBoxAdapter(
                          child: SizedBox(
                            height: 140.h,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Bottom space
                    SliverToBoxAdapter(child: SizedBox(height: 80.h)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom Header Action Button Widget
class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> gradient;
  final double delay;
  final AnimationController animationController;

  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
    required this.gradient,
    required this.delay,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(delay, delay + 0.3, curve: Curves.elasticOut),
      ),
    );

    return AnimatedBuilder(
      animation: itemAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: itemAnimation.value,
          child: Transform.rotate(
            angle: (1 - itemAnimation.value) * 0.5,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44.h,
          width: 44.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20.sp),
        ),
      ),
    );
  }
}
