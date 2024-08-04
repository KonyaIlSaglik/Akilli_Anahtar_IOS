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
    required this.id,
    required this.userName,
    required this.password,
    required this.passwordHash,
    required this.passwordSalt,
    required this.fullName,
    required this.active,
    required this.telephone,
    required this.mail,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_name': userName,
      'password': password,
      'password_hash': passwordHash,
      'password_salt': passwordSalt,
      'full_name': fullName,
      'active': active,
      'telephone': telephone,
      'mail': mail,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      userName: map['user_name'] as String,
      password: map['password'] as String,
      passwordHash: map['password_hash'] as String,
      passwordSalt: map['password_salt'] as String,
      fullName: map['full_name'] as String,
      active: map['active'] as int,
      telephone: map['telephone'] as String,
      mail: map['mail'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);
}
