import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_grate_app/ui/ui_login.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgetPasswordUI extends StatefulWidget {
  @override
  ForgetPasswordUIState createState() => ForgetPasswordUIState();
}

class ForgetPasswordUIState extends State<ForgetPasswordUI> {
  TextEditingController _usernameController = new TextEditingController();
  bool _isLoading = false;
  bool _usernameValidator = true;
  Color _usernameIconColor = Colors.grey;

  Future<String> makeRequest() async {
    Map data = {
      'username': '${_usernameController.text}',
      'grant_type': 'password'
    };

    var url = 'http://api.rmrcloud.com/token';
    http.post(url, body: data).then((response) {
      if (response.statusCode == 200) {
        Map map = json.decode(response.body);
        print(map['access_token']);
      }
      setState(() {
        _isLoading = false;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => new LoginUI()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: ModalProgressHUD(
        child: new Stack(
          children: <Widget>[
            new Image.asset(
              "images/background.jpg",
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.black.withOpacity(0),
                  child: Container(
                    color: Colors.blueGrey.withOpacity(0.25),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(100.0),
              child: new Row(
                children: <Widget>[
/*---------------------------------Left Image---------------------------------*/
                  new Expanded(
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          color: Colors.blueAccent.withOpacity(1),
                          child: Image.asset(
                            'images/forget_password.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    flex: 1,
                  ),

/*---------------------------------Login Form---------------------------------*/
                  new Expanded(
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(36.0),
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Image.asset("images/logo.png"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Text(
                                    "Forget Password",
                                    style: customWelcomeStyle(Colors.blueGrey.shade800),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 36,
                            ),
                            new TextField(
                              controller: _usernameController,
                              obscureText: false,
                              cursorColor: Colors.black,
                              keyboardType: TextInputType.emailAddress,
                              maxLines: 1,
                              onTap: () {
                                setState(() {
                                  _usernameIconColor = Colors.black;
                                });
                              },
                              style: customTextStyle(),
                              decoration: new InputDecoration(
                                icon: new Icon(
                                  Icons.mail_outline,
                                  color: _usernameIconColor,
                                ),
                                errorText:
                                    _usernameValidator ? null : "* Required",
                                errorStyle: customTextFieldErrorStyle(),
                                labelText: "Username",
                                labelStyle: customTextStyle(),
                                hintText: "e.g. example@mail.com",
                                hintStyle: customHintStyle(),
                                alignLabelWithHint: false,
                              ),
                            ),
                            SizedBox(
                              height: 32,
                            ),
                            new Stack(
                              children: <Widget>[
                                Align(
                                  child: MaterialButton(
                                    elevation: 4,
                                    color: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(36.0),
                                      side: BorderSide(color: Colors.white12),
                                    ),
                                    textColor: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 32,
                                          right: 32,
                                          top: 16,
                                          bottom: 16),
                                      child: new Text(
                                        "Send Request",
                                        style: customButtonTextStyle(),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _usernameValidator =
                                            _usernameController.text.isNotEmpty;
                                        if (_usernameValidator) {
                                          _isLoading = true;
                                          makeRequest();
                                        }
                                      });
                                    },
                                  ),
                                  alignment: Alignment.centerRight,
                                ),
                              ],
                            ),
                            Expanded(
                              child: new Container(
                                  height: double.infinity,
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Text(
                                        "Already have credentials? ",
                                        style: customInkWellTextStyle(),
                                      ),
                                      InkWell(
                                        child: new Text(
                                          "Login",
                                          style: customInkWellTextStyle(),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        new LoginUI()));
                                          });
                                        },
                                      ),
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    flex: 1,
                  ),
/*------------------------------Loading Indicator-----------------------------*/
                ],
              ),
            ),
          ],
        ),
        inAsyncCall: _isLoading,
        color: Colors.black,
        progressIndicator: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        dismissible: false,
      ),
    );
  }
}
