import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:task_day/models/habit_model.dart';

class NonMeasurableHabitCard extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onToggle;

  const NonMeasurableHabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
  });

  // Check if habit is completed today based on completedDates
  bool _isCompletedToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return habit.completedDates.any((date) {
      final habitDate = DateTime(date.year, date.month, date.day);
      return habitDate.isAtSameMomentAs(today);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = _isCompletedToday();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: habit.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: habit.color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: habit.color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24.r),
          onTap: () {
            context.push('/habit-details/${habit.id}', extra: habit);
          }, // For detailed view
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Row(
              children: [
                Container(
                  height: 64.h,
                  width: 64.w,
                  decoration: BoxDecoration(
                    color:
                        isDone
                            ? habit.color.withOpacity(0.3)
                            : habit.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(habit.icon, color: habit.color, size: 32.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        habit.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.7,
                          ),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutBack,
                    height: 40.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      gradient:
                          isDone
                              ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  habit.color,
                                  habit.color.withOpacity(0.7),
                                ],
                              )
                              : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  habit.color.withOpacity(0.1),
                                  habit.color.withOpacity(0.05),
                                ],
                              ),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color:
                            isDone ? habit.color : habit.color.withOpacity(0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: habit.color.withOpacity(isDone ? 0.4 : 0.2),
                          blurRadius: isDone ? 12 : 8,
                          spreadRadius: isDone ? 2 : 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AnimatedScale(
                      scale: isDone ? 1.0 : 0.7,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      child: Icon(
                        isDone ? Icons.check_rounded : Icons.add_rounded,
                        color: isDone ? Colors.white : habit.color,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
