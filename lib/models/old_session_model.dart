import 'dart:convert';

class OldSessionModel {
  final int? id;
  final String? platformIdentity;
  final String? platformName;
  final String? lastActiveTime;

  OldSessionModel({
    this.id,
    this.platformIdentity,
    this.platformName,
    this.lastActiveTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'platformIdentity': platformIdentity,
      'platformName': platformName,
      'lastActiveTime': lastActiveTime,
    };
  }

  factory OldSessionModel.fromMap(Map<String, dynamic> map) {
    return OldSessionModel(
      id: map['id'] as int,
      platformIdentity: map['platformIdentity'] as String,
      platformName: map['platformName'] as String,
      lastActiveTime: map['lastActiveTime'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory OldSessionModel.fromJson(String source) {
    try {
      return OldSessionModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
    } catch (e) {
      throw FormatException("Invalid JSON format: $e");
    }
  }

  static List<OldSessionModel> fromJsonList(String source) {
    final List<dynamic> jsonList = json.decode(source) as List<dynamic>;
    return jsonList
        .map((x) => OldSessionModel.fromJson(json.encode(x)))
        .toList();
  }
}
