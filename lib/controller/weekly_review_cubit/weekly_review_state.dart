part of 'weekly_review_cubit.dart';

abstract class WeeklyReviewState extends Equatable {
  const WeeklyReviewState();

  @override
  List<Object?> get props => [];
}

class WeeklyReviewInitial extends WeeklyReviewState {}

class WeeklyReviewLoading extends WeeklyReviewState {}

class WeeklyReviewLoaded extends WeeklyReviewState {
  final WeeklyReviewModel review;
  final List<String> suggestions;
  final bool isCurrentWeek;

  const WeeklyReviewLoaded({
    required this.review,
    required this.suggestions,
    required this.isCurrentWeek,
  });

  @override
  List<Object?> get props => [review, suggestions, isCurrentWeek];
}

class WeeklyReviewError extends WeeklyReviewState {
  final String message;

  const WeeklyReviewError({required this.message});

  @override
  List<Object?> get props => [message];
}
