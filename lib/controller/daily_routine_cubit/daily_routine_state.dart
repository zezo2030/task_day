part of 'daily_routine_cubit.dart';

abstract class DailyRoutineState extends Equatable {
  const DailyRoutineState();

  @override
  List<Object> get props => [];
}

class DailyRoutineInitial extends DailyRoutineState {}

class DailyRoutineLoading extends DailyRoutineState {}

class DailyRoutineLoaded extends DailyRoutineState {
  final List<DailyRoutineModel> dailyRoutines;

  const DailyRoutineLoaded({required this.dailyRoutines});

  @override
  List<Object> get props => [dailyRoutines];
}

class DailyRoutineError extends DailyRoutineState {
  final String message;

  const DailyRoutineError({required this.message});

  @override
  List<Object> get props => [message];
}

class DailyRoutineGetByDate extends DailyRoutineState {
  final DailyRoutineModel dailyRoutine;

  const DailyRoutineGetByDate({required this.dailyRoutine});

  @override
  List<Object> get props => [dailyRoutine];
}

class DailyRoutineGetByDateError extends DailyRoutineState {
  final String message;

  const DailyRoutineGetByDateError({required this.message});

  @override
  List<Object> get props => [message];
}

class DailyRoutineAdded extends DailyRoutineState {}

class DailyRoutineUpdated extends DailyRoutineState {}

class DailyRoutineDeleted extends DailyRoutineState {}

class DailyRoutineCleared extends DailyRoutineState {}
