import 'dart:convert';

import 'package:akilli_anahtar/utils/hive_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'parameter.g.dart';

@HiveType(typeId: HiveConstants.parametersTypeId)
class Parameter {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String value;

  @HiveField(3)
  int type;

  Parameter({
    required this.id,
    required this.name,
    required this.value,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'value': value,
      'type': type,
    };
  }

  factory Parameter.fromMap(Map<String, dynamic> map) {
    return Parameter(
      id: map['id'] as int,
      name: map['name'] as String,
      value: map['value'] as String,
      type: map['type'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Parameter.fromJson(String source) =>
      Parameter.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<Parameter> fromJsonList(String source) =>
      List<Parameter>.from((json.decode(source) as List<dynamic>)
          .map((x) => Parameter.fromJson(json.encode(x))));
}
