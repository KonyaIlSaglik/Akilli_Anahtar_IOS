// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class KullaniciSensor {
  int sensorId;
  String sensorName;
  String topicStat;
  String? degerTuru;
  String? birim;
  int? altReferans;
  int? ustReferans;
  String? kurumAdi;
  String? topicMessage;

  KullaniciSensor({
    required this.sensorId,
    required this.sensorName,
    required this.topicStat,
    this.degerTuru,
    this.birim,
    this.altReferans,
    this.ustReferans,
    this.kurumAdi,
  });

  factory KullaniciSensor.fromJson(Map<String, dynamic> json) =>
      KullaniciSensor(
        sensorId: json["sensor_id"],
        sensorName: json["sensor_name"],
        topicStat: json["topic_stat"],
        degerTuru: json["deger_turu"],
        birim: json["birim"],
        altReferans: json["alt_referans"],
        ustReferans: json["ust_referans"],
        kurumAdi: json["kurum_adi"],
      );

  Map<String, dynamic> toJson() => {
        "sensor_id": sensorId,
        "sensor_name": sensorName,
        "topic_stat": topicStat,
        "deger_turu": degerTuru,
        "birim": birim,
        "alt_referans": altReferans,
        "ust_referans": ustReferans,
        "kurum_adi": kurumAdi,
      };

  static List<KullaniciSensor> kullaniciSensorFromJson(String str) =>
      List<KullaniciSensor>.from(
          json.decode(str).map((x) => KullaniciSensor.fromJson(x)));

  static String kullaniciKapiToJson(List<KullaniciSensor> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}
