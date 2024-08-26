// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
  int id;
  String userName;
  String password;
  String passwordHash;
  String passwordSalt;
  String fullName;
  int active;
  String telephone;
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
