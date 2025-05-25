part of 'task_cubit.dart';

sealed class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object> get props => [];
}

final class TaskInitial extends TaskState {}

final class TaskLoading extends TaskState {}

final class TaskAdded extends TaskState {
  final TaskModel task;

  const TaskAdded(this.task);

  @override
  List<Object> get props => [task];
}

final class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);
}

final class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;

  const TaskLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

final class TaskToggled extends TaskState {
  final TaskModel task;

  const TaskToggled(this.task);

  @override
  List<Object> get props => [task];
}

final class TaskUpdated extends TaskState {
  final TaskModel task;

  const TaskUpdated(this.task);

  @override
  List<Object> get props => [task];
}

final class TaskDeleted extends TaskState {
  const TaskDeleted();
}

final class SubtaskAdded extends TaskState {
  final SubTaskModel subtask;

  const SubtaskAdded(this.subtask);

  @override
  List<Object> get props => [subtask];
}

final class SubtaskDeleted extends TaskState {
  final String subtaskId;

  const SubtaskDeleted(this.subtaskId);

  @override
  List<Object> get props => [subtaskId];
}

final class SubtaskToggled extends TaskState {
  final SubTaskModel subtask;

  const SubtaskToggled(this.subtask);

  @override
  List<Object> get props => [subtask];
}
