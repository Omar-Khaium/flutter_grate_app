import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/sqflite/db_helper.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/sqflite/model/user.dart';
import 'package:flutter_grate_app/ui/ui_dashboard.dart';
import 'package:flutter_grate_app/ui/ui_login.dart';
import 'package:shimmer/shimmer.dart';

class LauncherUI extends StatefulWidget {
  @override
  _LauncherUIState createState() => _LauncherUIState();
}

class _LauncherUIState extends State<LauncherUI> {
  DBHelper dbHelper = new DBHelper();
  Login login;
  LoggedInUser loggedInUser;

  begin() async {
    await dbHelper.getAllFromLogin().then((result) async {
      login = result;
      if (login != null) {
        if (login.isAuthenticated) {
          await getLoggedInUser();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => new DashboardUI(login, loggedInUser),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => new LogInUI(login),
            ),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => new LogInUI(login),
          ),
        );
      }
    });
  }

  Future getLoggedInUser() async {
    return await dbHelper.getAllFromLoggedInUser().then((result) {
      loggedInUser = result;
    });
  }

  @override
  void initState() {
    super.initState();
    begin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CupertinoActivityIndicator(
          animating: true,
          radius: 14,
        ),
      ),
    );
  }
}
