// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserOperationClaim {
  int id;
  int userId;
  int operationClaimId;
  UserOperationClaim({
    this.id = 0,
    this.userId = 0,
    this.operationClaimId = 0,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'operationClaimId': operationClaimId,
    };
  }

  factory UserOperationClaim.fromMap(Map<String, dynamic> map) {
    return UserOperationClaim(
      id: map['id'] as int,
      userId: map['userId'] as int,
      operationClaimId: map['operationClaimId'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserOperationClaim.fromJson(String source) =>
      UserOperationClaim.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<UserOperationClaim> fromJsonList(String source) =>
      List<UserOperationClaim>.from((json.decode(source) as List<dynamic>)
          .map((x) => UserOperationClaim.fromJson(json.encode(x))));

  UserOperationClaim copyWith({
    int? id,
    int? userId,
    int? operationClaimId,
  }) {
    return UserOperationClaim(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      operationClaimId: operationClaimId ?? this.operationClaimId,
    );
  }
}
