import 'package:akilli_anahtar/entities/city.dart';
import 'package:akilli_anahtar/entities/district.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/entities/user_organisation.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class HomeService {
  static String url = "$apiUrlOut/Home";

  static Future<City?> getCity(int id) async {
    var response = await BaseService.get(
      "$url/getCity?id=$id",
    );
    if (response.statusCode == 200) {
      return City.fromJson(response.body);
    }
    return null;
  }

  static Future<List<City>?> getAllCity() async {
    var response = await BaseService.get(
      "$url/getAllCity",
    );
    if (response.statusCode == 200) {
      return City.fromJsonList(response.body);
    }
    return null;
  }

  static Future<District?> getDistrict(int id) async {
    var response = await BaseService.get(
      "$url/getDistrict?id=$id",
    );
    if (response.statusCode == 200) {
      return District.fromJson(response.body);
    }
    return null;
  }

  static Future<List<District>?> getAllDistrict() async {
    var response = await BaseService.get(
      "$url/getAllDistrict",
    );
    if (response.statusCode == 200) {
      return District.fromJsonList(response.body);
    }
    return null;
  }

  static Future<OperationClaim?> getOperationClaim(int id) async {
    var response = await BaseService.get(
      "$url/getOperationClaim?id=$id",
    );
    if (response.statusCode == 200) {
      return OperationClaim.fromJson(response.body);
    }
    return null;
  }

  static Future<List<OperationClaim>?> getAllOperationClaim() async {
    var response = await BaseService.get(
      "$url/getAllOperationClaim",
    );
    if (response.statusCode == 200) {
      return OperationClaim.fromJsonList(response.body);
    }
    return null;
  }

  static Future<Organisation?> getOrganisation(int id) async {
    var response = await BaseService.get(
      "$url/getOrganisation?id=$id",
    );
    if (response.statusCode == 200) {
      return Organisation.fromJson(response.body);
    }
    return null;
  }

  static Future<List<Organisation>?> getAllOrganisation() async {
    var response = await BaseService.get(
      "$url/getAllOrganisation",
    );
    if (response.statusCode == 200) {
      return Organisation.fromJsonList(response.body);
    }
    return null;
  }

  static Future<List<UserOrganisation>?> getUserOrganisationsByOrganisationId(
      int organisationId) async {
    var response = await BaseService.get(
      "$url/getUserOrganisationsByOrganisationId?organisationId=$organisationId",
    );
    if (response.statusCode == 200) {
      return UserOrganisation.fromJsonList(response.body);
    }
    return null;
  }
}
