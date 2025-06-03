// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementModelAdapter extends TypeAdapter<AchievementModel> {
  @override
  final int typeId = 12;

  @override
  AchievementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AchievementModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      icon: IconData(fields[3] as int, fontFamily: 'MaterialIcons'),
      color: Color(fields[4] as int),
      type: fields[5] as AchievementType,
      targetValue: fields[6] as int,
      pointsReward: fields[7] as int,
      rarity: fields[8] as AchievementRarity,
      isUnlocked: fields[9] as bool,
      unlockedAt: fields[10] as DateTime?,
      currentProgress: fields[11] as int,
      isHidden: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AchievementModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconData)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.targetValue)
      ..writeByte(7)
      ..write(obj.pointsReward)
      ..writeByte(8)
      ..write(obj.rarity)
      ..writeByte(9)
      ..write(obj.isUnlocked)
      ..writeByte(10)
      ..write(obj.unlockedAt)
      ..writeByte(11)
      ..write(obj.currentProgress)
      ..writeByte(12)
      ..write(obj.isHidden);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AchievementTypeAdapter extends TypeAdapter<AchievementType> {
  @override
  final int typeId = 13;

  @override
  AchievementType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AchievementType.habitsCompleted;
      case 1:
        return AchievementType.streakDays;
      case 2:
        return AchievementType.totalPoints;
      case 3:
        return AchievementType.perfectWeeks;
      case 4:
        return AchievementType.earlyBird;
      case 5:
        return AchievementType.consistency;
      case 6:
        return AchievementType.variety;
      case 7:
        return AchievementType.dedication;
      case 8:
        return AchievementType.challenger;
      case 9:
        return AchievementType.social;
      default:
        return AchievementType.habitsCompleted;
    }
  }

  @override
  void write(BinaryWriter writer, AchievementType obj) {
    switch (obj) {
      case AchievementType.habitsCompleted:
        writer.writeByte(0);
        break;
      case AchievementType.streakDays:
        writer.writeByte(1);
        break;
      case AchievementType.totalPoints:
        writer.writeByte(2);
        break;
      case AchievementType.perfectWeeks:
        writer.writeByte(3);
        break;
      case AchievementType.earlyBird:
        writer.writeByte(4);
        break;
      case AchievementType.consistency:
        writer.writeByte(5);
        break;
      case AchievementType.variety:
        writer.writeByte(6);
        break;
      case AchievementType.dedication:
        writer.writeByte(7);
        break;
      case AchievementType.challenger:
        writer.writeByte(8);
        break;
      case AchievementType.social:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AchievementRarityAdapter extends TypeAdapter<AchievementRarity> {
  @override
  final int typeId = 14;

  @override
  AchievementRarity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AchievementRarity.common;
      case 1:
        return AchievementRarity.rare;
      case 2:
        return AchievementRarity.epic;
      case 3:
        return AchievementRarity.legendary;
      default:
        return AchievementRarity.common;
    }
  }

  @override
  void write(BinaryWriter writer, AchievementRarity obj) {
    switch (obj) {
      case AchievementRarity.common:
        writer.writeByte(0);
        break;
      case AchievementRarity.rare:
        writer.writeByte(1);
        break;
      case AchievementRarity.epic:
        writer.writeByte(2);
        break;
      case AchievementRarity.legendary:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementRarityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
