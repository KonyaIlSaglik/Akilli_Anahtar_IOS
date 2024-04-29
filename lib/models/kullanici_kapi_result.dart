import 'package:xml/xml.dart';

class KullaniciKapiResult {
  int? kapiId;
  String? kapiAdi;
  String? topicStat;
  String? topicRec;
  String? topicRes;
  String? siteAdi;
  String? ret;
  String? kapiTurAdi;
  String? topicMessage;

  KullaniciKapiResult({
    this.kapiId,
    this.kapiAdi,
    this.topicStat,
    this.topicRec,
    this.topicRes,
    this.siteAdi,
    this.ret,
    this.kapiTurAdi,
    this.topicMessage,
  });

  KullaniciKapiResult.fromXML(XmlElement xmlElement) {
    kapiId = int.parse(xmlElement.getElement("kapi_id")!.innerText);
    kapiAdi = xmlElement.getElement("kapi_adi")!.innerText;
    topicStat = xmlElement.getElement("topic_stat")!.innerText;
    topicRec = xmlElement.getElement("topic_rec")!.innerText;
    topicRes = xmlElement.getElement("topic_res")!.innerText;
    siteAdi = xmlElement.getElement("site_adi")!.innerText;
    ret = xmlElement.getElement("ret")!.innerText;
    kapiTurAdi = xmlElement.getElement("kapi_tur_adi")!.innerText;
  }

  static List<KullaniciKapiResult> fromXMLList(XmlElement xmlElement) {
    return xmlElement.childElements
        .map<KullaniciKapiResult>((e) => KullaniciKapiResult.fromXML(e))
        .toList();
  }
}
