// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredients.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IngredientsAdapter extends TypeAdapter<Ingredients> {
  @override
  final int typeId = 2;

  @override
  Ingredients read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ingredients(
      name: fields[0] as String,
      like: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Ingredients obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.like);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
