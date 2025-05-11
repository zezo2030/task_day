import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_day/core/extensions/widget_extensions.dart';
import 'package:task_day/core/themes/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(DateTime.now());

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                    // App Bar with date and profile
                    SliverAppBar(
                      expandedHeight: 120.h,
                      floating: true,
                      pinned: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Welcome Zoz",
                                    style: theme.textTheme.headlineLarge,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    formattedDate,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              Container(
                                height: 48.h,
                                width: 48.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.secondary,
                                      colorScheme.primary,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 24.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Magical Quote
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: Colors.amber,
                                  size: 22.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  "Magical Thought",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              "Every small habit you build today is creating the extraordinary future you desire.",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Today's Tasks Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 20.w,
                          right: 20.w,
                          top: 20.h,
                          bottom: 10.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Tasks",
                              style: theme.textTheme.headlineMedium,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: colorScheme.secondary,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "Add New",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tasks List
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final taskList = [
                          {
                            "title": "Morning meditation",
                            "time": "7:00 AM",
                            "completed": true,
                            "icon": Icons.self_improvement,
                          },
                          {
                            "title": "Read 20 pages",
                            "time": "9:30 AM",
                            "completed": false,
                            "icon": Icons.menu_book,
                          },
                          {
                            "title": "Team meeting",
                            "time": "11:00 AM",
                            "completed": false,
                            "icon": Icons.groups,
                          },
                        ];

                        if (index >= taskList.length) return null;

                        final task = taskList[index];
                        final bool isCompleted = task["completed"] as bool;
                        final completedColor = Colors.green;

                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            leading: Container(
                              height: 48.h,
                              width: 48.w,
                              decoration: BoxDecoration(
                                color:
                                    isCompleted
                                        ? completedColor.withOpacity(0.1)
                                        : colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                task["icon"] as IconData,
                                color:
                                    isCompleted
                                        ? completedColor
                                        : colorScheme.primary,
                                size: 24.sp,
                              ),
                            ),
                            title: Text(
                              task["title"] as String,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(
                                  isCompleted ? 0.6 : 1,
                                ),
                                decoration:
                                    isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                            subtitle: Text(
                              task["time"] as String,
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Container(
                              height: 24.h,
                              width: 24.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    isCompleted
                                        ? completedColor
                                        : Colors.transparent,
                                border:
                                    isCompleted
                                        ? null
                                        : Border.all(
                                          color: Colors.white30,
                                          width: 2,
                                        ),
                              ),
                              child:
                                  isCompleted
                                      ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16.sp,
                                      )
                                      : null,
                            ),
                          ),
                        );
                      }, childCount: 3),
                    ),

                    // Habits Header
                    SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Magic Habits",
                            style: theme.textTheme.headlineMedium,
                          ),
                          Icon(
                            Icons.auto_awesome_mosaic,
                            color: Colors.amberAccent,
                            size: 20.sp,
                          ),
                        ],
                      ).paddingOnly(
                        left: 20.w,
                        right: 20.w,
                        top: 30.h,
                        bottom: 16.h,
                      ),
                    ),

                    // Habits Grid
                    SliverToBoxAdapter(
                      child: Container(
                        height: 140.h,
                        margin: EdgeInsets.only(left: 20.w, bottom: 20.h),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildHabitCard(
                              icon: Icons.water_drop,
                              title: "Water",
                              progress: 0.75,
                              color: Colors.blueAccent,
                            ),
                            _buildHabitCard(
                              icon: Icons.directions_walk,
                              title: "Steps",
                              progress: 0.45,
                              color: Colors.orangeAccent,
                            ),
                            _buildHabitCard(
                              icon: Icons.bedtime,
                              title: "Sleep",
                              progress: 0.9,
                              color: Colors.purpleAccent,
                            ),
                            _buildHabitCard(
                              icon: Icons.book,
                              title: "Reading",
                              progress: 0.3,
                              color: Colors.greenAccent,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom space
                    SliverToBoxAdapter(child: SizedBox(height: 80.h)),
                  ],
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
              child: Icon(Icons.add, color: Colors.white, size: 32.sp),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHabitCard({
    required IconData icon,
    required String title,
    required double progress,
    required Color color,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        return Container(
          width: 120.w,
          margin: EdgeInsets.only(right: 16.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28.sp),
              SizedBox(height: 12.h),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Stack(
                children: [
                  Container(
                    height: 6.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  Container(
                    height: 6.h,
                    width: (120.w - 32.w) * progress,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
