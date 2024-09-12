import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String apiUrlIn = "http://10.42.42.19:81/api";
const String apiUrlOut = "https://wss.ossbs.com/AkilliAnahtar/api";
const String tokenModelKey = "tokenModel";
const String userKey = "user";
const String loginModelKey = "loginModel";
const String userClaimsKey = "userClaims";
const String favoritesKey = "favorites";
const String lastPageKey = "lastPage";
const Color goldColor = Color(0xffb49664);
//const Color mainColor = Color.fromARGB(255, 180, 150, 100);
const String gizlilikUrl = "https://ossbs.com/gizlilik/index.htm";

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
