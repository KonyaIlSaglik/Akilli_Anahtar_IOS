import 'dart:convert';
import 'package:akilli_anahtar/dtos/bm_box_dto.dart';
import 'package:akilli_anahtar/dtos/bm_organisation_dto.dart';
import 'package:akilli_anahtar/dtos/organisation_dto.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:http/http.dart' as http;

class BoxManagementService {
  static String url = "$apiUrlOut/BoxManagement";

  static Future<List<BmBoxDto>?> getBoxes(int userId) async {
    var response = await BaseService.get(
      "$url/getAllBox?userId=$userId",
    );
    if (response.statusCode == 200) {
      return BmBoxDto.fromJsonList(response.body);
    }
    return null;
  }

  static Future<List<BmOrganisationDto>?> getOrganisations(int userId) async {
    var response = await BaseService.get(
      "$url/getAllOrganisation?userId=$userId",
    );
    if (response.statusCode == 200) {
      return BmOrganisationDto.fromJsonList(response.body);
    }
    return null;
  }

  static Future<void> createOrganisation(OrganisationDto organisation) async {
    final uri = Uri.parse("$url/createOrganisation");
    var client = http.Client();
    try {
      var response = await client.post(
        uri,
        headers: {'content-type': 'application/json'},
        body: json.encode(organisation.toJson(forCreate: true)),
      );
      client.close();

      if (response.statusCode == 200) {
        print("Yeni Organizasyon Eklendi.");
        successSnackbar("Başarılı", "Organizasyon Oluşturuldu.");
      } else {
        print("organizasyon oluşmadı hatası: ${response.body}");
        errorSnackbar("Hata", "Organizasyon Oluşturulamadı.");
      }
    } catch (e) {
      print("organizasyon oluşturma başarısız.: $e");
    }
  }

  static Future<void> updateOrganisation(OrganisationDto organisation) async {
    final uri = Uri.parse("$url/updateOrganisation");
    var client = http.Client();
    try {
      var response = await client.put(
        uri,
        headers: {'content-type': 'application/json'},
        body: json.encode(organisation.toJson()),
      );
      if (response.statusCode == 200) {
        //successSnackbar("Başarılı", "Organizasyon Güncellemesi Başarılı.");
        print("Organizasyon güncellendi");
      } else {
        //errorSnackbar("Hata", "Organizasyon Güncellenemedi.");
      }
    } catch (e) {
      print("organizasyon güncellenemedi: $e");
    }
  }

  static Future<OrganisationDto?> getOrganisation(int id) async {
    final res = await BaseService.get("$url/getOrganisation?id=$id");
    if (res.statusCode == 200) {
      return OrganisationDto.fromJsonString(res.body);
    }
    return null;
  }
}
