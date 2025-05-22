import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
    with SingleTickerProviderStateMixin {
  late HabitModel _habit;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Animation flags for action effects
  bool _isIncrementAnimating = false;
  bool _isDecrementAnimating = false;
  bool _isCompletionAnimating = false;

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Create animations
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the habit color
    final Color habitColor = _habit.color;

    // Calculate progress
    final double progress = _habit.progress;

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
                      onPressed: () => Navigator.pop(context, _habit),
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
                        onPressed: () {
                          // Navigate to edit screen (not implemented yet)
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
                          // Show confirmation dialog before deleting
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF191B2F),
                                  title: Text(
                                    'Delete Habit',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    'Are you sure you want to delete this habit?',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Cancel',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Delete the habit
                                        context.read<HabitCubit>().deleteHabit(
                                          _habit,
                                        );
                                        // Close the dialog
                                        Navigator.pop(context);
                                        // Go back to previous screen
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Delete',
                                        style: GoogleFonts.poppins(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),

                  // Main content as SliverPadding and SliverList
                  SliverPadding(
                    padding: EdgeInsets.all(16.w),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Habit title
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: habitColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _habit.icon,
                                color: habitColor,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                _habit.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Status indicator
                        Row(
                          children: [
                            Text(
                              "Status:",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _isCompletedToday()
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isCompletedToday()
                                        ? Icons.check_circle
                                        : Icons.pending,
                                    size: 16.sp,
                                    color:
                                        _isCompletedToday()
                                            ? Colors.green
                                            : Colors.orange,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _isCompletedToday()
                                        ? "Completed Today"
                                        : "Not Completed Today",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          _isCompletedToday()
                                              ? Colors.green
                                              : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        // Description
                        Text(
                          "Description",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _habit.description,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Progress section for measurable habits
                        if (_habit.isMeasurable &&
                            _habit.targetValue != null) ...[
                          Text(
                            "Progress",
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16.r),
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
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "${(progress * 100).toInt()}%",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: habitColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.1,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      habitColor,
                                    ),
                                    minHeight: 8.h,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                // Increment/decrement buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildActionButton(
                                      onTap: _decrementValue,
                                      icon: Icons.remove,
                                      color: Colors.redAccent,
                                    ),
                                    SizedBox(width: 16.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 10.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      child: Text(
                                        "${_habit.currentValue ?? 0}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    _buildActionButton(
                                      onTap: _incrementValue,
                                      icon: Icons.add,
                                      color: Colors.greenAccent,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 20.h),

                        // Complete/Reset button for non-measurable habits
                        if (!_habit.isMeasurable)
                          Center(
                            child: ElevatedButton(
                              onPressed: _toggleHabitCompletion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isCompletedToday()
                                        ? Colors.orange
                                        : Colors.green,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 12.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isCompletedToday()
                                        ? Icons.refresh
                                        : Icons.check,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    _isCompletedToday()
                                        ? "Reset Completion"
                                        : "Mark as Complete",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        SizedBox(height: 20.h),

                        // Completion history
                        Text(
                          "Completion History",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        _buildCompletionHistory(),
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

  // Helper method to build increment/decrement buttons
  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: color, size: 24.sp),
      ),
    );
  }

  // Helper method to build completion history
  Widget _buildCompletionHistory() {
    if (_habit.completedDates.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48.sp,
                color: Colors.white.withOpacity(0.3),
              ),
              SizedBox(height: 8.h),
              Text(
                "No completions yet",
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.5),
                ),
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
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
          return ListTile(
            leading: Icon(Icons.check_circle, color: _habit.color),
            title: Text(
              DateFormat('EEEE, MMM dd, yyyy').format(date),
              style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white),
            ),
            subtitle: Text(
              DateFormat('hh:mm a').format(date),
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          );
        },
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

    // Also check completed dates for today
    return _isCompletedToday();
  }

  // Increment the current value for measurable habits
  void _incrementValue() {
    if (_habit.isMeasurable && _habit.targetValue != null) {
      final currentValue = _habit.currentValue ?? 0;
      if (currentValue < _habit.targetValue!) {
        // Start animation
        setState(() {
          _isIncrementAnimating = true;
          // Update UI immediately
          _habit = _habit.copyWith(currentValue: currentValue + 1);
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
      final newValue = _habit.currentValue! - 1;

      // Start animation and update UI
      setState(() {
        _isDecrementAnimating = true;
        _habit = _habit.copyWith(currentValue: newValue);
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
