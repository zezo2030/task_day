import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import '../models/reward_model.dart';

class RewardCard extends StatelessWidget {
  final RewardModel reward;
  final int userPoints;
  final int userLevel;
  final Function(String) onClaim;

  const RewardCard({
    super.key,
    required this.reward,
    required this.userPoints,
    required this.userLevel,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final bool canAfford = userPoints >= reward.costInPoints;
    final bool meetsLevelRequirement =
        reward.requiredLevel == null || userLevel >= reward.requiredLevel!;
    final bool canClaim =
        canAfford && meetsLevelRequirement && reward.canBeClaimed;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color:
            canClaim ? reward.color.withOpacity(0.15) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              canClaim
                  ? reward.color.withOpacity(0.4)
                  : Colors.white.withOpacity(0.1),
          width: 1.w,
        ),
        boxShadow:
            canClaim
                ? [
                  BoxShadow(
                    color: reward.color.withOpacity(0.2),
                    blurRadius: 8.r,
                    spreadRadius: 2.r,
                  ),
                ]
                : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color:
                      canClaim
                          ? reward.color.withOpacity(0.2)
                          : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  reward.icon,
                  color: canClaim ? reward.color : Colors.white30,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title,
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: canClaim ? Colors.white : Colors.white60,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      reward.description,
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color:
                            canClaim
                                ? Colors.white70
                                : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
              if (reward.requiredLevel != null) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color:
                        meetsLevelRequirement
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FluentSystemIcons.ic_fluent_trophy_regular,
                        color:
                            meetsLevelRequirement ? Colors.green : Colors.red,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Level ${reward.requiredLevel}',
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color:
                              meetsLevelRequirement ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color:
                      canAfford
                          ? Colors.amber.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FluentSystemIcons.ic_fluent_star_filled,
                      color: canAfford ? Colors.amber : Colors.red,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${reward.costInPoints}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: canAfford ? Colors.amber : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canClaim ? () => onClaim(reward.id) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canClaim ? reward.color : Colors.grey,
                foregroundColor: Colors.white,
                elevation: canClaim ? 3 : 0,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                _getButtonText(),
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    if (reward.isClaimed) return 'Claimed ✓';
    if (!canAfford) return 'Not Enough Points';
    if (reward.requiredLevel != null && userLevel < reward.requiredLevel!) {
      return 'Level Too Low';
    }
    return 'Claim Reward';
  }

  bool get canAfford => userPoints >= reward.costInPoints;

  Color _getRarityColor() {
    switch (reward.rarity) {
      case RewardRarity.common:
        return Colors.grey;
      case RewardRarity.uncommon:
        return Colors.green;
      case RewardRarity.rare:
        return Colors.blue;
      case RewardRarity.epic:
        return Colors.purple;
      case RewardRarity.legendary:
        return Colors.orange;
    }
  }

  String _getRarityText() {
    switch (reward.rarity) {
      case RewardRarity.common:
        return 'Common';
      case RewardRarity.uncommon:
        return 'Uncommon';
      case RewardRarity.rare:
        return 'Rare';
      case RewardRarity.epic:
        return 'Epic';
      case RewardRarity.legendary:
        return 'Legendary';
    }
  }
}
