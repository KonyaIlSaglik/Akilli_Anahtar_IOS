import 'package:akilli_anahtar/entities/city.dart';
import 'dart:convert';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class CityService {
  static String url = "$apiUrlOut/City";
  static Future<City?> get(int id) async {
    var response = await BaseService.get(url, id);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var city = City.fromJson(json.encode(result["data"]));
      return city;
    }
    return null;
  }

  static Future<List<City>?> getAll() async {
    var response = await BaseService.getAll(url);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var cityList = List<City>.from((result["data"] as List<dynamic>)
          .map((e) => City.fromJson(json.encode(e))));
      return cityList;
    }
    return null;
  }

  static Future<Result> add(City city) async {
    return BaseService.add(url, city.toJson());
  }

  static Future<Result> update(City city) async {
    return BaseService.update(url, city.toJson());
  }

  static Future<Result> delete(int id) async {
    return BaseService.delete(url, id);
  }
}
