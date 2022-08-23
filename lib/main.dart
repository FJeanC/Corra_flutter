import 'dart:async';

import 'package:corra/cronometro_final.dart';
import 'package:corra/run_view.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Future<void> main() async {
  // Placeholder Splash Screen Material App.
  runApp(const NoPermissionApp(hasCheckedPermissions: false));
  WidgetsFlutterBinding.ensureInitialized();

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.unableToDetermine) {
    permission = await GeolocatorPlatform.instance.requestPermission();
  }
  switch (permission) {
    case LocationPermission.deniedForever:
      runApp(const NoPermissionApp(hasCheckedPermissions: true));
      break;

    case LocationPermission.always:
    case LocationPermission.whileInUse:
      runApp(const MyApp());
      break;

    case LocationPermission.denied:
    case LocationPermission.unableToDetermine:
      runApp(const NoPermissionApp(hasCheckedPermissions: false));
  }
}

class NoPermissionApp extends StatelessWidget {
  const NoPermissionApp({Key? key, required hasCheckedPermissions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('No permissao'),
          backgroundColor: Colors.amber,
        ),
        body: const Center(
          child: Text('Sem permissao menor'),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Corra'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Permissao")),

      //body: const CronometroFinalView(),
      body: const RunView(),
    );
  }
}
