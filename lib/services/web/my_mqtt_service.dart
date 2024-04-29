import 'dart:convert';

import 'package:akilli_anahtar/services/web/mqtt_listener.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:platform_device_id/platform_device_id.dart';

class MyMqttClient extends MqttServerClient {
  static MyMqttClient? _client;
  MqttConnectionState? state = MqttConnectionState.disconnected;

  IMqttConnListener? connListener;
  IMqttSubListener? subListener;

  MyMqttClient(String server, String clientIdentifier)
      : super(server, clientIdentifier);

  static MyMqttClient get instance {
    if (_client == null) {
      print("Client Oluşturuldu");
      _client = MyMqttClient("", "");
    } else {
      print("Client Bulundu");
    }
    return _client!;
  }

  void sub(String topic) {
    var status = _client!.getSubscriptionTopicStatus(topic);
    if (status == MqttSubscriptionStatus.active) {
      print("$topic --> already subscribed");
    } else {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  @override
  Future<MqttConnectionStatus?> connect(
      [String? username, String? password]) async {
    var deviceId = await PlatformDeviceId.getDeviceId;
    var now = DateTime.now().toString();
    var identifier = "$deviceId-$now";
    _client = this;
    _client!.server = "red.oss.net.tr";
    _client!.port = 1883;
    _client!.keepAlivePeriod = 60;
    _client!.autoReconnect = true;
    _client!.resubscribeOnAutoReconnect = true;
    _client!.onConnected = connected;
    _client!.onDisconnected = disconnected;
    _client!.onSubscribed = subscribed;
    _client!.onSubscribeFail = onSubscribeFail;
    _client!.onUnsubscribed = onUnsubscribed;
    _client!.onAutoReconnect = onAutoReconnect;
    _client!.onAutoReconnected = onAutoReconnected;
    _client!.pongCallback = pongCallback;
    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs("mcan", "admknh06")
        .startClean()
        .withClientIdentifier(identifier)
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = connMess;
    print("$server bağlanılıyor");
    state = MqttConnectionState.connecting;
    await super.connect(username, password);
    return _client!.connectionStatus;
  }

  @override
  void disconnect() {
    super.disconnect();
    state = MqttConnectionState.disconnected;
    _client = null;
  }

  void setConnListener(IMqttConnListener l) {
    connListener = l;
  }

  void setSubListener(IMqttSubListener l) {
    subListener = l;
  }

  void connected() {
    state = MqttConnectionState.connected;
    connListener!.connected(server);
  }

  void disconnected() {
    state = MqttConnectionState.disconnected;
    connListener!.disconnected(server);
  }

  void subscribed(MqttSubscription sub) {
    print("${sub.topic} --> Subscribed.");
  }

  void listen() {
    _client!.updates.listen((event) {
      var response = event[0].payload as MqttPublishMessage;
      var message = Utf8Decoder().convert(response.payload.message!);
      subListener!.onMessage(event[0].topic!, message);
    });
  }

  void pub(String topic, String message) {
    var builder = MqttPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
    print("$topic --> $message gönderildi");
  }
}
