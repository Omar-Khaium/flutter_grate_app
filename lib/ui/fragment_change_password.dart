import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_grate_app/sqflite/database_info.dart';
import 'package:flutter_grate_app/sqflite/db_helper.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/ui/ui_login.dart';
import 'package:flutter_grate_app/utils.dart';
import 'package:flutter_grate_app/widgets/custome_back_button.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:flutter_grate_app/widgets/widget_no_internet.dart';
import 'package:http/http.dart' as http;

import '../constraints.dart';

class ChangePasswordFragment extends StatefulWidget {
  ValueChanged<int> backToDashboard;
  Login login;

  ChangePasswordFragment({Key key, this.backToDashboard, this.login})
      : super(key: key);

  @override
  _ChangePasswordFragmentState createState() => _ChangePasswordFragmentState();
}

class _ChangePasswordFragmentState extends State<ChangePasswordFragment> with SingleTickerProviderStateMixin{
  var _formKey = GlobalKey<FormState>();

  TextEditingController _oldPasswordController = new TextEditingController();
  TextEditingController _newPasswordController = new TextEditingController();
  TextEditingController _confirmPasswordController = new TextEditingController();

  DBHelper dbHelper = new DBHelper();
  bool _isOldPasswordObscureText = true;
  bool _isNewPasswordObscureText = true;
  bool _isConfirmPasswordObscureText = true;

  bool offline = false;

  Future getPasswordChanged() async {
    showDialog(
        context: context,
        builder: (_) => loadingAlert());

    Map<String, String> headers = {
      'Authorization': widget.login.accessToken,
      'UserName': '${widget.login.username}',
      'Password': '${_oldPasswordController.text}',
      'NewPassword': '${_newPasswordController.text}',
    };

    try {
      var result =
          await http.post(BASE_URL + API_CHANGE_PASSWORD, headers: headers);
      Navigator.of(context).pop();
      setState(() {
        offline = false;
      });
      if (result.statusCode == 200) {
        showPopup();
      } else {
        showMessage(context, "Network error!", result.body, Colors.redAccent,
            Icons.warning);
      }
    } catch (error) {
      Navigator.of(context).pop();
      setState(() {
        offline = true;
      });
      if (error.toString().contains("SocketException")) {
        showNoInternetConnection(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, top: 16),
      child: new Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              child: Row(
                children: <Widget>[
                  CustomBackButton(
                    onTap: () => widget.backToDashboard(0),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Text(offline ? "Offline" : "Change Password",
                      style: fragmentTitleStyle()),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            child: Divider(),
          ),
          Expanded(
            child: offline
                ? NoInternetConnectionWidget(refreshConnectivity)
                : Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        new TextFormField(
                          validator: (val) => val.isEmpty ? "Required" : null,
                          cursorColor: Colors.black87,
                          controller: _oldPasswordController,
                          keyboardType: TextInputType.emailAddress,
                          obscureText: _isOldPasswordObscureText,
                          maxLines: 1,
                          decoration: new InputDecoration(
                            labelText: "Old Password",
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black87)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            icon: new Icon(
                              Icons.lock,
                              color: Colors.grey,
                            ),
                            isDense: true,
                            suffixIcon: new IconButton(
                              icon: _isOldPasswordObscureText
                                  ? new Icon(
                                      Icons.visibility,
                                    )
                                  : new Icon(
                                      Icons.visibility_off,
                                    ),
                              onPressed: () {
                                setState(() {
                                  _isOldPasswordObscureText =
                                      _isOldPasswordObscureText ? false : true;
                                });
                              },
                              iconSize: 24,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        new TextFormField(
                          validator: (val) => val.isEmpty ? "Required" : null,
                          cursorColor: Colors.black87,
                          controller: _newPasswordController,
                          obscureText: _isNewPasswordObscureText,
                          keyboardType: TextInputType.emailAddress,
                          maxLines: 1,
                          decoration: new InputDecoration(
                            labelText: "New Password",
                            hintText: "e.g. ******",
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black87)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            icon: new Icon(
                              Icons.lock,
                              color: Colors.grey,
                            ),
                            isDense: true,
                            suffixIcon: new IconButton(
                              icon: _isNewPasswordObscureText
                                  ? new Icon(
                                      Icons.visibility,
                                    )
                                  : new Icon(
                                      Icons.visibility_off,
                                    ),
                              onPressed: () {
                                setState(() {
                                  _isNewPasswordObscureText =
                                      _isNewPasswordObscureText ? false : true;
                                });
                              },
                              iconSize: 24,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        new TextFormField(
                          validator: (val) => val.isEmpty ? "Required" : null,
                          cursorColor: Colors.black87,
                          controller: _confirmPasswordController,
                          obscureText: _isConfirmPasswordObscureText,
                          keyboardType: TextInputType.emailAddress,
                          maxLines: 1,
                          decoration: new InputDecoration(
                            labelText: "Confirm Password",
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black87)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                            icon: new Icon(
                              Icons.lock,
                              color: Colors.grey,
                            ),
                            isDense: true,
                            suffixIcon: new IconButton(
                              icon: _isConfirmPasswordObscureText
                                  ? new Icon(
                                      Icons.visibility,
                                    )
                                  : new Icon(
                                      Icons.visibility_off,
                                    ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordObscureText =
                                      _isConfirmPasswordObscureText
                                          ? false
                                          : true;
                                });
                              },
                              iconSize: 24,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: EdgeInsets.only(right: 36),
                            height: 64,
                            width: 156,
                            child: RaisedButton(
                              highlightElevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(36.0),
                                  side: BorderSide(color: Colors.white12)),
                              disabledColor: Colors.black,
                              color: Colors.black,
                              elevation: 5,
                              textColor: Colors.white,
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                "Submit",
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontFamily: "Roboto"),
                              ),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  if (_oldPasswordController.text !=
                                          _newPasswordController.text &&
                                      _oldPasswordController.text !=
                                          _confirmPasswordController.text &&
                                      _newPasswordController.text ==
                                          _confirmPasswordController.text) {
                                    getPasswordChanged();
                                  } else if (_oldPasswordController.text ==
                                      _newPasswordController.text) {
                                    showMessage(
                                        context,
                                        "Validation Error",
                                        "Old Password and new password can't be the same",
                                        Colors.red,
                                        Icons.error);
                                  } else if (_oldPasswordController.text ==
                                      _confirmPasswordController.text) {
                                    showMessage(
                                        context,
                                        "Validation Error",
                                        "Old Password and confirm password can't be the same",
                                        Colors.red,
                                        Icons.error);
                                  } else if (_newPasswordController.text !=
                                      _confirmPasswordController.text) {
                                    showMessage(
                                        context,
                                        "Validation Error",
                                        "New password and Confirm password didn't matched",
                                        Colors.red,
                                        Icons.error);
                                  }
                                } else {
                                  showMessage(
                                      context,
                                      "Validation Error",
                                      "Please fill all the fields",
                                      Colors.red,
                                      Icons.error);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          )
        ],
      ),
    );
  }

  refreshConnectivity(bool flag) {
    setState(() {
      offline = flag;
    });
  }

  void showPopup() {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.all(0),
            content: Container(
              width: 400,
              height: 400,
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  /*
                  Image.asset('images/change_password.jpg',height: 100,width: 100,),*/
                  Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                            width: double.infinity,
                            color: Colors.black87,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "Do you want to update your password ?",
                                style: new TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            )),
                      ),
                      Container(
                        width: 200,
                        margin: EdgeInsets.only(top: 8, bottom: 8),
                        child: Divider(
                          color: Colors.grey,
                          thickness: .5,
                        ),
                      ),
                      SizedBox(
                        height: 36,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "You recently requested to update the password,click confirm to change it.",
                          style: new TextStyle(
                              color: Colors.black87, fontSize: 20),
                        ),
                      ),
                      SizedBox(
                        height: 36,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 128,
                              child: OutlineButton(
                                highlightElevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(36.0),
                                    side: BorderSide(color: Colors.white12)),
                                color: Colors.black,
                                textColor: Colors.white,
                                padding: EdgeInsets.all(12.0),
                                child: Text(
                                  "Cancel",
                                  style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontFamily: "Roboto"),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 24,
                            ),
                            Container(
                              width: 128,
                              child: RaisedButton(
                                highlightElevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(36.0),
                                    side: BorderSide(color: Colors.white12)),
                                disabledColor: Colors.black,
                                color: Colors.black,
                                elevation: 2,
                                textColor: Colors.white,
                                padding: EdgeInsets.all(12.0),
                                child: Text(
                                  "Confirm",
                                  style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontFamily: "Roboto"),
                                ),
                                onPressed: () {
                                  if (widget.login.isRemembered) {
                                    Navigator.of(context).pop();
                                    showPopupLogout(
                                        "Do you want to logout ?", "Logout");
                                  } else {
                                    Center(
                                      child: Text(
                                        "Save your password first",
                                        style: new TextStyle(
                                            color: Colors.white, fontSize: 36),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ));
      },
    );
  }

  void showPopupLogout(String text, String button) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.all(0),
            content: Container(
              width: 400,
              height: 400,
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  /*
                  Image.asset('images/change_password.jpg',height: 100,width: 100,),*/
                  Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                            width: double.infinity,
                            color: Colors.black87,
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                text,
                                style: new TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            )),
                      ),
                      Container(
                        width: 200,
                        margin: EdgeInsets.only(top: 8, bottom: 8),
                        child: Divider(
                          color: Colors.grey,
                          thickness: .5,
                        ),
                      ),
                      SizedBox(
                        height: 36,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Your password have been saved,do you want to logout?",
                          style: new TextStyle(
                              color: Colors.black87, fontSize: 20),
                        ),
                      ),
                      SizedBox(
                        height: 36,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 132,
                              child: OutlineButton(
                                highlightElevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(36.0),
                                    side: BorderSide(color: Colors.white12)),
                                color: Colors.black,
                                textColor: Colors.white,
                                padding: EdgeInsets.all(12.0),
                                child: Text(
                                  "No,Thanks",
                                  style: new TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontFamily: "Roboto"),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 24,
                            ),
                            Container(
                              width: 132,
                              child: RaisedButton(
                                highlightElevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(36.0),
                                    side: BorderSide(color: Colors.white12)),
                                disabledColor: Colors.black,
                                color: Colors.black,
                                elevation: 2,
                                textColor: Colors.white,
                                padding: EdgeInsets.all(12.0),
                                child: Text(
                                  button,
                                  style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontFamily: "Roboto"),
                                ),
                                onPressed: () {
                                  widget.login.password =
                                      _newPasswordController.text;
                                  dbHelper.update(
                                      widget.login, DBInfo.TABLE_LOGIN);
                                  Navigator.of(context).pop();
                                  widget.login.isAuthenticated = false;
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              new LoginUI()));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ));
      },
    );
  }
}
