import 'package:xml/xml.dart';

class KullaniciGirisResult2 {
  int? id;
  String? kad;
  String? adsoyad;
  int? yetki;
  int? ap;
  String? ret;

  KullaniciGirisResult2({
    this.id,
    this.kad,
    this.adsoyad,
    this.yetki,
    this.ap,
    this.ret,
  });

  KullaniciGirisResult2.fromXML(XmlElement xmlElement) {
    id = int.parse(xmlElement.getElement("ID")!.innerText);
    kad = xmlElement.getElement("KAD")!.innerText;
    adsoyad = xmlElement.getElement("ADSOYAD")!.innerText;
    yetki = int.parse(xmlElement.getElement("YETKI")!.innerText);
    ap = int.parse(xmlElement.getElement("AP")!.innerText);
    ret = xmlElement.getElement("ret")!.innerText;
  }
}
