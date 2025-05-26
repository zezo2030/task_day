import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'daily_stats_model.g.dart';

/// نموذج للإحصائيات اليومية المخزنة
/// هذا النموذج يحفظ البيانات المعقدة التي نحتاج لحسابها مرة واحدة يومياً
@HiveType(typeId: 3)
class DailyStatsModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id; // تاريخ بصيغة 'yyyy-MM-dd'

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int totalTasks;

  @HiveField(3)
  final int completedTasks;

  @HiveField(4)
  final double tasksCompletionRate;

  @HiveField(5)
  final int totalHabits;

  @HiveField(6)
  final int completedHabits;

  @HiveField(7)
  final double habitsCompletionRate;

  @HiveField(8)
  final Map<String, int> habitStreaks; // habitId -> streak length

  @HiveField(9)
  final int longestStreak;

  @HiveField(10)
  final double productivityScore; // نقاط الإنتاجية العامة (0-100)

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  DailyStatsModel({
    required this.id,
    required this.date,
    required this.totalTasks,
    required this.completedTasks,
    required this.tasksCompletionRate,
    required this.totalHabits,
    required this.completedHabits,
    required this.habitsCompletionRate,
    required this.habitStreaks,
    required this.longestStreak,
    required this.productivityScore,
    required this.createdAt,
    required this.updatedAt,
  });

  DailyStatsModel copyWith({
    String? id,
    DateTime? date,
    int? totalTasks,
    int? completedTasks,
    double? tasksCompletionRate,
    int? totalHabits,
    int? completedHabits,
    double? habitsCompletionRate,
    Map<String, int>? habitStreaks,
    int? longestStreak,
    double? productivityScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DailyStatsModel(
    id: id ?? this.id,
    date: date ?? this.date,
    totalTasks: totalTasks ?? this.totalTasks,
    completedTasks: completedTasks ?? this.completedTasks,
    tasksCompletionRate: tasksCompletionRate ?? this.tasksCompletionRate,
    totalHabits: totalHabits ?? this.totalHabits,
    completedHabits: completedHabits ?? this.completedHabits,
    habitsCompletionRate: habitsCompletionRate ?? this.habitsCompletionRate,
    habitStreaks: habitStreaks ?? this.habitStreaks,
    longestStreak: longestStreak ?? this.longestStreak,
    productivityScore: productivityScore ?? this.productivityScore,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    date,
    totalTasks,
    completedTasks,
    tasksCompletionRate,
    totalHabits,
    completedHabits,
    habitsCompletionRate,
    habitStreaks,
    longestStreak,
    productivityScore,
    createdAt,
    updatedAt,
  ];
}

/// نموذج للإحصائيات الأسبوعية/الشهرية المخزنة
@HiveType(typeId: 4)
class PeriodStatsModel extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id; // 'weekly_2024_week_10' أو 'monthly_2024_03'

  @HiveField(1)
  final String period; // 'weekly' أو 'monthly'

  @HiveField(2)
  final DateTime startDate;

  @HiveField(3)
  final DateTime endDate;

  @HiveField(4)
  final double overallProgress; // التقدم العام للفترة

  @HiveField(5)
  final double tasksProgress; // تقدم المهام

  @HiveField(6)
  final double habitsProgress; // تقدم العادات

  @HiveField(7)
  final int totalProductivityPoints; // مجموع نقاط الإنتاجية

  @HiveField(8)
  final double averageProductivityScore; // متوسط النقاط اليومية

  @HiveField(9)
  final List<String> bestHabits; // أفضل العادات في الفترة

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  PeriodStatsModel({
    required this.id,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.overallProgress,
    required this.tasksProgress,
    required this.habitsProgress,
    required this.totalProductivityPoints,
    required this.averageProductivityScore,
    required this.bestHabits,
    required this.createdAt,
    required this.updatedAt,
  });

  PeriodStatsModel copyWith({
    String? id,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    double? overallProgress,
    double? tasksProgress,
    double? habitsProgress,
    int? totalProductivityPoints,
    double? averageProductivityScore,
    List<String>? bestHabits,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PeriodStatsModel(
    id: id ?? this.id,
    period: period ?? this.period,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    overallProgress: overallProgress ?? this.overallProgress,
    tasksProgress: tasksProgress ?? this.tasksProgress,
    habitsProgress: habitsProgress ?? this.habitsProgress,
    totalProductivityPoints:
        totalProductivityPoints ?? this.totalProductivityPoints,
    averageProductivityScore:
        averageProductivityScore ?? this.averageProductivityScore,
    bestHabits: bestHabits ?? this.bestHabits,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    period,
    startDate,
    endDate,
    overallProgress,
    tasksProgress,
    habitsProgress,
    totalProductivityPoints,
    averageProductivityScore,
    bestHabits,
    createdAt,
    updatedAt,
  ];
}
