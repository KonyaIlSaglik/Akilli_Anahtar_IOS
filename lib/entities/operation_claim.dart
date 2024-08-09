import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class OperationClaim {
  int id;
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
      List<OperationClaim>.from(json
          .decode(source)
          .map((x) => OperationClaim.fromJson(json.encode(x))));
}
