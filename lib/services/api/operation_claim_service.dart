import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/data_result.dart';
import 'dart:convert';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class OperationClaimService {
  static String url = "$apiUrlOut/OperationClaim";

  static Future<DataResult<List<OperationClaim>>> getClaims(User user) async {
    var uri = Uri.parse("$url/getuserclaims");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
      body: user.toJson(),
    );
    client.close();
    var dataResult = DataResult<List<OperationClaim>>();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      dataResult.data =
          OperationClaim.fromJsonList(json.encode(result["data"]));
      dataResult.success = result["success"];
      dataResult.message = result["message"] ?? "";
      await LocalDb.add(userClaimsKey, json.encode(result["data"]));
    } else {
      dataResult.success = false;
      dataResult.message = response.body;
    }
    return dataResult;
  }

  static Future<OperationClaim?> get(int id) async {
    var uri = Uri.parse("$url/get?id=$id");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
    );
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      var operationClaim = OperationClaim.fromJson(json.encode(result["data"]));
      return operationClaim;
    }
    return null;
  }

  static Future<List<OperationClaim>?> getAll() async {
    var uri = Uri.parse("$url/getall");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
    );
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      var operationClaimList = List<OperationClaim>.from(
          (result["data"] as List<dynamic>)
              .map((e) => OperationClaim.fromJson(json.encode(e))));
      return operationClaimList;
    }
    return null;
  }

  static Future<Result> add(OperationClaim operationClaim) async {
    var uri = Uri.parse("$url/add");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
      body: operationClaim.toJson(),
    );
    client.close();
    var result = Result();
    if (response.statusCode == 200) {
      var body = json.decode(response.body) as Map<String, dynamic>;
      result.success = body["success"] as bool;
      result.message = body["message"] ?? "";
    }
    return result;
  }

  static Future<Result> update(OperationClaim operationClaim) async {
    var uri = Uri.parse("$url/update");
    var client = http.Client();
    var authController = Get.find<AuthController>();
    var tokenModel = authController.tokenModel.value;
    var response = await client.put(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${tokenModel.accessToken}',
      },
      body: operationClaim.toJson(),
    );
    client.close();
    var result = Result();
    if (response.statusCode == 200) {
      var body = json.decode(response.body) as Map<String, dynamic>;
      result.success = body["success"] as bool;
      result.message = body["message"] ?? "";
    }
    return result;
  }
}
