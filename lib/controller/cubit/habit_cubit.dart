import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:task_day/services/hive_service.dart';

part 'habit_state.dart';

class HabitCubit extends Cubit<HabitState> {
  HabitCubit() : super(HabitInitial());

  void addHabit(HabitModel habit) async {
    try {
      emit(HabitInitial());
      await HiveService.addHabit(habit);
      emit(HabitAdded(habit));
      print('Habit added: ${habit.title}');
    } catch (e) {
      emit(HabitError(e.toString()));
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void getHabits() async {
    try {
      emit(HabitInitial());
      final habits = await HiveService.getAllHabits();
      emit(HabitsLoaded(habits));
      print('Habits loaded: ${habits.length}');
    } catch (e) {
      emit(HabitsLoadError(e.toString()));
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void updateHabit(HabitModel habit) async {
    try {
      emit(HabitInitial());
      await HiveService.updateHabit(habit);
      emit(HabitUpdated(habit));
      print('Habit updated: ${habit.title}');
    } catch (e) {
      emit(HabitError(e.toString()));
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void deleteHabit(HabitModel habit) async {
    try {
      emit(HabitInitial());
      await HiveService.deleteHabit(habit.id);
      emit(HabitDeleted(habit));
      print('Habit deleted: ${habit.title}');
    } catch (e) {
      emit(HabitError(e.toString()));
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void completeHabit(HabitModel habit) async {
    try {
      emit(HabitInitial());
      await HiveService.completeHabit(habit.id);
      // Get the updated habit after completion
      final updatedHabit = (await HiveService.getAllHabits()).firstWhere(
        (h) => h.id == habit.id,
        orElse: () => habit,
      );
      emit(HabitCompleted(updatedHabit));
      print('Habit completed: ${habit.title}');
    } catch (e) {
      emit(HabitError(e.toString()));
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void resetHabit(HabitModel habit) async {
    try {
      emit(HabitInitial());
      await HiveService.resetHabit(habit.id);
      // Get the updated habit after reset
      final updatedHabit = (await HiveService.getAllHabits()).firstWhere(
        (h) => h.id == habit.id,
        orElse: () => habit,
      );
      emit(HabitUpdated(updatedHabit));
      print('Habit reset: ${habit.title}');
    } catch (e) {
      emit(HabitError(e.toString()));
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
