import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:task_day/core/themes/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_day/controller/status_cubit/status_cubit.dart';
import 'package:task_day/services/quick_stats_service.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    );
    _animationController.forward();

    // تحميل البيانات باستخدام النهج الهجين
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatusCubit>().loadStatusData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: BlocBuilder<StatusCubit, StatusState>(
                  builder: (context, state) {
                    if (state is StatusLoading) {
                      return _buildLoadingState(theme);
                    } else if (state is StatusError) {
                      return _buildErrorState(state.message, theme);
                    } else if (state is StatusLoaded) {
                      return _buildLoadedState(
                        state.statusData,
                        theme,
                        colorScheme,
                      );
                    }

                    return _buildInitialState(theme);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // حالات مختلفة لـ BlocBuilder
  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          SizedBox(height: 16.h),
          Text('Loading your progress...', style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<StatusCubit>().loadStatusData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FluentSystemIcons.ic_fluent_data_bar_vertical_filled,
            size: 64.sp,
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Welcome to your Status Screen',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Pull down to refresh your progress',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(
    StatusData statusData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return RefreshIndicator(
      onRefresh: () => context.read<StatusCubit>().refreshStatusData(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(statusData, colorScheme)),
          SliverToBoxAdapter(
            child: _buildProgressSection(statusData, theme, colorScheme),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
              child: Text(
                'Habit Streaks',
                style: theme.textTheme.headlineMedium,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final habit = statusData.habitsWithStreaks[index];
              final delay = Duration(milliseconds: 100 * index);

              return FutureBuilder(
                future: Future.delayed(delay),
                builder: (context, snapshot) {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity:
                        snapshot.connectionState == ConnectionState.done
                            ? 1
                            : 0,
                    child: _buildHabitStreakItem(habit, theme, colorScheme),
                  );
                },
              );
            }, childCount: statusData.habitsWithStreaks.length),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 20.h)),
        ],
      ),
    );
  }

  Widget _buildHeader(StatusData statusData, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.7),
                colorScheme.surface.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(15.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FluentSystemIcons.ic_fluent_checkmark_circle_filled,
                      size: 30.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Progress',
                          style: GoogleFonts.poppins(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _getMotivationalMessage(
                            statusData.todayTasksCompletionRate,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    '${statusData.todayCompletedTasks}/${statusData.todayTotalTasks}',
                    'Tasks',
                    Icons.task_alt,
                    colorScheme.secondary,
                  ),
                  _buildStatItem(
                    '${statusData.currentLongestStreak}',
                    'Day Streak',
                    Icons.local_fire_department,
                    Colors.amber,
                  ),
                  _buildStatItem(
                    '${(statusData.todayTasksCompletionRate * 100).toInt()}%',
                    'Rate',
                    Icons.insights,
                    colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(
    StatusData statusData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Progress', style: theme.textTheme.headlineMedium),
            SizedBox(height: 15.h),
            LinearPercentIndicator(
              animation: true,
              animationDuration: 1000,
              lineHeight: 15.0,
              percent: statusData.weeklyProgress.clamp(0.0, 1.0),
              barRadius: Radius.circular(8.r),
              progressColor: colorScheme.secondary,
              backgroundColor: Colors.white.withOpacity(0.1),
              center: Text(
                '${(statusData.weeklyProgress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text('Monthly Progress', style: theme.textTheme.headlineMedium),
            SizedBox(height: 15.h),
            LinearPercentIndicator(
              animation: true,
              animationDuration: 1000,
              lineHeight: 15.0,
              percent: statusData.monthlyProgress.clamp(0.0, 1.0),
              barRadius: Radius.circular(8.r),
              progressColor: colorScheme.primary,
              backgroundColor: Colors.white.withOpacity(0.1),
              center: Text(
                '${(statusData.monthlyProgress * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitStreakItem(
    HabitStreakInfo habit,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: habit.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(habit.icon, color: habit.color),
        ),
        title: Text(habit.title, style: theme.textTheme.bodyLarge),
        subtitle:
            habit.isCompletedToday
                ? Text(
                  '✓ Completed today',
                  style: TextStyle(color: Colors.green, fontSize: 12.sp),
                )
                : null,
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                color: Colors.amber,
                size: 18.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                '${habit.currentStreak} days',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // دالة لإرجاع رسائل تحفيزية بناء على معدل الإنجاز
  String _getMotivationalMessage(double completionRate) {
    if (completionRate >= 0.8) {
      return 'You\'re crushing it today! 🔥';
    } else if (completionRate >= 0.6) {
      return 'Great progress! Keep going! 💪';
    } else if (completionRate >= 0.4) {
      return 'You\'re on the right track! 👍';
    } else if (completionRate > 0) {
      return 'Every step counts! Keep moving! 🚀';
    } else {
      return 'Ready to start your day? Let\'s go! ✨';
    }
  }
}
