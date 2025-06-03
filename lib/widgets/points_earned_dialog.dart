import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_icons/fluentui_icons.dart';

class PointsEarnedDialog extends StatefulWidget {
  final int pointsEarned;
  final String habitTitle;

  const PointsEarnedDialog({
    super.key,
    required this.pointsEarned,
    required this.habitTitle,
  });

  @override
  State<PointsEarnedDialog> createState() => _PointsEarnedDialogState();
}

class _PointsEarnedDialogState extends State<PointsEarnedDialog>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _bounceController.forward();
    });

    // Auto close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(opacity: _fadeAnimation.value, child: child);
        },
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withOpacity(0.9),
                Colors.blue.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 20.r,
                spreadRadius: 5.r,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bounceAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          widget.pointsEarned >= 0
                              ? [Colors.amber, Colors.orange]
                              : [Colors.red, Colors.redAccent],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (widget.pointsEarned >= 0
                                ? Colors.amber
                                : Colors.red)
                            .withOpacity(0.4),
                        blurRadius: 15.r,
                        spreadRadius: 3.r,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.pointsEarned >= 0
                        ? FluentSystemIcons.ic_fluent_star_filled
                        : Icons.remove_circle,
                    color: Colors.white,
                    size: 40.sp,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Points Text
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bounceAnimation.value,
                    child: child,
                  );
                },
                child: Text(
                  widget.pointsEarned >= 0
                      ? '+${widget.pointsEarned}'
                      : '${widget.pointsEarned}',
                  style: GoogleFonts.cairo(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.pointsEarned >= 0 ? Colors.amber : Colors.red,
                  ),
                ),
              ),

              Text(
                'نقطة',
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 16.h),

              // Habit Name
              Text(
                widget.pointsEarned >= 0
                    ? 'أحسنت! لقد أكملت'
                    : 'تم إلغاء إكمال',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: Colors.white70,
                ),
              ),

              SizedBox(height: 4.h),

              Text(
                widget.habitTitle,
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20.h),

              // Motivational Message
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  widget.pointsEarned >= 0
                      ? 'استمر في التقدم! كل خطوة تقربك من أهدافك 🚀'
                      : 'لا بأس، يمكنك إكمالها مرة أخرى! 💪',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, int pointsEarned, String habitTitle) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => PointsEarnedDialog(
            pointsEarned: pointsEarned,
            habitTitle: habitTitle,
          ),
    );
  }
}
