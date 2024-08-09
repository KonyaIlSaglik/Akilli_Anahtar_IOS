// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TokenModel {
  String token;
  String expiration;
  TokenModel({
    this.token = "",
    this.expiration = "",
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token,
      'expiration': expiration,
    };
  }

  factory TokenModel.fromMap(Map<String, dynamic> map) {
    return TokenModel(
      token: map['token'] as String,
      expiration: map['expiration'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory TokenModel.fromJson(String source) =>
      TokenModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
