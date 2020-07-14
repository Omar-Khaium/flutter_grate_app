import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_grate_app/model/hive/user.dart';
import 'package:flutter_grate_app/model/organaization_model.dart';
import 'package:flutter_grate_app/services.dart';
import 'package:flutter_grate_app/ui/ui_dashboard.dart';
import 'package:flutter_grate_app/ui/ui_forgret_password.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:flutter_grate_app/widgets/widget_dark_background.dart';
import 'package:flutter_grate_app/widgets/widget_left_image.dart';
import 'package:flutter_grate_app/widgets/widget_no_internet.dart';
import 'package:flutter_grate_app/widgets/widget_text.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../utils.dart';

class LoginUI extends StatefulWidget {
  @override
  _LoginUIState createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> with SingleTickerProviderStateMixin {
  bool _isRemembered = false;
  bool _isObscureText = true;
  bool offline = false;

  var _key = new GlobalKey<FormState>();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  Box<User> userBox;
  User user;

  List<Organization> _list = [];

  @override
  void initState() {
    super.initState();
    _isObscureText = true;
    userBox = Hive.box("users");
    restoreData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: offline
            ? NoInternetConnectionWidget(refreshConnectivity)
            : Center(
                child: OrientationBuilder(
                  builder: (context, orientation) => new Stack(
                    children: <Widget>[
                      DarkBackgroundWidget(),
                      Center(
                        child: Container(
                          height: 600,
                          padding: const EdgeInsets.all(48),
                          child: new Row(
                            children: <Widget>[
                              new Expanded(
                                child: LeftPanelForLoginWidget(),
                                flex: 1,
                              ),
                              new Expanded(
                                child: Container(
                                  height: 600,
                                  padding: const EdgeInsets.all(24),
                                  decoration:
                                  BoxDecoration(color: Colors.white),
                                  child: ListView(
                                    shrinkWrap: true,
                                    physics: ScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    children: <Widget>[
                                      Form(
                                        key: _key,
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
                                                  child: Image.asset(
                                                      "images/logo.png"),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16),
                                                  child: Text(
                                                    "Login",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .display1
                                                        .copyWith(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w900),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 48),
                                              child: ListView(
                                                scrollDirection: Axis.vertical,
                                                shrinkWrap: true,
                                                physics: ScrollPhysics(),
                                                children: <Widget>[
                                                  new TextFormField(
                                                    controller: _emailController,
                                                    obscureText: false,
                                                    autocorrect: false,
                                                    autofocus: false,
                                                    cursorColor: Colors.black,
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                    maxLines: 1,
                                                    validator: (val) {
                                                      return val.isNotEmpty
                                                          ? null
                                                          : "* Required";
                                                    },
                                                    style: customTextStyle(),
                                                    decoration:
                                                        new InputDecoration(
                                                      isDense: true,
                                                      icon: new Icon(
                                                        Icons.mail_outline,
                                                      ),
                                                      labelText: "Username",
                                                      labelStyle:
                                                          customTextStyle(),
                                                      hintText:
                                                          "e.g. example@mail.com",
                                                      hintStyle:
                                                          customHintStyle(),
                                                      alignLabelWithHint: false,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  new TextFormField(
                                                    controller:
                                                        _passwordController,
                                                    obscureText: _isObscureText,
                                                    cursorColor: Colors.black,
                                                    autocorrect: false,
                                                    autofocus: false,
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                    maxLines: 1,
                                                    validator: (val) {
                                                      return val.isNotEmpty
                                                          ? null
                                                          : "* Required";
                                                    },
                                                    style: customTextStyle(),
                                                    decoration:
                                                        new InputDecoration(
                                                      isDense: true,
                                                      icon: new Icon(
                                                        Icons.lock_outline,
                                                      ),
                                                      labelText: "Password",
                                                      labelStyle:
                                                          customTextStyle(),
                                                      hintText: "e.g. ******",
                                                      hintStyle:
                                                          customHintStyle(),
                                                      alignLabelWithHint: false,
                                                      suffixIcon: new IconButton(
                                                        icon: _isObscureText
                                                            ? new Icon(
                                                                Icons.visibility,
                                                              )
                                                            : new Icon(
                                                                Icons
                                                                    .visibility_off,
                                                              ),
                                                        onPressed: () {
                                                          setState(() {
                                                            _isObscureText =
                                                                _isObscureText
                                                                    ? false
                                                                    : true;
                                                          });
                                                        },
                                                        iconSize: 24,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  new Stack(
                                                    children: <Widget>[
                                                      Align(
                                                        child: new Row(
                                                          children: <Widget>[
                                                            Checkbox(
                                                              activeColor:
                                                                  Colors.black,
                                                              checkColor:
                                                                  Colors.white,
                                                              value:
                                                                  _isRemembered,
                                                              materialTapTargetSize:
                                                                  MaterialTapTargetSize
                                                                      .padded,
                                                              onChanged:
                                                                  (bool value) {
                                                                setState(() {
                                                                  _isRemembered =
                                                                      value;
                                                                });
                                                              },
                                                            ),
                                                            InkWell(
                                                              child: TextWidget(
                                                                "Remember Me",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .subhead
                                                                    .copyWith(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold),
                                                              ),
                                                              onTap: () {
                                                                setState(() {
                                                                  _isRemembered =
                                                                      !_isRemembered;
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                        alignment:
                                                            Alignment.centerLeft,
                                                      ),
                                                      Align(
                                                        child: MaterialButton(
                                                          elevation: 4,
                                                          color: Colors.black,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .circular(
                                                                    36.0),
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .white12),
                                                          ),
                                                          textColor: Colors.white,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 32,
                                                                    right: 32,
                                                                    top: 16,
                                                                    bottom: 16),
                                                            child: TextWidget(
                                                              "Login",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .title
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              if (_key
                                                                  .currentState
                                                                  .validate()) {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (_) =>
                                                                        loadingAlert());
                                                                login();
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
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 36),
                                              child: InkWell(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                      left: 16,
                                                      top: 16,
                                                      right: 16,
                                                      bottom: 16),
                                                  child: TextWidget(
                                                    "Forget Password",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .subhead
                                                        .copyWith(
                                                            color: Colors.black),
                                                  ),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                new ForgetPasswordUI()));
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
      ),
    );
  }

  restoreData() async {
    if (userBox.length > 0) {
      user = userBox.getAt(0);

      if (user != null && user.isRemembered) {
        setState(() {
          _emailController.text = user.email;
          _passwordController.text = user.password;
          _isRemembered = true;
        });
      }
    }
  }

  refreshConnectivity(bool flag) {
    setState(() {
      offline = flag;
    });
  }

  Future<String> login() async {
    Map body = {
      'username': '${_emailController.text.trim()}',
      'password': '${_passwordController.text.trim()}',
      'grant_type': 'password'
    };
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    try {
      var response = await loginService(body);
      print(response.statusCode);
      setState(() {
        offline = false;
      });
      if (response.statusCode == 200) {
        Map map = json.decode(response.body);
        user = User(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            isRemembered: _isRemembered,
            isAuthenticated: true,
            accessToken: map['token_type'] + " " + map['access_token'],
            validity: map['expires_in']);

        await getUserInfo();
        await getOrganizationData();
      } else {
        Navigator.of(context).pop();
        user = User(
            email: _emailController.text,
            password: _passwordController.text,
            isRemembered: _isRemembered,
            isAuthenticated: false);
        if (userBox.length == 0)
          userBox.add(user);
        else
          userBox.putAt(0, user);
        showMessage(context, "Network error!", "Wrong Credentials",
            Colors.redAccent, Icons.warning);
      }
      return "";
    } catch (error) {
      user = User(
          email: _emailController.text,
          password: _passwordController.text,
          isRemembered: _isRemembered,
          isAuthenticated: false);
      if (userBox.length == 0)
        userBox.add(user);
      else
        userBox.putAt(0, user);
      showMessage(context, "Network error!", "Something Went Wrong",
          Colors.redAccent, Icons.warning);
      Navigator.of(context).pop();
      setState(() {
        offline = true;
      });
      if (error.toString().contains("SocketException")) {
        showNoInternetConnection(context);
      }
      return "";
    }
  }

  getUserInfo() async {
    Map<String, String> headers = {
      'Authorization': user.accessToken,
      'username': user.email
    };

    var result = await getUserInfoService(headers);

    if (result.statusCode == 200) {
      var map = json.decode(result.body);
      user.guid = map['emp']['UserId'];
      user.id = map['emp']['Id'];
      user.firstName = map['emp']['FirstName'];
      user.lastName = map['emp']['LastName'];
      user.email = map['emp']['Email'];
      user.photo = map['emp']['ProfilePicture'];
      user.companyID = map['company']['Id'];
      user.companyGUID = map['company']['CompanyId'];
      user.companyName = map['company']['CompanyName'];
      user.companyEmail = map['company']['EmailAdress'];
      user.companyLogo = map['company']['CompanyLogo'];
      user.companyPhone = map['company']['Phone'];
      user.companyFax = map['company']['Fax'];
      user.companyStreet = map['company']['Street'];
      user.companyCity = map['company']['City'];
      user.companyState = map['company']['State'];
      user.companyZipCode = map['company']['ZipCode'];
      if (userBox.length == 0)
        userBox.add(user);
      else
        userBox.putAt(0, user);
      return;
    } else {
      showMessage(context, "Network error!", json.decode(result.body),
          Colors.redAccent, Icons.warning);
      return;
    }
  }

  Future getOrganizationData() async {
    try {
      Map<String, String> headers = {
        'Authorization': user.accessToken,
      };

      var result = await getOrganizationService(headers);

      setState(() {
        offline = false;
      });

      if (result.statusCode == 200) {
        Map map = json.decode(result.body);
        _list = List.generate(map['orglist'].length, (index) {
          return Organization.fromMap(map['orglist'][index]);
        });

        Navigator.of(context).pop();
        chooseOrganization();
        return result;
      } else {
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        return {};
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

  chooseOrganization() async {
    if (_list.length == 1) {
      Navigator.of(context).pop();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => new DashboardUI()));
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    content: Container(
                      height: 400,
                      width: 500,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: _list.length,
                        separatorBuilder: (BuildContext context, index) =>
                            Divider(),
                        itemBuilder: (BuildContext context, index) {
                          return Container(
                            decoration: BoxDecoration(
                                color: _list[index].selected
                                    ? Colors.white
                                    : Colors.white),
                            child: ListTile(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (_) => loadingAlert());
                                saveOrganization(index);
                              },
                              trailing: _list[index].selected
                                  ? Icon(
                                      MdiIcons.checkDecagram,
                                      color: Colors.black,
                                      size: 36,
                                    )
                                  : SizedBox(
                                      width: 4,
                                      height: 4,
                                    ),
                              title: Text(
                                _list[index].text,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline
                                    .copyWith(
                                      color: Colors.black,
                                    ),
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      "Please Choose A Company :",
                      style: Theme.of(context).textTheme.headline.copyWith(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    actions: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          onPressed: () => Navigator.of(context).pop(),
                          color: Colors.grey.shade200,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              "Close",
                              style: Theme.of(context)
                                  .textTheme
                                  .subhead
                                  .copyWith(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
    }
  }

  saveOrganization(index) async {
    Map<String, String> headers = {
      'Authorization': user.accessToken,
      'Companyid': _list[index].value
    };
    try {
      var result = await changeOrganizationService(headers);
      setState(() {
        offline = false;
      });
      if (result.statusCode == 200) {
        user.companyGUID = _list[index].value;
        user.companyName = _list[index].text;
        userBox.putAt(0, user);
        Navigator.of(context).pop();

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => new DashboardUI()));
      } else {
        Navigator.of(context).pop();
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        return null;
      }
    } catch (error) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      setState(() {
        offline = true;
      });
      if (error.toString().contains("SocketException")) {
        showNoInternetConnection(context);
      }
    }
  }
}
