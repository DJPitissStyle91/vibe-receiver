import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibe Receiver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SocketConnectionPage(),
    );
  }
}

class SocketConnectionPage extends StatefulWidget {
  @override
  _SocketConnectionPageState createState() => _SocketConnectionPageState();
}

class _SocketConnectionPageState extends State<SocketConnectionPage> {
  Socket? socket;
  bool isConnected = false;
  Timer? reconnectTimer;

  @override
  void initState() {
    super.initState();
    connectToSocket();
  }

  @override
  void dispose() {
    cancelReconnectTimer();
    super.dispose();
  }

  void connectToSocket() async {
    try {
      socket = await Socket.connect('ilgazcengiz.com', 31693);
      socket?.write('vibR');
      setState(() {
        isConnected = true;
      });

      socket?.listen(
        (List<int> data) {
          final number = data[0];
          vibratePhone(number);
        },
        onError: (dynamic error) {
          reconnect();
        },
        onDone: () {
          reconnect();
        },
      );
    } catch (e) {
      reconnect();
    }
  }

  void reconnect() {
    cancelReconnectTimer();
    reconnectTimer = Timer(Duration(seconds: 5), () {
      setState(() {
        isConnected = false;
      });
      connectToSocket();
    });
  }

  void cancelReconnectTimer() {
    reconnectTimer?.cancel();
    reconnectTimer = null;
  }

  void vibratePhone(int number) {
    Vibration.vibrate(duration: number, amplitude: number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC7228B),
      body: Center(
        child: Text(
          isConnected ? 'Connected' : 'Disconnected',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}