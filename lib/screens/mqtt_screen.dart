import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'points_line_chart.dart';

class MqttScreen extends StatefulWidget {
  const MqttScreen({Key? key}) : super(key: key);

  @override
  _MqttScreensState createState() => _MqttScreensState();
}

class _MqttScreensState extends State<MqttScreen> {
  String broker = '10.0.2.2';
  int port = 1885;
  // String username         = 'fcg.._seu_user_no_brokerrix';
  // String passwd           = '0qVi...seu_pass_no_nroker';
  String clientIdentifier = 'flutter_client';

  MqttClient? client;
  MqttConnectionState? connectionState;

  String _message = '';

  String titulo = 'Desconectado';

  StreamSubscription? subscription;

  void _subscribeToTopic(String topic) {
    if (connectionState == MqttConnectionState.connected) {
      print('[MQTT client] Subscribing to ${topic.trim()}');
      client?.subscribe(topic, MqttQos.exactlyOnce);
    }
  }

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(titulo),
            // ThermometerWidget(
            //   borderColor: Colors.black,
            //   innerColor: Colors.green,
            //   indicatorColor: Colors.red,
            //   temperature: _temp,
            // ),
            PointsLineChartScreen(messageTopic: _message,)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _connect,
        tooltip: 'Play',
        child: const Icon(Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    // _disconnect();
    client?.disconnect();
    subscription?.cancel();
    super.dispose();
  }

  void _connect() async {
    /// First create a client, the client is constructed with a broker name, client identifier
    /// and port if needed. The client identifier (short ClientId) is an identifier of each MQTT
    /// client connecting to a MQTT broker. As the word identifier already suggests, it should be unique per broker.
    /// The broker uses it for identifying the client and the current state of the client. If you don’t need a state
    /// to be hold by the broker, in MQTT 3.1.1 you can set an empty ClientId, which results in a connection without any state.
    /// A condition is that clean session connect flag is true, otherwise the connection will be rejected.
    /// The client identifier can be a maximum length of 23 characters. If a port is not specified the standard port
    /// of 1883 is used.
    /// If you want to use websockets rather than TCP see below.
    ///
    client = MqttServerClient.withPort(broker, clientIdentifier, port);

    // client.setProtocolV311();

    /// A websocket URL must start with ws:// or wss:// or Dart will throw an exception, consult your websocket MQTT broker
    /// for details.
    /// To use websockets add the following lines -:
    /// client.useWebSocket = true;
    /// client.port = 80;  ( or whatever your WS port is)
    /// Note do not set the secure flag if you are using wss, the secure flags is for TCP sockets only.
    /// Set logging on if needed, defaults to off
    client?.logging(on: false);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client?.keepAlivePeriod = 30;

    /// Add the successful connection callback
    client?.onConnected = onConnected;

    /// Add the unsolicited disconnection callback
    client?.onDisconnected = _onDisconnected;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    // final MqttConnectMessage connMess = MqttConnectMessage()
    //     .withClientIdentifier(clientIdentifier)
    //     .withWillTopic('willtopic') // If you set this you must set a will message
    //     .withWillMessage('My Will message')
    //     .startClean() // Non persistent session for testing
    //     .withWillQos(MqttQos.atMostOnce);
    // print('[MQTT client] MQTT client connecting....');
    // client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.
    try {
      await client?.connect();
    } catch (e) {
      print(e);
      _disconnect();
    }

    /// Check if we are connected
    if (client?.connectionState == MqttConnectionState.connected) {
      print('[MQTT client] connected');
      setState(() {
        connectionState = client?.connectionState;
        titulo = 'Conectado';
      });
    } else {
      print('[MQTT client] ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client?.connectionState}');
      _disconnect();
    }

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    subscription = client?.updates?.listen(_onMessage) as StreamSubscription;

    _subscribeToTopic("yolo/conteo/flutter");
  }

  /// The successful connect callback
  void onConnected() {
    print('EXAMPLE::OnConnected client callback - Client connection was successful');
  }

  void _disconnect() {
    print('[MQTT client] _disconnect()');

    client?.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    print('[MQTT client] _onDisconnected');

    setState(() {
      //topics.clear();
      connectionState = client?.connectionState!;
      // client = null;
      titulo = 'Desconectado';
      subscription?.cancel();
      // subscription = null;
    });

    // subscription?.cancel();
    print('[MQTT client] MQTT client disconnected');
  }

  void _onMessage(List<MqttReceivedMessage> event) {
    print(event.length);
    final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
    final String message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    /// The above may seem a little convoluted for users only interested in the
    /// payload, some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    print('[MQTT client] MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- ${message} -->');
    print(client?.connectionState);
    print("[MQTT client] message with topic: ${event[0].topic}");
    print("[MQTT client] message with message: ${message}");
    setState(() {
      _message = message;
    });
  }
}
