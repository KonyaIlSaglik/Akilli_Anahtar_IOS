import 'package:akilli_anahtar/dtos/um_device_dto.dart';
import 'package:akilli_anahtar/dtos/um_organisation_dto.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class UserManagementService {
  static String url = "$apiUrlOut/UserManagement";

  static Future<List<UmDeviceDto>?> getAllDevices(int userId) async {
    var response = await BaseService.get(
      "$url/getAllDevices?userId=$userId",
    );
    if (response.statusCode == 200) {
      return UmDeviceDto.fromJsonList(response.body);
    }
    return null;
  }

  static Future<bool> addUserDevice(int userId, deviceId) async {
    var response = await BaseService.post(
      "$url/addUserDevice?userId=$userId&deviceId=$deviceId",
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<bool> deleteUserDevice(int userId, deviceId) async {
    var response = await BaseService.post(
      "$url/deleteUserDevice?userId=$userId&deviceId=$deviceId",
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<List<UmOrganisationDto>?> getAllOrganisations(
      int userId) async {
    var response = await BaseService.get(
      "$url/getAllOrganisations?userId=$userId",
    );
    if (response.statusCode == 200) {
      return UmOrganisationDto.fromJsonList(response.body);
    }
    return null;
  }

  static Future<bool> addUserOrganisation(int userId, organisationId) async {
    var response = await BaseService.post(
      "$url/addUserOrganisation?userId=$userId&organisationId=$organisationId",
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<bool> deleteUserOrganisation(int userId, organisationId) async {
    var response = await BaseService.post(
      "$url/deleteUserOrganisation?userId=$userId&organisationId=$organisationId",
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
