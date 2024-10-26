import 'dart:convert';
import 'package:akilli_anahtar/utils/hive_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'session_model.g.dart';

@HiveType(typeId: HiveConstants.sessionTypeId)
class Session {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int userId;

  @HiveField(2)
  final String loginTime;

  @HiveField(3)
  final String platformIdentity;

  @HiveField(4)
  final String accessToken;

  @HiveField(5)
  final String expiration;

  @HiveField(6)
  final String? logoutTime;

  @HiveField(7) // New Hive field for platformName
  final String? platformName;

  Session({
    required this.id,
    required this.userId,
    required this.loginTime,
    required this.platformIdentity,
    required this.accessToken,
    required this.expiration,
    this.logoutTime,
    this.platformName, // Include platformName in constructor
  });

  factory Session.empty() {
    return Session(
      id: 0,
      userId: 0,
      accessToken: "",
      expiration: "",
      loginTime: "",
      platformIdentity: "",
      logoutTime: null,
      platformName: "", // Default value for platformName
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'loginTime': loginTime,
      'platformIdentity': platformIdentity,
      'accessToken': accessToken,
      'expiration': expiration,
      'logoutTime': logoutTime,
      'platformName': platformName, // Include platformName in map
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as int,
      userId: map['userId'] as int,
      loginTime: map['loginTime'] as String,
      platformIdentity: map['platformIdentity'] as String,
      accessToken: map['accessToken'] as String,
      expiration: map['expiration'] as String,
      logoutTime: map['logoutTime'] as String?,
      platformName: map['platformName'] as String?, // Handle platformName
    );
  }

  String toJson() => json.encode(toMap());

  factory Session.fromJson(String source) {
    try {
      return Session.fromMap(json.decode(source) as Map<String, dynamic>);
    } catch (e) {
      throw FormatException("Invalid JSON format: $e");
    }
  }

  static List<Session> fromJsonList(String source) {
    final List<dynamic> jsonList = json.decode(source) as List<dynamic>;
    return jsonList.map((x) => Session.fromJson(json.encode(x))).toList();
  }

  @override
  String toString() {
    return 'Session(id: $id, userId: $userId, loginTime: $loginTime, platformIdentity: $platformIdentity, accessToken: $accessToken, expiration: $expiration, logoutTime: $logoutTime, platformName: $platformName)';
  }
}
