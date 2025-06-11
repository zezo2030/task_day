import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:task_day/core/themes/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_day/controller/status_cubit/status_cubit.dart';
import 'package:task_day/services/quick_stats_service.dart';
import 'package:intl/intl.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool _showAllHabits = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Load data
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
                  colors: [const Color(0xFF191B2F), const Color(0xFF0F1227)],
                ),
              ),
              child: SafeArea(
                child: BlocBuilder<StatusCubit, StatusState>(
                  builder: (context, state) {
                    if (state is StatusLoading) {
                      return _buildLoadingState(colorScheme);
                    } else if (state is StatusError) {
                      return _buildErrorState(state.message, colorScheme);
                    } else if (state is StatusLoaded) {
                      return _buildLoadedState(state.statusData, colorScheme);
                    }

                    return _buildInitialState(colorScheme);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: colorScheme.primary,
            strokeWidth: 3.w,
          ),
          SizedBox(height: 20.h),
          Text(
            'Loading your progress...',
            style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FluentSystemIcons.ic_fluent_error_circle_filled,
            size: 60.sp,
            color: Colors.red.shade400,
          ),
          SizedBox(height: 20.h),
          Text(
            'Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30.h),
          ElevatedButton.icon(
            onPressed: () => context.read<StatusCubit>().loadStatusData(),
            icon: Icon(FluentSystemIcons.ic_fluent_arrow_clockwise_regular),
            label: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FluentSystemIcons.ic_fluent_data_bar_vertical_filled,
            size: 80.sp,
            color: colorScheme.primary,
          ),
          SizedBox(height: 24.h),
          Text(
            'Your Progress Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            'Track your daily achievements and progress',
            style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(StatusData statusData, ColorScheme colorScheme) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header Section
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: _buildHeader(statusData, colorScheme),
            ),
          ),
        ),

        // Today's Overview Cards
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value * 1.5),
              child: _buildTodayOverview(statusData, colorScheme),
            ),
          ),
        ),

        // Progress Charts Section
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value * 2),
              child: _buildProgressSection(statusData, colorScheme),
            ),
          ),
        ),

        // Weekly Summary
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value * 2.5),
              child: _buildWeeklySummary(statusData, colorScheme),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 20.h)),
        // Habits with Streaks
        if (statusData.habitsWithStreaks.isNotEmpty)
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value * 3),
                child: _buildHabitsStreakSection(statusData, colorScheme),
              ),
            ),
          ),

        // Bottom padding
        SliverToBoxAdapter(child: SizedBox(height: 40.h)),
      ],
    );
  }

  Widget _buildHeader(StatusData statusData, ColorScheme colorScheme) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d').format(now);

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Text(
            'Progress Overview',
            style: GoogleFonts.poppins(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            formattedDate,
            style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayOverview(StatusData statusData, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Summary',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Tasks',
                  '${statusData.todayCompletedTasks}/${statusData.todayTotalTasks}',
                  statusData.todayTasksCompletionRate,
                  FluentSystemIcons.ic_fluent_document_filled,
                  colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildSummaryCard(
                  'Habits',
                  '${statusData.todayCompletedHabits}/${statusData.todayTotalHabits}',
                  statusData.todayHabitsCompletionRate,
                  FluentSystemIcons.ic_fluent_checkmark_circle_filled,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.w),
          // Combined completion card
          _buildSummaryCard(
            'Overall Progress',
            '${statusData.todayCompletedItems}/${statusData.todayTotalItems}',
            statusData.todayCombinedCompletionRate,
            FluentSystemIcons.ic_fluent_trophy_filled,
            Colors.amber,
          ),
          SizedBox(height: 12.w),
          _buildProductivityCard(statusData, colorScheme),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    double percentage,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24.sp),
              Spacer(),
              Text(
                '${(percentage * 100).round()}%',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white70),
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityCard(
    StatusData statusData,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.secondary.withOpacity(0.2),
            colorScheme.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.secondary.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FluentSystemIcons.ic_fluent_trophy_filled,
                color: Colors.amber,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Productivity Score',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Text(
                '${statusData.currentProductivityScore.round()}/100',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          LinearProgressIndicator(
            value: statusData.currentProductivityScore / 100,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            borderRadius: BorderRadius.circular(4.r),
            minHeight: 8.h,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(StatusData statusData, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Trends',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildTrendCard(
                  'Weekly',
                  statusData.weeklyProgress,
                  'This Week',
                  FluentSystemIcons.ic_fluent_notebook_filled,
                  colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTrendCard(
                  'Monthly',
                  statusData.monthlyProgress,
                  'This Month',
                  FluentSystemIcons.ic_fluent_home_filled,
                  colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(
    String title,
    double progress,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 12.h),
          Text(
            '${(progress * 100).round()}%',
            style: GoogleFonts.poppins(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(StatusData statusData, ColorScheme colorScheme) {
    // Calculate weekly average for display
    final weeklyRates = statusData.weeklyCompletionRates;
    final averageCompletion =
        weeklyRates.isEmpty
            ? 0.0
            : weeklyRates.reduce((a, b) => a + b) / weeklyRates.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FluentSystemIcons.ic_fluent_status_filled,
                color: colorScheme.primary,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'This Week',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${(averageCompletion * 100).round()}% Complete',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Combined completion info
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  FluentSystemIcons.ic_fluent_checkmark_circle_filled,
                  color: Colors.green,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Today: ${statusData.todayCompletedItems}/${statusData.todayTotalItems} items',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Text(
                  '${(statusData.todayCombinedCompletionRate * 100).round()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildWeekDaysFromData(weeklyRates),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDay(String day, double completion) {
    final color =
        completion >= 0.8
            ? Colors.green
            : completion >= 0.5
            ? Colors.orange
            : Colors.red.shade400;

    return Column(
      children: [
        Text(
          day,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 32.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                height: 40.h * completion,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(8.r),
                    top: completion == 1.0 ? Radius.circular(8.r) : Radius.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${(completion * 100).round()}%',
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildWeekDaysFromData(List<double> weeklyRates) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return List.generate(7, (index) {
      final completion = index < weeklyRates.length ? weeklyRates[index] : 0.0;
      return _buildWeekDay(dayNames[index], completion);
    });
  }

  Widget _buildHabitsStreakSection(
    StatusData statusData,
    ColorScheme colorScheme,
  ) {
    final habitsToShow =
        _showAllHabits
            ? statusData.habitsWithStreaks
            : statusData.habitsWithStreaks.take(5).toList();

    final hasMoreHabits = statusData.habitsWithStreaks.length > 5;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FluentSystemIcons.ic_fluent_trophy_filled,
                color: Colors.orange,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Habit Streaks',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Text(
                'Longest: ${statusData.currentLongestStreak} days',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...habitsToShow.map(
            (habit) => Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color:
                      habit.isCompletedToday
                          ? Colors.green.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
                  width: 1.w,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: habit.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(habit.icon, color: habit.color, size: 20.sp),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (habit.isCompletedToday)
                          Text(
                            '✓ Completed today',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FluentSystemIcons.ic_fluent_add_filled,
                          color: Colors.orange,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${habit.currentStreak}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // زر عرض المزيد/أقل
          if (hasMoreHabits)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAllHabits = !_showAllHabits;
                    });
                  },
                  icon: Icon(
                    _showAllHabits
                        ? FluentSystemIcons.ic_fluent_chevron_up_filled
                        : FluentSystemIcons.ic_fluent_chevron_down_filled,
                    color: Colors.orange,
                    size: 16.sp,
                  ),
                  label: Text(
                    _showAllHabits
                        ? 'Show Less'
                        : 'Show ${statusData.habitsWithStreaks.length - 5} More',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
