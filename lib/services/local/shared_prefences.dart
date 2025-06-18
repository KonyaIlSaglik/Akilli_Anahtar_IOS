import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDb {
  static Future<String?> get(String key) async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  static Future<List<String>?> getStringList(String key) async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getStringList(key);
  }

  static Future<bool> add(String key, String value) async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString(key, value);
  }

  static Future<bool> addStringList(String key, List<String> value) async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setStringList(key, value);
  }

  static Future<bool> delete(String key) async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.remove(key);
  }

  static Future<bool> update(String key, String value) async {
    WidgetsFlutterBinding.ensureInitialized();
    await delete(key);
    return add(key, value);
  }

  static Future<bool> clear() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.clear();
  }
}
