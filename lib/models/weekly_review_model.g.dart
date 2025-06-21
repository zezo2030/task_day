// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_review_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyReviewModelAdapter extends TypeAdapter<WeeklyReviewModel> {
  @override
  final int typeId = 31;

  @override
  WeeklyReviewModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyReviewModel(
      id: fields[0] as String,
      weekStartDate: fields[1] as DateTime,
      weekEndDate: fields[2] as DateTime,
      totalRoutines: fields[3] as int,
      completedRoutines: fields[4] as int,
      completionRate: fields[5] as double,
      dailyCompletions: (fields[6] as Map).cast<String, int>(),
      topPerformingRoutines: (fields[7] as List).cast<String>(),
      needsImprovementRoutines: (fields[8] as List).cast<String>(),
      routineCompletionRates: (fields[9] as Map).cast<String, double>(),
      bestDay: fields[10] as String,
      worstDay: fields[11] as String,
      totalStreaks: fields[12] as int,
      createdAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyReviewModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.weekStartDate)
      ..writeByte(2)
      ..write(obj.weekEndDate)
      ..writeByte(3)
      ..write(obj.totalRoutines)
      ..writeByte(4)
      ..write(obj.completedRoutines)
      ..writeByte(5)
      ..write(obj.completionRate)
      ..writeByte(6)
      ..write(obj.dailyCompletions)
      ..writeByte(7)
      ..write(obj.topPerformingRoutines)
      ..writeByte(8)
      ..write(obj.needsImprovementRoutines)
      ..writeByte(9)
      ..write(obj.routineCompletionRates)
      ..writeByte(10)
      ..write(obj.bestDay)
      ..writeByte(11)
      ..write(obj.worstDay)
      ..writeByte(12)
      ..write(obj.totalStreaks)
      ..writeByte(13)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyReviewModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
