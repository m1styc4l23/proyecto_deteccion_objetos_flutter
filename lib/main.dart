import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yolo_subs/database/db_provider.dart';
import 'package:yolo_subs/provider/grafica_provider.dart';
import 'package:yolo_subs/screens/mqtt_screen.dart';
import 'package:yolo_subs/screens/main_screens.dart';

void main() {
  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DBProvider()),
          ChangeNotifierProvider(create: (_) => GraficaProvider()),
        ],
      child: const MyApp(),
    );
  }

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yolo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/main',
      routes: {
        '/main': (context) => const MainScreens(),
        '/grafica3': (context) => const MqttScreen()
      },
    );
  }
}
