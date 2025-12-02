import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/models/version_model.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:http/http.dart' as http;

class BoxService {
  static String url = "$apiUrlOut/Box";

  static Future<Box?> get(int id) async {
    var response = await BaseService.get("$url/get?id=$id");
    if (response.statusCode == 200) {
      var box = Box.fromJson(response.body);
      return box;
    }
    return null;
  }

  static Future<List<Box>?> getAll() async {
    var response = await BaseService.get(
      "$url/getAll",
    );
    if (response.statusCode == 200) {
      return Box.fromJsonList(response.body);
    }
    return null;
  }

  static Future<Box?> add(Box box) async {
    var response = await BaseService.add("$url/add", box.toJson());
    if (response.statusCode == 200) {
      var box = Box.fromJson(response.body);
      return box;
    }
    return null;
  }

  static Future<Box?> update(Box box) async {
    var response = await BaseService.update("$url/update", box.toJson());
    if (response.statusCode == 200) {
      var box = Box.fromJson(response.body);
      return box;
    }
    return null;
  }

  static Future<bool> delete(int id) async {
    var response = await BaseService.delete("$url/delete?id=$id");
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<VersionModel?> checkNewVersion({
    required String espType,
    required int boxTypeId,
  }) async {
    try {
      print(" [BoxService] checkNewVersion başladı");
      print("- espType: $espType");
      print("- boxTypeId: $boxTypeId");

      const typePaths = {
        1: "ortamizleme",
        2: "bariyer",
        3: "sulama",
        4: "bariyer-lora",
        5: "sulama-lora",
        6: "ortamizleme-lora",
      };

      final path = typePaths[boxTypeId];
      if (path == null) {
        print(" Geçersiz boxTypeId: $boxTypeId");
        return VersionModel(version: "GÜNCEL");
      }

      final versionUrl =
          Uri.parse("https://www.ossbs.com/update/$path/$espType/version.html");
      print(
          "++++++++++++++++++++++++ Versiyon dosyası URL: ${versionUrl.toString()}");

      final response =
          await http.get(versionUrl).timeout(const Duration(seconds: 8));
      print(" HTTP yanıt kodu: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = response.body.trim();
        print(" Gelen içerik:\n$body");

        final colon = body.indexOf(':');
        final dash = body.indexOf('-');
        String versionString;

        if (colon > 0 && dash > colon) {
          versionString = body.substring(colon + 1, dash).trim();
        } else {
          versionString = body;
        }

        print(" Bulunan versiyon: $versionString");
        return VersionModel(version: versionString);
      } else {
        print(" HTTP ${response.statusCode} hatası: ${response.body}");
      }
    } catch (e, s) {
      print(" Versiyon kontrolü hatası: $e");
      print(s);
    }

    print(" checkNewVersion başarısız veya versiyon alınamadı.");
    return null;
  }
}
