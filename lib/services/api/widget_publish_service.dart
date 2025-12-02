import 'dart:convert';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class WidgetApiService {
  static const String baseUrl = "https://wss.ossbs.com/api/Device";

  static Future<bool> widgetPublish(String topic, String payload) async {
    try {
      final url = Uri.parse("$baseUrl/widgetPublish");
      final token = Get.find<AuthController>().session.value.accessToken;
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "topic": topic,
          "payload": payload,
        }),
      );

      if (response.statusCode == 200) {
        print(" Widget Publish başarılı: ${response.body}");
        return true;
      } else {
        print(" Hata: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception: $e");
      return false;
    }
  }
}
