// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_model2.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoginModel2Adapter extends TypeAdapter<LoginModel2> {
  @override
  final int typeId = 0;

  @override
  LoginModel2 read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginModel2(
      userName: fields[0] as String,
      password: fields[1] as String,
      identity: fields[2] as String,
      platformName: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LoginModel2 obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.userName)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(2)
      ..write(obj.identity)
      ..writeByte(3)
      ..write(obj.platformName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginModel2Adapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
