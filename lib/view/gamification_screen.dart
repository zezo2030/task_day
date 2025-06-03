import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_icons/fluentui_icons.dart';

import '../services/gamification_service.dart';
import '../models/user_profile_model.dart';
import '../models/achievement_model.dart';
import '../models/reward_model.dart';
import '../widgets/achievement_card.dart';
import '../widgets/reward_card.dart';
import '../widgets/level_progress_widget.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  UserProfileModel? _userProfile;
  List<AchievementModel> _achievements = [];
  List<RewardModel> _rewards = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadGamificationData();
  }

  Future<void> _loadGamificationData() async {
    setState(() => _isLoading = true);

    try {
      final profile = await GamificationService.getUserProfile();
      final achievements = await GamificationService.getAllAchievements();
      final rewards = await GamificationService.getAvailableRewards();
      final stats = await GamificationService.getGamificationStats();

      setState(() {
        _userProfile = profile;
        _achievements = achievements;
        _rewards = rewards;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body:
          _isLoading
              ? _buildLoadingScreen()
              : CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildProfileSection(),
                        SizedBox(height: 20.h),
                        _buildTabSection(),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.blue.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.purple),
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'جاري تحميل بياناتك...',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1E293B),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'نظام التحفيز',
          style: GoogleFonts.cairo(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.purple.withOpacity(0.3), const Color(0xFF1E293B)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _loadGamificationData,
          icon: Icon(FluentSystemIcons.ic_fluent_arrow_clockwise_regular),
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    if (_userProfile == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.2),
            Colors.blue.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.purple.withOpacity(0.3), width: 1.w),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.blue],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FluentSystemIcons.ic_fluent_person_filled,
                  color: Colors.white,
                  size: 30.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userProfile!.name,
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'المستوى ${_userProfile!.currentLevel}',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FluentSystemIcons.ic_fluent_star_filled,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${_userProfile!.totalPoints}',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          LevelProgressWidget(profile: _userProfile!),
          SizedBox(height: 16.h),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'السلسلة الحالية',
            '${_userProfile!.currentStreak}',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'أطول سلسلة',
            '${_userProfile!.longestStreak}',
            Icons.emoji_events,
            Colors.amber,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'الإنجازات',
            '${_stats["unlockedAchievements"] ?? 0}/${_stats["totalAchievements"] ?? 0}',
            Icons.military_tech,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1.w),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.cairo(fontSize: 10.sp, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: Icon(FluentSystemIcons.ic_fluent_trophy_regular),
                text: 'الإنجازات',
              ),
              Tab(
                icon: Icon(FluentSystemIcons.ic_fluent_gift_regular),
                text: 'المكافآت',
              ),
              Tab(
                icon: Icon(FluentSystemIcons.ic_fluent_target_regular),
                text: 'التحديات',
              ),
              Tab(
                icon: Icon(
                  FluentSystemIcons.ic_fluent_data_bar_vertical_regular,
                ),
                text: 'الإحصائيات',
              ),
            ],
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.white60,
            indicator: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: GoogleFonts.cairo(fontSize: 12.sp),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 400.h,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAchievementsTab(),
              _buildRewardsTab(),
              _buildChallengesTab(),
              _buildStatisticsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab() {
    final unlockedAchievements =
        _achievements.where((a) => a.isUnlocked).toList();
    final lockedAchievements =
        _achievements.where((a) => !a.isUnlocked).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (unlockedAchievements.isNotEmpty) ...[
            Text(
              'إنجازاتك المفتوحة (${unlockedAchievements.length})',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12.h),
            ...unlockedAchievements.map(
              (achievement) =>
                  AchievementCard(achievement: achievement, isUnlocked: true),
            ),
            SizedBox(height: 20.h),
          ],
          Text(
            'إنجازات قادمة (${lockedAchievements.length})',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          ...lockedAchievements.map(
            (achievement) =>
                AchievementCard(achievement: achievement, isUnlocked: false),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المكافآت المتاحة (${_rewards.length})',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          if (_rewards.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    FluentSystemIcons.ic_fluent_gift_regular,
                    size: 60.sp,
                    color: Colors.white30,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'لا توجد مكافآت متاحة حالياً',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._rewards.map(
              (reward) => RewardCard(
                reward: reward,
                userPoints: _userProfile?.totalPoints ?? 0,
                userLevel: _userProfile?.currentLevel ?? 1,
                onClaim: _claimReward,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChallengesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التحدي الأسبوعي',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.2),
                  Colors.teal.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1.w,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      FluentSystemIcons.ic_fluent_target_filled,
                      color: Colors.green,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'تحدي الأسبوع',
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '150 نقطة',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  'أكمل 5 عادات كل يوم لمدة أسبوع',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 16.h),
                LinearProgressIndicator(
                  value: 0.3, // Replace with actual progress
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(Colors.green),
                ),
                SizedBox(height: 8.h),
                Text(
                  'التقدم: 10/35',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائياتك',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDetailedStatCard(
            'إجمالي النقاط',
            '${_stats["totalPoints"] ?? 0}',
            Icons.star,
            Colors.amber,
          ),
          SizedBox(height: 12.h),
          _buildDetailedStatCard(
            'المستوى الحالي',
            '${_stats["currentLevel"] ?? 1}',
            Icons.trending_up,
            Colors.blue,
          ),
          SizedBox(height: 12.h),
          _buildDetailedStatCard(
            'السلسلة الحالية',
            '${_stats["currentStreak"] ?? 0} يوم',
            Icons.local_fire_department,
            Colors.orange,
          ),
          SizedBox(height: 12.h),
          _buildDetailedStatCard(
            'أطول سلسلة',
            '${_stats["longestStreak"] ?? 0} يوم',
            Icons.emoji_events,
            Colors.purple,
          ),
          SizedBox(height: 12.h),
          _buildDetailedStatCard(
            'الإنجازات المفتوحة',
            '${_stats["unlockedAchievements"] ?? 0}',
            Icons.military_tech,
            Colors.green,
          ),
          SizedBox(height: 12.h),
          _buildDetailedStatCard(
            'المكافآت المُستلمة',
            '${_stats["claimedRewards"] ?? 0}',
            Icons.card_giftcard,
            Colors.pink,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1.w),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _claimReward(String rewardId) async {
    final success = await GamificationService.claimReward(rewardId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم استلام المكافأة بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadGamificationData(); // Reload data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في استلام المكافأة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
