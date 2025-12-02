import 'dart:convert';

class UpdateGoogleUserDto {
  final int userId;
  final String? fullName;
  final String? telephone;

  UpdateGoogleUserDto({
    required this.userId,
    this.fullName,
    this.telephone,
  });

  factory UpdateGoogleUserDto.fromJson(String jsonStr) {
    final jsonMap = json.decode(jsonStr);
    return UpdateGoogleUserDto(
      userId: jsonMap['userId'],
      fullName: jsonMap['fullName'],
      telephone: jsonMap['telephone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'telephone': telephone,
    };
  }

  bool get isGoogleProfileComplete =>
      fullName != null &&
      fullName!.trim().isNotEmpty &&
      telephone != null &&
      telephone!.trim().isNotEmpty;
}
