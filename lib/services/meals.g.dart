// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meals.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealsAdapter extends TypeAdapter<Meals> {
  @override
  final int typeId = 1;

  @override
  Meals read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Meals(
      name: fields[0] as String,
      mealType: fields[1] as String,
      imageUrl: fields[2] as String,
      youtubeUrl: fields[3] as String,
      recipeUrl: fields[4] as String,
      tag1: fields[5] as String,
      tag2: fields[6] as String,
      tag3: fields[7] as String,
      cookingTime: fields[8] as String,
      restaurant: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Meals obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.mealType)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.youtubeUrl)
      ..writeByte(4)
      ..write(obj.recipeUrl)
      ..writeByte(5)
      ..write(obj.tag1)
      ..writeByte(6)
      ..write(obj.tag2)
      ..writeByte(7)
      ..write(obj.tag3)
      ..writeByte(8)
      ..write(obj.cookingTime)
      ..writeByte(9)
      ..write(obj.restaurant);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
