import 'package:flutter/material.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:task_day/core/themes/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Sample data - in a real app, this would come from a provider or database
  final Map<String, dynamic> _statusData = {
    'tasksCompleted': 8,
    'totalTasks': 12,
    'tasksCompletionRate': 0.67,
    'habitsStreak': 14,
    'weeklyProgress': 0.82,
    'monthlyProgress': 0.75,
  };

  final List<Map<String, dynamic>> _habitStreaks = [
    {
      'title': 'Morning Workout',
      'streak': 21,
      'icon': Icons.fitness_center,
      'color': Colors.orange,
    },
    {
      'title': 'Reading',
      'streak': 14,
      'icon': Icons.book,
      'color': Colors.blue,
    },
    {
      'title': 'Meditation',
      'streak': 30,
      'icon': Icons.self_improvement,
      'color': Colors.purple,
    },
    {
      'title': 'Drinking Water',
      'streak': 25,
      'icon': Icons.water_drop,
      'color': Colors.cyan,
    },
    {
      'title': 'Journaling',
      'streak': 10,
      'icon': Icons.edit_note,
      'color': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    );
    _animationController.forward();
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
                  colors: [colorScheme.surface, colorScheme.background],
                ),
              ),
              child: SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(context, colorScheme),
                    ),
                    SliverToBoxAdapter(
                      child: _buildProgressSection(context, colorScheme),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
                        child: Text(
                          'Habit Streaks',
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = _habitStreaks[index];
                        final delay = Duration(milliseconds: 100 * index);

                        return FutureBuilder(
                          future: Future.delayed(delay),
                          builder: (context, snapshot) {
                            return AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity:
                                  snapshot.connectionState ==
                                          ConnectionState.done
                                      ? 1
                                      : 0,
                              child: _buildHabitStreakItem(
                                item,
                                theme,
                                colorScheme,
                              ),
                            );
                          },
                        );
                      }, childCount: _habitStreaks.length),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.all(20.w),
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
                color: colorScheme.primary.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(15.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FluentSystemIcons.ic_fluent_checkmark_circle_filled,
                      size: 30.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Progress',
                          style: GoogleFonts.poppins(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'You\'re doing great! Keep it up.',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    '${_statusData['tasksCompleted']}/${_statusData['totalTasks']}',
                    'Tasks',
                    Icons.task_alt,
                    colorScheme.secondary,
                  ),
                  _buildStatItem(
                    '${_statusData['habitsStreak']}',
                    'Day Streak',
                    Icons.local_fire_department,
                    Colors.amber,
                  ),
                  _buildStatItem(
                    '${(_statusData['tasksCompletionRate'] * 100).toInt()}%',
                    'Rate',
                    Icons.insights,
                    colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 15.h),
            LinearPercentIndicator(
              animation: true,
              animationDuration: 1000,
              lineHeight: 15.0,
              percent: _statusData['weeklyProgress'],
              barRadius: Radius.circular(8.r),
              progressColor: colorScheme.secondary,
              backgroundColor: Colors.white.withOpacity(0.1),
              center: Text(
                '${(_statusData['weeklyProgress'] * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Monthly Progress',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 15.h),
            LinearPercentIndicator(
              animation: true,
              animationDuration: 1000,
              lineHeight: 15.0,
              percent: _statusData['monthlyProgress'],
              barRadius: Radius.circular(8.r),
              progressColor: colorScheme.primary,
              backgroundColor: Colors.white.withOpacity(0.1),
              center: Text(
                '${(_statusData['monthlyProgress'] * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitStreakItem(
    Map<String, dynamic> item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(item['icon'], color: colorScheme.secondary),
        ),
        title: Text(item['title'], style: theme.textTheme.bodyLarge),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                color: Colors.amber,
                size: 18.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                '${item['streak']} days',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
