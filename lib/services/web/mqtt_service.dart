// ignore_for_file: invalid_use_of_protected_member

import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:platform_device_id/platform_device_id.dart';

import 'mqtt_listener.dart';

class MqttService {
  static MqttServerClient? client;
  static MqttConnectionState? state;
  static IMqttConnListener? listener;

  static Future<MqttConnectionState?> connect() async {
    state = MqttConnectionState.disconnected;
    client = null;
    var deviceId = await PlatformDeviceId.getDeviceId;
    var now = DateTime.now().toString();
    var identifier = "$deviceId-$now";
    client = MqttServerClient("red.oss.net.tr", identifier);
    //client!.logging(on: true);
    client!.port = 1883;
    client!.keepAlivePeriod = 60;
    client!.autoReconnect = true;
    client!.resubscribeOnAutoReconnect = true;
    client!.onConnected = onConnected;
    client!.onDisconnected = onDisconnected;
    client!.onSubscribed = onSubscribed;
    client!.onSubscribeFail = onSubscribeFail;
    client!.onUnsubscribed = onUnsubscribed;
    client!.onAutoReconnect = onAutoReconnect;
    client!.onAutoReconnected = onAutoReconnected;
    client!.pongCallback = pongCallback;
    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs("mcan", "admknh06")
        .startClean()
        .withClientIdentifier(identifier)
        .withWillQos(MqttQos.atMostOnce);
    client!.connectionMessage = connMess;
    var response = await client!.connect();
    print("Connecting...");
    state = response!.state;
    return state;
  }

  static void disconnect() {
    if (client != null) {
      client!.disconnect();
    }
    client = null;
  }

  static void subscribe(String topic) {
    client!.subscribe(topic, MqttQos.atLeastOnce);
  }

  static void unSubscribe(String topic) {
    client!.subscriptionsManager!.unsubscribeTopic(topic);
    print("$topic unSubscribe");
  }

  static void onConnected() {
    state = MqttConnectionState.connected;
    print('Connected');
  }

  static void onDisconnected() {
    state = MqttConnectionState.disconnected;
    print('Disconnected');
  }

  static void onAutoReconnect() {
    print("onAutoReconnect");
  }

  static void onAutoReconnected() {
    print("onAutoReconnected");
  }

  static void onSubscribed(MqttSubscription sub) {
    print("${sub.topic} Subscribed.");
  }

  static void onSubscribeFail(MqttSubscription sub) {
    print("${sub.topic} SubscribeFail.");
  }

  static void onUnsubscribed(MqttSubscription sub) {
    print("${sub.topic} Unsubscribed.");
  }

  static void pongCallback() {
    print("pongCallback");
  }

  static void publishMessage(String topic, String message) {
    var builder = MqttPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
    print("$message gönderildi.. $topic ....");
  }
}
