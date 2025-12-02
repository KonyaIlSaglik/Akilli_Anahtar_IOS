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
      'claims': claims,
    };
  }

  factory SessionDto.fromMap(Map<String, dynamic> map) {
    List<String>? parsedClaims;

    final rawClaims = map['claims'];
    if (rawClaims != null) {
      if (rawClaims is String) {
        // String olarak kaydedilmişse decode etmeyi dene
        try {
          final decoded = jsonDecode(rawClaims);
          if (decoded is List) {
            parsedClaims = List<String>.from(decoded);
          } else {
            parsedClaims = [rawClaims];
          }
        } catch (_) {
          parsedClaims = [rawClaims];
        }
      } else if (rawClaims is List) {
        parsedClaims = List<String>.from(rawClaims);
      }
    }

    return SessionDto(
      id: (map['id'] ?? 0) is int
          ? map['id']
          : int.tryParse(map['id'].toString()) ?? 0,
      loginTime: map['loginTime']?.toString() ?? '',
      accessToken: map['accessToken']?.toString() ?? '',
      expiration: map['expiration']?.toString() ?? '',
      claims: parsedClaims,
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
