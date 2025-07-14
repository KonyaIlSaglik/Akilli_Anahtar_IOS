import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class ParameterService {
  static String url = "$apiUrlOut/Parameter";

  static Future<List<Parameter>?> getAllByTypeId(int id) async {
    var response = await BaseService.get(
      "$url/getAllByTypeId?id=$id",
    );
    if (response.statusCode == 200) {
      return Parameter.fromJsonList(response.body);
    }
    return null;
  }
}
