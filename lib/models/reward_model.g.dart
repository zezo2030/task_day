// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RewardModelAdapter extends TypeAdapter<RewardModel> {
  @override
  final int typeId = 15;

  @override
  RewardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RewardModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      icon: IconData(fields[3] as int, fontFamily: 'MaterialIcons'),
      color: Color(fields[4] as int),
      type: fields[5] as RewardType,
      costInPoints: fields[6] as int,
      rarity: fields[7] as RewardRarity,
      isAvailable: fields[8] as bool,
      isClaimed: fields[9] as bool,
      claimedAt: fields[10] as DateTime?,
      requiredLevel: fields[11] as int?,
      specialCondition: fields[12] as String?,
      expiryDate: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RewardModel obj) {
    writer
      ..writeByte(14)
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
      ..write(obj.costInPoints)
      ..writeByte(7)
      ..write(obj.rarity)
      ..writeByte(8)
      ..write(obj.isAvailable)
      ..writeByte(9)
      ..write(obj.isClaimed)
      ..writeByte(10)
      ..write(obj.claimedAt)
      ..writeByte(11)
      ..write(obj.requiredLevel)
      ..writeByte(12)
      ..write(obj.specialCondition)
      ..writeByte(13)
      ..write(obj.expiryDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RewardTypeAdapter extends TypeAdapter<RewardType> {
  @override
  final int typeId = 16;

  @override
  RewardType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RewardType.theme;
      case 1:
        return RewardType.avatar;
      case 2:
        return RewardType.badge;
      case 3:
        return RewardType.title;
      case 4:
        return RewardType.feature;
      case 5:
        return RewardType.customization;
      case 6:
        return RewardType.special;
      case 7:
        return RewardType.motivation;
      default:
        return RewardType.theme;
    }
  }

  @override
  void write(BinaryWriter writer, RewardType obj) {
    switch (obj) {
      case RewardType.theme:
        writer.writeByte(0);
        break;
      case RewardType.avatar:
        writer.writeByte(1);
        break;
      case RewardType.badge:
        writer.writeByte(2);
        break;
      case RewardType.title:
        writer.writeByte(3);
        break;
      case RewardType.feature:
        writer.writeByte(4);
        break;
      case RewardType.customization:
        writer.writeByte(5);
        break;
      case RewardType.special:
        writer.writeByte(6);
        break;
      case RewardType.motivation:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RewardRarityAdapter extends TypeAdapter<RewardRarity> {
  @override
  final int typeId = 17;

  @override
  RewardRarity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RewardRarity.common;
      case 1:
        return RewardRarity.uncommon;
      case 2:
        return RewardRarity.rare;
      case 3:
        return RewardRarity.epic;
      case 4:
        return RewardRarity.legendary;
      default:
        return RewardRarity.common;
    }
  }

  @override
  void write(BinaryWriter writer, RewardRarity obj) {
    switch (obj) {
      case RewardRarity.common:
        writer.writeByte(0);
        break;
      case RewardRarity.uncommon:
        writer.writeByte(1);
        break;
      case RewardRarity.rare:
        writer.writeByte(2);
        break;
      case RewardRarity.epic:
        writer.writeByte(3);
        break;
      case RewardRarity.legendary:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardRarityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
