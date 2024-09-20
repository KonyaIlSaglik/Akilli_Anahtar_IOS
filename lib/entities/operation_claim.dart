import 'dart:convert';

import 'package:akilli_anahtar/utils/hive_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part '../hive_adapters/operation_claim.g.dart';

@HiveType(typeId: HiveConstants.claimsTypeId)
class OperationClaim {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  OperationClaim({
    this.id = 0,
    this.name = "",
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory OperationClaim.fromMap(Map<String, dynamic> map) {
    return OperationClaim(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory OperationClaim.fromJson(String source) =>
      OperationClaim.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<OperationClaim> fromJsonList(String source) =>
      List<OperationClaim>.from((json.decode(source) as List<dynamic>)
          .map((x) => OperationClaim.fromJson(json.encode(x))));

  static String toJsonList(List<OperationClaim> claims) {
    return json.encode(claims.map((c) => c.toJson()).toList());
  }
}
