import 'dart:convert';

import 'package:akilli_anahtar/models/kullanici_kapi_model.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:http/http.dart' as http;

class DeviceService {
  static String url = "${apiUrlOut}Device";

  static Future<List<KullaniciKapi>?> getKullaniciKapi(int id) async {
    var uri = Uri.parse("$url/get");
    var client = http.Client();
    var response = await client.get(uri);
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      var kapilar = KullaniciKapi.fromJsonList(result["data"]);
      return kapilar;
    }
    return null;
  }
}
