import 'package:firebase_database/firebase_database.dart';
import 'package:akilli_anahtar/models/notification_db_model.dart';

class NotificationController {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<List<NotificationDbModel>> fetchNotifications({
    required String userId,
    required String dateKey,
  }) async {
    final snapshot = await _db
        .child('notifications/$userId/$dateKey')
        .orderByChild('received_at_epoch')
        .limitToLast(100)
        .get();

    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final List<NotificationDbModel> list = data.entries.map((entry) {
        final map = Map<String, dynamic>.from(entry.value);
        return NotificationDbModel.fromFirebase(entry.key, dateKey, map);
      }).toList();

      list.sort(
          (a, b) => (b.receivedAtEpoch ?? 0).compareTo(a.receivedAtEpoch ?? 0));
      return list;
    }
    return [];
  }

  Future<List<String>> fetchAvailableDates(String userId) async {
    final snapshot =
        await _db.child('notifications/$userId').orderByKey().get();

    if (snapshot.exists) {
      return snapshot.children.map((e) => e.key!).toList().reversed.toList();
    }
    return [];
  }
}
