import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_grate_app/ui/ui_login.dart';
import 'package:flutter_grate_app/utils.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:flutter_grate_app/widgets/widget_dark_background.dart';
import 'package:flutter_grate_app/widgets/widget_no_internet.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgetPasswordUI extends StatefulWidget {
  @override
  ForgetPasswordUIState createState() => ForgetPasswordUIState();
}

class ForgetPasswordUIState extends State<ForgetPasswordUI>
    with SingleTickerProviderStateMixin {
  TextEditingController _usernameController = new TextEditingController();
  bool offline = false;
  bool _usernameValidator = true;
  Color _usernameIconColor = Colors.grey;

  Future<String> makeRequest() async {
    showDialog(context: context, builder: (_) => loadingAlert());
    Map<String, String> data = {'EmailAddress': '${_usernameController.text}'};
    try {
      var response =
          await http.post(BASE_URL + API_FORGET_PASSWORD, headers: data);
      setState(() {
        offline = false;
      });
      if (response.statusCode == 200) {
        Map map = json.decode(response.body);
        setState(() {
          Navigator.of(context).pop();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => new LogInUI(null)));
        });
      } else {
        Navigator.of(context).pop();
        showAPIResponse(
            context, "Something went wrong...", Color(COLOR_DANGER));
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
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      right: true,
      left: true,
      child: new Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        body: offline
            ? NoInternetConnectionWidget(refreshConnectivity)
            : OrientationBuilder(
                builder: (context, orientation) => new Stack(
                  children: <Widget>[
                    DarkBackgroundWidget(),
                    Center(
                      child: Container(
                        height: 600,
                        padding: const EdgeInsets.all(48),
                        child: new Row(
                          children: <Widget>[
/*---------------------------------Left Image---------------------------------*/
                            new Expanded(
                              child: Container(
                                height: double.infinity,
                                width: double.infinity,
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child:
                                                Image.asset("images/logo.png"),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 16),
                                            child: Text(
                                              "Forget Password",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .display1
                                                  .copyWith(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w900),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          new TextField(
                                            controller: _usernameController,
                                            obscureText: false,
                                            cursorColor: Colors.black,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            maxLines: 1,
                                            onTap: () {
                                              setState(() {
                                                _usernameIconColor =
                                                    Colors.black;
                                              });
                                            },
                                            style: customTextStyle(),
                                            decoration: new InputDecoration(
                                              icon: new Icon(
                                                Icons.mail_outline,
                                                color: _usernameIconColor,
                                              ),
                                              errorText: _usernameValidator
                                                  ? null
                                                  : "* Required",
                                              errorStyle:
                                                  customTextFieldErrorStyle(),
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
                                                        new BorderRadius
                                                            .circular(36.0),
                                                    side: BorderSide(
                                                        color: Colors.white12),
                                                  ),
                                                  textColor: Colors.white,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 32,
                                                            right: 32,
                                                            top: 16,
                                                            bottom: 16),
                                                    child: new Text(
                                                      "Send Request",
                                                      style:
                                                          customButtonTextStyle(),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _usernameValidator =
                                                          _usernameController
                                                              .text.isNotEmpty;
                                                      if (_usernameValidator) {
                                                        makeRequest();
                                                      }
                                                    });
                                                  },
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      new LogInUI(null)));
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            new Text(
                                              "Already have credentials? ",
                                              style: customInkWellTextStyle(),
                                            ),
                                            new Text(
                                              "Login",
                                              style: customInkWellTextStyle(),
                                            )
                                          ],
                                        ),
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
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  refreshConnectivity(bool flag) {
    setState(() {
      offline = flag;
    });
  }
}
