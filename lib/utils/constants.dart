import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:turkish/turkish.dart';

const String mqttHostKey = "mqttHost";
const String mqttPortKey = "mqttPort";
const String mqttUserKey = "mqttUser";
const String mqttPasswordKey = "mqttPassword";

String notificationKey(int deviceId) {
  return "notification$deviceId";
}

const String apiUrlOut =
    "http://uzak.konyasm.gov.tr:42027/AkilliAnahtarApi/api";
//const String apiUrlOut = "https://wss.ossbs.com/AkilliAnahtarApi/api";
const String userIdKey = "userId";
const String webTokenKey = "webToken";
const String userNameKey = "userName";
const String passwordKey = "password";
const String watherVisibleKey = "watherVisible";
const Color goldColor = Colors.brown;
//const Color goldColor = Color(0xffb49664);
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
  DateTime dateTime = DateTime.parse(isoDate);

  String formattedDate = DateFormat('dd.MM.yyyy').format(dateTime);

  return formattedDate;
}

String getTime(String isoDate) {
  DateTime dateTime = DateTime.parse(isoDate);
  String formattedDate = DateFormat('HH:mm').format(dateTime);

  return formattedDate;
}

String? capitalizeWords(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .split(' ') // Metni boşluklardan ayır
      .map((word) => word.isNotEmpty
          ? word[0].toUpperCaseTr() + word.toLowerCaseTr().substring(1)
          : word) // Her kelimenin ilk harfini büyük yap
      .join(' '); // Kelimeleri tekrar birleştir
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

Color primaryColor = Colors.brown[900]!;
const double minWidth = 361;
TextTheme textTheme(context) => Theme.of(context).textTheme;
width(context) => MediaQuery.sizeOf(context).width;
height(context) => MediaQuery.sizeOf(context).height;
