import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:task_day/controller/daily_routine_cubit/daily_routine_cubit.dart';
import 'package:task_day/models/daily_routine_model.dart';
import 'package:uuid/uuid.dart';

class CreateDailyRoutineScreen extends StatefulWidget {
  const CreateDailyRoutineScreen({super.key});

  @override
  State<CreateDailyRoutineScreen> createState() =>
      _CreateDailyRoutineScreenState();
}

class _CreateDailyRoutineScreenState extends State<CreateDailyRoutineScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  int _repetitions = 1;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurringDaily = false;

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _nameController.dispose();
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
          child: Stack(
            children: [
              // Animated background particles
              _buildAnimatedBackground(),

              // Main content
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: _buildHeader(),
                          ),
                          SizedBox(height: 24.h),
                          _buildQuickTemplates(),
                          SizedBox(height: 24.h),
                          _buildNameField(),
                          SizedBox(height: 16.h),
                          _buildTimeSection(),
                          SizedBox(height: 16.h),
                          _buildRepetitionsSection(),
                          SizedBox(height: 16.h),
                          _buildDateSection(),
                          SizedBox(height: 32.h),
                          _buildActionButtons(),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Floating particles
        Positioned(
          top: 100.h,
          right: 30.w,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  height: 40.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.3),
                        const Color(0xFF8B5CF6).withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 250.h,
          left: 40.w,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.2 - _pulseAnimation.value * 0.2,
                child: Container(
                  height: 25.h,
                  width: 25.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981).withOpacity(0.2),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 200.h,
          right: 60.w,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value * 0.8,
                child: Container(
                  height: 30.h,
                  width: 30.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF59E0B).withOpacity(0.25),
                  ),
                ),
              );
            },
          ),
        ),
        // Gradient overlay circles
        Positioned(
          top: -100.h,
          left: -50.w,
          child: Container(
            height: 300.h,
            width: 300.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.15),
                  const Color(0xFF6366F1).withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150.h,
          right: -100.w,
          child: Container(
            height: 400.h,
            width: 400.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.12),
                  const Color(0xFF8B5CF6).withOpacity(0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button row
        Row(
          children: [
            IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
              onPressed: () => context.pop(),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Text(
                'New Routine',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(width: 48.w), // Balance for back button
          ],
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6366F1),
                          const Color(0xFF8B5CF6),
                          const Color(0xFF3B82F6),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: Colors.white,
                      size: 36.sp,
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.2),
                          const Color(0xFF8B5CF6).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '✨ New',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Daily Routine',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildQuickTemplates() {
    final templates = [
      {
        'name': 'Morning',
        'icon': Icons.wb_sunny,
        'start': 6,
        'end': 9,
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFF97316)],
      },
      {
        'name': 'Workout',
        'icon': Icons.fitness_center,
        'start': 7,
        'end': 8,
        'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
      },
      {
        'name': 'Reading',
        'icon': Icons.book,
        'start': 21,
        'end': 22,
        'gradient': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      },
      {
        'name': 'Meditation',
        'icon': Icons.self_improvement,
        'start': 20,
        'end': 20,
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flash_on, color: const Color(0xFF6366F1), size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              'Quick Templates',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 110.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final template = templates[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: GestureDetector(
                        onTap: () => _applyTemplate(template),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 130.w,
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.05),
                                Colors.white.withOpacity(0.02),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: (template['gradient'] as List<Color>)[0]
                                  .withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (template['gradient'] as List<Color>)[0]
                                    .withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: template['gradient'] as List<Color>,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (template['gradient']
                                              as List<Color>)[0]
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  template['icon'] as IconData,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                template['name'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${template['start']}:00 - ${template['end']}:00',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.sp,
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return _buildInputCard(
      title: 'Routine Name',
      icon: Icons.edit,
      child: TextFormField(
        controller: _nameController,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
        decoration: InputDecoration(
          hintText: 'Enter routine name...',
          hintStyle: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: Colors.grey.shade500,
            letterSpacing: 0.3,
          ),
          fillColor: Colors.transparent,
          filled: true,

          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 18.h,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide(
              color: const Color(0xFF818CF8).withOpacity(0.5),
              width: 1.5,
            ),
          ),
          errorStyle: GoogleFonts.poppins(
            color: const Color(0xFFEF4444),
            fontSize: 12.sp,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a routine name';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTimeSection() {
    return Row(
      children: [
        Expanded(
          child: _buildInputCard(
            title: 'Start Time',
            icon: Icons.access_time,
            child: GestureDetector(
              onTap: () => _selectStartTime(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
                child: Text(
                  _startTime.format(context),
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildInputCard(
            title: 'End Time',
            icon: Icons.access_time_filled,
            child: GestureDetector(
              onTap: () => _selectEndTime(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
                child: Text(
                  _endTime.format(context),
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepetitionsSection() {
    return _buildInputCard(
      title: 'Repetitions & Schedule',
      icon: Icons.repeat,
      child: Column(
        children: [
          // Repetitions row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
            child: Row(
              children: [
                IconButton(
                  onPressed:
                      _isRecurringDaily
                          ? null
                          : () {
                            if (_repetitions > 1) {
                              setState(() => _repetitions--);
                            }
                          },
                  icon: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _isRecurringDaily
                              ? Colors.grey.withOpacity(0.1)
                              : const Color(0xFF6366F1).withOpacity(0.2),
                      border: Border.all(
                        color:
                            _isRecurringDaily
                                ? Colors.grey.withOpacity(0.3)
                                : const Color(0xFF6366F1).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.remove,
                      color:
                          _isRecurringDaily
                              ? Colors.grey.shade600
                              : const Color(0xFF6366F1),
                      size: 18.sp,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child:
                        _isRecurringDaily
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.all_inclusive,
                                  color: const Color(0xFF10B981),
                                  size: 24.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Infinite',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    color: const Color(0xFF10B981),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            )
                            : Text(
                              '$_repetitions times',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                  ),
                ),
                IconButton(
                  onPressed:
                      _isRecurringDaily
                          ? null
                          : () {
                            setState(() => _repetitions++);
                          },
                  icon: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _isRecurringDaily
                              ? Colors.grey.withOpacity(0.1)
                              : const Color(0xFF6366F1).withOpacity(0.2),
                      border: Border.all(
                        color:
                            _isRecurringDaily
                                ? Colors.grey.withOpacity(0.3)
                                : const Color(0xFF6366F1).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color:
                          _isRecurringDaily
                              ? Colors.grey.shade600
                              : const Color(0xFF6366F1),
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          // Daily repeat toggle
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _isRecurringDaily
                            ? const Color(0xFF10B981).withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                    border: Border.all(
                      color:
                          _isRecurringDaily
                              ? const Color(0xFF10B981).withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    FluentSystemIcons.ic_fluent_arrow_repeat_all_regular,
                    color:
                        _isRecurringDaily
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6366F1),
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repeat Daily',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isRecurringDaily,
                  onChanged: (value) {
                    setState(() {
                      _isRecurringDaily = value;
                    });
                  },
                  activeColor: const Color(0xFF10B981),
                  activeTrackColor: const Color(0xFF10B981).withOpacity(0.3),
                  inactiveThumbColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return _buildInputCard(
      title: 'Date',
      icon: Icons.calendar_today,
      child: GestureDetector(
        onTap: () => _selectDate(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
          child: Text(
            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1).withOpacity(0.8),
                            const Color(0xFF8B5CF6).withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 18.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Input field container with transparent background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return BlocListener<DailyRoutineCubit, DailyRoutineState>(
      listener: (context, state) {},
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1000),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 40 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.white.withOpacity(0.04),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18.r),
                          onTap: () => context.pop(),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.close,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 18.sp,
                                ),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 2,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.05,
                          child: Container(
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
                              borderRadius: BorderRadius.circular(18.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: const Color(
                                    0xFF8B5CF6,
                                  ).withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18.r),
                                onTap: _saveRoutine,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(3.w),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14.sp,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Flexible(
                                        child: Text(
                                          'Save Routine',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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

  void _applyTemplate(Map<String, dynamic> template) {
    setState(() {
      _nameController.text = '${template['name']} Routine';
      _startTime = TimeOfDay(hour: template['start'] as int, minute: 0);
      _endTime = TimeOfDay(hour: template['end'] as int, minute: 0);
      _repetitions = 1;
      _isRecurringDaily = true; // Set to true by default for templates
    });
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveRoutine() {
    if (_formKey.currentState!.validate()) {
      final routine = DailyRoutineModel(
        id: const Uuid().v4(),
        name: _nameController.text,
        startTime: _startTime,
        endTime: _endTime,
        isCompleted: false,
        counterReperter: _repetitions,
        dateTime: _selectedDate,
        isRecurringDaily: _isRecurringDaily,
      );
      context.pop(true);
      // Add the routine - the BlocListener will handle navigation
      context.read<DailyRoutineCubit>().addDailyRoutine(routine);
    }
  }
}
