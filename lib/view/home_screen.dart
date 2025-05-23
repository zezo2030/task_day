import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_day/core/extensions/widget_extensions.dart';
import 'package:task_day/core/themes/app_theme.dart';
import 'package:task_day/widgets/habit_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(DateTime.now());
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
                  colors: [colorScheme.surface, colorScheme.surface],
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
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      (1 - _animationController.value) * -30,
                                      0,
                                    ),
                                    child: Opacity(
                                      opacity: _animationController.value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Welcome Zoz",
                                      style: GoogleFonts.poppins(
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.bold,
                                        foreground:
                                            Paint()
                                              ..shader = LinearGradient(
                                                colors: [
                                                  Colors.white,
                                                  colorScheme.secondary,
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
                                    SizedBox(height: 4.h),
                                    Text(
                                      formattedDate,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      (1 - _animationController.value) * 30,
                                      0,
                                    ),
                                    child: Opacity(
                                      opacity: _animationController.value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Magical Quote
                    SliverToBoxAdapter(
                      child: AnimatedBuilder(
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
                    ),

                    // Today's Tasks Header
                    SliverToBoxAdapter(
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

                        // Staggered animation effect
                        final itemAnimation = Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              0.1 + 0.1 * index, // Staggered start
                              0.6 + 0.1 * index, // Staggered end
                              curve: Curves.easeOutQuart,
                            ),
                          ),
                        );

                        final task = taskList[index];
                        final bool isCompleted = task["completed"] as bool;
                        final completedColor = Colors.green;

                        return AnimatedBuilder(
                          animation: itemAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, (1 - itemAnimation.value) * 50),
                              child: Opacity(
                                opacity: itemAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
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
                                          : colorScheme.primary.withOpacity(
                                            0.1,
                                          ),
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
                          ),
                        );
                      }, childCount: 3),
                    ),

                    // Habits Header
                    SliverToBoxAdapter(
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
                    ),

                    // Habits Grid
                    SliverToBoxAdapter(
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
                        child: Container(
                          height: 140.h,
                          margin: EdgeInsets.only(left: 20.w, bottom: 20.h),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: List.generate(4, (index) {
                              final habitList = [
                                {
                                  "icon": Icons.water_drop,
                                  "title": "Water",
                                  "progress": 0.75,
                                  "color": Colors.blueAccent,
                                },
                                {
                                  "icon": Icons.directions_walk,
                                  "title": "Steps",
                                  "progress": 0.45,
                                  "color": Colors.orangeAccent,
                                },
                                {
                                  "icon": Icons.bedtime,
                                  "title": "Sleep",
                                  "progress": 0.9,
                                  "color": Colors.purpleAccent,
                                },
                                {
                                  "icon": Icons.book,
                                  "title": "Reading",
                                  "progress": 0.3,
                                  "color": Colors.greenAccent,
                                },
                              ];

                              final habit = habitList[index];

                              // Staggered animation for each habit card
                              final itemAnimation = Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                    0.3 + 0.1 * index, // Staggered start
                                    0.7 + 0.1 * index, // Staggered end
                                    curve: Curves.easeOutQuart,
                                  ),
                                ),
                              );

                              return AnimatedBuilder(
                                animation: itemAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      (1 - itemAnimation.value) * 60,
                                      0,
                                    ),
                                    child: Opacity(
                                      opacity: itemAnimation.value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: HabitCard(
                                  icon: habit["icon"] as IconData,
                                  title: habit["title"] as String,
                                  progress: habit["progress"] as double,
                                  color: habit["color"] as Color,
                                ),
                              );
                            }),
                          ),
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
              child: FloatingActionButton(
                heroTag: 'homeScreenFAB',
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () {
                  // Add new task
                },
                child: Icon(Icons.add, color: Colors.white, size: 32.sp),
              ),
            ),
          );
        },
      ),
    );
  }
}
