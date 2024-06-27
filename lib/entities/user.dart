// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
  int? id;
  String? kad;
  String? sifre;
  String? passwordHash;
  String? passwordSalt;
  String? adsoyad;
  int? ap;
  int? yetki;
  String? kurumId;
  String? telefon;
  String? mail;

  User({
    this.id,
    this.kad,
    this.sifre,
    this.passwordHash,
    this.passwordSalt,
    this.adsoyad,
    this.ap,
    this.yetki,
    this.kurumId,
    this.telefon,
    this.mail,
  });

  User copyWith({
    int? id,
    String? kad,
    String? sifre,
    String? passwordHash,
    String? passwordSalt,
    String? adsoyad,
    int? ap,
    int? yetki,
    String? kurumId,
    String? telefon,
    String? mail,
  }) {
    return User(
      id: id ?? this.id,
      kad: kad ?? this.kad,
      sifre: sifre ?? this.sifre,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      adsoyad: adsoyad ?? this.adsoyad,
      ap: ap ?? this.ap,
      yetki: yetki ?? this.yetki,
      kurumId: kurumId ?? this.kurumId,
      telefon: telefon ?? this.telefon,
      mail: mail ?? this.mail,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'kad': kad,
      'sifre': sifre,
      'passwordHash': passwordHash,
      'passwordSalt': passwordSalt,
      'adsoyad': adsoyad,
      'ap': ap,
      'yetki': yetki,
      'kurumId': kurumId,
      'telefon': telefon,
      'mail': mail,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] != null ? map['id'] as int : null,
      kad: map['kad'] != null ? map['kad'] as String : null,
      sifre: map['sifre'] != null ? map['sifre'] as String : null,
      passwordHash:
          map['passwordHash'] != null ? map['passwordHash'] as String : null,
      passwordSalt:
          map['passwordSalt'] != null ? map['passwordSalt'] as String : null,
      adsoyad: map['adsoyad'] != null ? map['adsoyad'] as String : null,
      ap: map['ap'] != null ? map['ap'] as int : null,
      yetki: map['yetki'] != null ? map['yetki'] as int : null,
      kurumId: map['kurumId'] != null ? map['kurumId'] as String : null,
      telefon: map['telefon'] != null ? map['telefon'] as String : null,
      mail: map['mail'] != null ? map['mail'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, kad: $kad, sifre: $sifre, passwordHash: $passwordHash, passwordSalt: $passwordSalt, adsoyad: $adsoyad, ap: $ap, yetki: $yetki, kurumId: $kurumId, telefon: $telefon, mail: $mail)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.kad == kad &&
        other.sifre == sifre &&
        other.passwordHash == passwordHash &&
        other.passwordSalt == passwordSalt &&
        other.adsoyad == adsoyad &&
        other.ap == ap &&
        other.yetki == yetki &&
        other.kurumId == kurumId &&
        other.telefon == telefon &&
        other.mail == mail;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        kad.hashCode ^
        sifre.hashCode ^
        passwordHash.hashCode ^
        passwordSalt.hashCode ^
        adsoyad.hashCode ^
        ap.hashCode ^
        yetki.hashCode ^
        kurumId.hashCode ^
        telefon.hashCode ^
        mail.hashCode;
  }
}
