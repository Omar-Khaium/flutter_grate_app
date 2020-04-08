import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/drawer/drawer_theme.dart';
import 'package:flutter_grate_app/sqflite/database_info.dart';
import 'package:flutter_grate_app/sqflite/db_helper.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/ui/ui_login.dart';
import 'package:flutter_grate_app/widgets/custome_back_button.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';

class LogoutFragment extends StatefulWidget {
  Login login;
  ValueChanged<int> backToDashboard;

  LogoutFragment({Key key, this.login, this.backToDashboard})
      : super(key: key);

  @override
  _LogoutFragmentState createState() => _LogoutFragmentState();
}

class _LogoutFragmentState extends State<LogoutFragment> {
  DBHelper dbHelper = new DBHelper();

  saveToDatabase() async {
    Login log = await dbHelper.update(widget.login, DBInfo.TABLE_LOGIN);

    setState(() {
      if (log == null) {
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          flushbarStyle: FlushbarStyle.GROUNDED,
          backgroundColor: Colors.redAccent,
          icon: Icon(
            Icons.error_outline,
            size: 24.0,
            color: Colors.white,
          ),
          duration: Duration(seconds: 4),
          leftBarIndicatorColor: Colors.white70,
          boxShadows: [
            BoxShadow(
              color: Colors.red[800],
              offset: Offset(0.0, 2.0),
              blurRadius: 3.0,
            )
          ],
          title: "Offline Database ERROR!",
          message: "Failed to save in offline-database.",
          shouldIconPulse: false,
        )..show(context);
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => new LogInUI(widget.login)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.only(left: 32),
                child: Row(
                  children: <Widget>[
                    CustomBackButton(onTap: ()=> widget.backToDashboard(0),),
                    SizedBox(width: 16,),
                    Text("Logout", style: fragmentTitleStyle()),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Divider(),
              margin: EdgeInsets.only(left: 32, right: 32),
            ),
            Expanded(
              child: Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        height: MediaQuery.of(context).size.height / 4,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Image.asset("images/sign_out.png"),
                        ),
                      ),
                      SizedBox(
                        height: 48,
                      ),
                      Text(
                        "Are you sure?",
                        style: fragmentTitleStyle(),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          MaterialButton(
                            onPressed: () {
                              setState(() {
                                widget.backToDashboard(0);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: Offset(
                                      0,
                                      0,
                                    ),
                                  )
                                ],
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 32, right: 32, top: 16, bottom: 16),
                                  child: Text(
                                    "Cancel",
                                    style: defaultTextStyle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              setState(() {
                                widget.login.isAuthenticated = false;
                                saveToDatabase();
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade800,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.shade100,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: Offset(
                                      0,
                                      0,
                                    ),
                                  )
                                ],
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 32, right: 32, top: 16, bottom: 16),
                                  child: Text(
                                    "Logout",
                                    style: selectedTextStyle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
