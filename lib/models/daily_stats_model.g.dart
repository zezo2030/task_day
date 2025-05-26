// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_stats_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyStatsModelAdapter extends TypeAdapter<DailyStatsModel> {
  @override
  final int typeId = 3;

  @override
  DailyStatsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyStatsModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      totalTasks: fields[2] as int,
      completedTasks: fields[3] as int,
      tasksCompletionRate: fields[4] as double,
      totalHabits: fields[5] as int,
      completedHabits: fields[6] as int,
      habitsCompletionRate: fields[7] as double,
      habitStreaks: (fields[8] as Map).cast<String, int>(),
      longestStreak: fields[9] as int,
      productivityScore: fields[10] as double,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DailyStatsModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.totalTasks)
      ..writeByte(3)
      ..write(obj.completedTasks)
      ..writeByte(4)
      ..write(obj.tasksCompletionRate)
      ..writeByte(5)
      ..write(obj.totalHabits)
      ..writeByte(6)
      ..write(obj.completedHabits)
      ..writeByte(7)
      ..write(obj.habitsCompletionRate)
      ..writeByte(8)
      ..write(obj.habitStreaks)
      ..writeByte(9)
      ..write(obj.longestStreak)
      ..writeByte(10)
      ..write(obj.productivityScore)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyStatsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PeriodStatsModelAdapter extends TypeAdapter<PeriodStatsModel> {
  @override
  final int typeId = 4;

  @override
  PeriodStatsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PeriodStatsModel(
      id: fields[0] as String,
      period: fields[1] as String,
      startDate: fields[2] as DateTime,
      endDate: fields[3] as DateTime,
      overallProgress: fields[4] as double,
      tasksProgress: fields[5] as double,
      habitsProgress: fields[6] as double,
      totalProductivityPoints: fields[7] as int,
      averageProductivityScore: fields[8] as double,
      bestHabits: (fields[9] as List).cast<String>(),
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PeriodStatsModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.period)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.overallProgress)
      ..writeByte(5)
      ..write(obj.tasksProgress)
      ..writeByte(6)
      ..write(obj.habitsProgress)
      ..writeByte(7)
      ..write(obj.totalProductivityPoints)
      ..writeByte(8)
      ..write(obj.averageProductivityScore)
      ..writeByte(9)
      ..write(obj.bestHabits)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodStatsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
