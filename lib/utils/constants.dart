import 'dart:io';
import 'package:flutter/material.dart';

const String userKey = "user";
const String passwordKey = "password";
const String favoritesKey = "favorites";
const String lastPageKey = "lastPage";
const Color mainColor = Color.fromARGB(255, 180, 150, 100);
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
