import 'dart:convert';

import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:http/http.dart' as http;

class BoxService {
  static String url = "$apiUrlOut/Box";

  static Future<Box?> get(int id) async {
    var response = await BaseService.get(url, id);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var box = Box.fromJson(json.encode(result["data"]));
      return box;
    }
    return null;
  }

  static Future<List<Box>?> getAll() async {
    var response = await BaseService.getAll(url);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var boxList = List<Box>.from((result["data"] as List<dynamic>)
          .map((e) => Box.fromJson(json.encode(e))));
      return boxList;
    }
    return null;
  }

  static Future<Result> add(Box box) async {
    return BaseService.add(url, box.toJson());
  }

  static Future<Result> update(Box box) async {
    return BaseService.update(url, box.toJson());
  }

  static Future<Result> delete(int id) async {
    return BaseService.delete(url, id);
  }

  static Future<String> checkNewVersion() async {
    try {
      var uri = Uri.parse("https://www.ossbs.com/update/version.html");
      var client = http.Client();
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        var s1 = response.body.split(":");
        var s2 = s1[1].split("-");
        return s2[0];
      }
    } catch (e) {
      print(e);
      return "";
    }
    return "";
  }
}
