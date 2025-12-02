import 'dart:convert';

class UserDto {
  int? id;
  String? userName;
  String? fullName;
  String? password;
  String? mail;
  String? telephone;
  int? active;
  int? organisationId;
  String? organisationName;
  int? emailVerified;
  int? smsVerified;

  bool get isEmailVerified => emailVerified == 1;
  bool get isSmsVerified => smsVerified == 1;

  UserDto({
    this.id,
    this.userName,
    this.fullName,
    this.password,
    this.mail,
    this.telephone,
    this.active,
    this.organisationId,
    this.organisationName,
    this.emailVerified,
    this.smsVerified,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userName': userName,
      'fullName': fullName,
      'password': password,
      'mail': mail,
      'telephone': telephone,
      'active': active,
      'organisationId': organisationId,
      'organisationName': organisationName,
      'emailVerified': emailVerified,
      'smsVerified': smsVerified,
    };
  }

  factory UserDto.fromMap(Map<String, dynamic> map) {
    return UserDto(
      id: map['id'] != null ? map['id'] as int : null,
      userName: map['userName'] as String?,
      fullName: map['fullName'] != null ? map['fullName'] as String : "",
      password: map['password'] != null ? map['password'] as String : "",
      mail: map['mail'] != null ? map['mail'] as String : "",
      telephone: map['telephone'] != null ? map['telephone'] as String : "",
      active: map['active'] != null ? map['active'] as int : 0,
      organisationId:
          map['organisationId'] != null ? map['organisationId'] as int : 0,
      organisationName: map['organisationName'] != null
          ? map['organisationName'] as String
          : "",
      emailVerified:
          map['emailVerified'] != null ? map['emailVerified'] as int : null,
      smsVerified:
          map['smsVerified'] != null ? map['smsVerified'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDto.fromJson(String source) =>
      UserDto.fromMap(json.decode(source) as Map<String, dynamic>);

  UserDto copyWith({
    int? id,
    String? userName,
    String? fullName,
    String? password,
    String? mail,
    String? telephone,
    int? active,
    int? organisationId,
    String? organisationName,
    int? emailVerified,
    int? smsVerified,
  }) {
    return UserDto(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      password: password ?? this.password,
      mail: mail ?? this.mail,
      telephone: telephone ?? this.telephone,
      active: active ?? this.active,
      organisationId: organisationId ?? this.organisationId,
      organisationName: organisationName ?? this.organisationName,
      emailVerified: emailVerified ?? this.emailVerified,
      smsVerified: smsVerified ?? this.smsVerified,
    );
  }

  static List<UserDto> fromJsonList(String source) =>
      List<UserDto>.from((json.decode(source) as List<dynamic>)
          .map((x) => UserDto.fromJson(json.encode(x))));

  @override
  bool operator ==(covariant UserDto other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userName == userName &&
        other.fullName == fullName &&
        other.password == password &&
        other.mail == mail &&
        other.telephone == telephone &&
        other.active == active &&
        other.organisationId == organisationId &&
        other.organisationName == organisationName &&
        other.emailVerified == emailVerified &&
        other.smsVerified == smsVerified;
  }

  bool get isSocialProfileComplete =>
      fullName != null &&
      fullName!.trim().isNotEmpty &&
      telephone != null &&
      telephone!.trim().isNotEmpty;

  @override
  int get hashCode {
    return id.hashCode ^
        userName.hashCode ^
        fullName.hashCode ^
        password.hashCode ^
        mail.hashCode ^
        telephone.hashCode ^
        active.hashCode ^
        organisationId.hashCode ^
        organisationName.hashCode ^
        emailVerified.hashCode ^
        smsVerified.hashCode;
  }
}
