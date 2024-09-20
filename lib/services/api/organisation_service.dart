import 'package:akilli_anahtar/entities/organisation.dart';
import 'dart:convert';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class OrganisationService {
  static String url = "$apiUrlOut/Organisation";
  static Future<Organisation?> get(int id) async {
    var response = await BaseService.get(url, id);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var organisation = Organisation.fromJson(json.encode(result["data"]));
      return organisation;
    }
    return null;
  }

  static Future<List<Organisation>?> getAll() async {
    var response = await BaseService.getAll(url);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var organisationList = List<Organisation>.from(
          (result["data"] as List<dynamic>)
              .map((e) => Organisation.fromJson(json.encode(e))));
      return organisationList;
    }
    return null;
  }

  static Future<Result> add(Organisation organisation) async {
    return BaseService.add(url, organisation.toJson());
  }

  static Future<Result> update(Organisation organisation) async {
    return BaseService.update(url, organisation.toJson());
  }

  static Future<Result> delete(int id) async {
    return BaseService.delete(url, id);
  }
}
