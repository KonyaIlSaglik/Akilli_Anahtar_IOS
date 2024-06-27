// import 'dart:convert';
// import 'package:akilli_anahtar/models/kullanici_giris_result.dart';
// import 'package:akilli_anahtar/models/kullanici_kapi_model.dart';
// import 'package:akilli_anahtar/services/local/shared_prefences.dart';
// import 'package:akilli_anahtar/utils/constants.dart';
// import 'package:xml/xml.dart';
// import 'package:http/http.dart' as http;

// class WebService {
//   static String url = "http://wss.oss.net.tr:8085/Service.asmx";

//   static Future<KullaniciGirisResult2?> kullaniciGiris2(
//       String userName, String password) async {
//     var uri = Uri.parse(url);
//     var client = http.Client();
//     var body =
//         '''<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:tem="http://tempuri.org/">
//             <soap:Header/>
//             <soap:Body>
//                 <tem:KullaniciGiris>
//                   <tem:webservis_kad>android</tem:webservis_kad>
//                   <tem:webservis_sifre>Android23*</tem:webservis_sifre>
//                   <tem:kad>$userName</tem:kad>
//                   <tem:sifre>$password</tem:sifre>
//                 </tem:KullaniciGiris>
//             </soap:Body>
//           </soap:Envelope>''';
//     var response = await client.post(
//       uri,
//       headers: {
//         'content-type': 'text/xml; charset=utf-8',
//         'SOAPAction': 'http://tempuri.org/KullaniciGiris',
//         'Host': 'wss.oss.net.tr',
//       },
//       body: utf8.encode(body),
//     );
//     client.close();
//     var xml = XmlDocument.parse(response.body);
//     var xmlElement = xml.findAllElements("KullaniciGirisResult").single;
//     if (xmlElement.getElement("ID")!.innerText == "0") return null;
//     await LocalDb.add(userKey, xmlElement.toXmlString());
//     await LocalDb.add(passwordKey, password);
//     return KullaniciGirisResult2.fromXML(xmlElement);
//   }

//   static Future<List<KullaniciKapiResult2>?> kullaniciKapi(int userId) async {
//     var uri = Uri.parse(url);
//     var client = http.Client();
//     var body =
//         '''<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:tem="http://tempuri.org/">
//             <soap:Header/>
//             <soap:Body>
//               <tem:KullaniciKapi>
//                 <tem:kullanici_id>$userId</tem:kullanici_id>
//                 <tem:webservis_kad>android</tem:webservis_kad>
//                 <tem:webservis_sifre>Android23*</tem:webservis_sifre>
//               </tem:KullaniciKapi>
//             </soap:Body>
//           </soap:Envelope>''';
//     var response = await client.post(
//       uri,
//       headers: {
//         'content-type': 'text/xml; charset=utf-8',
//         'SOAPAction': 'http://tempuri.org/KullaniciKapi',
//         'Host': 'wss.oss.net.tr',
//       },
//       body: utf8.encode(body),
//     );
//     client.close();
//     var xml = XmlDocument.parse(response.body);
//     var xmlElement = xml.findAllElements("KullaniciKapiResult").single;
//     if (xmlElement.findAllElements("KULLANICI_KAPI").isEmpty) return null;
//     return KullaniciKapiResult2.fromXMLList(xmlElement);
//   }

//   static Future<bool?> kullaniciSifreDegistir(
//       {required kad, required eskiSifre, required yeniSifre}) async {
//     var uri = Uri.parse(url);
//     var client = http.Client();
//     var body =
//         '''<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:tem="http://tempuri.org/">
//             <soap:Header/>
//             <soap:Body>
//               <tem:KullaniciSifreDegisitir>
//                 <tem:kad>$kad</tem:kad>
//                 <tem:eskisifre>$eskiSifre</tem:eskisifre>
//                 <tem:yenisifre>$yeniSifre</tem:yenisifre>
//                 <tem:webservis_kad>android</tem:webservis_kad>
//                 <tem:webservis_sifre>Android23*</tem:webservis_sifre>
//               </tem:KullaniciSifreDegisitir>
//             </soap:Body>
//           </soap:Envelope>''';
//     var response = await client.post(
//       uri,
//       headers: {
//         'content-type': 'text/xml; charset=utf-8',
//         'SOAPAction': 'http://tempuri.org/KullaniciSifreDegisitir',
//         'Host': 'wss.oss.net.tr',
//       },
//       body: utf8.encode(body),
//     );
//     client.close();
//     var xml = XmlDocument.parse(response.body);
//     var xmlElement =
//         xml.findAllElements("KullaniciSifreDegisitirResult").single;
//     return xmlElement.innerText == "1";
//   }
// }
