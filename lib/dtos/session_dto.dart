import 'dart:convert';

class SessionDto {
  final int id;
  final String loginTime;
  final String accessToken;
  final String expiration;
  final List<String>? claims;

  SessionDto({
    required this.id,
    required this.loginTime,
    required this.accessToken,
    required this.expiration,
    this.claims,
  });

  factory SessionDto.empty() {
    return SessionDto(
      id: 0,
      accessToken: "",
      expiration: "",
      loginTime: "",
      claims: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loginTime': loginTime,
      'accessToken': accessToken,
      'expiration': expiration,
      'claims': json.encode(claims!),
    };
  }

  factory SessionDto.fromMap(Map<String, dynamic> map) {
    return SessionDto(
      id: map['id'] as int,
      loginTime: map['loginTime'] as String,
      accessToken: map['accessToken'] as String,
      expiration: map['expiration'] as String,
      claims: map['claims'] != null
          ? List<String>.from(map['claims'] as List<dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SessionDto.fromJson(String source) {
    try {
      return SessionDto.fromMap(json.decode(source) as Map<String, dynamic>);
    } catch (e) {
      throw FormatException("Invalid JSON format: $e");
    }
  }

  static List<SessionDto> fromJsonList(String source) {
    final List<dynamic> jsonList = json.decode(source) as List<dynamic>;
    return jsonList.map((x) => SessionDto.fromJson(json.encode(x))).toList();
  }
}
