import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class KullaniciKapi {
  int kapiId;
  String kapiAdi;
  String topicStat;
  String topicRec;
  String topicRes;
  String siteAdi;
  String ret;
  String kapiTurAdi;
  String? topicMessage;

  KullaniciKapi(
      {required this.kapiId,
      required this.kapiAdi,
      required this.topicStat,
      required this.topicRec,
      required this.topicRes,
      required this.siteAdi,
      required this.ret,
      required this.kapiTurAdi,
      this.topicMessage});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'kapiId': kapiId,
      'kapiAdi': kapiAdi,
      'topicStat': topicStat,
      'topicRec': topicRec,
      'topicRes': topicRes,
      'siteAdi': siteAdi,
      'ret': ret,
      'kapiTurAdi': kapiTurAdi,
    };
  }

  factory KullaniciKapi.fromMap(Map<String, dynamic> map) {
    return KullaniciKapi(
      kapiId: map['kapiId'] as int,
      kapiAdi: map['kapiAdi'] as String,
      topicStat: map['topicStat'] as String,
      topicRec: map['topicRec'] as String,
      topicRes: map['topicRes'] as String,
      siteAdi: map['siteAdi'] as String,
      ret: map['ret'] as String,
      kapiTurAdi: map['kapiTurAdi'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory KullaniciKapi.fromJson(String source) =>
      KullaniciKapi.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<KullaniciKapi> fromJsonList(Map<String, dynamic> json) {
    var kullaniciKapi = <KullaniciKapi>[];
    json['KullaniciKapi'].forEach((v) {
      kullaniciKapi.add(KullaniciKapi.fromJson(v));
    });
    return kullaniciKapi;
  }
}
