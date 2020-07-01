import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/drawer/drawer_theme.dart';
import 'package:flutter_grate_app/model/hive/user.dart';
import 'package:flutter_grate_app/ui/ui_login.dart';
import 'package:flutter_grate_app/widgets/custome_back_button.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:hive/hive.dart';

class LogoutFragment extends StatefulWidget {
  ValueChanged<int> backToDashboard;

  LogoutFragment({Key key, this.backToDashboard})
      : super(key: key);

  @override
  _LogoutFragmentState createState() => _LogoutFragmentState();
}

class _LogoutFragmentState extends State<LogoutFragment> {
  Box<User> userBox;
  User user;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box("users");
    user = userBox.get(0);
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
                              user.isAuthenticated = false;
                              userBox.putAt(0, user);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => new LoginUI()));
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
