import 'dart:convert';

import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/data_result.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:http/http.dart' as http;

class UserService {
  static String url = "${apiUrlOut}User";

  static Future<User?> get(int id) async {
    var uri = Uri.parse("$url/get?userId=$id");
    var client = http.Client();
    var response = await client.get(uri);
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      var user = User.fromJson(json.encode(result["data"]));
      return user;
    }
    return null;
  }

  static Future<DataResult<List<OperationClaim>>> getClaims() async {
    var uri = Uri.parse("$url/getuserclaims");
    var client = http.Client();
    var info = await LocalDb.get(userKey);
    var user = User.fromJson(info!);
    var response = await client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
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
      dataResult.message = result["message"];
      await LocalDb.add(userClaimsKey, json.encode(result["data"]));
    } else {
      dataResult.success = false;
      dataResult.message = response.body;
    }
    return dataResult;
  }
}
