import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/user_operation_claim.dart';
import 'package:akilli_anahtar/models/data_result.dart';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'dart:convert';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class UserOperationClaimService {
  static String url = "$apiUrlOut/UserOperationClaim";

  static Future<List<UserOperationClaim>?> getAllByUserId(int userId) async {
    var uri = Uri.parse("$url/getallbyuserid?userId=$userId");
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
    print(response.body);
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      var operationClaimList = List<UserOperationClaim>.from(
          (result["data"] as List<dynamic>)
              .map((e) => UserOperationClaim.fromJson(json.encode(e))));
      return operationClaimList;
    }
    return null;
  }

  static Future<DataResult<UserOperationClaim>> add(
      UserOperationClaim operationClaim) async {
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
    var dataResult = DataResult<UserOperationClaim>();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      dataResult.data =
          UserOperationClaim.fromJson(json.encode(result["data"]));
      dataResult.success = result["success"];
      dataResult.message = result["message"];
    } else {
      dataResult.success = false;
      dataResult.message = response.body;
    }
    return dataResult;
  }

  static Future<Result> delete(id) async {
    return BaseService.delete(url, id);
  }
}
