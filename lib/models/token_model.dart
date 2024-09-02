// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TokenModel {
  int id;
  int userId;
  String loginTime;
  String platformIdentity;
  String accessToken;
  String expiration;
  String? logoutTime;
  TokenModel({
    required this.id,
    required this.userId,
    required this.loginTime,
    required this.platformIdentity,
    required this.accessToken,
    required this.expiration,
    this.logoutTime,
  });

  factory TokenModel.epmty() {
    return TokenModel(
      id: 0,
      userId: 0,
      accessToken: "",
      expiration: "",
      loginTime: "",
      platformIdentity: "",
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'loginTime': loginTime,
      'platformIdentity': platformIdentity,
      'accessToken': accessToken,
      'expiration': expiration,
      'logoutTime': logoutTime,
    };
  }

  factory TokenModel.fromMap(Map<String, dynamic> map) {
    var model = TokenModel(
      id: map['id'] as int,
      userId: map['userId'] as int,
      loginTime: map['loginTime'] as String,
      platformIdentity: map['platformIdentity'] as String,
      accessToken: map['accessToken'] as String,
      expiration: map['expiration'] as String,
      logoutTime: map['logoutTime'],
    );
    return model;
  }

  String toJson() => json.encode(toMap());

  factory TokenModel.fromJson(String source) =>
      TokenModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
