import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_icons/fluentui_icons.dart';

import '../services/gamification_service.dart';
import '../models/user_profile_model.dart';
import '../core/themes/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;

  UserProfileModel? _currentProfile;
  bool _isLoading = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _loadProfile();
    _animationController.forward();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await GamificationService.getUserProfile();
      if (profile != null && mounted) {
        setState(() {
          _currentProfile = profile;
          _nameController.text = profile.name;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
        _showErrorSnackBar('Error loading data');
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_currentProfile != null) {
        final updatedProfile = _currentProfile!.copyWith(
          name: _nameController.text.trim(),
        );

        await GamificationService.saveUserProfile(updatedProfile);

        if (mounted) {
          _showSuccessSnackBar('Profile updated successfully');
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error occurred while updating');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.r),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.r),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
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
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'Edit Profile',
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
              ),
              body:
                  _isLoadingProfile
                      ? _buildLoadingScreen(theme)
                      : SingleChildScrollView(
                        padding: EdgeInsets.all(20.r),
                        child: FadeTransition(
                          opacity: _fadeInAnimation,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20.h),
                                  _buildProfileHeader(colorScheme),
                                  SizedBox(height: 40.h),
                                  _buildNameSection(colorScheme),
                                  SizedBox(height: 40.h),
                                  _buildSaveButton(colorScheme),
                                  SizedBox(height: 20.h),
                                ],
                              ),
                            ),
                          ),
                        ),
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
          Text(
            'Loading data...',
            style: GoogleFonts.cairo(fontSize: 16.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(24.r),
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
      child: Row(
        children: [
          Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Icon(
              FluentSystemIcons.ic_fluent_person_filled,
              color: Colors.white,
              size: 35.sp,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentProfile?.name ?? 'المستخدم',
                  style: GoogleFonts.cairo(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Level ${_currentProfile?.currentLevel ?? 1}',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${_currentProfile?.totalPoints ?? 0} points',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FluentSystemIcons.ic_fluent_edit_regular,
                color: colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Edit Name',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _nameController,
            style: GoogleFonts.cairo(fontSize: 16.sp, color: Colors.white),
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              labelText: 'New Name',
              labelStyle: GoogleFonts.cairo(
                color: Colors.white70,
                fontSize: 14.sp,
              ),
              hintText: 'Enter your new name',
              hintStyle: GoogleFonts.cairo(
                color: Colors.white60,
                fontSize: 14.sp,
              ),
              prefixIcon: Icon(
                FluentSystemIcons.ic_fluent_person_regular,
                color: colorScheme.primary,
                size: 20.sp,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.w,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: colorScheme.primary, width: 2.w),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.red, width: 1.w),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              if (value.trim().length < 2) {
                return 'Name must be more than one character';
              }
              if (value.trim().length > 50) {
                return 'Name must be less than 50 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: _isLoading ? null : _updateProfile,
          child: Container(
            alignment: Alignment.center,
            child:
                _isLoading
                    ? SizedBox(
                      height: 24.h,
                      width: 24.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FluentSystemIcons.ic_fluent_save_regular,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Save Changes',
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
