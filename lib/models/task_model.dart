import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime startDate;
  final DateTime endDate;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    required this.startDate,
    required this.endDate,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? startDate,
    DateTime? endDate,
  }) => TaskModel(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    isDone: isDone ?? this.isDone,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    isDone,
    startDate,
    endDate,
  ];
}
