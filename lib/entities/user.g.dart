// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 3;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as int,
      userName: fields[1] as String,
      password: fields[2] as String,
      passwordHash: fields[3] as String,
      passwordSalt: fields[4] as String,
      fullName: fields[5] as String,
      active: fields[6] as int,
      telephone: fields[7] as String,
      mail: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userName)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.passwordHash)
      ..writeByte(4)
      ..write(obj.passwordSalt)
      ..writeByte(5)
      ..write(obj.fullName)
      ..writeByte(6)
      ..write(obj.active)
      ..writeByte(7)
      ..write(obj.telephone)
      ..writeByte(8)
      ..write(obj.mail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
