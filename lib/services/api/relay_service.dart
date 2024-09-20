import 'package:akilli_anahtar/entities/relay.dart';
import 'dart:convert';
import 'package:akilli_anahtar/models/result.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class RelayService {
  static String url = "$apiUrlOut/Relay";
  static Future<Relay?> get(int id) async {
    var response = await BaseService.get(url, id);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var relay = Relay.fromJson(json.encode(result["data"]));
      return relay;
    }
    return null;
  }

  static Future<List<Relay>?> getAll() async {
    var response = await BaseService.getAll(url);
    if (response != null) {
      var result = json.decode(response) as Map<String, dynamic>;
      var relayList = List<Relay>.from((result["data"] as List<dynamic>)
          .map((e) => Relay.fromJson(json.encode(e))));
      return relayList;
    }
    return null;
  }

  static Future<Result> add(Relay relay) async {
    return BaseService.add(url, relay.toJson());
  }

  static Future<Result> update(Relay relay) async {
    return BaseService.update(url, relay.toJson());
  }

  static Future<Result> delete(int id) async {
    return BaseService.delete(url, id);
  }
}
