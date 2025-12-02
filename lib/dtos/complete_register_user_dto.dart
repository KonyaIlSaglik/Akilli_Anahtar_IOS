class CompleteRegisterUserDto {
  final int userId;
  final String fullName;
  final String telephone;
  final String password;

  CompleteRegisterUserDto({
    required this.userId,
    required this.fullName,
    required this.telephone,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "fullName": fullName,
        "telephone": telephone,
        "password": password,
      };
}
