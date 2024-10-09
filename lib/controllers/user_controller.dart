// import 'package:akilli_anahtar/entities/user.dart';
// import 'package:akilli_anahtar/services/api/user_service.dart';
// import 'package:get/get.dart';
// import 'package:turkish/turkish.dart';

// class UserController extends GetxController {
//   var loadingUser = false.obs;
//   var users = <User>[].obs;

//   Future<void> getAll() async {
//     loadingUser.value = true;
//     var result = await UserService.getAll();
//     if (result != null) {
//       users.value = result;
//       sort();
//       loadingUser.value = false;
//     }
//   }

//   void sort() {
//     users.sort((a, b) =>
//         a.fullName.toLowerCaseTr().compareToTr(b.fullName.toLowerCaseTr()));
//   }

//   Future<void> copySelectedUser() async {
//     // var addedUserResult = await UserService.register(RegisterModel(
//     //   userName: "Kopya(${selectedUser.value.userName})",
//     //   fullName: selectedUser.value.fullName,
//     //   email: selectedUser.value.mail,
//     //   password: "12345",
//     //   tel: selectedUser.value.telephone,
//     // ));

//     // if (addedUserResult.success) {
//     //   users.add(addedUserResult.data!);
//     //   selectedUser.value = addedUserResult.data!;

//     //   var copyUserDevices = <UserDevice>[];
//     //   for (UserDevice userDevice in selectedUserDevices) {
//     //     var added = await UserDeviceService.add(
//     //         userDevice.copyWith(id: 0, userId: selectedUser.value.id));
//     //     if (added.success) {
//     //       copyUserDevices.add(added.data!);
//     //     }
//     //   }
//     //   selectedUserDevices.value = copyUserDevices;

//     //   var copyUserClaims = <UserOperationClaim>[];
//     //   for (UserOperationClaim claim in selectedUserClaims) {
//     //     var added = await UserOperationClaimService.add(
//     //         claim.copyWith(id: 0, userId: selectedUser.value.id));
//     //     if (added.success) {
//     //       copyUserClaims.add(added.data!);
//     //     }
//     //   }
//     //   selectedUserClaims.value = copyUserClaims;
//     // }
//   }
// }
