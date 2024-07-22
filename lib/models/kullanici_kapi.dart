import 'dart:convert';

class KullaniciKapi {
  int kapiId;
  String kapiAdi;
  String topicStat;
  String? topicRec;
  String? topicRes;
  String? siteAdi;
  String? ret;
  String? kapiTurAdi;
  String? topicMessage;

  KullaniciKapi({
    required this.kapiId,
    required this.kapiAdi,
    required this.topicStat,
    this.topicRec,
    this.topicRes,
    this.siteAdi,
    this.ret,
    this.kapiTurAdi,
  });

  factory KullaniciKapi.fromJson(Map<String, dynamic> json) => KullaniciKapi(
        kapiId: json["kapi_id"],
        kapiAdi: json["kapi_adi"],
        topicStat: json["topic_stat"],
        topicRec: json["topic_rec"],
        topicRes: json["topic_res"],
        siteAdi: json["site_adi"],
        ret: json["ret"],
        kapiTurAdi: json["kapi_tur_adi"],
      );

  Map<String, dynamic> toJson() => {
        "kapi_id": kapiId,
        "kapi_adi": kapiAdi,
        "topic_stat": topicStat,
        "topic_rec": topicRec,
        "topic_res": topicRes,
        "site_adi": siteAdi,
        "ret": ret,
        "kapi_tur_adi": kapiTurAdi,
      };

  static List<KullaniciKapi> kullaniciKapiFromJson(String str) =>
      List<KullaniciKapi>.from(
          json.decode(str).map((x) => KullaniciKapi.fromJson(x)));

  static String kullaniciKapiToJson(List<KullaniciKapi> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}
