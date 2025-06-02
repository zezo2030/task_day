import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/controller/task_cubit/task_cubit.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final _subtaskController = TextEditingController();
  final FocusNode _subtaskFocus = FocusNode();

  late DateTime _startDate;
  late DateTime _endDate;
  late int _priority;
  late List<SubTaskModel> _subTasks;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Initialize with existing task data
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _startDate = widget.task.startDate;
    _endDate = widget.task.endDate;
    _priority = widget.task.priority;
    _subTasks = List<SubTaskModel>.from(widget.task.subTasks);
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
          } else if (state is TaskLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Task updated successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Navigate back to task details screen
            final updatedTask = state.tasks.firstWhere(
              (t) => t.id == widget.task.id,
            );
            context.pop(updatedTask);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
                    ),
                    child: Row(
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
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/');
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 20.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit Task',
                                style: GoogleFonts.poppins(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Update your task information',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form Content
                  Expanded(
                    child: SingleChildScrollView(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title field
                                    _buildSectionTitle('Task Title'),
                                    SizedBox(height: 12.h),
                                    _buildInputField(
                                      controller: _titleController,
                                      hintText: 'Enter task title',
                                      focusNode: _titleFocus,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
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
                                        if (value == null || value.isEmpty) {
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

                                    // Date range section
                                    _buildSectionTitle('Date Range'),
                                    SizedBox(height: 12.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildDateSelector(
                                            'Start Date',
                                            _startDate,
                                            onTap:
                                                () =>
                                                    _selectDate(context, true),
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                        Expanded(
                                          child: _buildDateSelector(
                                            'End Date',
                                            _endDate,
                                            onTap:
                                                () =>
                                                    _selectDate(context, false),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 28.h),

                                    // Priority section
                                    _buildSectionTitle('Priority'),
                                    SizedBox(height: 12.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildPriorityCard(
                                          'Low',
                                          Icons.remove,
                                          Colors.green,
                                          0,
                                        ),
                                        _buildPriorityCard(
                                          'Medium',
                                          Icons.horizontal_rule,
                                          Colors.orange,
                                          1,
                                        ),
                                        _buildPriorityCard(
                                          'High',
                                          Icons.keyboard_arrow_up,
                                          Colors.red,
                                          2,
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 40.h),

                                    // Update button
                                    Container(
                                      width: double.infinity,
                                      height: 56.h,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF6366F1),
                                            const Color(0xFF4F46E5),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF4F46E5,
                                            ).withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed:
                                            state is TaskLoading
                                                ? null
                                                : _submitForm,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.r,
                                            ),
                                          ),
                                        ),
                                        child:
                                            state is TaskLoading
                                                ? SizedBox(
                                                  height: 24.h,
                                                  width: 24.w,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                                : Text(
                                                  'Update Task',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                      ),
                                    ),

                                    SizedBox(height: 32.h),
                                  ],
                                ),
                              ),
                            );
                          },
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
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
        focusNode: focusNode,
        maxLines: maxLines,
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
            vertical: 20.h,
          ),
        ),
        validator: validator,
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
              height: 56.h,
              width: 56.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _addSubTask,
                icon: Icon(Icons.add, color: Colors.white, size: 24.sp),
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // Sub-tasks list
        if (_subTasks.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _subTasks.length,
              separatorBuilder:
                  (context, index) =>
                      Divider(color: Colors.white.withOpacity(0.05), height: 1),
              itemBuilder: (context, index) {
                final subTask = _subTasks[index];
                return Container(
                  decoration: BoxDecoration(
                    color:
                        subTask.isDone
                            ? Colors.green.withOpacity(0.05)
                            : Colors.transparent,
                    borderRadius:
                        index == 0
                            ? BorderRadius.only(
                              topLeft: Radius.circular(16.r),
                              topRight: Radius.circular(16.r),
                            )
                            : index == _subTasks.length - 1
                            ? BorderRadius.only(
                              bottomLeft: Radius.circular(16.r),
                              bottomRight: Radius.circular(16.r),
                            )
                            : BorderRadius.zero,
                  ),
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
                        color:
                            subTask.isDone
                                ? Colors.white.withOpacity(0.6)
                                : Colors.white,
                        decoration:
                            subTask.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.red.withOpacity(0.7),
                        size: 20.sp,
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
                fontSize: 12.sp,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: const Color(0xFF818CF8),
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  DateFormat('MMM d, y').format(date),
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityCard(
    String label,
    IconData icon,
    Color color,
    int value,
  ) {
    final bool isSelected = _priority == value;
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
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? color : Colors.white.withOpacity(0.6),
                size: 20.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
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
      // Create updated task
      final updatedTask = widget.task.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
        priority: _priority,
        subTasks: _subTasks,
      );

      // Use TaskCubit to update the task
      context.read<TaskCubit>().updateTask(updatedTask);
    }
  }
}
