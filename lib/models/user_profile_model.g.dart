// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 18;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      id: fields[0] as String,
      name: fields[1] as String,
      totalPoints: fields[2] as int,
      currentLevel: fields[3] as int,
      pointsToNextLevel: fields[4] as int,
      unlockedAchievements: (fields[5] as List).cast<String>(),
      currentStreak: fields[6] as int,
      longestStreak: fields[7] as int,
      lastActivityDate: fields[8] as DateTime?,
      weeklyProgress: (fields[9] as Map).cast<String, int>(),
      availableRewards: (fields[10] as List).cast<String>(),
      claimedRewards: (fields[11] as List).cast<String>(),
      createdAt: fields[12] as DateTime,
      lastUpdated: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.totalPoints)
      ..writeByte(3)
      ..write(obj.currentLevel)
      ..writeByte(4)
      ..write(obj.pointsToNextLevel)
      ..writeByte(5)
      ..write(obj.unlockedAchievements)
      ..writeByte(6)
      ..write(obj.currentStreak)
      ..writeByte(7)
      ..write(obj.longestStreak)
      ..writeByte(8)
      ..write(obj.lastActivityDate)
      ..writeByte(9)
      ..write(obj.weeklyProgress)
      ..writeByte(10)
      ..write(obj.availableRewards)
      ..writeByte(11)
      ..write(obj.claimedRewards)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
