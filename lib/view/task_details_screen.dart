import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/controller/task_cubit/task_cubit.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _subtaskController;
  final FocusNode _subtaskFocus = FocusNode();

  // Local state to track dismissed subtasks
  final Set<String> _dismissedSubtasks = <String>{};

  @override
  void initState() {
    super.initState();
    _subtaskController = TextEditingController();
  }

  @override
  void dispose() {
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
            // Clear dismissed subtasks when data is reloaded
            setState(() {
              _dismissedSubtasks.clear();
            });
          }
        },
        builder: (context, state) {
          // Get the current task from state or use the initial task
          TaskModel currentTask = widget.task;
          if (state is TaskLoaded) {
            // Find the current task from the loaded tasks
            try {
              currentTask = state.tasks.firstWhere(
                (task) => task.id == widget.task.id,
              );
            } catch (e) {
              // If task not found, use the original task
              currentTask = widget.task;
            }
          } else if (state is TaskUpdated) {
            currentTask = state.task;
          }

          // Get the priority color based on task priority
          final Color priorityColor = _getPriorityColor(currentTask.priority);

          // Calculate progress (excluding dismissed subtasks)
          final visibleSubtasks =
              currentTask.subTasks
                  .where((st) => !_dismissedSubtasks.contains(st.id))
                  .toList();
          final int totalSubtasks = visibleSubtasks.length;
          final int completedSubtasks =
              visibleSubtasks.where((st) => st.isDone).length;
          final double progress =
              totalSubtasks > 0 ? completedSubtasks / totalSubtasks : 0.0;

          // Check if all subtasks are completed (excluding dismissed ones)
          final bool allSubtasksCompleted =
              visibleSubtasks.isEmpty ||
              visibleSubtasks.every((subtask) => subtask.isDone);
          final bool canCompleteTask =
              currentTask.isDone || allSubtasksCompleted;

          return Scaffold(
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
                        color: priorityColor.withOpacity(0.08),
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

                  // Main content with CustomScrollView
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // App Bar
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        pinned: false,
                        floating: true,
                        snap: true,
                        expandedHeight: 60.h,
                        leading: IconButton(
                          icon: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop(currentTask);
                            } else {
                              context.go('/tasks');
                            }
                          },
                        ),
                        actions: [
                          IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            ),
                            onPressed: () {
                              // Navigate to edit screen
                              context.push(
                                '/edit-task/${currentTask.id}',
                                extra: currentTask,
                              );
                            },
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.withOpacity(0.1),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 18.sp,
                              ),
                            ),
                            onPressed: () {
                              _showDeleteConfirmation(currentTask);
                            },
                          ),
                          SizedBox(width: 8.w),
                        ],
                      ),

                      // Header section with title and completion status
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 8.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTaskHeader(
                                context,
                                currentTask,
                                priorityColor,
                                canCompleteTask,
                              ),
                              SizedBox(height: 20.h),
                              if (totalSubtasks > 0) ...[
                                _buildProgressSection(
                                  completedSubtasks,
                                  totalSubtasks,
                                  progress,
                                  priorityColor,
                                ),
                                SizedBox(height: 8.h),
                                // Progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.1,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      priorityColor,
                                    ),
                                    minHeight: 8.h,
                                  ),
                                ),
                              ],
                              SizedBox(height: 24.h),
                              _buildDescriptionSection(currentTask),
                              SizedBox(height: 24.h),
                            ],
                          ),
                        ),
                      ),

                      // Subtasks section header
                      SliverToBoxAdapter(
                        child: _buildSubtasksHeader(
                          completedSubtasks,
                          totalSubtasks,
                        ),
                      ),

                      SliverToBoxAdapter(child: SizedBox(height: 16.h)),

                      // Add subtask input
                      SliverToBoxAdapter(
                        child: _buildAddSubtaskRow(context, currentTask),
                      ),

                      SliverToBoxAdapter(child: SizedBox(height: 16.h)),

                      // Subtasks list
                      currentTask.subTasks.isEmpty ||
                              currentTask.subTasks.every(
                                (st) => _dismissedSubtasks.contains(st.id),
                              )
                          ? SliverToBoxAdapter(
                            child: SizedBox(
                              height: 300.h,
                              child: _buildEmptySubtasks(),
                            ),
                          )
                          : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                // Filter out dismissed subtasks
                                final visibleSubtasks =
                                    currentTask.subTasks
                                        .where(
                                          (st) =>
                                              !_dismissedSubtasks.contains(
                                                st.id,
                                              ),
                                        )
                                        .toList();

                                if (index >= visibleSubtasks.length) {
                                  return const SizedBox.shrink();
                                }

                                final subtask = visibleSubtasks[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  child: _buildSubtaskItem(
                                    subtask,
                                    index,
                                    currentTask,
                                  ),
                                );
                              },
                              childCount:
                                  currentTask.subTasks
                                      .where(
                                        (st) =>
                                            !_dismissedSubtasks.contains(st.id),
                                      )
                                      .length,
                            ),
                          ),

                      // Bottom padding
                      SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Extracted widget for Task Header
  Widget _buildTaskHeader(
    BuildContext context,
    TaskModel currentTask,
    Color priorityColor,
    bool canCompleteTask,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Priority indicator
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                _getPriorityText(currentTask.priority),
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: priorityColor,
                ),
              ),
            ),
            const Spacer(),
            // Task completion toggle
            InkWell(
              onTap: () {
                // Check if all subtasks are completed before allowing task completion
                if (!canCompleteTask) {
                  // Show error message if not all subtasks are completed
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Complete all subtasks before marking this task as done',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.orange.withOpacity(0.9),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  );
                  return;
                }

                // Use TaskCubit to toggle task completion
                context.read<TaskCubit>().toggleTask(currentTask);
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color:
                      currentTask.isDone
                          ? Colors.green.withOpacity(0.15)
                          : canCompleteTask
                          ? Colors.grey.withOpacity(0.15)
                          : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      currentTask.isDone
                          ? Icons.check_circle
                          : canCompleteTask
                          ? Icons.circle_outlined
                          : Icons.lock_outline,
                      color:
                          currentTask.isDone
                              ? Colors.green
                              : canCompleteTask
                              ? Colors.grey
                              : Colors.red.withOpacity(0.7),
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      currentTask.isDone
                          ? 'Completed'
                          : canCompleteTask
                          ? 'In Progress'
                          : 'Complete Subtasks',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            currentTask.isDone
                                ? Colors.green
                                : canCompleteTask
                                ? Colors.grey
                                : Colors.red.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        // Task title
        Text(
          currentTask.title,
          style: GoogleFonts.poppins(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 20.h),
        // Task dates
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: Colors.white.withOpacity(0.7),
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              "${DateFormat('MMM d, y').format(currentTask.startDate)} - ${DateFormat('MMM d, y').format(currentTask.endDate)}",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Extracted widget for Progress Section
  Widget _buildProgressSection(
    int completedSubtasks,
    int totalSubtasks,
    double progress,
    Color priorityColor,
  ) {
    return Row(
      children: [
        Text(
          "Progress:",
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          "$completedSubtasks of $totalSubtasks tasks",
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Text(
          "${(progress * 100).toInt()}%",
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: priorityColor,
          ),
        ),
      ],
    );
  }

  // Extracted widget for Description Section
  Widget _buildDescriptionSection(TaskModel currentTask) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Text(
            currentTask.description,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // Extracted widget for Subtasks Header
  Widget _buildSubtasksHeader(int completedSubtasks, int totalSubtasks) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Subtasks",
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.task_alt_outlined,
                  size: 16.sp,
                  color: const Color(0xFF4F46E5),
                ),
                SizedBox(width: 6.w),
                Text(
                  "$completedSubtasks/$totalSubtasks",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Extracted widget for Add Subtask Row
  Widget _buildAddSubtaskRow(BuildContext context, TaskModel currentTask) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color:
                      currentTask.isDone
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white.withOpacity(0.12),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _subtaskController,
                focusNode: _subtaskFocus,
                enabled: !currentTask.isDone, // Disable if task is done
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color:
                      currentTask.isDone
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white,
                ),
                decoration: InputDecoration(
                  hintText:
                      currentTask.isDone
                          ? 'Task completed'
                          : 'Add new subtask...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  filled: true,
                  fillColor:
                      currentTask.isDone
                          ? Colors.white.withOpacity(0.03)
                          : Colors.transparent,
                ),
                onSubmitted:
                    currentTask.isDone ? null : (_) => _addSubTask(currentTask),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          InkWell(
            onTap:
                currentTask.isDone
                    ? null // Disable onTap if task is done
                    : () => _addSubTask(currentTask),
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color:
                    currentTask.isDone
                        ? Colors.grey.withOpacity(0.2) // Disabled color
                        : const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow:
                    currentTask.isDone
                        ? null
                        : [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
              ),
              child: Icon(
                Icons.add,
                color:
                    currentTask.isDone
                        ? Colors.white.withOpacity(0.3) // Disabled icon color
                        : Colors.white,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Empty state for subtasks
  Widget _buildEmptySubtasks() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(28.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.white.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4F46E5).withOpacity(0.2),
                    const Color(0xFF7C3AED).withOpacity(0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.playlist_add_check_rounded,
                size: 44.sp,
                color: const Color(0xFF4F46E5),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "No subtasks yet",
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Break down your task into smaller,\nmanageable subtasks",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.5),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF4F46E5).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 15.sp,
                    color: const Color(0xFF4F46E5),
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    "Use the input above to add subtasks",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Single subtask item
  Widget _buildSubtaskItem(
    SubTaskModel subtask,
    int index,
    TaskModel currentTask,
  ) {
    // Get the priority color for this task
    final Color taskPriorityColor = _getPriorityColor(currentTask.priority);
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              subtask.isDone
                  ? [
                    taskPriorityColor.withOpacity(0.08),
                    taskPriorityColor.withOpacity(0.05),
                  ]
                  : [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color:
              subtask.isDone
                  ? taskPriorityColor.withOpacity(0.4)
                  : Colors.white.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                subtask.isDone
                    ? taskPriorityColor.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Dismissible(
        key: ValueKey('${currentTask.id}_${subtask.id}'),
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.transparent, Colors.red.withOpacity(0.3)],
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete_sweep_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                'Delete',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          // Add to dismissed set immediately for UI
          setState(() {
            _dismissedSubtasks.add(subtask.id);
          });

          // Handle the actual removal
          _removeSubtask(subtask, currentTask);
          return true;
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            children: [
              // Custom checkbox with animation
              GestureDetector(
                onTap: () => _toggleSubtaskStatus(subtask, currentTask),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 28.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        subtask.isDone
                            ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                taskPriorityColor,
                                taskPriorityColor.withOpacity(0.8),
                              ],
                            )
                            : null,
                    color: subtask.isDone ? null : Colors.transparent,
                    border: Border.all(
                      color:
                          subtask.isDone
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow:
                        subtask.isDone
                            ? [
                              BoxShadow(
                                color: taskPriorityColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child:
                      subtask.isDone
                          ? Icon(
                            Icons.check_rounded,
                            size: 18.sp,
                            color: Colors.white,
                          )
                          : null,
                ),
              ),

              SizedBox(width: 16.w),

              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            subtask.isDone
                                ? Colors.white.withOpacity(0.7)
                                : Colors.white,
                        decoration:
                            subtask.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                        decorationColor: Colors.white.withOpacity(0.5),
                        decorationThickness: 2,
                      ),
                      child: Text(subtask.title),
                    ),

                    if (subtask.isDone) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14.sp,
                            color: taskPriorityColor,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Completed',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: taskPriorityColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Priority indicator (optional visual enhancement)
                  Container(
                    width: 4.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color:
                          subtask.isDone
                              ? taskPriorityColor
                              : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Delete button
                  GestureDetector(
                    onTap: () => _removeSubtask(subtask, currentTask),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 16.sp,
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

  // Add a new subtask
  void _addSubTask(TaskModel currentTask) {
    final String title = _subtaskController.text.trim();

    // Check if the task is already completed
    if (currentTask.isDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot add subtasks to a completed task.',
            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white),
          ),
          backgroundColor: Colors.orange.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return; // Exit if task is completed
    }

    if (title.isNotEmpty) {
      final newSubtask = SubTaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
      );

      // Use TaskCubit to add subtask
      context.read<TaskCubit>().addSubtask(currentTask.id, newSubtask);

      // Clear input
      _subtaskController.clear();
      FocusScope.of(context).requestFocus(_subtaskFocus);
    }
  }

  // Toggle subtask completion status
  void _toggleSubtaskStatus(SubTaskModel subtask, TaskModel currentTask) {
    // Use TaskCubit to toggle subtask
    context.read<TaskCubit>().toggleSubtask(currentTask.id, subtask);
  }

  // Remove a subtask
  void _removeSubtask(SubTaskModel subtask, TaskModel currentTask) {
    // Use TaskCubit to delete subtask
    context.read<TaskCubit>().deleteSubtask(currentTask.id, subtask.id);
  }

  // Helper method to get priority color
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return const Color(0xFF3B82F6); // Low - Blue
      case 1:
        return const Color(0xFFF59E0B); // Medium - Amber
      case 2:
        return const Color(0xFFEF4444); // High - Red
      default:
        return const Color(0xFF3B82F6); // Default - Blue
    }
  }

  // Helper method to get priority text
  String _getPriorityText(int priority) {
    switch (priority) {
      case 0:
        return 'Low Priority';
      case 1:
        return 'Medium Priority';
      case 2:
        return 'High Priority';
      default:
        return 'Low Priority';
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation(TaskModel task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: const Color(0xFF191B2F),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 32.sp,
                  ),
                ),

                SizedBox(height: 16.h),

                // Title
                Text(
                  'Delete Task',
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 12.h),

                // Description
                Text(
                  'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24.h),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Delete the task
                            context.read<TaskCubit>().deleteTask(task.id);
                            // Navigate back to tasks list
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/tasks');
                            }
                          },
                          child: Text(
                            'Delete',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
        );
      },
    );
  }
}
