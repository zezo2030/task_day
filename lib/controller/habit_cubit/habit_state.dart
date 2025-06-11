part of 'habit_cubit.dart';

sealed class HabitState extends Equatable {
  const HabitState();

  @override
  List<Object> get props => [];
}

final class HabitInitial extends HabitState {}

final class HabitAdded extends HabitState {
  final HabitModel habit;

  const HabitAdded(this.habit);

  @override
  List<Object> get props => [habit];
}

final class HabitError extends HabitState {
  final String message;

  const HabitError(this.message);

  @override
  List<Object> get props => [message];
}

final class HabitsLoaded extends HabitState {
  final List<HabitModel> habits;

  const HabitsLoaded(this.habits);

  @override
  List<Object> get props => [habits];
}

final class HabitsLoadError extends HabitState {
  final String message;

  const HabitsLoadError(this.message);

  @override
  List<Object> get props => [message];
}

final class HabitUpdated extends HabitState {
  final HabitModel habit;

  const HabitUpdated(this.habit);

  @override
  List<Object> get props => [habit];
}

final class HabitDeleted extends HabitState {
  final HabitModel habit;

  const HabitDeleted(this.habit);

  @override
  List<Object> get props => [habit];
}

final class HabitCompleted extends HabitState {
  final HabitModel habit;

  const HabitCompleted(this.habit);

  @override
  List<Object> get props => [habit];
}
