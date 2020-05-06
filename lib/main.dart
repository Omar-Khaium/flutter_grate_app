import 'package:flutter/material.dart';
import 'package:flutter_grate_app/model/hive/basement_report.dart';
import 'package:flutter_grate_app/ui/ui_launcher.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'model/hive/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(BasementReportAdapter());
  runApp(
    new MaterialApp(
      home: new LauncherUI(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.blueGrey.shade900),
    ),
  );
}
