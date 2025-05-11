import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:task_day/models/habit_model.dart';

class HabitStreakCalendar extends StatelessWidget {
  final HabitModel habit;
  final int daysToShow;

  const HabitStreakCalendar({
    Key? key,
    required this.habit,
    this.daysToShow = 7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final dates = List.generate(
      daysToShow,
      (index) => today.subtract(Duration(days: daysToShow - 1 - index)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Streak Calendar',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          height: 90.h,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: habit.color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final date = dates[index];
              final isToday =
                  DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(today);
              final isCompleted = habit.completedDates.any(
                (completedDate) =>
                    DateFormat('yyyy-MM-dd').format(completedDate) ==
                    DateFormat('yyyy-MM-dd').format(date),
              );

              return Container(
                width: 50.w,
                margin: EdgeInsets.only(right: 12.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(date).substring(0, 1),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            isToday
                                ? habit.color
                                : theme.textTheme.bodySmall?.color,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 40.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        color:
                            isCompleted
                                ? habit.color
                                : isToday
                                ? habit.color.withOpacity(0.1)
                                : theme.colorScheme.onSurface.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border:
                            isToday && !isCompleted
                                ? Border.all(color: habit.color, width: 2)
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                isCompleted
                                    ? Colors.white
                                    : isToday
                                    ? habit.color
                                    : theme.textTheme.bodyMedium?.color,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
