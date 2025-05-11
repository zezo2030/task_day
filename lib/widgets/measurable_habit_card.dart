import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class MeasurableHabitCard extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onIncrement;

  const MeasurableHabitCard({
    Key? key,
    required this.habit,
    required this.onIncrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = habit.progress;

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
          onTap: () {}, // For detailed view
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 32.r,
                  lineWidth: 6.w,
                  animation: true,
                  animationDuration: 1200,
                  percent: progress.clamp(0.0, 1.0),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: habit.color,
                  backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                  center: Icon(habit.icon, color: habit.color, size: 24.sp),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: "${habit.currentValue ?? 0}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: habit.color,
                                fontSize: 16.sp,
                              ),
                            ),
                            TextSpan(
                              text: " / ${habit.targetValue ?? 0}",
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: habit.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add, color: habit.color),
                    onPressed: onIncrement,
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
