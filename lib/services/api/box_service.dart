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

  static Future<VersionModel?> checkNewVersion() async {
    try {
      var uri = Uri.parse("https://www.ossbs.com/update/version.html");
      var client = http.Client();
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        return VersionModel.fromString(response.body);
      }
    } catch (e) {
      print(e);
      return null;
    }
    return null;
  }
}
