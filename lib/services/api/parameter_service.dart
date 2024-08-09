import 'dart:convert';

import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:http/http.dart' as http;

class ParameterService {
  static String url = "${apiUrlOut}Parameter";

  static Future<List<Parameter>?> getParametersbyType(int type) async {
    var uri = Uri.parse("$url/parametersbytype?type=$type");
    var client = http.Client();
    var response = await client.get(uri);
    client.close();
    if (response.statusCode == 200) {
      var result = json.decode(response.body) as Map<String, dynamic>;
      print("parametreler");
      print(json.encode(result["data"]));
      var list = List<Parameter>.from(
        (result["data"] as List<dynamic>)
            .map((e) => Parameter.fromMap(e as Map<String, dynamic>)),
      );
      return list;
    }
    return null;
  }
}
