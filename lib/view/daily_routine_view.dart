import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:task_day/controller/daily_routine_cubit/daily_routine_cubit.dart';
import 'package:task_day/core/router/navigation_helper.dart';
import 'package:task_day/models/daily_routine_model.dart';
import 'package:task_day/services/notification_service.dart';

class DailyTaskView extends StatefulWidget {
  const DailyTaskView({super.key});

  @override
  State<DailyTaskView> createState() => _DailyTaskViewState();
}

class _DailyTaskViewState extends State<DailyTaskView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late DailyRoutineCubit _dailyRoutineCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _dailyRoutineCubit = context.read<DailyRoutineCubit>();
    _dailyRoutineCubit.getTodayDailyRoutines();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh data when returning to this screen
      _dailyRoutineCubit.getTodayDailyRoutines();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(DateTime.now());

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
          child: Stack(
            children: [
              // Background decorative elements
              Positioned(
                top: -50.h,
                right: -30.w,
                child: Container(
                  height: 220.h,
                  width: 220.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6366F1).withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 150.h,
                left: -70.w,
                child: Container(
                  height: 170.h,
                  width: 170.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8B5CF6).withOpacity(0.07),
                  ),
                ),
              ),

              // Main content with CustomScrollView
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    pinned: false,
                    floating: true,
                    snap: true,
                    expandedHeight: 60.h,
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
                      onPressed: () => context.pop(),
                    ),
                    actions: [
                      // زر اختبار الإشعارات
                      IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange.withOpacity(0.2),
                          ),
                          child: Icon(
                            Icons.notifications_active,
                            color: Colors.orange,
                            size: 18.sp,
                          ),
                        ),
                        onPressed: () async {
                          await NotificationService.showTestNotification();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم إرسال إشعار اختبار!',
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                        onPressed: () async {
                          // Navigate to create screen
                          await NavigationHelper.goToCreateDailyRoutineWithResult(
                            context,
                          );
                          // Always refresh when returning from create screen
                          _dailyRoutineCubit.getTodayDailyRoutines();
                        },
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),

                  // Header section with title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 8.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDailyTaskHeader(context, formattedDate),
                          SizedBox(height: 24.h),
                          BlocBuilder<DailyRoutineCubit, DailyRoutineState>(
                            builder: (context, state) {
                              if (state is DailyRoutineLoaded) {
                                return _buildStatsSection(state.dailyRoutines);
                              }
                              return _buildStatsSection([]);
                            },
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),

                  // Daily Tasks content
                  SliverToBoxAdapter(
                    child: BlocListener<DailyRoutineCubit, DailyRoutineState>(
                      listener: (context, state) {},
                      child: BlocBuilder<DailyRoutineCubit, DailyRoutineState>(
                        builder: (context, state) {
                          return _buildDailyTasksContent(state);
                        },
                      ),
                    ),
                  ),

                  // Bottom padding
                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          width: 200.w,
          height: 56.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6366F1),
                const Color(0xFF8B5CF6),
                const Color(0xFF3B82F6),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28.r),
              onTap: () async {
                // Navigate to create screen
                await NavigationHelper.goToCreateDailyRoutineWithResult(
                  context,
                );
                // Always refresh when returning from create screen
                _dailyRoutineCubit.getTodayDailyRoutines();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Add Routine',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  // Daily Task Header
  Widget _buildDailyTaskHeader(BuildContext context, String formattedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date indicator
        SizedBox(height: 16.h),

        // Main title with icon
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.3),
                    const Color(0xFF8B5CF6).withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.today_outlined,
                color: const Color(0xFF6366F1),
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Tasks',
                    style: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    formattedDate,
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
      ],
    );
  }

  // Stats Section
  Widget _buildStatsSection(List<DailyRoutineModel> routines) {
    final completedCount = routines.where((r) => r.isCompleted).length;
    final pendingCount = routines.length - completedCount;
    final totalCount = routines.length;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.task_alt,
              label: 'Completed',
              value: completedCount.toString(),
              color: Colors.green,
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: Colors.white.withOpacity(0.1),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.pending_actions,
              label: 'Pending',
              value: pendingCount.toString(),
              color: Colors.orange,
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: Colors.white.withOpacity(0.1),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.schedule,
              label: 'Total',
              value: totalCount.toString(),
              color: const Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
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

  // Daily Tasks Content
  Widget _buildDailyTasksContent(DailyRoutineState state) {
    if (state is DailyRoutineLoading) {
      return Container(
        height: 400.h,
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
        ),
      );
    }

    if (state is DailyRoutineError) {
      return Container(
        height: 400.h,
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        child: Center(
          child: SelectableText.rich(
            TextSpan(
              text: 'خطأ: ${state.message}',
              style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.red),
            ),
          ),
        ),
      );
    }

    if (state is DailyRoutineLoaded) {
      if (state.dailyRoutines.isEmpty) {
        return _buildEmptyState();
      }
      return _buildRoutinesList(state.dailyRoutines);
    }

    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400.h,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(Icons.today_outlined, size: 48.sp, color: Colors.white),
          ),
          SizedBox(height: 24.h),
          Text(
            'لا توجد مهام يومية',
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'ابدأ بإضافة مهامك اليومية الأولى',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinesList(List<DailyRoutineModel> routines) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      child: AnimatedList(
        key: GlobalKey<AnimatedListState>(),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        initialItemCount: routines.length,
        itemBuilder: (context, index, animation) {
          if (index >= routines.length) return const SizedBox.shrink();
          final routine = routines[index];
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(
              opacity: animation,
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildRoutineCard(routine),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoutineCard(DailyRoutineModel routine) {
    return Dismissible(
      key: Key(routine.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF191B2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(color: Colors.red.withOpacity(0.3)),
              ),
              title: Text(
                'حذف الروتين',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'هل أنت متأكد من حذف "${routine.name}"؟',
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'حذف',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _dailyRoutineCubit.deleteDailyRoutine(routine.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.withOpacity(0.8), Colors.red.withOpacity(0.6)],
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'حذف',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color:
                routine.isCompleted
                    ? Colors.green.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            // Completion status
            GestureDetector(
              onTap: () {
                // Toggle completion status
                final updatedRoutine = DailyRoutineModel(
                  id: routine.id,
                  name: routine.name,
                  startTime: routine.startTime,
                  endTime: routine.endTime,
                  isCompleted: !routine.isCompleted,
                  counterReperter: routine.counterReperter,
                  dateTime: routine.dateTime,
                  isRecurringDaily: routine.isRecurringDaily,
                );
                _dailyRoutineCubit.updateDailyRoutine(updatedRoutine);
              },
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        routine.isCompleted
                            ? Colors.green
                            : Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                  color:
                      routine.isCompleted ? Colors.green : Colors.transparent,
                ),
                child:
                    routine.isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                        : null,
              ),
            ),
            SizedBox(width: 16.w),

            // Routine details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      decoration:
                          routine.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${routine.startTime.format(context)} - ${routine.endTime.format(context)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Counter
            if (routine.counterReperter > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  routine.isRecurringDaily
                      ? '∞'
                      : '${routine.counterReperter}x',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: const Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
