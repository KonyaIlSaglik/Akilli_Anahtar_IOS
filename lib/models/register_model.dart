import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class RegisterModel {
  String fullName;
  String userName;
  String password;
  String tel;
  String email;
  RegisterModel({
    this.fullName = "",
    this.userName = "",
    this.password = "",
    this.tel = "",
    this.email = "",
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fullName': fullName,
      'userName': userName,
      'password': password,
      'tel': tel,
      'email': email,
    };
  }

  factory RegisterModel.fromMap(Map<String, dynamic> map) {
    return RegisterModel(
      fullName: map['fullName'] as String,
      userName: map['userName'] as String,
      password: map['password'] as String,
      tel: map['tel'] as String,
      email: map['email'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory RegisterModel.fromJson(String source) =>
      RegisterModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
