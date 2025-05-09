import 'package:app_chan_doan/connection_manage.dart';
import 'package:app_chan_doan/mqtt.dart';
import 'package:app_chan_doan/seri_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:app_chan_doan/menu_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  mqtt.initializeMQTTClient();
  mqtt.connect();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @overrideF
  State<MyApp> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      mqtt.publish('{"disconnect":$id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MenuPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
