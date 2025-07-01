import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:task_day/controller/habit_cubit/habit_cubit.dart';
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

class _HabitsScreenState extends State<HabitsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late AnimationController _animationController;

  // Sample data for demonstration - combined list for all habits
  final List<HabitModel> _allHabits = [];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Load habits once when screen is created
    _loadHabits();
  }

  // Separate method to load habits
  void _loadHabits() {
    // Small delay to ensure widget is properly mounted
    Future.microtask(() {
      if (mounted) {
        context.read<HabitCubit>().getHabits();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Refresh habits by calling the cubit
    context.read<HabitCubit>().getHabits();
  }

  void _incrementHabitProgress(String habitId) {
    // Find the habit in _allHabits
    final habitIndex = _allHabits.indexWhere(
      (h) => h.id == habitId && h.isMeasurable == true,
    );

    if (habitIndex != -1) {
      final habit = _allHabits[habitIndex];
      // Only increment if not already at the target
      if ((habit.currentValue ?? 0) < (habit.targetValue ?? 0)) {
        // Call the HabitCubit to update and persist the habit
        context.read<HabitCubit>().completeHabit(habit);
      }
    }
  }

  void _toggleHabitCompletion(String habitId) {
    // Find the habit in _allHabits
    final habitIndex = _allHabits.indexWhere(
      (h) => h.id == habitId && h.isMeasurable == false,
    );

    if (habitIndex != -1) {
      final habit = _allHabits[habitIndex];

      // Check if habit is completed today based on completedDates
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final isCompletedToday = habit.completedDates.any((date) {
        final habitDate = DateTime(date.year, date.month, date.day);
        return habitDate.isAtSameMomentAs(today);
      });

      // If habit is already completed today, reset it
      if (isCompletedToday) {
        context.read<HabitCubit>().resetHabit(habit);
      } else {
        // Otherwise, mark it as completed
        context.read<HabitCubit>().completeHabit(habit);
      }
    }
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
            body: BlocConsumer<HabitCubit, HabitState>(
              listener: (context, state) {
                if (state is HabitError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.toString())));
                } else if (state is HabitCompleted ||
                    state is HabitUpdated ||
                    state is HabitDeleted ||
                    state is HabitAdded) {
                  // Refresh the habits list after any habit state change
                  context.read<HabitCubit>().getHabits();
                } else if (state is HabitsLoaded) {
                  // Update local habits list and trigger UI rebuild
                  setState(() {
                    _allHabits.clear();
                    _allHabits.addAll(state.habits);
                  });
                }
              },
              builder: (context, state) {
                if (state is HabitsLoaded) {
                  _allHabits.clear();
                  _allHabits.addAll(state.habits);
                }
                return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  color: colorScheme.secondary,
                  onRefresh: _refreshData,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [colorScheme.surface, colorScheme.surface],
                      ),
                    ),
                    child: SafeArea(
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                                              borderRadius:
                                                  BorderRadius.circular(15.r),
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
                                          AnimatedBuilder(
                                            animation: _animationController,
                                            builder: (context, child) {
                                              return Transform.translate(
                                                offset: Offset(
                                                  0,
                                                  (1 -
                                                          _animationController
                                                              .value) *
                                                      20,
                                                ),
                                                child: Opacity(
                                                  opacity:
                                                      _animationController
                                                          .value,
                                                  child: Text(
                                                    'Magic Habits',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 32.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      foreground:
                                                          Paint()
                                                            ..shader =
                                                                LinearGradient(
                                                                  colors: [
                                                                    Colors
                                                                        .white,
                                                                    colorScheme
                                                                        .secondary,
                                                                  ],
                                                                ).createShader(
                                                                  Rect.fromLTWH(
                                                                    0,
                                                                    0,
                                                                    200.w,
                                                                    70.h,
                                                                  ),
                                                                ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
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
                                              colorScheme.primary.withOpacity(
                                                0.7,
                                              ),
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
                                  SizedBox(height: 12.h),

                                  // Last reset info
                                  SizedBox(height: 16.h),

                                  // Magical stats section - apply animation
                                  AnimatedBuilder(
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
                                      padding: EdgeInsets.all(20.sp),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            colorScheme.primary.withOpacity(
                                              0.7,
                                            ),
                                            colorScheme.surface.withOpacity(
                                              0.7,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.primary
                                                .withOpacity(0.2),
                                            blurRadius: 15,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
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
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Habits Section Title - animated
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                10.h,
                                20.w,
                                16.h,
                              ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'All Habits',
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        // Add your onTap logic here
                                        context.go("/create-habit");
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 8.h,
                                        ),
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
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 20.sp,
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              'New Habit',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14.sp,
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

                          // Streak Calendar - animated
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 8.h, 0, 16.h),
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
                                child:
                                    _allHabits.isNotEmpty
                                        ? HabitStreakCalendar(
                                          habit: _allHabits.first,
                                          daysToShow:
                                              7, // Always show 7 days regardless of screen size
                                        )
                                        : SizedBox(
                                          height: 20.h,
                                        ), // Show empty space if no habits
                              ),
                            ),
                          ),

                          // Habits List - with animation
                          SliverPadding(
                            padding: EdgeInsets.all(16.sp),
                            sliver:
                                _allHabits.isEmpty
                                    ? SliverFillRemaining(
                                      child: AnimatedBuilder(
                                        animation: _animationController,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _animationController.value,
                                            child: Opacity(
                                              opacity:
                                                  _animationController.value,
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: _buildEmptyState(
                                          'No habits yet',
                                          'Add your first habit to start building your perfect routine',
                                          colorScheme,
                                        ),
                                      ),
                                    )
                                    : SliverList(
                                      delegate: SliverChildBuilderDelegate((
                                        context,
                                        index,
                                      ) {
                                        final habit = _allHabits[index];

                                        // Staggered animation effect
                                        final itemAnimation = Tween<double>(
                                          begin: 0.0,
                                          end: 1.0,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: _animationController,
                                            curve: Interval(
                                              (0.1 + 0.1 * index).clamp(
                                                0.0,
                                                0.9,
                                              ), // Staggered start, clamped
                                              (0.6 + 0.1 * index).clamp(
                                                0.0,
                                                1.0,
                                              ), // Staggered end, clamped to max 1.0
                                              curve: Curves.easeOutQuart,
                                            ),
                                          ),
                                        );

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
                                          child:
                                              habit.isMeasurable == true
                                                  ? MeasurableHabitCard(
                                                    habit: habit,
                                                    onIncrement:
                                                        () =>
                                                            _incrementHabitProgress(
                                                              habit.id,
                                                            ),
                                                  )
                                                  : NonMeasurableHabitCard(
                                                    habit: habit,
                                                    onToggle:
                                                        () =>
                                                            _toggleHabitCompletion(
                                                              habit.id,
                                                            ),
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
                );
              },
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
