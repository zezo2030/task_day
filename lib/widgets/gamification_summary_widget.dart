import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:go_router/go_router.dart';
import '../services/gamification_service.dart';
import '../models/user_profile_model.dart';

class GamificationSummaryWidget extends StatefulWidget {
  const GamificationSummaryWidget({super.key});

  @override
  State<GamificationSummaryWidget> createState() =>
      _GamificationSummaryWidgetState();
}

class _GamificationSummaryWidgetState extends State<GamificationSummaryWidget> {
  UserProfileModel? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await GamificationService.getUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 80.h,
        margin: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.purple),
            strokeWidth: 2.w,
          ),
        ),
      );
    }

    if (_userProfile == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => context.push('/gamification'),
      child: Container(
        margin: EdgeInsets.all(16.r),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.withOpacity(0.2),
              Colors.blue.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.purple.withOpacity(0.3), width: 1.w),
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.purple, Colors.blue]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FluentSystemIcons.ic_fluent_trophy_regular,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Level ${_userProfile!.currentLevel}',
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 60.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _userProfile!.levelProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple, Colors.blue],
                              ),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${_userProfile!.totalPoints} Points • ${_userProfile!.currentStreak} Days Streak',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              FluentSystemIcons.ic_fluent_chevron_right_regular,
              color: Colors.white60,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
