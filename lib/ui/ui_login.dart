import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/model/organaization_model.dart';
import 'package:flutter_grate_app/sqflite/database_info.dart';
import 'package:flutter_grate_app/sqflite/db_helper.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/sqflite/model/user.dart';
import 'package:flutter_grate_app/ui/ui_dashboard.dart';
import 'package:flutter_grate_app/ui/ui_forgret_password.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:flutter_grate_app/widgets/widget_dark_background.dart';
import 'package:flutter_grate_app/widgets/widget_left_image.dart';
import 'package:flutter_grate_app/widgets/widget_text.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../utils.dart';

class LogInUI extends StatefulWidget {
  Login login;

  LogInUI(this.login);

  @override
  _LogInUIState createState() => _LogInUIState();
}

class _LogInUIState extends State<LogInUI> {
  bool _isRemembered = false;
  bool _isObscureText = true;
  var _key = new GlobalKey<FormState>();
  TextEditingController _usernameController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  DBHelper dbHelper = new DBHelper();
  Login login;
  LoggedInUser loggedInUser;

  saveToDatabase() async {
    Login log = await dbHelper.saveLogin(login);

    if (log == null) {
      Navigator.of(context).pop();

      showMessage(
          context,
          "Offline Database ERROR!",
          "Failed to save in offline-database.",
          Colors.redAccent,
          Icons.error_outline);
    } else {
      await getData(login);
      await getOrganizationData(login);

      Navigator.of(context).pop();

      showDialog(context: context, barrierDismissible: false, builder: (context)=>BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4,sigmaY: 4),
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
                separatorBuilder: (BuildContext context, index) => Divider(),
                itemBuilder: (BuildContext context, index) {
                  return Container(
                    decoration: BoxDecoration(
                        color: _list[index].selected
                            ? Colors.white
                            : Colors.white),
                    child: ListTile(
                      onTap: () {
                        resetSelection(index);
                        showDialog(
                            context: context,
                            builder: (_) => loadingAlert());
                  saveOrganization(index, login);
                      },
                      trailing: _list[index].selected
                          ? Icon(MdiIcons.checkDecagram, color: Colors.black,size: 36,)
                          : SizedBox(width: 4,height: 4,),
                      title: Text(
                        _list[index].text,
                        overflow: TextOverflow.ellipsis,
                           style: Theme.of(context).textTheme.headline.copyWith(color: Colors.black, ),
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  );
                },
              ),
            ),
            title: Text("Please Choose A Company :", style: Theme.of(context).textTheme.headline.copyWith(color: Colors.black, fontWeight: FontWeight.bold),),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.all(8),
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                  ),
                  onPressed: ()=>Navigator.of(context).pop(),
                  color: Colors.grey.shade200,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text("Close", style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.grey.shade700, fontWeight: FontWeight.bold),),
                  ),
                ),
              ),
              /*Container(
                margin: EdgeInsets.all(8),
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                  ),
                  onPressed: (){
                    saveOrganization(index, login);

                  },
                  color: Colors.grey.shade900,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text("Login", style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white, fontWeight: FontWeight.bold),),
                  ),
                ),
              ),*/
            ],
          ),
        ),
      ));
    }
  }

  saveOrganization(index, Login login) async {
    Map<String, String> headers = {
      'Authorization': login.accessToken,
      'Companyid': _list[index].value
    };

    var url = "https://api.gratecrm.com/ChangeDefaultCompany";
    var result = await http.post(url, headers: headers);
    try {
      if (result.statusCode == 200) {
        loggedInUser.CompanyGUID = _list[index].value;
        loggedInUser.CompanyName = _list[index].text;
        Navigator.of(context).pop();

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                new DashboardUI(login, loggedInUser)));
      } else {
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        return null;
      }
    } catch (error) {
      print(error);
    }
  }

  saveLoggedInUserToDatabase(LoggedInUser loggedInUser) async {
    await dbHelper.deleteAll(DBInfo.TABLE_CURRENT_USER);
    await dbHelper.save(loggedInUser, DBInfo.TABLE_CURRENT_USER);
  }

  resetSelection(index) async {
    for (Organization item in _list) {
      setState(() {
        item.selected = false;
      });
    }
    setState(() {
      _list[index].selected = true;
    });
  }
  List<Organization> _list = [];

  Future getOrganizationData(Login login) async {
    try {
      Map<String, String> headers = {
        'Authorization': login.accessToken,
      };
      var url = "https://api.gratecrm.com/GetOrganizationList";
      var result = await http.get(url, headers: headers);
      if (result.statusCode == 200) {
        Map map = json.decode(result.body);
        _list = List.generate(map['orglist'].length, (index) {
          return Organization.fromMap(map['orglist'][index]);
        });
        if (_list.length == 1) {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                  new DashboardUI(login, loggedInUser)));
        }
        return result;
      } else {
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        return {};
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    _isObscureText = true;
    if (widget.login != null && widget.login.isRemembered) {
      _usernameController.text = widget.login.username;
      _passwordController.text = widget.login.password;
      _isRemembered = widget.login.isRemembered;
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
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
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
                            child: ListView(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              children: <Widget>[
                                Container(
                                  height: 504,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(color: Colors.white),
                                  child: Form(
                                    key: _key,
                                    child: new Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                "Login",
                                                style: Theme.of(context).textTheme.display1.copyWith(color: Colors.black, fontWeight: FontWeight.w900),
                                              ),
                                            ),
                                          ],
                                        ),
                                        ListView(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          physics: ScrollPhysics(),
                                          children: <Widget>[
                                            new TextFormField(
                                              controller: _usernameController,
                                              obscureText: false,
                                              autocorrect: false,
                                              autofocus: false,
                                              cursorColor: Colors.black,
                                              keyboardType: TextInputType.emailAddress,
                                              maxLines: 1,
                                              validator: (val) {
                                                return val.isNotEmpty ? null : "* Required";
                                              },
                                              style: customTextStyle(),
                                              decoration: new InputDecoration(
                                                isDense: true,
                                                icon: new Icon(
                                                  Icons.mail_outline,
                                                ),
                                                labelText: "Username",
                                                labelStyle: customTextStyle(),
                                                hintText: "e.g. example@mail.com",
                                                hintStyle: customHintStyle(),
                                                alignLabelWithHint: false,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 16,
                                            ),
                                            new TextFormField(
                                              controller: _passwordController,
                                              obscureText: _isObscureText,
                                              cursorColor: Colors.black,
                                              autocorrect: false,
                                              autofocus: false,
                                              keyboardType: TextInputType.emailAddress,
                                              maxLines: 1,
                                              validator: (val) {
                                                return val.isNotEmpty ? null : "* Required";
                                              },
                                              style: customTextStyle(),
                                              decoration: new InputDecoration(
                                                isDense: true,
                                                icon: new Icon(
                                                  Icons.lock_outline,
                                                ),
                                                labelText: "Password",
                                                labelStyle: customTextStyle(),
                                                hintText: "e.g. ******",
                                                hintStyle: customHintStyle(),
                                                alignLabelWithHint: false,
                                                suffixIcon: new IconButton(
                                                  icon: _isObscureText
                                                      ? new Icon(
                                                    Icons.visibility,
                                                  )
                                                      : new Icon(
                                                    Icons.visibility_off,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _isObscureText =
                                                      _isObscureText ? false : true;
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
                                                        activeColor: Colors.black,
                                                        checkColor: Colors.white,
                                                        value: _isRemembered,
                                                        materialTapTargetSize:
                                                        MaterialTapTargetSize.padded,
                                                        onChanged: (bool value) {
                                                          setState(() {
                                                            _isRemembered = value;
                                                          });
                                                        },
                                                      ),
                                                      InkWell(
                                                        child: TextWidget(
                                                          "Remember Me",
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .subhead
                                                              .copyWith(
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                        onTap: () {
                                                          setState(() {
                                                            _isRemembered = !_isRemembered;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  alignment: Alignment.centerLeft,
                                                ),
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
                                                      child: TextWidget(
                                                        "Login",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .title
                                                            .copyWith(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (_key.currentState.validate()) {
                                                          showDialog(
                                                              context: context,
                                                              builder: (_) => loadingAlert());
                                                          login = new Login(
                                                              null,
                                                              _usernameController.text,
                                                              _passwordController.text,
                                                              _isRemembered,
                                                              false,
                                                              "",
                                                              0);
                                                          makeRequest();
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  alignment: Alignment.centerRight,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        InkWell(
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
                                                  .copyWith(color: Colors.black),
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
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  Future<String> makeRequest() async {
    Map data = {
      'username': '${_usernameController.text}',
      'password': '${_passwordController.text}',
      'grant_type': 'password'
    };
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

    var url = 'https://api.gratecrm.com/token';
    try {
      http.post(url, body: data).then((response) {
        if (response.statusCode == 200) {
          Map map = json.decode(response.body);
          login.accessToken = map['token_type'] + " " + map['access_token'];
          login.validity = map['expires_in'];
          login.isAuthenticated = true;
          saveToDatabase();
        } else {
          login.isAuthenticated = false;
          Navigator.of(context).pop();
          showMessage(context, "Authentication Error!", "Check your \'Username\' and \'Password\' again.", Colors.redAccent, Icons.warning);
        }
      });
    } catch (error) {
      login.isAuthenticated = false;
      Navigator.of(context).pop();
      showMessage(context, "Authentication Error!", "Timeout", Colors.redAccent, Icons.warning);
    }
  }

  getData(Login login) async {
    Map<String, String> headers = {
      'Authorization': login.accessToken,
      'username': login.username
    };

    var url = "https://api.gratecrm.com/GetUserByUserName";
    var result = await http.get(url, headers: headers);
    if (result.statusCode == 200) {
      loggedInUser = LoggedInUser.fromMap(json.decode(result.body));
      await saveLoggedInUserToDatabase(loggedInUser);
      return loggedInUser;
    } else {
      showMessage(context, "Network error!", json.decode(result.body),
          Colors.redAccent, Icons.warning);
      return null;
    }
  }
}
