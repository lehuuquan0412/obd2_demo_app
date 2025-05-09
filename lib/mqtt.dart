import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTManager {
  MqttServerClient client;
  final String topic;

  MQTTManager({required this.client, required this.topic});

  void initializeMQTTClient() {
    client.logging(on: true);
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client.connectionMessage = connMessage;
  }

  void connect() async {
    try {
      print('client connecting....');
      await client.connect();
    } on Exception catch (e) {
      print('client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    print('Disconnected');
    client.disconnect();
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  void onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print('OnDisconnected callback is solicited, this is correct');
    }
  }

  void onConnected() {
    print('client connected....');
    client.subscribe(topic, MqttQos.atLeastOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print(
          'Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });
    print('OnConnected client callback - Client connection was sucessful');
  }
}

final client = MqttServerClient('test.mosquitto.org', 'flutter_client');
MQTTManager mqtt = MQTTManager(client: client, topic: '2000/req');
