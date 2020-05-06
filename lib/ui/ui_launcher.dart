import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/model/hive/basement_report.dart';
import 'package:flutter_grate_app/model/hive/user.dart';
import 'package:flutter_grate_app/ui/ui_dashboard.dart';
import 'package:flutter_grate_app/ui/ui_login.dart';
import 'package:hive/hive.dart';

class LauncherUI extends StatefulWidget {
  @override
  _LauncherUIState createState() => _LauncherUIState();
}

class _LauncherUIState extends State<LauncherUI> {
  Box<User> userBox;
  User user;
  Future<bool> _future;
  Box<BasementReport> reportBox;

  @override
  void initState() {
    super.initState();
    _future = getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data) {
                return new DashboardUI();
              } else {
                return new LoginUI();
              }
            } else {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      "images/logo.png",
                      width: 144,
                      height: 144,
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    CircularProgressIndicator(
                      backgroundColor: Colors.grey.shade300,
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getUser() async {
    userBox = await Hive.openBox("users");
    reportBox = await Hive.openBox("basement_reports");
    return userBox.length == 0
        ? false
        : userBox.getAt(0).isAuthenticated ? true : false;
  }
}
