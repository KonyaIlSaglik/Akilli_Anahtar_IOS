import 'dart:convert';

import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/services/api/parameter_service.dart';
import 'package:akilli_anahtar/services/local/i_cache_manager.dart';
import 'package:akilli_anahtar/utils/hive_constants.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:platform_device_id/platform_device_id.dart';

class MqttController extends GetxController {
  var connecting = false.obs;
  late MqttServerClient client;
  var isConnected = false.obs;
  var status = 'Disconnected'.obs;
  List<Function(String topic)> subListenerList = <Function(String topic)>[].obs;

  @override
  void onInit() {
    super.onInit();
    initClient();
  }

  void initClient() async {
    var paramsManager = CacheManager<Parameter>(HiveConstants.parametersKey,
        HiveConstants.parametersTypeId, ParameterAdapter());
    await paramsManager.init();
    var params = paramsManager.getAll();
    if (params == null || params.isEmpty) {
      var paramsResult = await ParameterService.getParametersbyType(1);
      if (paramsResult != null) {
        params = paramsResult;
        await paramsManager.clear();
        paramsManager.addList(params);
      }
    }
    var deviceId = await PlatformDeviceId.getDeviceId;
    var now = DateTime.now().toString();
    var identifier = "$deviceId-$now";
    if (params != null) {
      var host = params.firstWhere((p) => p.name == "mqtt_host_public").value;
      client = MqttServerClient(host, identifier);
      client.port =
          int.tryParse(params.firstWhere((p) => p.name == "mqtt_port").value) ??
              1883;
      client.keepAlivePeriod = 60;
      client.autoReconnect = true;
      client.resubscribeOnAutoReconnect = true;
      client.onConnected = onConnected;
      client.onDisconnected = onDisconnected;
      client.onSubscribed = onSubscribed;
      client.pongCallback = pong;
      final MqttConnectMessage connMess = MqttConnectMessage()
          .authenticateAs(
            params.firstWhere((p) => p.name == "mqtt_user").value,
            params.firstWhere((p) => p.name == "mqtt_password").value,
          )
          .startClean()
          .withClientIdentifier(identifier)
          .withWillQos(MqttQos.atMostOnce);
      client.connectionMessage = connMess;
    }
    print("Mqtt initialized");
    connect();
  }

  Future<void> connect() async {
    connecting.value = true;
    try {
      status.value = 'Connecting';
      await client.connect();
    } catch (e) {
      status.value = 'Connection failed: $e';
      client.disconnect();
    } finally {
      connecting.value = false;
    }
  }

  void onConnected() {
    isConnected.value = true;
    status.value = 'Connected';
    print('MQTT client connected');
  }

  void onDisconnected() {
    isConnected.value = false;
    status.value = 'Disconnected';
    print('MQTT client disconnected');
  }

  void onSubscribed(MqttSubscription sb) {
    for (var listen in subListenerList) {
      listen(sb.topic.toString());
    }
  }

  void pong() {
    print('Ping response received');
  }

  void subscribeToTopic(String topic) {
    if (client.getSubscriptionTopicStatus(topic) !=
        MqttSubscriptionStatus.active) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  void onMessage(Function(String topic, String message) onMessage) {
    client.updates.listen((event) {
      var response = event[0].payload as MqttPublishMessage;
      var message = Utf8Decoder().convert(response.payload.message!);
      onMessage(event[0].topic.toString(), message);
    });
  }

  MqttSubscriptionStatus getSubscriptionTopicStatus(topic) {
    return client.getSubscriptionTopicStatus(topic);
  }

  void publishMessage(String topic, String message) {
    final builder = MqttPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  @override
  void onClose() {
    client.disconnect();
    super.onClose();
  }
}
