import 'package:hive_flutter/hive_flutter.dart';

class CacheManager<T> {
  final String key;
  final int typeId;
  final TypeAdapter<T> adapter;
  Box<T>? box;

  CacheManager(this.key, this.typeId, this.adapter);

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter(adapter);
      print("$key: registered");
    } else {
      print("$key: already registered");
    }
    if (!(box?.isOpen ?? false)) {
      box = await Hive.openBox<T>(key);
      print("$key: opened");
    } else {
      print("$key: box already opened");
    }
  }

  Future<void> add(T value) async {
    var result = await box?.add(value);
    print("$key: value added to box");
  }

  Future<void> addList(List<T> values) async {
    await box?.addAll(values);
    print("$key: values added to box");
  }

  T? get() {
    if (box!.values.isNotEmpty) {
      print("$key: value getted");
      return box?.values.first;
    }
    print("$key: value empty");
    return null;
  }

  List<T>? getAll() {
    print("$key: values getted");
    return box?.values.toList();
  }

  Future<void> clear() async {
    print("$key: box cleaned");
    await box?.clear();
  }
}
