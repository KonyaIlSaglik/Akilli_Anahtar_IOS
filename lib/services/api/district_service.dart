import 'package:akilli_anahtar/entities/district.dart';
import 'dart:convert';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class DistrictService {
  static String url = "$apiUrlOut/District";
  static Future<District?> get(int id) async {
    var response = await BaseService.get(url, id);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var district = District.fromJson(json.encode(result["data"]));
      return district;
    }
    return null;
  }

  static Future<List<District>?> getAll() async {
    var response = await BaseService.getAll(url);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var districtList = List<District>.from((result["data"] as List<dynamic>)
          .map((e) => District.fromJson(json.encode(e))));
      return districtList;
    }
    return null;
  }

  static Future<Result> add(District district) async {
    return BaseService.add(url, district.toJson());
  }

  static Future<Result> update(District district) async {
    return BaseService.update(url, district.toJson());
  }

  static Future<Result> delete(int id) async {
    return BaseService.delete(url, id);
  }
}
