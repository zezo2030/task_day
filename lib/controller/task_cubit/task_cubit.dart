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

  // toggle task
  Future<void> toggleTask(TaskModel task) async {
    emit(TaskLoading());
    try {
      await HiveService.toggleTaskCompletion(task.id);
      emit(TaskToggled(task));
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
      emit(SubtaskAdded(subtask));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // delete subtask
  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    emit(TaskLoading());
    try {
      await HiveService.deleteSubtask(taskId, subtaskId);
      emit(SubtaskDeleted(subtaskId));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  // toggle subtask
  Future<void> toggleSubtask(String taskId, SubTaskModel subtask) async {
    emit(TaskLoading());
    try {
      await HiveService.toggleSubtaskCompletion(taskId, subtask.id);
      emit(SubtaskToggled(subtask));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
