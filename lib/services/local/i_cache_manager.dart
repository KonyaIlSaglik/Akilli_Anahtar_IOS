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
    }
    if (!(box?.isOpen ?? false)) {
      box = await Hive.openBox<T>(key);
    }
  }

  Future<void> add(T value) async {
    var result = await box?.add(value);
  }

  Future<void> addList(List<T> values) async {
    await box?.addAll(values);
  }

  T? get() {
    if (box!.values.isNotEmpty) {
      return box?.values.first;
    }
    return null;
  }

  List<T>? getAll() {
    return box?.values.toList();
  }

  Future<void> clear() async {
    await box?.clear();
  }
}
