import 'dart:convert';

import 'package:akilli_anahtar/utils/hive_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: HiveConstants.loginModelTypeId)
class LoginModel {
  @HiveField(0)
  String userName;

  @HiveField(1)
  String password;

  @HiveField(2)
  String identity;

  LoginModel({
    this.userName = "",
    this.password = "",
    this.identity = "",
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userName': userName,
      'password': password,
      'identity': identity,
    };
  }

  factory LoginModel.fromMap(Map<String, dynamic> map) {
    return LoginModel(
      userName: map['userName'] as String,
      password: map['password'] as String,
      identity: map['identity'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginModel.fromJson(String source) =>
      LoginModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
