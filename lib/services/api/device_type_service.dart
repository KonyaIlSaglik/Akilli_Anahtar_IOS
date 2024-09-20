import 'package:akilli_anahtar/entities/device_type.dart';
import 'dart:convert';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class DeviceTypeService {
  static String url = "$apiUrlOut/DeviceType";
  static Future<DeviceType?> get(int id) async {
    var response = await BaseService.get(url, id);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var deviceType = DeviceType.fromJson(json.encode(result["data"]));
      return deviceType;
    }
    return null;
  }

  static Future<List<DeviceType>?> getAll() async {
    var response = await BaseService.getAll(url);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var deviceTypeList = List<DeviceType>.from(
          (result["data"] as List<dynamic>)
              .map((e) => DeviceType.fromJson(json.encode(e))));
      return deviceTypeList;
    }
    return null;
  }

  static Future<Result> add(DeviceType deviceType) async {
    return BaseService.add(url, deviceType.toJson());
  }

  static Future<Result> update(DeviceType deviceType) async {
    return BaseService.update(url, deviceType.toJson());
  }

  static Future<Result> delete(int id) async {
    return BaseService.delete(url, id);
  }
}
