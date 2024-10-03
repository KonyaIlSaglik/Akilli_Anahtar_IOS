import 'package:intl/intl.dart';

class VersionModel {
  String version;
  String date;

  VersionModel({
    this.version = "",
    this.date = "",
  });

  factory VersionModel.fromString(String data) {
    // string -->  Ver:1.13-01.09.2023_11.30
    print(data);
    var model = VersionModel();
    if (data.contains(":")) {
      data = data.split(":")[1];
      model.version = data.split("-")[0];
      String formattedString = data.split("-")[1].replaceAll('_', ' ');
      DateFormat dateFormat = DateFormat('dd.MM.yyyy HH.mm');
      DateTime dd = dateFormat.parse(formattedString);
      model.date = DateFormat("dd.MM.yyyy HH:mm").format(dd);
    }
    return model;
  }
}
