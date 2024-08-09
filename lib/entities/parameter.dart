import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Parameter {
  int id;
  String name;
  String value;
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
}
