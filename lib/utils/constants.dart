import 'dart:convert';
import 'dart:io';
import 'package:akilli_anahtar/pages/new_home/body/favorite_page.dart';
import 'package:akilli_anahtar/pages/new_home/body/test_body.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:another_flushbar/flushbar.dart';

const String apiUrlIn = "http://10.42.41.36:85/api";
const String apiUrlOut = "https://wss.ossbs.com/AkilliAnahtarApi/api";
const String sessionKey = "session";
const String userKey = "user";
const String loginModelKey = "loginModel";
const String userClaimsKey = "userClaims";
const String favoritesKey = "favorites";
const String lastPageKey = "lastPage";
const Color goldColor = Color(0xffb49664);
//const Color mainColor = Color.fromARGB(255, 180, 150, 100);
const String gizlilikUrl = "https://ossbs.com/gizlilik/index.htm";

Future<void> checkNewVersion(context, showForce) async {
  VersionStatus? versionStatus = await NewVersionPlus().getVersionStatus();
  if (versionStatus != null && (versionStatus.canUpdate || showForce)) {
    NewVersionPlus().showUpdateDialog(
      allowDismissal: !versionStatus.canUpdate,
      dismissButtonText: versionStatus.canUpdate ? "" : "Kapat",
      updateButtonText: versionStatus.canUpdate ? "Güncelle" : "Mağazaya git",
      dialogTitle: versionStatus.canUpdate
          ? "Yeni Güncelleme Bulundu"
          : "Uygulamanız Güncel",
      dialogText: versionStatus.canUpdate
          ? "Mevcut Versiyon: ${versionStatus.localVersion}\nGüncel Versiyon: ${versionStatus.storeVersion}\n\nSürüm Notları:\n\t${versionStatus.releaseNotes}"
          : "Daha sonra tekrar kontrol edin",
      context: context,
      versionStatus: versionStatus,
    );
  }
}

Future<String> getDeviceId() async {
  var info = DeviceInfoPlugin();
  String deviceId = "";
  if (Platform.isAndroid) {
    var androidInfo = await info.androidInfo;
    deviceId = androidInfo.id;
  }
  if (Platform.isIOS) {
    var iosInfo = await info.iosInfo;
    deviceId =
        iosInfo.identifierForVendor ?? "${iosInfo.name}-${iosInfo.model}";
  }
  return deviceId;
}

Future<String> getDeviceName() async {
  var info = DeviceInfoPlugin();
  String deviceName = "";
  if (Platform.isAndroid) {
    var androidInfo = await info.androidInfo;
    deviceName = "${androidInfo.brand} ${androidInfo.model}";
  }
  if (Platform.isIOS) {
    var iosInfo = await info.iosInfo;
    deviceName = "I Phone ${iosInfo.name}";
  }
  return deviceName;
}

bool isJson(String data) {
  try {
    json.decode(data);
    return true;
  } catch (e) {
    return false;
  }
}

String getDate(String isoDate) {
  // Parse the ISO 8601 string to DateTime
  DateTime dateTime = DateTime.parse(isoDate);

  // Format the DateTime to the desired format
  String formattedDate = DateFormat('dd.MM.yyyy').format(dateTime);

  return formattedDate;
}

String getTime(String isoDate) {
  // Parse the ISO 8601 string to DateTime
  DateTime dateTime = DateTime.parse(isoDate);

  // Format the DateTime to the desired format
  String formattedDate = DateFormat('HH:mm').format(dateTime);

  return formattedDate;
}

exitApp(context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Çıkış"),
        content: Text("Uygulama kapatılsın mı?"),
        actions: [
          TextButton(
            child: Text(
              'Vazgeç',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              'Kapat',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              exit(0);
            },
          ),
        ],
      );
    },
  );
}

void successBar(BuildContext context, String title, String message) {
  Flushbar(
    title: title,
    message: message,
    backgroundColor: Colors.green,
    titleColor: Colors.white,
    messageColor: Colors.white,
    flushbarPosition: FlushbarPosition.TOP,
    duration: Duration(seconds: 10),
    icon: Icon(
      Icons.done_outline,
      color: Colors.white,
    ),
  ).show(context);
}

errorSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    backgroundColor: Colors.red.withOpacity(0.75),
    colorText: Colors.white,
    icon: Icon(Icons.dangerous_outlined, color: Colors.white),
  );
}

successSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    backgroundColor: Colors.green.withOpacity(0.75),
    colorText: Colors.white,
    icon: Icon(
      Icons.done_outline,
      color: Colors.white,
    ),
  );
}

infoSnackbar(String title, String message) {
  Get.snackbar(
    title,
    message,
    backgroundColor: Colors.blue.withOpacity(0.75),
    colorText: Colors.white,
    icon: Icon(
      Icons.info_outline,
      color: Colors.white,
    ),
  );
}

Color primaryColor = Colors.deepPurple[900]!;
const double minWidth = 361;
TextTheme textTheme(context) => Theme.of(context).textTheme;
width(context) => MediaQuery.sizeOf(context).width;
height(context) => MediaQuery.sizeOf(context).height;

const String testPage = "test";
const String favoritePage = "favorites";

const Map<String, Widget> pagesList = {
  testPage: TestBody(),
  favoritePage: FavoritePage(),
  //ziyaretlerPage: Ziyaretler(),
};
