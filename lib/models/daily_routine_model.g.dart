// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_routine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyRoutineModelAdapter extends TypeAdapter<DailyRoutineModel> {
  @override
  final int typeId = 30;

  @override
  DailyRoutineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyRoutineModel(
      id: fields[0] as String,
      name: fields[1] as String,
      startTime: fields[2] as TimeOfDay,
      endTime: fields[3] as TimeOfDay,
      isCompleted: fields[4] as bool,
      counterReperter: fields[5] as int,
      dateTime: fields[6] as DateTime,
      isRecurringDaily: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DailyRoutineModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.counterReperter)
      ..writeByte(6)
      ..write(obj.dateTime)
      ..writeByte(7)
      ..write(obj.isRecurringDaily);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRoutineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
