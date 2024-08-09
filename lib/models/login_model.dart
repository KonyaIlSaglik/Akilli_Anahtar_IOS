import 'dart:convert';

class LoginModel {
  String userName;
  String password;
  LoginModel({
    this.userName = "",
    this.password = "",
  });

  LoginModel copyWith({
    String? userName,
    String? password,
  }) {
    return LoginModel(
      userName: userName ?? this.userName,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userName': userName,
      'password': password,
    };
  }

  factory LoginModel.fromMap(Map<String, dynamic> map) {
    return LoginModel(
      userName: map['userName'] as String,
      password: map['password'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginModel.fromJson(String source) =>
      LoginModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'LoginModel(userName: $userName, password: $password)';

  @override
  bool operator ==(covariant LoginModel other) {
    if (identical(this, other)) return true;

    return other.userName == userName && other.password == password;
  }

  @override
  int get hashCode => userName.hashCode ^ password.hashCode;
}
