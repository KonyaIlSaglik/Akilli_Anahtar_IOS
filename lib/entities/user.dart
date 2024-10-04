// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:akilli_anahtar/utils/hive_constants.dart';

part 'user.g.dart';

@HiveType(typeId: HiveConstants.userTypeId)
class User {
  @HiveField(0)
  int id;

  @HiveField(1)
  String userName;

  @HiveField(2)
  String fullName;

  @HiveField(3)
  String password;

  @HiveField(4)
  String mail;

  @HiveField(5)
  String telephone;

  @HiveField(6)
  int active;

  User({
    this.id = 0,
    this.userName = "",
    this.fullName = "",
    this.password = "",
    this.mail = "",
    this.telephone = "",
    this.active = 1,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userName': userName,
      'fullName': fullName,
      'password': password,
      'mail': mail,
      'telephone': telephone,
      'active': active,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] != null ? map['id'] as int : 0,
      userName: map['userName'] != null ? map['userName'] as String : "",
      fullName: map['fullName'] != null ? map['fullName'] as String : "",
      password: map['password'] != null ? map['password'] as String : "",
      mail: map['mail'] != null ? map['mail'] as String : "",
      telephone: map['telephone'] != null ? map['telephone'] as String : "",
      active: map['active'] != null ? map['active'] as int : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  User copyWith({
    int? id,
    String? userName,
    String? fullName,
    String? password,
    String? mail,
    String? telephone,
    int? active,
  }) {
    return User(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      mail: mail ?? this.mail,
      telephone: telephone ?? this.telephone,
      active: active ?? this.active,
    );
  }

  static List<User> fromJsonList(String source) =>
      List<User>.from((json.decode(source) as List<dynamic>)
          .map((x) => User.fromJson(json.encode(x))));
}
