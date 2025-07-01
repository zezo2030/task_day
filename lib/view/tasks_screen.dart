import 'package:flutter/material.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/controller/task_cubit/task_cubit.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  final String _filterOption = 'All';
  String _dateFilter = 'Today'; // Current selected date filter
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _fabController;

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

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Load tasks when screen initializes
    _loadTasksBasedOnFilter();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  // Load tasks based on current date filter
  void _loadTasksBasedOnFilter() {
    final taskCubit = context.read<TaskCubit>();
    switch (_dateFilter) {
      case 'Today':
        taskCubit.getTodayTasks();
        break;
      case 'Week':
        taskCubit.getWeekTasks();
        break;
      case 'Month':
        taskCubit.getMonthTasks();
        break;
      case 'Custom':
        if (_customStartDate != null && _customEndDate != null) {
          taskCubit.getTasksByDateRange(_customStartDate!, _customEndDate!);
        } else {
          taskCubit.getTasks();
        }
        break;
      default:
        taskCubit.getTasks();
    }
  }

  // Handle date filter change
  void _onDateFilterChanged(String filter) {
    if (_dateFilter != filter) {
      setState(() {
        _dateFilter = filter;
      });
      _loadTasksBasedOnFilter();
    }
  }

  // Show custom date range picker
  Future<void> _showCustomDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange:
          _customStartDate != null && _customEndDate != null
              ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4F46E5),
              onPrimary: Colors.white,
              surface: Color(0xFF191B2F),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF0F1227),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _dateFilter = 'Custom';
      });
      context.read<TaskCubit>().getTasksByDateRange(picked.start, picked.end);
    }
  }

  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks) {
    List<TaskModel> filteredTasks;

    // Apply status filter
    switch (_filterOption) {
      case 'Completed':
        filteredTasks = tasks.where((task) => task.isDone).toList();
        break;
      case 'Pending':
        filteredTasks = tasks.where((task) => !task.isDone).toList();
        break;
      case 'All':
      default:
        filteredTasks = tasks;
    }

    return filteredTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                          _dateFilterButton('Today', _dateFilter == 'Today'),
                          _dateFilterButton('Week', _dateFilter == 'Week'),
                          _dateFilterButton('Month', _dateFilter == 'Month'),
                          Container(
                            height: 38.h,
                            width: 38.w,
                            decoration: BoxDecoration(
                              color:
                                  _dateFilter == 'Custom'
                                      ? const Color(
                                        0xFF4F46E5,
                                      ).withOpacity(0.15)
                                      : Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color:
                                    _dateFilter == 'Custom'
                                        ? const Color(
                                          0xFF4F46E5,
                                        ).withOpacity(0.5)
                                        : const Color(
                                          0xFF4F46E5,
                                        ).withOpacity(0.2),
                                width: _dateFilter == 'Custom' ? 1.5 : 1,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.calendar_month,
                                color: const Color(0xFF4F46E5),
                                size: 18.sp,
                              ),
                              onPressed: _showCustomDateRangePicker,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Show custom date range info if selected
                  if (_dateFilter == 'Custom' &&
                      _customStartDate != null &&
                      _customEndDate != null)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: const Color(0xFF4F46E5).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.date_range,
                              color: const Color(0xFF4F46E5),
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${DateFormat('MMM d').format(_customStartDate!)} - ${DateFormat('MMM d, y').format(_customEndDate!)}',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: const Color(0xFF4F46E5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _dateFilter = 'Today';
                                  _customStartDate = null;
                                  _customEndDate = null;
                                });
                                _loadTasksBasedOnFilter();
                              },
                              child: Icon(
                                Icons.close,
                                color: const Color(0xFF4F46E5),
                                size: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 16.h),

                  // Statistics cards
                  _buildStatisticsCards(),

                  // Tasks List with BlocBuilder
                  Expanded(
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
                        }
                      },
                      builder: (context, state) {
                        if (state is TaskLoading) {
                          return _buildLoadingState();
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
                            _loadTasksBasedOnFilter();
                          });
                          return _buildLoadingState();
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
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - _animationController.value) * 20),
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
          ),
          // Filter/Menu button
          Container(
            height: 45.h,
            width: 45.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.tune, color: Colors.white, size: 20.sp),
              onPressed: () {
                // Show filter options
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDateFilters() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _dateFilterButton('Today', _dateFilter == 'Today'),
            _dateFilterButton('Week', _dateFilter == 'Week'),
            _dateFilterButton('Month', _dateFilter == 'Month'),
            Container(
              height: 40.h,
              width: 40.w,
              decoration: BoxDecoration(
                color:
                    _dateFilter == 'Custom'
                        ? const Color(0xFF4F46E5).withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color:
                      _dateFilter == 'Custom'
                          ? const Color(0xFF4F46E5).withOpacity(0.8)
                          : const Color(0xFF4F46E5).withOpacity(0.3),
                  width: _dateFilter == 'Custom' ? 2 : 1,
                ),
                boxShadow:
                    _dateFilter == 'Custom'
                        ? [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.calendar_month,
                  color: const Color(0xFF4F46E5),
                  size: 18.sp,
                ),
                onPressed: _showCustomDateRangePicker,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateFilterButton(String text, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () => _onDateFilterChanged(text),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                    )
                    : null,
            color: isSelected ? null : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color:
                  isSelected
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.grey.shade300,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        int totalTasks = 0;
        int completedTasks = 0;
        int pendingTasks = 0;

        if (state is TaskLoaded) {
          final tasks = _getFilteredTasks(state.tasks);
          totalTasks = tasks.length;
          completedTasks = tasks.where((task) => task.isDone).length;
          pendingTasks = tasks.where((task) => !task.isDone).length;
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  totalTasks.toString(),
                  const Color(0xFF4F46E5),
                  Icons.assignment,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  completedTasks.toString(),
                  const Color(0xFF10B981),
                  Icons.check_circle,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  pendingTasks.toString(),
                  const Color(0xFFF59E0B),
                  Icons.pending,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 60.h,
            width: 60.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(const Color(0xFF4F46E5)),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Loading tasks...',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String emptyMessage = 'No ${_filterOption.toLowerCase()} tasks';
    if (_dateFilter != 'All') {
      emptyMessage += ' for ${_dateFilter.toLowerCase()}';
    }

    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _animationController.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    FluentSystemIcons.ic_fluent_document_filled,
                    size: 60.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  emptyMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap the + button to create your first task',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
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
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
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
    // Navigate to the task details screen using go_router
    context.push('/task-details/${task.id}', extra: task).then((updatedTask) {
      // Refresh tasks if returned from details screen with changes
      if (updatedTask != null && updatedTask is TaskModel) {
        // Reload tasks based on current filter instead of loading all tasks
        _loadTasksBasedOnFilter();
      }
    });
  }
}
