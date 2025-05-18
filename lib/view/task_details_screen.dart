import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:task_day/models/task_model.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TaskModel _task;
  late TextEditingController _subtaskController;
  final FocusNode _subtaskFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _task = widget.task;
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
    // Get the priority color based on task priority
    final Color priorityColor = _getPriorityColor(_task.priority);

    // Calculate progress
    final int totalSubtasks = _task.subTasks.length;
    final int completedSubtasks =
        _task.subTasks.where((st) => st.isDone).length;
    final double progress =
        totalSubtasks > 0 ? completedSubtasks / totalSubtasks : 0.0;

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
            onPressed: () => Navigator.pop(context, _task),
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
                // Navigate to edit screen (not implemented yet)
              },
            ),
            SizedBox(width: 8.w),
          ],
        ),
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

              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section with title and completion status
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 8.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Priority indicator
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                _getPriorityText(_task.priority),
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
                                setState(() {
                                  _task = _task.copyWith(isDone: !_task.isDone);
                                });
                              },
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _task.isDone
                                          ? Colors.green.withOpacity(0.15)
                                          : Colors.grey.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _task.isDone
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color:
                                          _task.isDone
                                              ? Colors.green
                                              : Colors.grey,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      _task.isDone
                                          ? 'Completed'
                                          : 'In Progress',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            _task.isDone
                                                ? Colors.green
                                                : Colors.grey,
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
                          _task.title,
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
                              "${DateFormat('MMM d, y').format(_task.startDate)} - ${DateFormat('MMM d, y').format(_task.endDate)}",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        // Progress section
                        if (totalSubtasks > 0) ...[
                          Row(
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
                          ),
                          SizedBox(height: 8.h),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                priorityColor,
                              ),
                              minHeight: 8.h,
                            ),
                          ),
                        ],

                        SizedBox(height: 24.h),

                        // Description section
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
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _task.description,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                        ),

                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),

                  // Subtasks section
                  Padding(
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
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
                  ),

                  SizedBox(height: 16.h),

                  // Add subtask input
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              controller: _subtaskController,
                              focusNode: _subtaskFocus,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Add new subtask...',
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
                                fillColor: Colors.transparent,
                              ),
                              onSubmitted: (_) => _addSubTask(),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        InkWell(
                          onTap: _addSubTask,
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF4F46E5,
                                  ).withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Subtasks list
                  Expanded(
                    child:
                        _task.subTasks.isEmpty
                            ? _buildEmptySubtasks()
                            : _buildSubtasksList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty state for subtasks
  Widget _buildEmptySubtasks() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist_rounded,
            size: 60.sp,
            color: Colors.white.withOpacity(0.2),
          ),
          SizedBox(height: 16.h),
          Text(
            "No subtasks yet",
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Add subtasks to break down your task",
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.3),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Subtasks list
  Widget _buildSubtasksList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.only(top: 10.h),
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: _task.subTasks.length,
        itemBuilder: (context, index) {
          final subtask = _task.subTasks[index];
          return _buildSubtaskItem(subtask, index);
        },
      ),
    );
  }

  // Single subtask item
  Widget _buildSubtaskItem(SubTaskModel subtask, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              subtask.isDone
                  ? const Color(0xFF4F46E5).withOpacity(0.3)
                  : Colors.white.withOpacity(0.06),
          width: 1.5,
        ),
      ),
      child: Dismissible(
        key: Key(subtask.id),
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20.w),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            Icons.delete_outline,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          _removeSubtask(index);
        },
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          leading: InkWell(
            onTap: () => _toggleSubtaskStatus(index),
            borderRadius: BorderRadius.circular(20.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    subtask.isDone
                        ? const Color(0xFF4F46E5).withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                border: Border.all(
                  color:
                      subtask.isDone
                          ? const Color(0xFF4F46E5)
                          : Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child:
                  subtask.isDone
                      ? Icon(
                        Icons.check,
                        size: 16.sp,
                        color: const Color(0xFF4F46E5),
                      )
                      : null,
            ),
          ),
          title: Text(
            subtask.title,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color:
                  subtask.isDone ? Colors.white.withOpacity(0.6) : Colors.white,
              decoration: subtask.isDone ? TextDecoration.lineThrough : null,
              decorationColor: Colors.white.withOpacity(0.4),
              decorationThickness: 2,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.white.withOpacity(0.6),
                  size: 20.sp,
                ),
                onPressed: () => _removeSubtask(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add a new subtask
  void _addSubTask() {
    final String title = _subtaskController.text.trim();
    if (title.isNotEmpty) {
      setState(() {
        List<SubTaskModel> updatedSubtasks = List.from(_task.subTasks);
        updatedSubtasks.add(
          SubTaskModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
          ),
        );
        _task = _task.copyWith(subTasks: updatedSubtasks);
        _subtaskController.clear();
      });
      FocusScope.of(context).requestFocus(_subtaskFocus);
    }
  }

  // Toggle subtask completion status
  void _toggleSubtaskStatus(int index) {
    setState(() {
      List<SubTaskModel> updatedSubtasks = List.from(_task.subTasks);
      final subtask = updatedSubtasks[index];
      updatedSubtasks[index] = subtask.copyWith(isDone: !subtask.isDone);
      _task = _task.copyWith(subTasks: updatedSubtasks);
    });
  }

  // Remove a subtask
  void _removeSubtask(int index) {
    setState(() {
      List<SubTaskModel> updatedSubtasks = List.from(_task.subTasks);
      updatedSubtasks.removeAt(index);
      _task = _task.copyWith(subTasks: updatedSubtasks);
    });
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
}
