import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:akilli_anahtar/utils/hive_constants.dart';

@HiveType(typeId: HiveConstants.loginModel2TypeId)
class LoginModel2 {
  @HiveField(0)
  String userName;

  @HiveField(1)
  String password;

  @HiveField(2)
  String identity;

  @HiveField(3)
  String platformName;

  LoginModel2({
    this.userName = "",
    this.password = "",
    this.identity = "",
    this.platformName = "",
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userName': userName,
      'password': password,
      'identity': identity,
      'platformName': platformName,
    };
  }

  factory LoginModel2.fromMap(Map<String, dynamic> map) {
    return LoginModel2(
      userName: map['userName'] as String,
      password: map['password'] as String,
      identity: map['identity'] as String,
      platformName: map['platformName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginModel2.fromJson(String source) =>
      LoginModel2.fromMap(json.decode(source) as Map<String, dynamic>);
}
