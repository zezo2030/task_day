import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_day/models/weekly_review_model.dart';
import 'package:task_day/services/weekly_review_service.dart';

part 'weekly_review_state.dart';

class WeeklyReviewCubit extends Cubit<WeeklyReviewState> {
  WeeklyReviewCubit() : super(WeeklyReviewInitial());

  /// Generate review for current week
  Future<void> generateCurrentWeekReview() async {
    emit(WeeklyReviewLoading());
    try {
      final weekStart = WeeklyReviewService.getCurrentWeekStart();
      final review = await WeeklyReviewService.generateWeeklyReview(weekStart);
      final suggestions = WeeklyReviewService.generateSuggestions(review);

      emit(
        WeeklyReviewLoaded(
          review: review,
          suggestions: suggestions,
          isCurrentWeek: true,
        ),
      );
    } catch (e) {
      emit(WeeklyReviewError(message: e.toString()));
    }
  }

  /// Generate review for previous week
  Future<void> generatePreviousWeekReview() async {
    emit(WeeklyReviewLoading());
    try {
      final weekStart = WeeklyReviewService.getPreviousWeekStart();
      final review = await WeeklyReviewService.generateWeeklyReview(weekStart);
      final suggestions = WeeklyReviewService.generateSuggestions(review);

      emit(
        WeeklyReviewLoaded(
          review: review,
          suggestions: suggestions,
          isCurrentWeek: false,
        ),
      );
    } catch (e) {
      emit(WeeklyReviewError(message: e.toString()));
    }
  }

  /// Generate review for specific week
  Future<void> generateWeekReview(DateTime weekStart) async {
    emit(WeeklyReviewLoading());
    try {
      final review = await WeeklyReviewService.generateWeeklyReview(weekStart);
      final suggestions = WeeklyReviewService.generateSuggestions(review);
      final currentWeekStart = WeeklyReviewService.getCurrentWeekStart();
      final isCurrentWeek = _isSameWeek(weekStart, currentWeekStart);

      emit(
        WeeklyReviewLoaded(
          review: review,
          suggestions: suggestions,
          isCurrentWeek: isCurrentWeek,
        ),
      );
    } catch (e) {
      emit(WeeklyReviewError(message: e.toString()));
    }
  }

  /// Clear current state
  void clearReview() {
    emit(WeeklyReviewInitial());
  }

  /// Check if two dates are in the same week
  bool _isSameWeek(DateTime date1, DateTime date2) {
    final week1Start = WeeklyReviewService.getWeekStart(date1);
    final week2Start = WeeklyReviewService.getWeekStart(date2);

    return week1Start.isAtSameMomentAs(week2Start);
  }
}
