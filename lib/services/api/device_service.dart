import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class DeviceService {
  static String url = "$apiUrlOut/Device";

  static Future<List<Device>?> getAllByBoxId(int id) async {
    return await BaseService.get2(
      "$url/getAllByBoxId?id=$id",
      (json) => Device.fromJsonList(json),
    );
  }

  static Future<List<Device>?> getAllByUserId(int id) async {
    return await BaseService.get2(
      "$url/getAllByUserId?id=$id",
      (json) => Device.fromJsonList(json),
    );
  }

  static Future<Device?> get(int id) async {
    return await BaseService.get2(
      "$url/get?id=$id",
      (json) => Device.fromJson(json),
    );
  }

  static Future<List<Device>?> getAll() async {
    return await BaseService.get2(
      "$url/getAll",
      (json) => Device.fromJsonList(json),
    );
  }

  static Future<Device?> add(Device box) async {
    return BaseService.add2(
      "$url/add",
      box.toJson(),
      (json) => Device.fromJson(json),
    );
  }

  static Future<Device?> update(Device box) async {
    return BaseService.update2(
      "$url/update",
      box.toJson(),
      (json) => Device.fromJson(json),
    );
  }

  static Future<Device?> delete(int id) async {
    return BaseService.delete2(
      "$url/delete?id=$id",
      (json) => Device.fromJson(json),
    );
  }

  // static Future<List<Device>?> getAllByUserId(String id) async {
  //   var uri = Uri.parse("$url/getAllByUserId?id=$id");
  //   var client = http.Client();
  //   var authController = Get.find<AuthController>();
  //   var tokenModel = authController.tokenModel.value;
  //   var response = await client.get(
  //     uri,
  //     headers: {
  //       'content-type': 'application/json; charset=utf-8',
  //       'Authorization': 'Bearer ${tokenModel.accessToken}',
  //     },
  //   );
  //   client.close();
  //   if (response.statusCode == 200) {
  //     var devices = Device.fromJsonList(response.body);
  //     return devices;
  //   }
  //   return null;
  // }

  // static Future<List<Device>?> getAll() async {
  //   var response = await BaseService.getAll(url);
  //   if (response.statusCode == 200) {
  //     var boxList = List<Device>.from(response.body as List<dynamic>)
  //         .map((e) => Device.fromJson(json.encode(e)));
  //     return boxList.toList();
  //   }
  //   return null;
  // }

  // static Future<Device?> add(Device box) async {
  //   var response = await BaseService.add(url, box.toJson());
  //   if (response.statusCode == 200) {
  //     var box = Device.fromJson(response.body);
  //     return box;
  //   }
  //   return null;
  // }

  // static Future<Device?> update(Device box) async {
  //   var response = await BaseService.update(url, box.toJson());
  //   if (response.statusCode == 200) {
  //     var box = Device.fromJson(response.body);
  //     return box;
  //   }
  //   return null;
  // }

  // static Future<Device?> delete(int id) async {
  //   var response = await BaseService.delete(url, id);
  //   if (response.statusCode == 200) {
  //     var box = Device.fromJson(response.body);
  //     return box;
  //   }
  //   return null;
  // }
}
