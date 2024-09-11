// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:akilli_anahtar/utils/hive_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part '../hive_adapters/user.g.dart';

@HiveType(typeId: HiveConstants.userTypeId)
class User {
  @HiveField(0)
  int id;

  @HiveField(1)
  String userName;

  @HiveField(2)
  String password;

  @HiveField(3)
  String passwordHash;

  @HiveField(4)
  String passwordSalt;

  @HiveField(5)
  String fullName;

  @HiveField(6)
  int active;

  @HiveField(7)
  String telephone;

  @HiveField(8)
  String mail;

  User({
    this.id = 0,
    this.userName = "",
    this.password = "",
    this.passwordHash = "",
    this.passwordSalt = "",
    this.fullName = "",
    this.active = 1,
    this.telephone = "",
    this.mail = "",
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userName': userName,
      'password': password,
      'passwordHash': passwordHash,
      'passwordSalt': passwordSalt,
      'fullName': fullName,
      'active': active,
      'telephone': telephone,
      'mail': mail,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] != null ? map['id'] as int : 0,
      userName: map['userName'] != null ? map['userName'] as String : "",
      password: map['password'] != null ? map['password'] as String : "",
      passwordHash:
          map['passwordHash'] != null ? map['passwordHash'] as String : "",
      passwordSalt:
          map['passwordSalt'] != null ? map['passwordSalt'] as String : "",
      fullName: map['fullName'] != null ? map['fullName'] as String : "",
      active: map['active'] != null ? map['active'] as int : 0,
      telephone: map['telephone'] != null ? map['telephone'] as String : "",
      mail: map['mail'] != null ? map['mail'] as String : "",
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
