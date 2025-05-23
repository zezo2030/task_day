import 'package:flutter/material.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/view/task_details_screen.dart';
import 'package:task_day/controller/task_cubit/task_cubit.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  final String _filterOption = 'All';
  late AnimationController _animationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Load tasks when screen initializes
    context.read<TaskCubit>().getTasks();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks) {
    switch (_filterOption) {
      case 'Completed':
        return tasks.where((task) => task.isDone).toList();
      case 'Pending':
        return tasks.where((task) => !task.isDone).toList();
      case 'All':
      default:
        return tasks;
    }
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
      child: SafeArea(
        child: Stack(
          children: [
            // Background effects (decorative circles)
            Positioned(
              top: -50.h,
              right: -30.w,
              child: Container(
                height: 200.h,
                width: 200.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4F46E5).withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 150.h,
              left: -70.w,
              child: Container(
                height: 150.h,
                width: 150.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF818CF8).withOpacity(0.07),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with beautiful effect
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  0,
                                  (1 - _animationController.value) * 20,
                                ),
                                child: Opacity(
                                  opacity: _animationController.value,
                                  child: Text(
                                    'My Tasks',
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
                                              Rect.fromLTWH(0, 0, 200.w, 70.h),
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            'Organize your day with style',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      // Animated search button
                      Container(
                        height: 45.h,
                        width: 45.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4F46E5).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          onPressed: () {
                            // Add search functionality
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Date selector container
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _dateFilterButton('Today', true),
                        _dateFilterButton('Week', false),
                        _dateFilterButton('Month', false),
                        Container(
                          height: 38.h,
                          width: 38.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: const Color(0xFF4F46E5).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.calendar_month,
                              color: const Color(0xFF4F46E5),
                              size: 18.sp,
                            ),
                            onPressed: () {
                              // Calendar picker
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Tasks List with BlocBuilder
                Expanded(
                  child: BlocConsumer<TaskCubit, TaskState>(
                    listener: (context, state) {
                      if (state is TaskError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${state.message}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is TaskLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4F46E5),
                          ),
                        );
                      }

                      if (state is TaskLoaded) {
                        final filteredTasks = _getFilteredTasks(state.tasks);
                        return filteredTasks.isEmpty
                            ? _buildEmptyState()
                            : _buildTasksList(filteredTasks);
                      }

                      // Handle other states
                      if (state is TaskAdded ||
                          state is TaskToggled ||
                          state is TaskDeleted) {
                        // Refresh tasks after any modification
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.read<TaskCubit>().getTasks();
                        });
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4F46E5),
                          ),
                        );
                      }

                      return _buildEmptyState();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateFilterButton(String text, bool isSelected) {
    return InkWell(
      onTap: () {
        // Change date filter
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF4F46E5).withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isSelected
                    ? const Color(0xFF4F46E5).withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _animationController.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FluentSystemIcons.ic_fluent_document_filled,
                  size: 80.sp,
                  color: Colors.grey.shade700,
                ),
                SizedBox(height: 20.h),
                Text(
                  'No ${_filterOption.toLowerCase()} tasks',
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Tap + to create a new task',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 30.h),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add new task action
                  },
                  icon: Icon(Icons.add, size: 20.sp),
                  label: Text('Create Task'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.purpleAccent,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 8,
                    shadowColor: Colors.purpleAccent.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTasksList(List<TaskModel> tasks) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ListView.builder(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            // Staggered animation effect
            final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  0.1 + 0.1 * index, // Staggered start
                  0.6 + 0.1 * index, // Staggered end
                  curve: Curves.easeOutQuart,
                ),
              ),
            );

            return Transform.translate(
              offset: Offset(0, (1 - itemAnimation.value) * 50),
              child: Opacity(
                opacity: itemAnimation.value,
                child: _buildEnhancedTaskCard(task, context, index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEnhancedTaskCard(
    TaskModel task,
    BuildContext context,
    int index,
  ) {
    final bool isLate = task.endDate.isBefore(DateTime.now()) && !task.isDone;
    final taskPriority = index % 3; // Just for demo: 0=low, 1=medium, 2=high
    final priorityColor =
        taskPriority == 0
            ? const Color(0xFF3B82F6) // Blue
            : taskPriority == 1
            ? const Color(0xFFF59E0B) // Amber
            : const Color(0xFFEF4444); // Red

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color:
                task.isDone
                    ? const Color(0xFF10B981).withOpacity(0.15) // Green
                    : isLate
                    ? const Color(0xFFEF4444).withOpacity(0.15) // Red
                    : const Color(0xFF9D4EDD).withOpacity(0.15), // Purple
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color:
              task.isDone
                  ? const Color(0xFF10B981).withOpacity(0.3) // Green
                  : isLate
                  ? const Color(0xFFEF4444).withOpacity(0.3) // Red
                  : const Color(0xFF9D4EDD).withOpacity(0.3), // Purple
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => _showEnhancedTaskDetails(task),
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Priority indicator
                  Container(
                    width: 4.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            decoration:
                                task.isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey.shade400,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      // Beautiful Task completion button
                      _buildBeautifulTaskButton(task),
                      if (isLate && !task.isDone)
                        Container(
                          margin: EdgeInsets.only(top: 6.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'LATE',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date indicator
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14.sp,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${DateFormat('MMM d').format(task.startDate)} - ${DateFormat('MMM d').format(task.endDate)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  // Task priority label
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      taskPriority == 0
                          ? 'LOW'
                          : taskPriority == 1
                          ? 'MED'
                          : 'HIGH',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: priorityColor,
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

  Widget _buildBeautifulTaskButton(TaskModel task) {
    return GestureDetector(
      onTap: () {
        context.read<TaskCubit>().toggleTask(task);
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            height: 50.h,
            width: 50.w,
            transform:
                !task.isDone
                    ? (Matrix4.identity()
                      ..scale(1.0 + (_pulseController.value * 0.05)))
                    : Matrix4.identity(),
            decoration: BoxDecoration(
              gradient:
                  task.isDone
                      ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF10B981),
                          const Color(0xFF059669),
                        ],
                      )
                      : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF818CF8).withOpacity(0.1),
                          const Color(0xFF4F46E5).withOpacity(0.1),
                        ],
                      ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      task.isDone
                          ? const Color(0xFF10B981).withOpacity(0.4)
                          : const Color(0xFF4F46E5).withOpacity(0.2),
                  blurRadius: task.isDone ? 15 : 10,
                  offset: const Offset(0, 5),
                  spreadRadius: task.isDone ? 2 : 0,
                ),
              ],
              border: Border.all(
                color:
                    task.isDone
                        ? const Color(0xFF10B981)
                        : const Color(0xFF4F46E5).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (task.isDone)
                  Container(
                    height: 40.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    task.isDone
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    key: ValueKey(task.isDone),
                    color: task.isDone ? Colors.white : const Color(0xFF4F46E5),
                    size: 30.sp,
                  ),
                ),
                if (task.isDone) ...[
                  Positioned(
                    top: 10.h,
                    right: 8.w,
                    child: Icon(
                      Icons.star_rounded,
                      size: 10.sp,
                      color: Colors.yellow.shade300,
                    ),
                  ),
                  Positioned(
                    bottom: 8.h,
                    left: 8.w,
                    child: Icon(
                      Icons.star_rounded,
                      size: 8.sp,
                      color: Colors.yellow.shade200,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEnhancedTaskDetails(TaskModel task) {
    // Navigate to the task details screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
    ).then((updatedTask) {
      // Refresh tasks if returned from details screen with changes
      if (updatedTask != null && updatedTask is TaskModel) {
        context.read<TaskCubit>().getTasks();
      }
    });
  }
}
