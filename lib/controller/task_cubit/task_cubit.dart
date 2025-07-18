import 'package:equatable/equatable.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/services/hive_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'task_state.dart';

enum TaskFilter { all, today, week, month, custom }

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskInitial());

  // Track current filter
  TaskFilter _currentFilter = TaskFilter.all;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  TaskFilter get currentFilter => _currentFilter;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;

  // Reload tasks based on current filter
  Future<void> _reloadCurrentFilter() async {
    List<TaskModel> tasks;

    switch (_currentFilter) {
      case TaskFilter.all:
        tasks = await HiveService.getAllTasks();
        break;
      case TaskFilter.today:
        tasks = await HiveService.getTodayTasks();
        print(
          'TaskCubit: _reloadCurrentFilter (today) returned ${tasks.length} tasks',
        );
        break;
      case TaskFilter.week:
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        tasks = await HiveService.getTasksByDateRange(startOfWeek, endOfWeek);
        break;
      case TaskFilter.month:
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        tasks = await HiveService.getTasksByDateRange(startOfMonth, endOfMonth);
        break;
      case TaskFilter.custom:
        if (_customStartDate != null && _customEndDate != null) {
          tasks = await HiveService.getTasksByDateRange(
            _customStartDate!,
            _customEndDate!,
          );
        } else {
          tasks = await HiveService.getAllTasks();
        }
        break;
    }

    emit(TaskLoaded(tasks));
  }

  // add task
  Future<void> addTask(TaskModel task) async {
    emit(TaskLoading());
    try {
      await HiveService.addTask(task);
      // Reload based on current filter instead of all tasks
      await _reloadCurrentFilter();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // get tasks
  Future<void> getTasks() async {
    emit(TaskLoading());
    try {
      _currentFilter = TaskFilter.all;
      _customStartDate = null;
      _customEndDate = null;
      final tasks = await HiveService.getAllTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // get tasks for today
  Future<void> getTodayTasks() async {
    emit(TaskLoading());
    try {
      _currentFilter = TaskFilter.today;
      _customStartDate = null;
      _customEndDate = null;
      final tasks = await HiveService.getTodayTasks();
      print('TaskCubit: getTodayTasks returned ${tasks.length} tasks');
      emit(TaskLoaded(tasks));
    } catch (e) {
      print('TaskCubit: Error in getTodayTasks: $e');
      emit(TaskError(e.toString()));
    }
  }

  // get tasks for this week
  Future<void> getWeekTasks() async {
    emit(TaskLoading());
    try {
      _currentFilter = TaskFilter.week;
      _customStartDate = null;
      _customEndDate = null;
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final tasks = await HiveService.getTasksByDateRange(
        startOfWeek,
        endOfWeek,
      );
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // get tasks for this month
  Future<void> getMonthTasks() async {
    emit(TaskLoading());
    try {
      _currentFilter = TaskFilter.month;
      _customStartDate = null;
      _customEndDate = null;
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      final tasks = await HiveService.getTasksByDateRange(
        startOfMonth,
        endOfMonth,
      );
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // get tasks for custom date range
  Future<void> getTasksByDateRange(DateTime startDate, DateTime endDate) async {
    emit(TaskLoading());
    try {
      _currentFilter = TaskFilter.custom;
      _customStartDate = startDate;
      _customEndDate = endDate;
      final tasks = await HiveService.getTasksByDateRange(startDate, endDate);
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // toggle task
  Future<void> toggleTask(TaskModel task) async {
    emit(TaskLoading());
    try {
      await HiveService.toggleTaskCompletion(task.id);
      // Reload based on current filter instead of all tasks
      await _reloadCurrentFilter();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // delete task
  Future<void> deleteTask(String id) async {
    emit(TaskLoading());
    try {
      await HiveService.deleteTask(id);
      // Reload based on current filter instead of all tasks
      await _reloadCurrentFilter();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // update task
  Future<void> updateTask(TaskModel task) async {
    emit(TaskLoading());
    try {
      await HiveService.updateTask(task);
      // Reload based on current filter instead of all tasks
      await _reloadCurrentFilter();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // add subtask
  Future<void> addSubtask(String taskId, SubTaskModel subtask) async {
    emit(TaskLoading());
    try {
      await HiveService.addSubtask(taskId, subtask);
      // Reload based on current filter instead of all tasks
      await _reloadCurrentFilter();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // delete subtask
  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    emit(TaskLoading());
    try {
      await HiveService.deleteSubtask(taskId, subtaskId);
      // Reload based on current filter instead of all tasks
      await _reloadCurrentFilter();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // toggle subtask
  Future<void> toggleSubtask(String taskId, SubTaskModel subtask) async {
    emit(TaskLoading());
    try {
      await HiveService.toggleSubtaskCompletion(taskId, subtask.id);
      // Reload based on current filter instead of all tasks
      await _reloadCurrentFilter();
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
