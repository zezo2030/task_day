import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:task_day/widgets/measurable_habit_card.dart';
import 'package:task_day/widgets/non_measurable_habit_card.dart';
import 'package:task_day/widgets/habit_streak_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_day/core/themes/app_theme.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Sample data for demonstration - combined list for all habits
  final List<HabitModel> _allHabits = [
    // Measurable habits
    HabitModel(
      id: '1',
      title: 'Drink Water',
      description: '8 glasses per day',
      icon: Icons.water_drop,
      color: Colors.blueAccent,
      isMeasurable: true,
      targetValue: 8,
      currentValue: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      completedDates: [
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().subtract(const Duration(days: 2)),
        DateTime.now().subtract(const Duration(days: 4)),
      ],
    ),
    // Non-measurable habit
    HabitModel(
      id: '4',
      title: 'Morning Meditation',
      description: 'Start day with 10 min meditation',
      icon: Icons.self_improvement,
      color: Colors.teal,
      isMeasurable: false,
      isDone: true,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      completedDates: [
        DateTime.now(),
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().subtract(const Duration(days: 2)),
      ],
    ),
    HabitModel(
      id: '2',
      title: 'Walk Steps',
      description: '10,000 steps daily',
      icon: Icons.directions_walk,
      color: Colors.orangeAccent,
      isMeasurable: true,
      targetValue: 10000,
      currentValue: 6500,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      completedDates: [
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().subtract(const Duration(days: 3)),
      ],
    ),
    HabitModel(
      id: '5',
      title: 'Journaling',
      description: 'Write daily reflections',
      icon: Icons.edit_note,
      color: Colors.deepPurple,
      isMeasurable: false,
      isDone: false,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      completedDates: [
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().subtract(const Duration(days: 3)),
      ],
    ),
    HabitModel(
      id: '3',
      title: 'Read Book',
      description: '20 pages per day',
      icon: Icons.menu_book,
      color: Colors.purpleAccent,
      isMeasurable: true,
      targetValue: 20,
      currentValue: 12,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      completedDates: [
        DateTime.now().subtract(const Duration(days: 2)),
        DateTime.now().subtract(const Duration(days: 3)),
        DateTime.now().subtract(const Duration(days: 4)),
      ],
    ),
    HabitModel(
      id: '6',
      title: 'Healthy Breakfast',
      description: 'Start with nutritious meal',
      icon: Icons.breakfast_dining,
      color: Colors.green,
      isMeasurable: false,
      isDone: false,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      completedDates: [
        DateTime.now().subtract(const Duration(days: 2)),
        DateTime.now().subtract(const Duration(days: 3)),
      ],
    ),
  ];

  Future<void> _refreshData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      // Refresh data if needed
    });
  }

  void _incrementHabitProgress(String habitId) {
    setState(() {
      final habitIndex = _allHabits.indexWhere(
        (h) => h.id == habitId && h.isMeasurable == true,
      );
      if (habitIndex != -1) {
        final habit = _allHabits[habitIndex];
        if ((habit.currentValue ?? 0) < (habit.targetValue ?? 0)) {
          _allHabits[habitIndex] = habit.copyWith(
            currentValue: (habit.currentValue ?? 0) + 1,
          );
        }
      }
    });
  }

  void _toggleHabitCompletion(String habitId) {
    setState(() {
      final habitIndex = _allHabits.indexWhere(
        (h) => h.id == habitId && h.isMeasurable == false,
      );
      if (habitIndex != -1) {
        final habit = _allHabits[habitIndex];
        final newIsDone = !(habit.isDone ?? false);

        // Update completedDates list if newly completed
        List<DateTime> newCompletedDates = List.from(habit.completedDates);
        if (newIsDone &&
            !habit.completedDates.any(
              (date) =>
                  DateTime.now().day == date.day &&
                  DateTime.now().month == date.month &&
                  DateTime.now().year == date.year,
            )) {
          newCompletedDates.add(DateTime.now());
        }

        _allHabits[habitIndex] = habit.copyWith(
          isDone: newIsDone,
          completedDates: newCompletedDates,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 380;

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
                  colors: [colorScheme.surface, colorScheme.background],
                ),
              ),
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                color: colorScheme.secondary,
                onRefresh: _refreshData,
                child: SafeArea(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Simple header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // App header with title and profile
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.sp),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              colorScheme.secondary,
                                              colorScheme.primary,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15.r,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colorScheme.primary
                                                  .withOpacity(0.3),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.auto_awesome,
                                          color: Colors.white,
                                          size: 24.sp,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        'Magic Habits',
                                        style: theme.textTheme.headlineLarge,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 42.h,
                                    width: 42.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          colorScheme.secondary.withOpacity(
                                            0.7,
                                          ),
                                          colorScheme.primary.withOpacity(0.7),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary
                                              .withOpacity(0.2),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.filter_list_rounded,
                                      color: Colors.white,
                                      size: 20.sp,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              // Magical stats section
                              Container(
                                padding: EdgeInsets.all(20.sp),
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
                                      color: colorScheme.primary.withOpacity(
                                        0.2,
                                      ),
                                      blurRadius: 15,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Build your ideal future, one habit at a time',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        color: Colors.white,
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildInfoCard(
                                          title: 'Total Habits',
                                          value: '${_allHabits.length}',
                                          icon:
                                              FluentSystemIcons
                                                  .ic_fluent_list_filled,
                                          isSmallScreen: isSmallScreen,
                                          color: colorScheme.secondary,
                                        ),
                                        Container(
                                          height: 40.h,
                                          width: 1,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        _buildInfoCard(
                                          title: 'Completed',
                                          value:
                                              '${_allHabits.where((h) => h.completedDates.any((date) => DateTime.now().day == date.day && DateTime.now().month == date.month && DateTime.now().year == date.year)).length}',
                                          icon:
                                              FluentSystemIcons
                                                  .ic_fluent_checkmark_filled,
                                          isSmallScreen: isSmallScreen,
                                          color: Colors.green,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Habits Section Title
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'All Habits',
                                style: theme.textTheme.headlineMedium,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome_mosaic,
                                    color: Colors.amberAccent,
                                    size: 20.sp,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Streak Calendar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child:
                              _allHabits.isNotEmpty
                                  ? HabitStreakCalendar(
                                    habit: _allHabits.first,
                                    daysToShow: isSmallScreen ? 5 : 7,
                                  )
                                  : SizedBox(
                                    height: 20.h,
                                  ), // Show empty space if no habits
                        ),
                      ),

                      // Habits List
                      SliverPadding(
                        padding: EdgeInsets.all(16.sp),
                        sliver:
                            _allHabits.isEmpty
                                ? SliverFillRemaining(
                                  child: _buildEmptyState(
                                    'No habits yet',
                                    'Add your first habit to start building your perfect routine',
                                    colorScheme,
                                  ),
                                )
                                : SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final habit = _allHabits[index];

                                    return habit.isMeasurable == true
                                        ? MeasurableHabitCard(
                                          habit: habit,
                                          onIncrement:
                                              () => _incrementHabitProgress(
                                                habit.id,
                                              ),
                                        )
                                        : NonMeasurableHabitCard(
                                          habit: habit,
                                          onToggle:
                                              () => _toggleHabitCompletion(
                                                habit.id,
                                              ),
                                        );
                                  }, childCount: _allHabits.length),
                                ),
                      ),

                      // Bottom padding
                      SliverToBoxAdapter(child: SizedBox(height: 80.h)),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: Container(
              height: 64.h,
              width: 64.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colorScheme.secondary, colorScheme.primary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.secondary.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () {
                  // Add new habit
                },
                child: Icon(Icons.add, color: Colors.white, size: 32.sp),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isSmallScreen,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10.w : 12.w,
        vertical: 4.h,
      ),
      child: Row(
        children: [
          Container(
            height: isSmallScreen ? 32.h : 36.h,
            width: isSmallScreen ? 32.w : 36.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isSmallScreen ? 14.sp : 16.sp,
            ),
          ),
          SizedBox(width: isSmallScreen ? 8.w : 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 16.sp : 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 10.sp : 12.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.sp),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.secondary.withOpacity(0.5),
                  colorScheme.primary.withOpacity(0.5),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FluentSystemIcons.ic_fluent_notebook_filled,
              size: 60.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.white70,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
