// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parameter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParameterAdapter extends TypeAdapter<Parameter> {
  @override
  final int typeId = 5;

  @override
  Parameter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Parameter(
      id: fields[0] as int,
      name: fields[1] as String,
      value: fields[2] as String,
      type: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Parameter obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParameterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
