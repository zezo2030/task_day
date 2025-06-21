import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:task_day/controller/weekly_review_cubit/weekly_review_cubit.dart';
import 'package:task_day/models/weekly_review_model.dart';

class WeeklyReviewScreen extends StatefulWidget {
  final DateTime? weekStart;

  const WeeklyReviewScreen({super.key, this.weekStart});

  @override
  State<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends State<WeeklyReviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateReview();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  void _generateReview() {
    final cubit = context.read<WeeklyReviewCubit>();
    if (widget.weekStart != null) {
      cubit.generateWeekReview(widget.weekStart!);
    } else {
      cubit.generateCurrentWeekReview();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: BlocBuilder<WeeklyReviewCubit, WeeklyReviewState>(
              builder: (context, state) {
                if (state is WeeklyReviewLoading) {
                  return _buildLoadingState();
                } else if (state is WeeklyReviewLoaded) {
                  return _buildLoadedState(state);
                } else if (state is WeeklyReviewError) {
                  return _buildErrorState(state.message);
                }
                return _buildInitialState();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(Icons.analytics, color: Colors.white, size: 48.sp),
          ),
          SizedBox(height: 24.h),
          Text(
            'Analyzing Week...',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: const Color(0xFFEF4444),
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error Occurred',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, color: const Color(0xFF6366F1), size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            'Weekly Review',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(WeeklyReviewLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(state.review, state.isCurrentWeek),
          SizedBox(height: 24.h),
          _buildOverallStats(state.review),
          SizedBox(height: 20.h),
          _buildDailyBreakdown(state.review),
          SizedBox(height: 20.h),
          _buildSuggestions(state.suggestions),
          SizedBox(height: 20.h),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader(WeeklyReviewModel review, bool isCurrentWeek) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Weekly Review',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                isCurrentWeek ? 'Current Week' : 'Previous Review',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 48.w), // Balance the back button
      ],
    );
  }

  Widget _buildOverallStats(WeeklyReviewModel review) {
    return _buildCard(
      title: 'Overall Statistics',
      icon: Icons.bar_chart,
      child: Column(
        children: [
          _buildStatRow(
            'Total Routines',
            review.totalRoutines.toString(),
            const Color(0xFF6366F1),
          ),
          SizedBox(height: 12.h),
          _buildStatRow(
            'Completed',
            review.completedRoutines.toString(),
            const Color(0xFF10B981),
          ),
          SizedBox(height: 12.h),
          _buildStatRow(
            'Completion Rate',
            '${review.completionRate.toStringAsFixed(0)}%',
            _getCompletionRateColor(review.completionRate),
          ),
          SizedBox(height: 12.h),
          _buildStatRow('Best Day', review.bestDay, const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildDailyBreakdown(WeeklyReviewModel review) {
    return _buildCard(
      title: 'Daily Breakdown',
      icon: Icons.calendar_view_week,
      child: Column(
        children:
            review.dailyCompletions.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _buildStatRow(
                  entry.key,
                  '${entry.value} completed',
                  const Color(0xFF8B5CF6),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSuggestions(List<String> suggestions) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return _buildCard(
      title: 'Improvement Suggestions',
      icon: Icons.lightbulb_outline,
      child: Column(
        children:
            suggestions.map((suggestion) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  suggestion,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6366F1), size: 20.sp),
              SizedBox(width: 12.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              context.read<WeeklyReviewCubit>().generatePreviousWeekReview();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            child: Text(
              'Previous Week',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              context.read<WeeklyReviewCubit>().generateCurrentWeekReview();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Current Week',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getCompletionRateColor(double rate) {
    if (rate >= 80) return const Color(0xFF10B981);
    if (rate >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
