import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:task_day/models/habit_model.dart';

class HabitStreakCalendar extends StatefulWidget {
  final HabitModel habit;
  final int daysToShow;

  const HabitStreakCalendar({
    super.key,
    required this.habit,
    this.daysToShow = 7,
  });

  @override
  State<HabitStreakCalendar> createState() => _HabitStreakCalendarState();
}

class _HabitStreakCalendarState extends State<HabitStreakCalendar> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Use post-frame callback to ensure rendering is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToToday() {
    // Calculate position to center today's date
    final itemWidth = 62.w; // 50.w + 12.w right margin
    final todayIndex = widget.daysToShow - 1; // Today is last in the list
    final screenWidth = MediaQuery.of(context).size.width;
    final scrollPosition =
        (todayIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    // Ensure we don't scroll past boundaries
    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetScroll = scrollPosition.clamp(0.0, maxScroll);

    _scrollController.animateTo(
      targetScroll,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    // Generate dates with today in the center instead of at the end
    final halfDays = (widget.daysToShow ~/ 2);
    final dates = List.generate(widget.daysToShow, (index) {
      if (index < halfDays) {
        // Days before today
        return today.subtract(Duration(days: halfDays - index));
      } else {
        // Today and days after
        return today.add(Duration(days: index - halfDays));
      }
    });

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
            color: widget.habit.color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final date = dates[index];
              final isToday =
                  DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(today);
              final isCompleted = widget.habit.completedDates.any(
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
                                ? widget.habit.color
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
                                ? widget.habit.color
                                : isToday
                                ? widget.habit.color.withOpacity(0.1)
                                : theme.colorScheme.onSurface.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border:
                            isToday && !isCompleted
                                ? Border.all(
                                  color: widget.habit.color,
                                  width: 2,
                                )
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
                                    ? widget.habit.color
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
