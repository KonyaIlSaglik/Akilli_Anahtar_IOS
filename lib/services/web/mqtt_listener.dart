abstract class IMqttConnListener {
  void connected(String server);
  void disconnected(String server);
}

abstract class IMqttSubListener {
  void onMessage(String topic, String message);
}
