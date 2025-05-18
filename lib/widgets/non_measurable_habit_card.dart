import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:task_day/view/habit_details_screen.dart';

class NonMeasurableHabitCard extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onToggle;

  const NonMeasurableHabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = habit.isDone ?? false;

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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HabitDetailsScreen(habit: habit),
              ),
            );
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
                Theme(
                  data: ThemeData(
                    checkboxTheme: CheckboxThemeData(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      side: BorderSide(color: habit.color, width: 2),
                      fillColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return habit.color;
                        }
                        return Colors.transparent;
                      }),
                    ),
                  ),
                  child: Checkbox(value: isDone, onChanged: (_) => onToggle()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
