import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_day/controller/habit_cubit/habit_cubit.dart';
import 'package:task_day/core/utils/validation.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:go_router/go_router.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  IconData _selectedIcon = Icons.fitness_center;
  Color _selectedColor = const Color(0xFF7C4DFF);
  bool _isMeasurable = false;
  int? _targetValue;

  // List of available icons for habits
  final List<IconData> _availableIcons = [
    Icons.fitness_center,
    Icons.water_drop,
    Icons.book,
    Icons.code,
    Icons.directions_run,
    Icons.self_improvement,
    Icons.outdoor_grill,
    Icons.restaurant,
    Icons.brush,
    Icons.sports_soccer,
    Icons.mic,
    Icons.language,
    Icons.health_and_safety,
    Icons.local_florist,
  ];

  // List of available colors for habits
  final List<Color> _availableColors = [
    const Color(0xFF7C4DFF), // Violet
    const Color(0xFF2196F3), // Blue
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFF009688), // Teal
    const Color(0xFF4CAF50), // Green
    const Color(0xFF8BC34A), // Light Green
    const Color(0xFFCDDC39), // Lime
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFFFF9800), // Orange
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFFF44336), // Red
    const Color(0xFFE91E63), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF607D8B), // Blue Grey
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Create animations
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

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
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
              // Background decorative elements
              Positioned(
                top: -50.h,
                right: -30.w,
                child: Container(
                  height: 220.h,
                  width: 220.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedColor.withOpacity(0.08),
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

              // Main content
              Column(
                children: [
                  // Animated content
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(
                            opacity: _fadeInAnimation.value,
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 20.h,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with back button (now inside scrollable area)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 48.h,
                                        width: 48.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            15.r,
                                          ),
                                          color: Colors.white.withOpacity(0.07),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.arrow_back_ios_new,
                                            color: Colors.white,
                                            size: 20.sp,
                                          ),
                                          onPressed: () {
                                            if (context.canPop()) {
                                              context.pop();
                                            } else {
                                              // Navigate to main screen with habits tab (index 1)
                                              context.go('/?tab=1');
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 20.w),
                                      Text(
                                        'Create Habit',
                                        style: GoogleFonts.poppins(
                                          fontSize: 32.sp,
                                          fontWeight: FontWeight.bold,
                                          foreground:
                                              Paint()
                                                ..shader = LinearGradient(
                                                  colors: [
                                                    Colors.white,
                                                    _selectedColor,
                                                  ],
                                                ).createShader(
                                                  Rect.fromLTWH(
                                                    0,
                                                    0,
                                                    200.w,
                                                    70.h,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 30.h),

                              // Header section with animation
                              FadeTransition(
                                opacity: Tween<double>(
                                  begin: 0.0,
                                  end: 1.0,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: const Interval(
                                      0.2,
                                      0.8,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                ),
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.2),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: _animationController,
                                      curve: const Interval(
                                        0.2,
                                        0.8,
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(20.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: _selectedColor.withOpacity(0.3),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _selectedColor.withOpacity(
                                            0.1,
                                          ),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(16.w),
                                          decoration: BoxDecoration(
                                            color: _selectedColor.withOpacity(
                                              0.1,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _selectedIcon,
                                            color: _selectedColor,
                                            size: 32.sp,
                                          ),
                                        ),
                                        SizedBox(height: 16.h),
                                        Text(
                                          "Create a New Habit",
                                          style: GoogleFonts.poppins(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                            foreground:
                                                Paint()
                                                  ..shader = LinearGradient(
                                                    colors: [
                                                      _selectedColor
                                                          .withOpacity(0.7),
                                                      Colors.white,
                                                      _selectedColor,
                                                    ],
                                                    stops: const [
                                                      0.0,
                                                      0.5,
                                                      1.0,
                                                    ],
                                                  ).createShader(
                                                    Rect.fromLTWH(
                                                      0,
                                                      0,
                                                      200.w,
                                                      70.h,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          "Build consistent habits one day at a time",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // Title field
                              _buildAnimatedLabel("Habit Title"),
                              SizedBox(height: 8.h),
                              _buildTextField(
                                controller: _titleController,
                                hintText: "What habit would you like to track?",
                                validator: validateNotEmpty,
                              ),

                              SizedBox(height: 24.h),

                              // Description field
                              _buildAnimatedLabel("Description"),
                              SizedBox(height: 8.h),
                              _buildTextField(
                                controller: _descriptionController,
                                hintText: "Why is this habit important to you?",
                                maxLines: 3,
                                validator: validateNotEmpty,
                              ),

                              SizedBox(height: 24.h),

                              // Icon selection
                              _buildAnimatedLabel("Select an Icon"),
                              SizedBox(height: 12.h),
                              _buildIconSelector(),

                              SizedBox(height: 24.h),

                              // Color selection
                              _buildAnimatedLabel("Choose a Color"),
                              SizedBox(height: 12.h),
                              _buildColorSelector(),

                              SizedBox(height: 24.h),

                              // Habit type selection
                              _buildAnimatedLabel("Habit Type"),
                              SizedBox(height: 12.h),
                              _buildHabitTypeSelector(),

                              SizedBox(height: 24.h),

                              // Target value field (only for measurable habits)
                              if (_isMeasurable) ...[
                                _buildAnimatedLabel("Target Value"),
                                SizedBox(height: 8.h),
                                _buildTextField(
                                  hintText: "Enter your target amount",
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      setState(() {
                                        _targetValue = int.tryParse(value);
                                      });
                                    }
                                  },
                                  validator: validatePositiveInt,
                                ),
                                SizedBox(height: 24.h),
                              ],

                              // Create button
                              BlocConsumer<HabitCubit, HabitState>(
                                listener: (context, state) {
                                  if (state is HabitError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error: ${state.message}',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return Center(
                                    child: TweenAnimationBuilder<double>(
                                      duration: const Duration(
                                        milliseconds: 1000,
                                      ),
                                      curve: Curves.elasticOut,
                                      tween: Tween<double>(
                                        begin: 0.5,
                                        end: 1.0,
                                      ),
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: ElevatedButton(
                                            onPressed:
                                                state is! HabitAdded
                                                    ? () {
                                                      if (_formKey.currentState
                                                              ?.validate() ??
                                                          false) {
                                                        // Create a new habit model
                                                        final newHabit = HabitModel(
                                                          id:
                                                              DateTime.now()
                                                                  .millisecondsSinceEpoch
                                                                  .toString(),
                                                          title:
                                                              _titleController
                                                                  .text
                                                                  .trim(),
                                                          description:
                                                              _descriptionController
                                                                  .text
                                                                  .trim(),
                                                          isMeasurable:
                                                              _isMeasurable,
                                                          targetValue:
                                                              _isMeasurable
                                                                  ? _targetValue
                                                                  : null,
                                                          currentValue:
                                                              _isMeasurable
                                                                  ? 0
                                                                  : null,
                                                          color: _selectedColor,
                                                          icon: _selectedIcon,
                                                          createdAt:
                                                              DateTime.now(),
                                                          completedDates: [],
                                                        );

                                                        // Add the habit using the cubit
                                                        context
                                                            .read<HabitCubit>()
                                                            .addHabit(newHabit);

                                                        // Navigation is handled in the listener
                                                        context.go('/?tab=1');
                                                      }
                                                      context
                                                          .read<HabitCubit>()
                                                          .getHabits();
                                                    }
                                                    : null, // Disable button if already added
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _selectedColor,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 32.w,
                                                vertical: 16.h,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16.r),
                                              ),
                                              elevation: 8,
                                              shadowColor: _selectedColor
                                                  .withOpacity(0.5),
                                            ),
                                            child: Text(
                                              "Create Habit",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 40.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build animated label
  Widget _buildAnimatedLabel(String text) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to build text fields
  Widget _buildTextField({
    TextEditingController? controller,
    String? hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5)),
          fillColor: Colors.white.withOpacity(0.05),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: _selectedColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: _selectedColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.redAccent, width: 2),
          ),
          contentPadding: EdgeInsets.all(16.w),
        ),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  // Helper method to build icon selector
  Widget _buildIconSelector() {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _availableIcons.length,
        itemBuilder: (context, index) {
          final bool isSelected = _selectedIcon == _availableIcons[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedIcon = _availableIcons[index];
                });
              },
              borderRadius: BorderRadius.circular(12.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 60.w,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? _selectedColor.withOpacity(0.2)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? _selectedColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  _availableIcons[index],
                  color:
                      isSelected
                          ? _selectedColor
                          : Colors.white.withOpacity(0.7),
                  size: 28.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to build color selector
  Widget _buildColorSelector() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _availableColors.length,
        itemBuilder: (context, index) {
          final bool isSelected = _selectedColor == _availableColors[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedColor = _availableColors[index];
                });
              },
              borderRadius: BorderRadius.circular(30.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 50.w,
                decoration: BoxDecoration(
                  color: _availableColors[index],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: _availableColors[index].withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                          : null,
                ),
                child:
                    isSelected
                        ? Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        )
                        : null,
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to build habit type selector
  Widget _buildHabitTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeOption(
            title: "Regular Habit",
            description: "Track completion with checkmarks",
            isSelected: !_isMeasurable,
            onTap: () {
              setState(() {
                _isMeasurable = false;
              });
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildTypeOption(
            title: "Measurable Habit",
            description: "Track with numeric values",
            isSelected: _isMeasurable,
            onTap: () {
              setState(() {
                _isMeasurable = true;
              });
            },
          ),
        ),
      ],
    );
  }

  // Helper method to build habit type option
  Widget _buildTypeOption({
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? _selectedColor.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? _selectedColor : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: _selectedColor.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                  : null,
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color:
                  isSelected ? _selectedColor : Colors.white.withOpacity(0.7),
              size: 24.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? _selectedColor : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
