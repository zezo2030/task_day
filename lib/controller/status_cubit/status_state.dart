part of 'status_cubit.dart';

sealed class StatusState extends Equatable {
  const StatusState();

  @override
  List<Object> get props => [];
}

final class StatusInitial extends StatusState {}

final class StatusLoading extends StatusState {}

final class StatusLoaded extends StatusState {
  final StatusData statusData;

  const StatusLoaded(this.statusData);

  @override
  List<Object> get props => [statusData];
}

final class StatusError extends StatusState {
  final String message;

  const StatusError(this.message);

  @override
  List<Object> get props => [message];
}

/// نموذج بيانات الحالة الشاملة
class StatusData extends Equatable {
  // البيانات الفورية (اليوم)
  final int todayCompletedTasks;
  final int todayTotalTasks;
  final double todayTasksCompletionRate;
  final int todayCompletedHabits;
  final int todayTotalHabits;
  final double todayHabitsCompletionRate;
  final int currentLongestStreak;
  final double currentProductivityScore;

  // البيانات المخزنة (فترات أطول)
  final double weeklyProgress;
  final double monthlyProgress;

  // بيانات تفصيلية
  final List<HabitStreakInfo> habitsWithStreaks;

  // معلومات إضافية
  final DateTime lastCalculatedAt;
  final String dataSource; // 'hybrid', 'quick', 'stored', 'calculated_for_date'

  const StatusData({
    required this.todayCompletedTasks,
    required this.todayTotalTasks,
    required this.todayTasksCompletionRate,
    required this.todayCompletedHabits,
    required this.todayTotalHabits,
    required this.todayHabitsCompletionRate,
    required this.currentLongestStreak,
    required this.currentProductivityScore,
    required this.weeklyProgress,
    required this.monthlyProgress,
    required this.habitsWithStreaks,
    required this.lastCalculatedAt,
    required this.dataSource,
  });

  /// إنشاء StatusData من DailyStatsModel (البيانات المخزنة)
  factory StatusData.fromDailyStats(DailyStatsModel dailyStats) {
    return StatusData(
      todayCompletedTasks: dailyStats.completedTasks,
      todayTotalTasks: dailyStats.totalTasks,
      todayTasksCompletionRate: dailyStats.tasksCompletionRate,
      todayCompletedHabits: dailyStats.completedHabits,
      todayTotalHabits: dailyStats.totalHabits,
      todayHabitsCompletionRate: dailyStats.habitsCompletionRate,
      currentLongestStreak: dailyStats.longestStreak,
      currentProductivityScore: dailyStats.productivityScore,
      weeklyProgress: 0.0, // يجب حسابها منفصلة
      monthlyProgress: 0.0, // يجب حسابها منفصلة
      habitsWithStreaks: [], // يجب حسابها منفصلة
      lastCalculatedAt: dailyStats.updatedAt,
      dataSource: 'stored',
    );
  }

  StatusData copyWith({
    int? todayCompletedTasks,
    int? todayTotalTasks,
    double? todayTasksCompletionRate,
    int? todayCompletedHabits,
    int? todayTotalHabits,
    double? todayHabitsCompletionRate,
    int? currentLongestStreak,
    double? currentProductivityScore,
    double? weeklyProgress,
    double? monthlyProgress,
    List<HabitStreakInfo>? habitsWithStreaks,
    DateTime? lastCalculatedAt,
    String? dataSource,
  }) => StatusData(
    todayCompletedTasks: todayCompletedTasks ?? this.todayCompletedTasks,
    todayTotalTasks: todayTotalTasks ?? this.todayTotalTasks,
    todayTasksCompletionRate:
        todayTasksCompletionRate ?? this.todayTasksCompletionRate,
    todayCompletedHabits: todayCompletedHabits ?? this.todayCompletedHabits,
    todayTotalHabits: todayTotalHabits ?? this.todayTotalHabits,
    todayHabitsCompletionRate:
        todayHabitsCompletionRate ?? this.todayHabitsCompletionRate,
    currentLongestStreak: currentLongestStreak ?? this.currentLongestStreak,
    currentProductivityScore:
        currentProductivityScore ?? this.currentProductivityScore,
    weeklyProgress: weeklyProgress ?? this.weeklyProgress,
    monthlyProgress: monthlyProgress ?? this.monthlyProgress,
    habitsWithStreaks: habitsWithStreaks ?? this.habitsWithStreaks,
    lastCalculatedAt: lastCalculatedAt ?? this.lastCalculatedAt,
    dataSource: dataSource ?? this.dataSource,
  );

  @override
  List<Object> get props => [
    todayCompletedTasks,
    todayTotalTasks,
    todayTasksCompletionRate,
    todayCompletedHabits,
    todayTotalHabits,
    todayHabitsCompletionRate,
    currentLongestStreak,
    currentProductivityScore,
    weeklyProgress,
    monthlyProgress,
    habitsWithStreaks,
    lastCalculatedAt,
    dataSource,
  ];
}
