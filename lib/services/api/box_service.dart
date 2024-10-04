import 'dart:convert';

import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/models/version_model.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:http/http.dart' as http;

class BoxService {
  static String url = "$apiUrlOut/Box";

  static Future<Box?> get(int id) async {
    var response = await BaseService.get(url, id);
    if (response.statusCode == 200) {
      var box = Box.fromJson(response.body);
      return box;
    }
    return null;
  }

  static Future<List<Box>?> getAll() async {
    var response = await BaseService.getAll(url);
    if (response.statusCode == 200) {
      var boxList = List<Box>.from(response.body as List<dynamic>)
          .map((e) => Box.fromJson(json.encode(e)));
      return boxList.toList();
    }
    return null;
  }

  static Future<Box?> add(Box box) async {
    var response = await BaseService.add(url, box.toJson());
    if (response.statusCode == 200) {
      var box = Box.fromJson(response.body);
      return box;
    }
    return null;
  }

  static Future<Box?> update(Box box) async {
    var response = await BaseService.update(url, box.toJson());
    if (response.statusCode == 200) {
      var box = Box.fromJson(response.body);
      return box;
    }
    return null;
  }

  static Future<Box?> delete(int id) async {
    var response = await BaseService.delete(url, id);
    if (response.statusCode == 200) {
      var box = Box.fromJson(response.body);
      return box;
    }
    return null;
  }

  static Future<VersionModel> checkNewVersion() async {
    var model = VersionModel();
    try {
      var uri = Uri.parse("https://www.ossbs.com/update/version.html");
      var client = http.Client();
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        return VersionModel.fromString(response.body);
      }
    } catch (e) {
      print(e);
      return model;
    }
    return model;
  }
}
