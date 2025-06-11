import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_day/controller/habit_cubit/habit_cubit.dart';

class HabitDetailsScreen extends StatefulWidget {
  final HabitModel habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen>
    with TickerProviderStateMixin {
  late HabitModel _habit;
  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonPulseAnimation;
  late Animation<double> _buttonScaleAnimation;

  // Animation flags for action effects
  bool _isIncrementAnimating = false;
  bool _isDecrementAnimating = false;
  bool _isCompletionAnimating = false;

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;

    // Initialize main animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Initialize button animation controller
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Create main animations
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Create button animations
    _buttonPulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation once without repeating
    _animationController.forward();

    // Fetch the latest data for this habit when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitCubit>().getHabits();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the habit color
    final Color habitColor = _habit.color;

    // Calculate progress
    final double progress = _habit.progress;

    // Check if habit is completed today
    final bool isCompletedToday = _isCompletedToday();

    // Check if it's a measurable habit and target is reached
    final bool isTargetReached = _isTargetReached();

    return BlocConsumer<HabitCubit, HabitState>(
      listener: (context, state) {
        if (state is HabitCompleted && state.habit.id == _habit.id) {
          setState(() {
            _habit = state.habit;
          });
        } else if (state is HabitUpdated && state.habit.id == _habit.id) {
          setState(() {
            _habit = state.habit;
          });
        } else if (state is HabitsLoaded) {
          final updatedHabit = state.habits.firstWhere(
            (h) => h.id == _habit.id,
            orElse: () => _habit,
          );

          if (updatedHabit.id == _habit.id && updatedHabit != _habit) {
            setState(() {
              _habit = updatedHabit;
            });
          }
        }
      },
      builder: (context, state) {
        return Container(
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
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // App Bar as SliverAppBar
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    floating: true,
                    snap: true,
                    leading: IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop(_habit);
                        } else {
                          context.go('/habits');
                        }
                      },
                    ),
                    actions: [
                      IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                        onPressed: () async {
                          // Navigate to edit habit screen
                          final result = await context.push(
                            '/edit-habit/${_habit.id}',
                            extra: _habit,
                          );

                          // If habit was updated, refresh the current habit data
                          if (result is HabitModel) {
                            setState(() {
                              _habit = result;
                            });
                            // Also refresh the habits list
                            context.read<HabitCubit>().getHabits();
                          }
                        },
                      ),
                      IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 18.sp,
                          ),
                        ),
                        onPressed: () {
                          _showDeleteConfirmationDialog();
                        },
                      ),
                    ],
                  ),

                  // Main content as SliverPadding and SliverList
                  SliverPadding(
                    padding: EdgeInsets.all(16.w),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Habit title with enhanced styling
                        FadeTransition(
                          opacity: _fadeInAnimation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(_animationController),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        habitColor.withOpacity(0.3),
                                        habitColor.withOpacity(0.1),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: habitColor.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _habit.icon,
                                    color: habitColor,
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
                                        _habit.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (isCompletedToday) ...[
                                        SizedBox(height: 4.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 16.sp,
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                'Completed Today',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12.sp,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Enhanced progress section for measurable habits
                        if (_habit.isMeasurable) ...[
                          FadeTransition(
                            opacity: _fadeInAnimation,
                            child: Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: habitColor.withOpacity(0.1),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${_habit.currentValue ?? 0} of ${_habit.targetValue}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: habitColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                        ),
                                        child: Text(
                                          "${(progress * 100).toInt()}%",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: habitColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.h),

                                  // Enhanced animated progress bar
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(
                                      milliseconds: 1200,
                                    ),
                                    curve: Curves.easeOutQuart,
                                    tween: Tween<double>(
                                      begin: 0.0,
                                      end: progress,
                                    ),
                                    builder: (context, animValue, child) {
                                      return Container(
                                        height: 12.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                          child: Stack(
                                            children: [
                                              LinearProgressIndicator(
                                                value: animValue,
                                                backgroundColor:
                                                    Colors.transparent,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(habitColor),
                                                minHeight: 12.h,
                                              ),
                                              // Shimmer effect
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6.r,
                                                        ),
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.transparent,
                                                        Colors.white
                                                            .withOpacity(0.1),
                                                        Colors.transparent,
                                                      ],
                                                      stops: const [
                                                        0.0,
                                                        0.5,
                                                        1.0,
                                                      ],
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  SizedBox(height: 20.h),

                                  // Enhanced increment/decrement buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Decrement button
                                      _buildEnhancedActionButton(
                                        onTap:
                                            (isTargetReached &&
                                                    isCompletedToday)
                                                ? null
                                                : _decrementValue,
                                        icon: Icons.remove,
                                        color: Colors.redAccent,
                                        isDisabled:
                                            (isTargetReached &&
                                                isCompletedToday) ||
                                            (_habit.currentValue ?? 0) <= 0,
                                        animating: _isDecrementAnimating,
                                      ),

                                      SizedBox(width: 20.w),

                                      // Value display with enhanced styling
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24.w,
                                          vertical: 12.h,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withOpacity(0.1),
                                              Colors.white.withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          border: Border.all(
                                            color: habitColor.withOpacity(0.3),
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: habitColor.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          "${_habit.currentValue ?? 0}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 28.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 20.w),

                                      // Increment button
                                      _buildEnhancedActionButton(
                                        onTap:
                                            (isTargetReached &&
                                                    isCompletedToday)
                                                ? null
                                                : _incrementValue,
                                        icon: Icons.add,
                                        color: Colors.greenAccent,
                                        isDisabled:
                                            (isTargetReached &&
                                                isCompletedToday) ||
                                            (_habit.currentValue ?? 0) >=
                                                (_habit.targetValue ?? 0),
                                        animating: _isIncrementAnimating,
                                      ),
                                    ],
                                  ),

                                  // Disable message for completed habits
                                  if (isTargetReached && isCompletedToday) ...[
                                    SizedBox(height: 16.h),
                                    Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        border: Border.all(
                                          color: Colors.amber.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.amber,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: Text(
                                              'Habit completed for today - Cannot be modified',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.sp,
                                                color: Colors.amber,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],

                        SizedBox(height: 24.h),

                        // Description
                        FadeTransition(
                          opacity: _fadeInAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Description",
                                style: GoogleFonts.poppins(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Container(
                                padding: EdgeInsets.all(20.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.08),
                                      Colors.white.withOpacity(0.03),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: habitColor.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _habit.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.sp,
                                    color: Colors.white.withOpacity(0.8),
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Complete/Reset button for non-measurable habits
                        if (!_habit.isMeasurable)
                          FadeTransition(
                            opacity: _fadeInAnimation,
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: ElevatedButton(
                                  onPressed: _toggleHabitCompletion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isCompletedToday
                                            ? Colors.orange
                                            : Colors.green,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24.w,
                                      vertical: 16.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                    elevation: 8,
                                    shadowColor: (isCompletedToday
                                            ? Colors.orange
                                            : Colors.green)
                                        .withOpacity(0.3),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isCompletedToday
                                            ? Icons.refresh
                                            : Icons.check,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        isCompletedToday
                                            ? "Reset"
                                            : "Mark as Complete",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: 24.h),

                        // Completion history
                        FadeTransition(
                          opacity: _fadeInAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Completion History",
                                style: GoogleFonts.poppins(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              _buildCompletionHistory(),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Enhanced action button with improved animations and disabled state
  Widget _buildEnhancedActionButton({
    required VoidCallback? onTap,
    required IconData icon,
    required Color color,
    required bool isDisabled,
    required bool animating,
  }) {
    return AnimatedBuilder(
      animation: _buttonAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: animating ? _buttonPulseAnimation.value : 1.0,
          child: Opacity(
            opacity: isDisabled ? 0.3 : 1.0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDisabled ? null : onTap,
                borderRadius: BorderRadius.circular(16.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient:
                        isDisabled
                            ? LinearGradient(
                              colors: [
                                Colors.grey.withOpacity(0.1),
                                Colors.grey.withOpacity(0.05),
                              ],
                            )
                            : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                color.withOpacity(0.3),
                                color.withOpacity(0.15),
                              ],
                            ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color:
                          isDisabled
                              ? Colors.grey.withOpacity(0.2)
                              : color.withOpacity(0.4),
                      width: 1,
                    ),
                    boxShadow:
                        isDisabled
                            ? []
                            : [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                  ),
                  child: Icon(
                    icon,
                    color: isDisabled ? Colors.grey : color,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to build completion history
  Widget _buildCompletionHistory() {
    if (_habit.completedDates.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.white.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 60.sp,
                color: Colors.white.withOpacity(0.3),
              ),
              SizedBox(height: 16.h),
              Text(
                "No completions yet",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Complete this habit to start tracking your progress",
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: Colors.white.withOpacity(0.3),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Sort dates from newest to oldest
    final sortedDates = List<DateTime>.from(_habit.completedDates)
      ..sort((a, b) => b.compareTo(a));

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: sortedDates.length,
        separatorBuilder:
            (context, index) =>
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final isToday = _isDateToday(date);

          return Container(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _habit.color.withOpacity(0.3),
                      _habit.color.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _habit.color.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(Icons.check, color: _habit.color, size: 20.sp),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('EEEE, MMM dd, yyyy').format(date),
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        color: Colors.white,
                        fontWeight:
                            isToday ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isToday)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _habit.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Today',
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: _habit.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                DateFormat('hh:mm a').format(date),
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to check if a date is today
  bool _isDateToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isAtSameMomentAs(today);
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF191B2F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Delete Habit',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to delete this habit? This action cannot be undone.',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Delete the habit
                  context.read<HabitCubit>().deleteHabit(_habit);
                  // Close the dialog
                  context.pop();
                  // Go back to previous screen
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/habits');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // Check if habit is completed today
  bool _isCompletedToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _habit.completedDates.any((date) {
      final habitDate = DateTime(date.year, date.month, date.day);
      return habitDate.isAtSameMomentAs(today);
    });
  }

  // Toggle habit completion for today with animation effect
  void _toggleHabitCompletion() {
    setState(() {
      _isCompletionAnimating = true;
    });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_isCompletedToday()) {
      // Update UI immediately
      setState(() {
        _habit = _habit.copyWith(
          completedDates:
              _habit.completedDates.where((date) {
                final habitDate = DateTime(date.year, date.month, date.day);
                return !habitDate.isAtSameMomentAs(today);
              }).toList(),
        );
      });

      // Then reset habit in backend
      context.read<HabitCubit>().resetHabit(_habit);
    } else {
      // Update UI immediately
      setState(() {
        _habit = _habit.copyWith(
          completedDates: [..._habit.completedDates, now],
        );
      });

      // Complete habit in backend
      context.read<HabitCubit>().completeHabit(_habit);
    }

    // Ensure habits list gets refreshed
    Future.delayed(const Duration(milliseconds: 100), () {
      context.read<HabitCubit>().getHabits();
    });

    // Reset animation state after short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isCompletionAnimating = false;
        });
      }
    });
  }

  // Check if measurable habit target is reached today
  bool _isTargetReached() {
    if (!_habit.isMeasurable || _habit.targetValue == null) return false;

    // Check if current value meets or exceeds target
    if ((_habit.currentValue ?? 0) >= _habit.targetValue!) {
      return true;
    }

    return false;
  }

  // Increment the current value for measurable habits
  void _incrementValue() {
    if (_habit.isMeasurable && _habit.targetValue != null) {
      final currentValue = _habit.currentValue ?? 0;
      final isCompleted = _isCompletedToday();
      final targetReached = _isTargetReached();

      // Prevent increment if already completed for today
      if (targetReached && isCompleted) return;

      if (currentValue < _habit.targetValue!) {
        // Start animation
        setState(() {
          _isIncrementAnimating = true;
          // Update UI immediately
          _habit = _habit.copyWith(currentValue: currentValue + 1);
        });

        // Trigger button pulse animation
        _buttonAnimationController.forward().then((_) {
          _buttonAnimationController.reverse();
        });

        // Update the habit via cubit
        context.read<HabitCubit>().updateHabit(_habit);

        // If we reached the target, mark it as completed
        if (currentValue + 1 >= _habit.targetValue! && !_isCompletedToday()) {
          final now = DateTime.now();
          // Update UI immediately
          setState(() {
            _habit = _habit.copyWith(
              completedDates: [..._habit.completedDates, now],
            );
          });
          context.read<HabitCubit>().completeHabit(_habit);
        }

        // Ensure habits list gets refreshed
        Future.delayed(const Duration(milliseconds: 100), () {
          context.read<HabitCubit>().getHabits();
        });

        // Reset animation state after short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isIncrementAnimating = false;
            });
          }
        });
      }
    }
  }

  // Decrement the current value for measurable habits
  void _decrementValue() {
    if (_habit.isMeasurable &&
        _habit.currentValue != null &&
        _habit.currentValue! > 0) {
      final isCompleted = _isCompletedToday();
      final targetReached = _isTargetReached();

      // Prevent decrement if completed for today and target is reached
      if (targetReached && isCompleted) return;

      final newValue = _habit.currentValue! - 1;

      // Start animation and update UI
      setState(() {
        _isDecrementAnimating = true;
        _habit = _habit.copyWith(currentValue: newValue);
      });

      // Trigger button pulse animation
      _buttonAnimationController.forward().then((_) {
        _buttonAnimationController.reverse();
      });

      // Update via cubit
      context.read<HabitCubit>().updateHabit(_habit);

      // If we're dropping below target after having completed, reset the habit
      if (_habit.targetValue != null &&
          newValue < _habit.targetValue! &&
          _isCompletedToday()) {
        // Update UI immediately
        setState(() {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          _habit = _habit.copyWith(
            completedDates:
                _habit.completedDates.where((date) {
                  final habitDate = DateTime(date.year, date.month, date.day);
                  return !habitDate.isAtSameMomentAs(today);
                }).toList(),
          );
        });

        context.read<HabitCubit>().resetHabit(_habit);
      }

      // Ensure habits list gets refreshed
      Future.delayed(const Duration(milliseconds: 100), () {
        context.read<HabitCubit>().getHabits();
      });

      // Reset animation state after short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isDecrementAnimating = false;
          });
        }
      });
    }
  }
}
