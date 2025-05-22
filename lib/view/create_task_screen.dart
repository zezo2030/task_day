import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/controller/task_cubit/task_cubit.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final _subtaskController = TextEditingController();
  final FocusNode _subtaskFocus = FocusNode();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  int _priority = 0; // 0: Low, 1: Medium, 2: High
  final List<SubTaskModel> _subTasks = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _subtaskController.dispose();
    _subtaskFocus.dispose();
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
      child: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is TaskAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Task created successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context, state.task);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Stack(
                children: [
                  // Background effects (decorative circles)
                  Positioned(
                    top: -50.h,
                    right: -30.w,
                    child: Container(
                      height: 220.h,
                      width: 220.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4F46E5).withOpacity(0.08),
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
                        color: const Color(0xFF818CF8).withOpacity(0.1),
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

                  // Now the entire content is in a SingleChildScrollView
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with back button
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 20.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 48.h,
                                    width: 48.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.r),
                                      color: Colors.white.withOpacity(0.07),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
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
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                  SizedBox(width: 20.w),
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                          (1 - _animationController.value) * 20,
                                          0,
                                        ),
                                        child: Opacity(
                                          opacity: _animationController.value,
                                          child: Text(
                                            'Create Task',
                                            style: GoogleFonts.poppins(
                                              fontSize: 32.sp,
                                              fontWeight: FontWeight.bold,
                                              foreground:
                                                  Paint()
                                                    ..shader = LinearGradient(
                                                      colors: [
                                                        Colors.white,
                                                        const Color(0xFF818CF8),
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
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Form content section
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Form(
                            key: _formKey,
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    0,
                                    (1 - _animationController.value) * 100,
                                  ),
                                  child: Opacity(
                                    opacity: _animationController.value,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title field
                                        _buildSectionTitle('Task Title'),
                                        SizedBox(height: 12.h),
                                        _buildInputField(
                                          controller: _titleController,
                                          hintText: 'Enter task title',
                                          focusNode: _titleFocus,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a task title';
                                            }
                                            return null;
                                          },
                                        ),

                                        SizedBox(height: 28.h),

                                        // Description field
                                        _buildSectionTitle('Description'),
                                        SizedBox(height: 12.h),
                                        _buildInputField(
                                          controller: _descriptionController,
                                          hintText: 'Enter task description',
                                          maxLines: 5,
                                          focusNode: _descriptionFocus,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a description';
                                            }
                                            return null;
                                          },
                                        ),

                                        SizedBox(height: 28.h),

                                        // Sub-tasks section
                                        _buildSectionTitle('Sub Tasks'),
                                        SizedBox(height: 12.h),
                                        _buildSubTasksSection(),

                                        SizedBox(height: 28.h),

                                        // Date selection
                                        _buildSectionTitle('Timeline'),
                                        SizedBox(height: 18.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildDateSelector(
                                                'Start Date',
                                                _startDate,
                                                onTap:
                                                    () => _selectDate(
                                                      context,
                                                      true,
                                                    ),
                                              ),
                                            ),
                                            SizedBox(width: 16.w),
                                            Expanded(
                                              child: _buildDateSelector(
                                                'End Date',
                                                _endDate,
                                                onTap:
                                                    () => _selectDate(
                                                      context,
                                                      false,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 28.h),

                                        // Priority selection
                                        _buildSectionTitle('Priority Level'),
                                        SizedBox(height: 18.h),
                                        _buildPrioritySelector(),

                                        SizedBox(height: 45.h),

                                        // Submit button
                                        _buildSubmitButton(),

                                        SizedBox(height: 40.h),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    FocusNode? focusNode,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        focusNode: focusNode,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
        decoration: InputDecoration(
          hintText: hintText,
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
        validator: validator,
        onTap: () {
          if (focusNode != null && !focusNode.hasFocus) {
            focusNode.requestFocus();
          }
        },
      ),
    );
  }

  Widget _buildSubTasksSection() {
    return Column(
      children: [
        // Input field to add new sub-tasks
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _subtaskController,
                  focusNode: _subtaskFocus,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add sub-task...',
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
                      vertical: 16.h,
                    ),
                  ),
                  onEditingComplete: _addSubTask,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF818CF8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: IconButton(
                onPressed: _addSubTask,
                icon: Icon(
                  Icons.add_rounded,
                  color: const Color(0xFF818CF8),
                  size: 28.sp,
                ),
                tooltip: 'Add Sub-task',
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // Sub-tasks list
        if (_subTasks.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _subTasks.length,
              separatorBuilder:
                  (context, index) =>
                      Divider(color: Colors.white.withOpacity(0.08), height: 1),
              itemBuilder: (context, index) {
                final subTask = _subTasks[index];
                return Dismissible(
                  key: Key(subTask.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.w),
                    color: Colors.red.withOpacity(0.2),
                    child: Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      _subTasks.removeAt(index);
                    });
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    leading: InkWell(
                      onTap: () {
                        setState(() {
                          _subTasks[index] = subTask.copyWith(
                            isDone: !subTask.isDone,
                          );
                        });
                      },
                      child: Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              subTask.isDone
                                  ? const Color(0xFF818CF8).withOpacity(0.2)
                                  : Colors.transparent,
                          border: Border.all(
                            color:
                                subTask.isDone
                                    ? const Color(0xFF818CF8)
                                    : Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child:
                            subTask.isDone
                                ? Icon(
                                  Icons.check,
                                  size: 16.sp,
                                  color: const Color(0xFF818CF8),
                                )
                                : null,
                      ),
                    ),
                    title: Text(
                      subTask.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color:
                            subTask.isDone
                                ? Colors.white.withOpacity(0.6)
                                : Colors.white,
                        decoration:
                            subTask.isDone ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.white.withOpacity(0.4),
                        decorationThickness: 2,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.white.withOpacity(0.6),
                        size: 22.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _subTasks.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              'Swipe left to delete sub-tasks',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _addSubTask() {
    if (_subtaskController.text.trim().isNotEmpty) {
      setState(() {
        _subTasks.add(
          SubTaskModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _subtaskController.text.trim(),
          ),
        );
        _subtaskController.clear();
      });
      FocusScope.of(context).requestFocus(_subtaskFocus);
    }
  }

  Widget _buildDateSelector(
    String label,
    DateTime date, {
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade400,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16.sp,
                  color: const Color(0xFF818CF8),
                ),
                SizedBox(width: 10.w),
                Text(
                  DateFormat('MMM d, y').format(date),
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    // Priority colors
    final lowColor = const Color(0xFF3B82F6); // Blue
    final mediumColor = const Color(0xFFF59E0B); // Amber
    final highColor = const Color(0xFFEF4444); // Red

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPriorityOption('Low', 0, lowColor),
        _buildPriorityOption('Medium', 1, mediumColor),
        _buildPriorityOption('High', 2, highColor),
      ],
    );
  }

  Widget _buildPriorityOption(String label, int value, Color color) {
    final isSelected = _priority == value;

    return InkWell(
      onTap: () => setState(() => _priority = value),
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 105.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color:
                isSelected
                    ? color.withOpacity(0.5)
                    : Colors.white.withOpacity(0.12),
            width: isSelected ? 1.8 : 1.5,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 14.w,
              height: 14.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade500,
                  width: 2,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : Colors.grey.shade400,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        final isLoading = state is TaskLoading;

        return Container(
          width: double.infinity,
          height: 65.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isLoading
                      ? [Colors.grey.shade600, Colors.grey.shade700]
                      : [const Color(0xFF818CF8), const Color(0xFF4F46E5)],
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: (isLoading
                        ? Colors.grey.shade600
                        : const Color(0xFF4F46E5))
                    .withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
              elevation: 0,
            ),
            child:
                isLoading
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Creating Task...',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    )
                    : Text(
                      'Create Task',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
          ),
        );
      },
    );
  }

  void _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: isStartDate ? DateTime.now() : _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4F46E5),
              onPrimary: Colors.white,
              surface: Color(0xFF191B2F),
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF0F1227),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is before the new start date, update it
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Create a new task
      final newTask = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        isDone: false,
        startDate: _startDate,
        endDate: _endDate,
        priority: _priority,
        subTasks: _subTasks,
      );

      // Use TaskCubit to add the task
      context.read<TaskCubit>().addTask(newTask);
    }
  }
}
