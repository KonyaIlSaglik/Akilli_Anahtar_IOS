import 'package:akilli_anahtar/entities/device.dart';
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

  static Future<Device?> add(Device box) async {
    var response = await BaseService.add(
      "$url/add",
      box.toJson(),
    );
    if (response.statusCode == 200) {
      return Device.fromJson(response.body);
    }
    return null;
  }

  static Future<Device?> update(Device box) async {
    var response = await BaseService.update(
      "$url/update",
      box.toJson(),
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
