import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class SubTaskModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isDone;

  const SubTaskModel({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  SubTaskModel copyWith({String? id, String? title, bool? isDone}) =>
      SubTaskModel(
        id: id ?? this.id,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
      );

  @override
  List<Object?> get props => [id, title, isDone];
}

@HiveType(typeId: 1)
class TaskModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final bool isDone;

  @HiveField(4)
  final DateTime startDate;

  @HiveField(5)
  final DateTime endDate;

  @HiveField(6)
  final int priority; // 0: Low, 1: Medium, 2: High

  @HiveField(7)
  final List<SubTaskModel> subTasks;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    required this.startDate,
    required this.endDate,
    required this.priority,
    this.subTasks = const [],
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? startDate,
    DateTime? endDate,
    int? priority,
    List<SubTaskModel>? subTasks,
  }) => TaskModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    isDone: isDone ?? this.isDone,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    priority: priority ?? this.priority,
    subTasks: subTasks ?? this.subTasks,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    isDone,
    startDate,
    endDate,
    priority,
    subTasks,
  ];
}
