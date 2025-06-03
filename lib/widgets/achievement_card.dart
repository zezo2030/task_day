import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import '../models/achievement_model.dart';

class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final bool isUnlocked;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color:
            isUnlocked
                ? achievement.color.withOpacity(0.15)
                : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              isUnlocked
                  ? achievement.color.withOpacity(0.4)
                  : Colors.white.withOpacity(0.1),
          width: 1.w,
        ),
        boxShadow:
            isUnlocked
                ? [
                  BoxShadow(
                    color: achievement.color.withOpacity(0.2),
                    blurRadius: 8.r,
                    spreadRadius: 2.r,
                  ),
                ]
                : null,
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color:
                  isUnlocked
                      ? achievement.color.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              achievement.icon,
              color: isUnlocked ? achievement.color : Colors.white30,
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
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.white : Colors.white60,
                        ),
                      ),
                    ),
                    if (isUnlocked) ...[
                      Icon(
                        FluentSystemIcons.ic_fluent_checkmark_circle_filled,
                        color: Colors.green,
                        size: 20.sp,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  achievement.description,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color:
                        isUnlocked
                            ? Colors.white70
                            : Colors.white.withOpacity(0.4),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getRarityColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: _getRarityColor().withOpacity(0.4),
                          width: 1.w,
                        ),
                      ),
                      child: Text(
                        _getRarityText(),
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: _getRarityColor(),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FluentSystemIcons.ic_fluent_star_filled,
                            color: Colors.amber,
                            size: 12.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${achievement.pointsReward}',
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isUnlocked && achievement.currentProgress > 0) ...[
                  SizedBox(height: 8.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التقدم: ${achievement.currentProgress}/${achievement.targetValue}',
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          color: Colors.white60,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      LinearProgressIndicator(
                        value: achievement.progressPercentage,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(achievement.color),
                        minHeight: 4.h,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor() {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  String _getRarityText() {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return 'عادي';
      case AchievementRarity.rare:
        return 'نادر';
      case AchievementRarity.epic:
        return 'ملحمي';
      case AchievementRarity.legendary:
        return 'أسطوري';
    }
  }
}
