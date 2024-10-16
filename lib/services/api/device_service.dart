import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class DeviceService {
  static String url = "$apiUrlOut/Device";

  static Future<List<Device>?> getAllByBoxId(int id) async {
    var response = await BaseService.get(
      "$url/getAllByBoxId?id=$id",
    );
    if (response.statusCode == 200) {
      return Device.fromJsonList(response.body);
    }
    return null;
  }

  static Future<List<Device>?> getAllByUserId(int id) async {
    var response = await BaseService.get(
      "$url/getAllByUserId?id=$id",
    );
    if (response.statusCode == 200) {
      return Device.fromJsonList(response.body);
    }
    return null;
  }

  static Future<Device?> get(int id) async {
    var response = await BaseService.get(
      "$url/get?id=$id",
    );
    if (response.statusCode == 200) {
      return Device.fromJson(response.body);
    }
    return null;
  }

  static Future<List<Device>?> getAll() async {
    var response = await BaseService.get(
      "$url/getAll",
    );
    if (response.statusCode == 200) {
      return Device.fromJsonList(response.body);
    }
    return null;
  }

  static Future<Device?> add(Device device) async {
    var response = await BaseService.add(
      "$url/add",
      device.toJson(),
    );
    if (response.statusCode == 200) {
      return Device.fromJson(response.body);
    }
    return null;
  }

  static Future<Device?> update(Device device) async {
    var response = await BaseService.update(
      "$url/update",
      device.toJson(),
    );
    if (response.statusCode == 200) {
      return Device.fromJson(response.body);
    }
    return null;
  }

  static Future<bool> delete(int id) async {
    var response = await BaseService.delete(
      "$url/delete?id=$id",
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<List<DeviceType>?> getDeviceTypes() async {
    var response = await BaseService.get(
      "$url/getDeviceTypes",
    );
    if (response.statusCode == 200) {
      return DeviceType.fromJsonList(response.body);
    }
    return null;
  }

  static Future<DeviceType?> addDeviceType(DeviceType deviceType) async {
    var response = await BaseService.add(
      "$url/addDeviceType",
      deviceType.toJson(),
    );
    if (response.statusCode == 200) {
      return DeviceType.fromJson(response.body);
    }
    return null;
  }

  static Future<DeviceType?> updateDeviceType(DeviceType deviceType) async {
    var response = await BaseService.update(
      "$url/updateDeviceType",
      deviceType.toJson(),
    );
    if (response.statusCode == 200) {
      return DeviceType.fromJson(response.body);
    }
    return null;
  }

  static Future<bool> deleteDeviceType(int id) async {
    var response = await BaseService.delete(
      "$url/deleteDeviceType?id=$id",
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
