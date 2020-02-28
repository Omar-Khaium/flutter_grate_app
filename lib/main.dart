import 'package:flutter/material.dart';
import 'package:flutter_grate_app/ui/ui_launcher.dart';

import 'flutter_connectivity.dart';

void main() {
  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();
  runApp(
    new MaterialApp(
      home: new LauncherUI(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blueGrey.shade900
      ),
    ),
  );
}