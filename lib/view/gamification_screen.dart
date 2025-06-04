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
import '../core/themes/app_theme.dart';
import 'edit_profile_screen.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  UserProfileModel? _userProfile;
  List<AchievementModel> _achievements = [];
  List<RewardModel> _rewards = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _loadGamificationData();
    _animationController.forward();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

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
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'Gamification',
                  style: GoogleFonts.cairo(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      FluentSystemIcons.ic_fluent_arrow_left_regular,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: _loadGamificationData,
                    icon: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        FluentSystemIcons.ic_fluent_arrow_clockwise_regular,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
              body: Stack(
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
                        color: colorScheme.primary.withOpacity(0.08),
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
                        color: const Color(0xFF818CF8).withOpacity(0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 260.h,
                    right: -80.w,
                    child: Container(
                      height: 120.h,
                      width: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF818CF8).withOpacity(0.05),
                      ),
                    ),
                  ),

                  // Main content
                  _isLoading
                      ? _buildLoadingScreen(theme)
                      : RefreshIndicator(
                        onRefresh: _loadGamificationData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: FadeTransition(
                            opacity: _fadeInAnimation,
                            child: Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Column(
                                  children: [
                                    SizedBox(height: 20.h),
                                    _buildProfileSection(colorScheme),
                                    SizedBox(height: 20.h),
                                    _buildTabSection(colorScheme),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.7),
                  theme.colorScheme.surface.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 20.h),
          Text('Loading your data...', style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildProfileSection(ColorScheme colorScheme) {
    if (_userProfile == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
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
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
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
                      _userProfile?.name ?? 'User',
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Level ${_userProfile?.currentLevel ?? 1}',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadGamificationData();
                  }
                },
                icon: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 1.w,
                    ),
                  ),
                  child: Icon(
                    FluentSystemIcons.ic_fluent_edit_regular,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
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
                      '${_userProfile?.totalPoints ?? 0}',
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
          if (_userProfile != null) LevelProgressWidget(profile: _userProfile!),
          SizedBox(height: 16.h),
          _buildStatsRow(colorScheme),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ColorScheme colorScheme) {
    if (_userProfile == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Current Streak',
            '${_userProfile?.currentStreak ?? 0}',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'Longest Streak',
            '${_userProfile?.longestStreak ?? 0}',
            Icons.emoji_events,
            Colors.amber,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'Achievements',
            '${_stats["unlockedAchievements"] ?? 0}/${_stats["totalAchievements"] ?? 0}',
            Icons.military_tech,
            colorScheme.primary,
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
        color: Colors.white.withOpacity(0.05),
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

  Widget _buildTabSection(ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.2),
                width: 1.w,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  icon: Icon(
                    FluentSystemIcons.ic_fluent_trophy_regular,
                    size: 20.sp,
                  ),
                  text: 'Achievements',
                ),
                Tab(
                  icon: Icon(
                    FluentSystemIcons.ic_fluent_gift_regular,
                    size: 20.sp,
                  ),
                  text: 'Rewards',
                ),
                Tab(
                  icon: Icon(
                    FluentSystemIcons.ic_fluent_target_regular,
                    size: 20.sp,
                  ),
                  text: 'Challenges',
                ),
                Tab(
                  icon: Icon(
                    FluentSystemIcons.ic_fluent_data_bar_vertical_regular,
                    size: 20.sp,
                  ),
                  text: 'Statistics',
                ),
              ],
              labelColor: colorScheme.primary,
              unselectedLabelColor: Colors.white60,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.3),
                    colorScheme.secondary.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.cairo(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            height: 450.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAchievementsTab(),
                _buildRewardsTab(),
                _buildChallengesTab(colorScheme),
                _buildStatisticsTab(colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    final unlockedAchievements =
        _achievements.where((a) => a.isUnlocked).toList();
    final lockedAchievements =
        _achievements.where((a) => !a.isUnlocked).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (unlockedAchievements.isNotEmpty) ...[
            Text(
              'Your Unlocked Achievements (${unlockedAchievements.length})',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            ...unlockedAchievements.map(
              (achievement) =>
                  AchievementCard(achievement: achievement, isUnlocked: true),
            ),
            SizedBox(height: 24.h),
          ],
          Text(
            'Upcoming Achievements (${lockedAchievements.length})',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          if (lockedAchievements.isEmpty)
            Center(
              child: Container(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  children: [
                    Icon(
                      FluentSystemIcons.ic_fluent_trophy_regular,
                      size: 64.sp,
                      color: Colors.white30,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No more achievements available',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: Colors.white60,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...lockedAchievements.map(
              (achievement) =>
                  AchievementCard(achievement: achievement, isUnlocked: false),
            ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildRewardsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Rewards (${_rewards.length})',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          if (_rewards.isEmpty)
            Center(
              child: Container(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  children: [
                    Icon(
                      FluentSystemIcons.ic_fluent_gift_regular,
                      size: 64.sp,
                      color: Colors.white30,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No rewards available currently',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: Colors.white60,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildChallengesTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Challenge',
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
              color: Colors.white.withOpacity(0.05),
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
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        FluentSystemIcons.ic_fluent_target_filled,
                        color: Colors.green,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Week Challenge',
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
                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.teal],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '150 Points',
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
                  'Complete 5 habits every day for a week',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 16.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: 0.3, // Replace with actual progress
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(Colors.green),
                    minHeight: 8.h,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Progress: 10/35',
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

  Widget _buildStatisticsTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Statistics',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDetailedStatCard(
            'Total Points',
            '${_stats["totalPoints"] ?? 0}',
            Icons.star,
            Colors.amber,
          ),
          SizedBox(height: 12.h),
          _buildDetailedStatCard(
            'Current Level',
            '${_stats["currentLevel"] ?? 1}',
            Icons.trending_up,
            colorScheme.primary,
          ),
          SizedBox(height: 12.h),
          _buildDetailedStatCard(
            'Current Streak',
            '${_stats["currentStreak"] ?? 0} days',
            Icons.local_fire_department,
            Colors.orange,
          ),
          SizedBox(height: 12.h),
          _buildDetailedStatCard(
            'Longest Streak',
            '${_stats["longestStreak"] ?? 0} days',
            Icons.emoji_events,
            colorScheme.secondary,
          ),
          SizedBox(height: 12.h),
          _buildDetailedStatCard(
            'Unlocked Achievements',
            '${_stats["unlockedAchievements"] ?? 0}',
            Icons.military_tech,
            Colors.green,
          ),
          SizedBox(height: 12.h),
          _buildDetailedStatCard(
            'Claimed Rewards',
            '${_stats["claimedRewards"] ?? 0}',
            Icons.card_giftcard,
            Colors.pink,
          ),
          SizedBox(height: 20.h),
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
        color: Colors.white.withOpacity(0.05),
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
          content: Text(
            'Reward claimed successfully!',
            style: GoogleFonts.cairo(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(16.r),
        ),
      );
      _loadGamificationData(); // Reload data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to claim reward',
            style: GoogleFonts.cairo(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(16.r),
        ),
      );
    }
  }
}
