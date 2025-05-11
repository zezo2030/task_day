import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'habits_screen.dart';
import 'tasks_screen.dart';
import 'status_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _bottomNavIndex = 0; // default index of first screen

  // List of screens to show
  final List<Widget> _screens = const [
    HomeScreen(),
    HabitsScreen(),
    TasksScreen(),
    StatusScreen(),
  ];

  // List of icons for the bottom navigation bar using Fluent icons
  final iconList = <IconData>[
    FluentSystemIcons.ic_fluent_home_regular,
    FluentSystemIcons.ic_fluent_notebook_regular,
    FluentSystemIcons.ic_fluent_document_regular,
    FluentSystemIcons.ic_fluent_status_regular,
  ];

  // Active icons for the bottom navigation bar
  final activeIconList = <IconData>[
    FluentSystemIcons.ic_fluent_home_filled,
    FluentSystemIcons.ic_fluent_notebook_filled,
    FluentSystemIcons.ic_fluent_document_filled,
    FluentSystemIcons.ic_fluent_status_filled,
  ];

  // Names for navigation items
  final List<String> navLabels = ['Home', 'Habits', 'Tasks', 'Status'];

  // Optional: Add controller for animations if you want to control them
  late AnimationController _fabAnimationController;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> fabAnimation;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation fabCurve;
  late CurvedAnimation borderRadiusCurve;

  @override
  void initState() {
    super.initState();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    fabCurve = CurvedAnimation(
      parent: _fabAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    fabAnimation = Tween<double>(begin: 0, end: 1).animate(fabCurve);
    borderRadiusAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(borderRadiusCurve);

    // Start the animations after a delay
    Future.delayed(
      const Duration(seconds: 1),
      () => _fabAnimationController.forward(),
    );
    Future.delayed(
      const Duration(seconds: 1),
      () => _borderRadiusAnimationController.forward(),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _borderRadiusAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(scaffoldBackgroundColor: const Color(0xFF1E293B)),
      child: Scaffold(
        extendBody: true,
        body: _screens[_bottomNavIndex],
        floatingActionButton: Container(
          height: 64.h,
          width: 64.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () {
              // Handle FAB press
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Add new task', style: GoogleFonts.poppins()),
                  backgroundColor: Colors.deepPurpleAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              );
            },
            child: Icon(
              FluentSystemIcons.ic_fluent_add_filled,
              color: Colors.white,
              size: 32.sp,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          child: AnimatedBottomNavigationBar.builder(
            itemCount: iconList.length,
            tabBuilder: (int index, bool isActive) {
              final color = isActive ? Colors.purpleAccent : Colors.white60;
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? activeIconList[index] : iconList[index],
                    size: 24.sp,
                    color: color,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    navLabels[index],
                    style: GoogleFonts.poppins(
                      color: color,
                      fontSize: 10.sp,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              );
            },
            backgroundColor: const Color(0xFF1E293B),
            activeIndex: _bottomNavIndex,
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.softEdge,
            leftCornerRadius: 24,
            rightCornerRadius: 24,
            onTap: (index) => setState(() => _bottomNavIndex = index),
            height: 70.h,
            splashColor: Colors.purpleAccent.withOpacity(0.3),
            splashSpeedInMilliseconds: 300,
            shadow: BoxShadow(
              offset: const Offset(0, -3),
              blurRadius: 10,
              spreadRadius: 0,
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}
