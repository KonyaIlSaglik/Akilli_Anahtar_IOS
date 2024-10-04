import 'dart:convert';

import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/entities/user_device.dart';
import 'package:akilli_anahtar/entities/user_organisation.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class UserService {
  static String url = "$apiUrlOut/User";

  static Future<User?> get(int id) async {
    return BaseService.get2(
      "/get?id=",
      (json) => User.fromJson(json),
    );
  }

  static Future<User?> getbyUserName(String userName) async {
    return BaseService.get2(
      "$url/getByUserName?userName=$userName",
      (json) => User.fromJson(json),
    );
  }

  static Future<List<User>?> getAll() async {
    return BaseService.get2(
      "$url/getAll",
      (json) => User.fromJsonList(json),
    );
  }

  static Future<User?> register(User user) async {
    return BaseService.add2(
      "$url/register",
      user.toJson(),
      (json) => User.fromJson(json),
    );
  }

  static Future<User?> update(User user) async {
    return BaseService.add2(
      "$url/register",
      user.toJson(),
      (json) => User.fromJson(json),
    );
  }

  static Future<bool> passwordUpdate(int id, String password) async {
    var requestBody = {
      'id': id,
      'password': password,
    };
    return BaseService.update2(
        url, json.encode(requestBody), (json) => json.contains("true"));
  }

  static Future<User> delete(id) async {
    return BaseService.delete2(
      "$url/delete?id=$id",
      (json) => User.fromJson(json),
    );
  }

  static Future<OperationClaim?> addClaim(int userId, int claimId) async {
    var requestBody = {
      'userId': userId,
      'claimId': claimId,
    };
    return BaseService.add2(
      "$url/addClaim?userId=$userId&claimId=$claimId",
      json.encode(requestBody),
      (json) => OperationClaim.fromJson(json),
    );
  }

  static Future<OperationClaim> deleteClaim(int userClaimId) async {
    return BaseService.delete2(
      "$url/deleteClaim?userClaimId=$userClaimId",
      (json) => OperationClaim.fromJson(json),
    );
  }

  static Future<UserDevice?> addDevice(int userId, int deviceId) async {
    var requestBody = {
      'userId': userId,
      'deviceId': deviceId,
    };
    return BaseService.add2(
      "$url/addDevice?userId=$userId&deviceId=$deviceId",
      json.encode(requestBody),
      (json) => UserDevice.fromJson(json),
    );
  }

  static Future<UserDevice> deleteUserDevice(int userDeviceId) async {
    return BaseService.delete2(
      "$url/deleteUserDevice?userDeviceId=$userDeviceId",
      (json) => UserDevice.fromJson(json),
    );
  }

  static Future<UserOrganisation?> addUserOrganisation(
      int userId, int organisationId) async {
    var requestBody = {
      'userId': userId,
      'organisationId': organisationId,
    };
    return BaseService.add2(
      "$url/addUserOrganisation?userId=$userId&organisationId=$organisationId",
      json.encode(requestBody),
      (json) => UserOrganisation.fromJson(json),
    );
  }

  static Future<UserOrganisation> deleteOrganisation(
      int userOrganisationId) async {
    return BaseService.delete2(
      "$url/deleteUserOrganisation?userOrganisationId=$userOrganisationId",
      (json) => UserOrganisation.fromJson(json),
    );
  }
}
