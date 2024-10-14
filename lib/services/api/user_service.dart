import 'dart:convert';

import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/entities/user_device.dart';
import 'package:akilli_anahtar/entities/user_operation_claim.dart';
import 'package:akilli_anahtar/entities/user_organisation.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class UserService {
  static String url = "$apiUrlOut/User";

  static Future<User?> get(int id) async {
    var response = await BaseService.get(
      "/get?id=",
    );
    if (response.statusCode == 200) {
      return User.fromJson(response.body);
    }
    return null;
  }

  static Future<User?> getbyUserName(String userName) async {
    var response = await BaseService.get(
      "$url/getByUserName?userName=$userName",
    );
    if (response.statusCode == 200) {
      return User.fromJson(response.body);
    }
    return null;
  }

  static Future<List<User>?> getAll() async {
    var response = await BaseService.get(
      "$url/getAll",
    );
    if (response.statusCode == 200) {
      return User.fromJsonList(response.body);
    }
    return null;
  }

  static Future<User?> register(User user) async {
    var response = await BaseService.add(
      "$url/register",
      user.toJson(),
    );
    if (response.statusCode == 200) {
      return User.fromJson(response.body);
    }
    return null;
  }

  static Future<User?> saveAs(User user) async {
    var response = await BaseService.add(
      "$url/saveAs",
      user.toJson(),
    );
    if (response.statusCode == 200) {
      return User.fromJson(response.body);
    }
    return null;
  }

  static Future<User?> update(User user) async {
    var response = await BaseService.update(
      "$url/update",
      user.toJson(),
    );
    if (response.statusCode == 200) {
      return User.fromJson(response.body);
    }
    return null;
  }

  static Future<bool> passwordUpdate(int id, String password) async {
    var requestBody = {
      'id': id,
      'password': password,
    };
    print(json.encode(requestBody));
    var response = await BaseService.update(
        "$url/passwordUpdate?id=$id&password=$password", null);
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
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

  static Future<List<UserOperationClaim>?> getUserClaims(int userId) async {
    var response = await BaseService.get(
      "$url/getUserClaims?userId=$userId",
    );
    if (response.statusCode == 200) {
      return UserOperationClaim.fromJsonList(response.body);
    }
    return null;
  }

  static Future<UserOperationClaim?> addUserClaim(
      int userId, int claimId) async {
    var requestBody = {
      'userId': userId,
      'claimId': claimId,
    };
    var response = await BaseService.add(
      "$url/addUserClaim?userId=$userId&claimId=$claimId",
      json.encode(requestBody),
    );
    if (response.statusCode == 200) {
      return UserOperationClaim.fromJson(response.body);
    }
    return null;
  }

  static Future<bool> deleteUserClaim(int userClaimId) async {
    var response = await BaseService.delete(
      "$url/deleteUserClaim?userClaimId=$userClaimId",
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<List<UserDevice>?> getUserDevices(int userId) async {
    var response = await BaseService.get(
      "$url/getUserDevices?userId=$userId",
    );
    if (response.statusCode == 200) {
      return UserDevice.fromJsonList(response.body);
    }
    return null;
  }

  static Future<UserDevice?> addUserDevice(int userId, int deviceId) async {
    var requestBody = {
      'userId': userId,
      'deviceId': deviceId,
    };
    var response = await BaseService.add(
      "$url/addUserDevice?userId=$userId&deviceId=$deviceId",
      json.encode(requestBody),
    );
    if (response.statusCode == 200) {
      return UserDevice.fromJson(response.body);
    }
    return null;
  }

  static Future<bool> deleteUserDevice(int userDeviceId) async {
    var response = await BaseService.delete(
      "$url/deleteUserDevice?userDeviceId=$userDeviceId",
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<List<UserOrganisation>?> getUserOrganisations(
      int userId) async {
    var response = await BaseService.get(
      "$url/getUserOrganisations?userId=$userId",
    );
    if (response.statusCode == 200) {
      return UserOrganisation.fromJsonList(response.body);
    }
    return null;
  }

  static Future<UserOrganisation?> addUserOrganisation(
      int userId, int organisationId) async {
    var requestBody = {
      'userId': userId,
      'organisationId': organisationId,
    };
    var response = await BaseService.add(
      "$url/addUserOrganisation?userId=$userId&organisationId=$organisationId",
      json.encode(requestBody),
    );
    if (response.statusCode == 200) {
      return UserOrganisation.fromJson(response.body);
    }
    return null;
  }

  static Future<bool> deleteUserOrganisation(int userOrganisationId) async {
    var response = await BaseService.delete(
      "$url/deleteUserOrganisation?userOrganisationId=$userOrganisationId",
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
