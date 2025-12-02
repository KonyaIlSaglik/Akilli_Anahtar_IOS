import 'dart:convert';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/dtos/device_user_role_dto.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ManagementService extends GetxController {
  static String url = "$apiUrlOut/User";
  final RxList<DeviceRoleDto> userDevices = <DeviceRoleDto>[].obs;

  static Future<Map<String, dynamic>?> addUserDeviceByChipId(int chipId) async {
    final response =
        await BaseService.post("$url/addUserDeviceByChipId?chipId=$chipId");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      data["ok"] = true;
      Future.microtask(() async {
        if (Get.isRegistered<HomeController>()) {
          try {
            await Get.find<HomeController>().getDevices();
          } catch (_) {}
        }
      });

      return data;
    }

    if (response.statusCode == 400) {
      final data = json.decode(response.body);
      return {
        "error": true,
        "message": data["message"] ?? "Bu cihaz zaten ekli."
      };
    }

    if (response.statusCode == 403) {
      final data = json.decode(response.body);
      return {
        "error": true,
        "requireShareCode": true,
        "message": data["message"] ??
            "Bu kutuda yönetici var. Yöneticiden paylaşım kodu isteyin."
      };
    }

    if (response.statusCode == 404) {
      final msg = response.body.isNotEmpty ? json.decode(response.body) : null;
      return {
        "error": true,
        "message": (msg is Map && msg["message"] != null)
            ? msg["message"]
            : "Kutu veya bileşen bulunamadı."
      };
    }

    if (response.statusCode == 409) {
      final data = json.decode(response.body);
      return {
        "error": true,
        "message": data["message"] ?? "Kayıt çakışması. Lütfen tekrar deneyin."
      };
    }

    return {
      "error": true,
      "message": "Beklenmeyen bir hata oluştu. (${response.statusCode})"
    };
  }

  static Future<String?> generateShareCode(int deviceId) async {
    final response =
        await BaseService.post("$url/generateShareCode?deviceId=$deviceId");

    if (response.statusCode == 200 && response.body.contains("code")) {
      final data = json.decode(response.body);
      return data["code"];
    }
    return null;
  }

  static Future<String?> generateShareCodeMulti(List<int> deviceIds) async {
    final client = http.Client();
    try {
      final token = Get.find<AuthController>().session.value.accessToken;
      final ids = deviceIds.whereType<int>().toList(growable: false);
      if (ids.isEmpty) throw Exception('deviceIds boş');

      final uri = Uri.parse("$url/generateShareCodeMulti");

      print(jsonEncode({"deviceIds": ids}));

      final res = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "deviceIds": ids,
        }),
      );

      if (res.statusCode == 200) {
        final map = jsonDecode(res.body) as Map<String, dynamic>;
        return (map['Code'] ?? map['code'])?.toString();
      }
      throw Exception('(${res.statusCode}) ${res.body}');
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>?> useShareCode(String code) async {
    final response = await BaseService.post("$url/useShareCode2?code=$code");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Future.microtask(() async {
        if (Get.isRegistered<HomeController>()) {
          try {
            await Get.find<HomeController>().getDevices();
          } catch (_) {}
        }
      });

      return {
        "deviceId": data["deviceId"],
      };
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getDeviceUsers(
      {int page = 0, String query = ""}) async {
    final response = await BaseService.get("$url/getUsers");
    if (response.statusCode == 200) {
      var userList =
          List<Map<String, dynamic>>.from(json.decode(response.body));
      if (userList.isEmpty) return List.empty();
      return userList;
    }
    return [];
  }

  static Future<bool> promoteToAdmin(int userId, int deviceId) async {
    final response = await BaseService.post(
        "$url/promoteToAdmin?userId=$userId&deviceId=$deviceId");
    return response.statusCode == 200;
  }

  static Future<List<DeviceRoleDto>> getUserDevices() async {
    final response = await BaseService.get("$url/userDevices");
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => DeviceRoleDto.fromJson(e)).toList();
    }
    return [];
  }

  static Future<int?> usersDeviceStatus2(int userId, int deviceId) async {
    final response = await BaseService.post(
      "$url/active-pasiveDeviceUser?userId=$userId&deviceId=$deviceId",
    );
    print("Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      try {
        final data = json.decode(response.body);
        final v = data["isActive"];
        if (v is int) return v;
        if (v is bool) return v ? 1 : 0;
      } catch (_) {}
    }
    return null;
  }

  static Future<bool> usersDeviceStatus(int userId, int deviceId) async {
    final response = await BaseService.post(
        "$url/active-pasiveDeviceUser?userId=$userId&deviceId=$deviceId");
    print("Response: ${response.statusCode} - ${response.body}");
    return response.statusCode == 200;
  }

  static Future<List<Map<String, dynamic>>> getDeviceUsers2({
    int page = 0,
    int pageSize = 20,
    String query = "",
  }) async {
    try {
      final q = Uri.encodeQueryComponent(query.trim());
      final uri =
          Uri.parse("$url/getUsers?page=$page&pageSize=$pageSize&userName=$q");

      final response = await BaseService.get(uri.toString());
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = json.decode(response.body);
        if (data is List) return List<Map<String, dynamic>>.from(data);
        if (data is Map && data["items"] is List) {
          return List<Map<String, dynamic>>.from(data["items"]);
        }
      }
      return [];
    } catch (e) {
      print("getDeviceUsers2 error: $e");
      return [];
    }
  }
}
