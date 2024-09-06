// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TokenModelAdapter extends TypeAdapter<TokenModel> {
  @override
  final int typeId = 1;

  @override
  TokenModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TokenModel(
      id: fields[0] as int,
      userId: fields[1] as int,
      loginTime: fields[2] as String,
      platformIdentity: fields[3] as String,
      accessToken: fields[4] as String,
      expiration: fields[5] as String,
      logoutTime: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TokenModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.loginTime)
      ..writeByte(3)
      ..write(obj.platformIdentity)
      ..writeByte(4)
      ..write(obj.accessToken)
      ..writeByte(5)
      ..write(obj.expiration)
      ..writeByte(6)
      ..write(obj.logoutTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
