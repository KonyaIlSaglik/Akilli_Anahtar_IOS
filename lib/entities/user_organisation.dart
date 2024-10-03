import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserOrganisation {
  int id;
  int userId;
  int organisationId;
  UserOrganisation({
    this.id = 0,
    this.userId = 0,
    this.organisationId = 0,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'organisationId': organisationId,
    };
  }

  factory UserOrganisation.fromMap(Map<String, dynamic> map) {
    return UserOrganisation(
      id: map['id'] != null ? map['id'] as int : 0,
      userId: map['userId'] != null ? map['userId'] as int : 0,
      organisationId:
          map['organisationId'] != null ? map['organisationId'] as int : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserOrganisation.fromJson(String source) =>
      UserOrganisation.fromMap(json.decode(source) as Map<String, dynamic>);
}
