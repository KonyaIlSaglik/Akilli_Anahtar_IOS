import 'package:akilli_anahtar/entities/city.dart';
import 'package:akilli_anahtar/entities/district.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class HomeService {
  static String url = "$apiUrlOut/Home";

  static Future<City?> getCity(int id) async {
    return BaseService.get2(
      "$url/getCity?id=",
      (json) => City.fromJson(json),
    );
  }

  static Future<List<City>?> getAllCity(int id) async {
    return BaseService.get2(
      "$url/getAllCity",
      (json) => City.fromJsonList(json),
    );
  }

  static Future<District?> getDistrict(int id) async {
    return BaseService.get2(
      "$url/getDistrict?id=",
      (json) => District.fromJson(json),
    );
  }

  static Future<List<District>?> getAllDistrict(int id) async {
    return BaseService.get2(
      "$url/getAllDistrict",
      (json) => District.fromJsonList(json),
    );
  }

  static Future<OperationClaim?> getOperationClaim(int id) async {
    return BaseService.get2(
      "$url/getOperationClaim?id=",
      (json) => OperationClaim.fromJson(json),
    );
  }

  static Future<List<OperationClaim>?> getAllOperationClaim(int id) async {
    return BaseService.get2(
      "$url/getAllOperationClaim",
      (json) => OperationClaim.fromJsonList(json),
    );
  }

  static Future<Organisation?> getOrganisation(int id) async {
    return BaseService.get2(
      "$url/getOrganisation?id=",
      (json) => Organisation.fromJson(json),
    );
  }

  static Future<List<Organisation>?> getAllOrganisation(int id) async {
    return BaseService.get2(
      "$url/getAllOrganisation",
      (json) => Organisation.fromJsonList(json),
    );
  }
}
