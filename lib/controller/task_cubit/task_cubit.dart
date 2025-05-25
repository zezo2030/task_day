import 'package:equatable/equatable.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/services/hive_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskInitial());

  // add task
  Future<void> addTask(TaskModel task) async {
    emit(TaskLoading());
    try {
      await HiveService.addTask(task);
      emit(TaskAdded(task));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // get tasks
  Future<void> getTasks() async {
    emit(TaskLoading());
    try {
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
      final tasks = await HiveService.getTodayTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // get tasks for this week
  Future<void> getWeekTasks() async {
    emit(TaskLoading());
    try {
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
      final updatedTask = task.copyWith(isDone: !task.isDone);
      emit(TaskUpdated(updatedTask));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // delete task
  Future<void> deleteTask(String id) async {
    emit(TaskLoading());
    try {
      await HiveService.deleteTask(id);
      emit(TaskDeleted());
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // add subtask
  Future<void> addSubtask(String taskId, SubTaskModel subtask) async {
    emit(TaskLoading());
    try {
      await HiveService.addSubtask(taskId, subtask);
      // Get the updated task from storage
      final tasks = await HiveService.getAllTasks();
      final updatedTask = tasks.firstWhere((task) => task.id == taskId);
      emit(TaskUpdated(updatedTask));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // delete subtask
  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    emit(TaskLoading());
    try {
      await HiveService.deleteSubtask(taskId, subtaskId);
      // Get the updated task from storage
      final tasks = await HiveService.getAllTasks();
      final updatedTask = tasks.firstWhere((task) => task.id == taskId);
      emit(TaskUpdated(updatedTask));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // toggle subtask
  Future<void> toggleSubtask(String taskId, SubTaskModel subtask) async {
    emit(TaskLoading());
    try {
      await HiveService.toggleSubtaskCompletion(taskId, subtask.id);
      // Get the updated task from storage
      final tasks = await HiveService.getAllTasks();
      final updatedTask = tasks.firstWhere((task) => task.id == taskId);
      emit(TaskUpdated(updatedTask));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
