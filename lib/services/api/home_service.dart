import 'dart:convert';
import 'dart:io';

import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/entities/city.dart';
import 'package:akilli_anahtar/entities/district.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/entities/user_organisation.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

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

  // yeni  //  ////////////////////////////

  static Future<List<Parameter>?> getParameters(int typeId) async {
    var response = await BaseService.get(
      "$url/getParameters?typeId=$typeId",
    );
    if (response.statusCode == 200) {
      return Parameter.fromJsonList(response.body);
    }
    return null;
  }

  static Future<List<HomeDeviceDto>?> getDevices(int userId) async {
    var response = await BaseService.get(
      "$url/getDevices?userId=$userId",
    );
    if (response.statusCode == 200) {
      return HomeDeviceDto.fromJsonList(response.body);
    }
    return null;
  }

  static Future<bool?> updateFavoriteSequence(
      int userId, int deviceId, int sequence) async {
    var path =
        "$url/updateFavoriteSequence?userId=$userId&deviceId=$deviceId&sequence=$sequence";
    var response = await BaseService.put(path);
    if (response.statusCode == 200) {
      return true;
    }
    return null;
  }

  static Future<bool?> updateFavoriteName(
      int userId, int deviceId, String? name) async {
    var response = await BaseService.put(
        "$url/updateFavoriteName?userId=$userId&deviceId=$deviceId&name=$name");
    if (response.statusCode == 200) {
      return true;
    }
    return null;
  }

  static Future<List<dynamic>?> fetchSensorMessages({
    int? organisationId,
    int? boxId,
    bool onlyAlarms = false,
    String? period,
    required String token,
  }) async {
    try {
      final query = {
        if (organisationId != null) "organisationId": organisationId.toString(),
        if (boxId != null) "boxId": boxId.toString(),
        "onlyAlarms": onlyAlarms.toString(),
        if (period != null) "period": period,
      };

      final qs = Uri(queryParameters: query).query;

      final response = await BaseService.get(
        '$url/getSensorMessagesReport?$qs',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        print('Hata: ${response.statusCode} - ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('İstek hatası: $e');
      return null;
    }
  }

  static Future<String?> downloadSensorReport({
    required BuildContext context,
    required String exportType,
    required String fileName,
    int? organisationId,
    int? boxId,
    bool onlyAlarms = false,
    String? period,
    required String token,
  }) async {
    try {
      final query = {
        if (organisationId != null) "organisationId": organisationId.toString(),
        if (boxId != null) "boxId": boxId.toString(),
        "onlyAlarms": onlyAlarms.toString(),
        if (period != null) "period": period,
        "export": exportType,
      };

      final qs = Uri(queryParameters: query).query;

      final response = await BaseService.get(
        '$url/getSensorMessagesReport?$qs',
      );

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return filePath;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Dosya indirilemedi (${response.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İndirme hatası: $e')),
      );
    }
  }
}
