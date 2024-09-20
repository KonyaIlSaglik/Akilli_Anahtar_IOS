import 'dart:convert';

import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class OperationClaimService {
  static String url = "$apiUrlOut/OperationClaim";

  static Future<OperationClaim?> get(int id) async {
    var response = await BaseService.get(url, id);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var operationClaim = OperationClaim.fromJson(json.encode(result["data"]));
      return operationClaim;
    }
    return null;
  }

  static Future<List<OperationClaim>?> getAll() async {
    var response = await BaseService.getAll(url);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var operationClaimList = List<OperationClaim>.from(
          (result["data"] as List<dynamic>)
              .map((e) => OperationClaim.fromJson(json.encode(e))));
      return operationClaimList;
    }
    return null;
  }

  static Future<Result> add(OperationClaim operationClaim) async {
    return BaseService.add(url, operationClaim.toJson());
  }

  static Future<Result> update(OperationClaim operationClaim) async {
    return BaseService.update(url, operationClaim.toJson());
  }

  static Future<Result> delete(int id) async {
    return BaseService.delete(url, id);
  }
}
