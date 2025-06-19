import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_day/models/daily_routine_model.dart';
import 'package:task_day/services/hive_service.dart';
import 'package:task_day/services/notification_service.dart';

part 'daily_routine_state.dart';

class DailyRoutineCubit extends Cubit<DailyRoutineState> {
  DailyRoutineCubit() : super(DailyRoutineInitial());

  /// Get daily routine by date
  Future<void> getDailyRoutineByDate(DateTime date) async {
    emit(DailyRoutineLoading());
    try {
      final dailyRoutine = await HiveService.getDailyRoutineByDate(date);
      if (dailyRoutine != null) {
        emit(DailyRoutineGetByDate(dailyRoutine: dailyRoutine));
      } else {
        emit(DailyRoutineGetByDateError(message: 'Daily routine not found'));
      }
    } catch (e) {
      emit(DailyRoutineGetByDateError(message: e.toString()));
    }
  }

  /// Get all daily routines
  Future<void> getDailyRoutines() async {
    emit(DailyRoutineLoading());
    try {
      // Check and perform daily reset if needed before loading routines
      await HiveService.checkAndPerformDailyReset();

      final dailyRoutines = await HiveService.getAllDailyRoutines();
      emit(DailyRoutineLoaded(dailyRoutines: dailyRoutines));
    } catch (e) {
      emit(DailyRoutineError(message: e.toString()));
    }
  }

  /// Get today's daily routines only
  Future<void> getTodayDailyRoutines() async {
    emit(DailyRoutineLoading());
    try {
      // Check and perform daily reset if needed before loading routines
      await HiveService.checkAndPerformDailyReset();

      final dailyRoutines = await HiveService.getTodayDailyRoutines();
      emit(DailyRoutineLoaded(dailyRoutines: dailyRoutines));
    } catch (e) {
      emit(DailyRoutineError(message: e.toString()));
    }
  }

  /// Add a daily routine
  Future<void> addDailyRoutine(DailyRoutineModel dailyRoutine) async {
    emit(DailyRoutineLoading());
    try {
      await HiveService.addDailyRoutine(dailyRoutine);

      // جدولة الإشعارات للروتين الجديد
      await NotificationService.scheduleDailyRoutineReminders(dailyRoutine);

      emit(DailyRoutineAdded());
      // Reload all daily routines after adding
      await getDailyRoutines();
    } catch (e) {
      emit(DailyRoutineError(message: e.toString()));
    }
  }

  /// Update a daily routine
  Future<void> updateDailyRoutine(DailyRoutineModel dailyRoutine) async {
    emit(DailyRoutineLoading());
    try {
      await HiveService.updateDailyRoutine(dailyRoutine);

      // إلغاء الإشعارات القديمة وجدولة الجديدة
      await NotificationService.cancelRoutineNotifications(dailyRoutine.id);
      await NotificationService.scheduleDailyRoutineReminders(dailyRoutine);

      emit(DailyRoutineUpdated());
      // Reload all daily routines after updating
      await getDailyRoutines();
    } catch (e) {
      emit(DailyRoutineError(message: e.toString()));
    }
  }

  /// Delete a daily routine
  Future<void> deleteDailyRoutine(String id) async {
    emit(DailyRoutineLoading());
    try {
      // إلغاء الإشعارات المرتبطة بالروتين
      await NotificationService.cancelRoutineNotifications(id);

      await HiveService.deleteDailyRoutine(id);
      emit(DailyRoutineDeleted());
      // Reload all daily routines after deleting
      await getDailyRoutines();
    } catch (e) {
      emit(DailyRoutineError(message: e.toString()));
    }
  }

  /// Clear all daily routines
  Future<void> clearAllDailyRoutines() async {
    emit(DailyRoutineLoading());
    try {
      await HiveService.clearAllDailyRoutines();
      emit(DailyRoutineCleared());
    } catch (e) {
      emit(DailyRoutineError(message: e.toString()));
    }
  }
}
