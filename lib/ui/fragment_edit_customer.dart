import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grate_app/model/customer_details.dart';
import 'package:flutter_grate_app/model/dropdown_item.dart';
import 'package:flutter_grate_app/model/product.dart';
import 'package:flutter_grate_app/model/zip_model.dart';
import 'package:flutter_grate_app/sqflite/database_info.dart';
import 'package:flutter_grate_app/sqflite/db_helper.dart';
import 'package:flutter_grate_app/sqflite/model/BasementReport.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/sqflite/model/user.dart';
import 'package:flutter_grate_app/ui/ui_login.dart';
import 'package:flutter_grate_app/widgets/UsFormatter.dart';
import 'package:flutter_grate_app/widgets/custome_back_button.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../utils.dart';

class EditCustomerFragment extends StatefulWidget {
  final Login login;
  final String customerID;
  final ValueChanged<int> backToDashboard;
  final ValueChanged<CustomerDetails> goToAddBasementReport;
  final ValueChanged<CustomerDetails> goToUpdateBasementReport;
  final ValueChanged<CustomerDetails> goToAddEstimate;
  final ValueChanged<CustomerDetails> goToUpdateEstimate;
  final ValueChanged<CustomerDetails> goToRecommendedLevel;
  CustomerDetails customer;
  LoggedInUser loggedInUser;


  EditCustomerFragment({this.login, this.customerID, this.backToDashboard,
    this.goToAddBasementReport, this.goToUpdateBasementReport,
    this.goToAddEstimate, this.goToUpdateEstimate, this.goToRecommendedLevel,
    this.customer, this.loggedInUser});

  @override
  _AddCustomerState createState() => _AddCustomerState();
}

class _AddCustomerState extends State<EditCustomerFragment> {
  DBHelper dbHelper = new DBHelper();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Zip zipDatas;

  bool _isGettingZipCodes = false;

  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _lastNameController = new TextEditingController();
  TextEditingController _businessTypeController = new TextEditingController();
  TextEditingController _primaryPhoneController = new TextEditingController();
  TextEditingController _cellPhoneController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _streetController = new TextEditingController();
  TextEditingController _cityController = new TextEditingController();
  TextEditingController _stateController = new TextEditingController();
  TextEditingController _zipController = new TextEditingController();

  List<DropDownSingleItem> TypeArray = [];
  int TypeDropdown;

  static String ACCESS_TOKEN = "";
  Product selectedProduct;
  final _UsNumberTextInputFormatter = UsNumberTextInputFormatter();

  @override
  void initState() {
    _checkBasementData();
    super.initState();
    Future.delayed(Duration.zero, () => getData());
    if (!widget.login.isAuthenticated) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => LogInUI(widget.login)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.customer.Name, style: Theme.of(context).textTheme.title.copyWith(color: Colors.black, fontWeight: FontWeight.bold),),
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _firstNameController,
                      style: customTextStyle(),
                      cursorColor: Colors.black87,
                      autofocus: false,
                      onChanged: (val) {
                        setState(() {});
                      },
                      validator: (val) {
                        return _firstNameController.text.isNotEmpty
                            ? null
                            : "* Required";
                      },
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      decoration: new InputDecoration(
                        labelText: "First Name",
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.black87)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        icon: new Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        hintStyle: customHintStyle(),
                        isDense: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      cursorColor: Colors.black87,
                      keyboardType: TextInputType.text,
                      controller: _lastNameController,
                      maxLines: 1,
                      autofocus: false,
                      textInputAction: TextInputAction.next,
                      validator: (val) {
                        return _lastNameController.text.isNotEmpty
                            ? null
                            : "* Required";
                      },
                      onChanged: (val) {
                        setState(() {});
                      },
                      style: customTextStyle(),
                      decoration: new InputDecoration(
                        labelText: "Last Name",
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.black87)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        icon: new Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        hintStyle: customHintStyle(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              DropdownButtonFormField(
                isDense: true,
                decoration: new InputDecoration(
                    icon: Icon(Icons.business),
                    labelText: "Business Type",
                    labelStyle: customTextStyle(),
                    hintText: "e.g. hint",
                    hintStyle: customHintStyle(),
                    alignLabelWithHint: false,
                    isDense: true),
                validator: (val) {
                  return TypeDropdown == 0
                      ? "Select another value"
                      : null;
                },
                items: List.generate(TypeArray.length, (index) {
                  return DropdownMenuItem(
                      value: index,
                      child: Text(TypeArray[index].DisplayText));
                }),
                onChanged: (index) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    TypeDropdown = index;
                  });
                },
                value: TypeDropdown,
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                cursorColor: Colors.black87,
                style: customTextStyle(),
                controller: _businessTypeController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                maxLines: 1,
                autofocus: false,
                onChanged: (val) {
                  setState(() {});
                },
                validator: (val) {
                  return TypeDropdown == 1
                      ? (_businessTypeController.text.isNotEmpty
                      ? null
                      : "* Required")
                      : null;
                },
                decoration: new InputDecoration(
                  labelText: "Business Name",
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black87)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  icon: new Icon(
                    Icons.business,
                    color: Colors.grey,
                  ),
                  isDense: true,
                  hintStyle: customHintStyle(),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _primaryPhoneController,
                      style: customTextStyle(),
                      onChanged: (val) {
                        setState(() {});
                      },
                      cursorColor: Colors.black87,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      autofocus: false,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                        _UsNumberTextInputFormatter,
                      ],
                      validator: (val) {
                        return _primaryPhoneController.text.isNotEmpty
                            ? null
                            : "* Required";
                      },
                      decoration: new InputDecoration(
                        labelText: "Primary Phone",
                        focusedBorder: UnderlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.black87)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        icon: new Icon(
                          Icons.call,
                          color: Colors.grey,
                        ),
                        hintStyle: customHintStyle(),
                        isDense: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      cursorColor: Colors.black87,
                      style: customTextStyle(),
                      controller: _cellPhoneController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      autofocus: false,
                      onChanged: (val) {
                        setState(() {});
                      },
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly,
                        _UsNumberTextInputFormatter,
                      ],
                      decoration: new InputDecoration(
                        labelText: "Cell Phone",
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black87)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        icon: new Icon(
                          Icons.call,
                          color: Colors.grey,
                        ),
                        isDense: true,
                        hintStyle: customHintStyle(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                cursorColor: Colors.black87,
                style: customTextStyle(),
                controller: _emailController,
                autofocus: false,
                onChanged: (val) {
                  setState(() {});
                },
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                maxLines: 1,
                validator: (val) {
                  return _emailController.text.isNotEmpty
                      ? null
                      : "* Required";
                },
                decoration: new InputDecoration(
                  labelText: "Email",
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black87)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  icon: new Icon(
                    Icons.email,
                    color: Colors.grey,
                  ),
                  hintStyle: customHintStyle(),
                  isDense: true,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                cursorColor: Colors.black87,
                style: customTextStyle(),
                controller: _streetController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                autofocus: false,
                onChanged: (val) {
                  setState(() {});
                },
                maxLines: 1,
                validator: (val) {
                  return _streetController.text.isNotEmpty
                      ? null
                      : "* Required";
                },
                decoration: new InputDecoration(
                  labelText: "Street",
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black87)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  icon: new Icon(
                    MdiIcons.road,
                    color: Colors.grey,
                  ),
                  hintStyle: customHintStyle(),
                  isDense: true,
                ),
              ),
              SizedBox(
                height: 16,
              ),TypeAheadFormField(
                validator: (val) {
                  return _zipController.text.isNotEmpty
                      ? null
                      : "* Required";
                },
                textFieldConfiguration: TextFieldConfiguration(
                    controller: _zipController,
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    decoration: new InputDecoration(
                      labelText: "Zip",
                      hintText: "e.g. - 12345",
                      focusedBorder: UnderlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.black87)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.grey)),
                      icon: new Icon(
                        MdiIcons.zipBox,
                        color: Colors.grey,
                      ),
                      suffixIcon: _isGettingZipCodes
                          ? CupertinoActivityIndicator()
                          : Container(
                        width: 0,
                        height: 0,
                      ),
                      hintStyle: customHintStyle(),
                      isDense: true,
                    )),
                suggestionsCallback: (pattern) async {
                  if (_zipController.text.length >= 3) {
                    setState(() {
                      _isGettingZipCodes = true;
                    });
                    return await getZipData(pattern);
                  } else {
                    return null;
                  }
                },
                itemBuilder: (context, suggestion) {
                  Zip zip = suggestion;
                  return ListTile(
                    leading: Icon(MdiIcons.zipBoxOutline),
                    title: Text(zip.zipCode),
                    subtitle: Row(
                      children: <Widget>[
                        Text(zip.city + ","),
                        Text(zip.state),
                      ],
                    ),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  zipDatas = suggestion;

                  setState(() {
                    _zipController.text = zipDatas.zipCode;
                    _cityController.text = zipDatas.city;
                    _stateController.text = zipDatas.state;
                  });
                },
                hideSuggestionsOnKeyboardHide: true,
                hideOnError: true,
              ),
              TextFormField(
                cursorColor: Colors.black87,
                style: customTextStyle(),
                controller: _cityController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                autofocus: false,
                onChanged: (val) {
                  setState(() {});
                },
                maxLines: 1,
                validator: (val) {
                  return _cityController.text.isNotEmpty
                      ? null
                      : "* Required";
                },
                decoration: new InputDecoration(
                  labelText: "City",
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black87)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  icon: new Icon(
                    Icons.location_city,
                    color: Colors.grey,
                  ),
                  hintStyle: customHintStyle(),
                  isDense: true,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                style: customTextStyle(),
                cursorColor: Colors.black87,
                controller: _stateController,
                autofocus: false,
                textCapitalization: TextCapitalization.characters,
                maxLength: 2,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                onChanged: (val) {
                  setState(() {});
                },
                maxLines: 1,
                validator: (val) {
                  return _stateController.text.isNotEmpty
                      ? null
                      : "* Required";
                },
                decoration: new InputDecoration(
                  labelText: "State",
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.black87)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  icon: new Icon(
                    MdiIcons.homeCity,
                    color: Colors.grey,
                  ),
                  hintStyle: customHintStyle(),
                  isDense: true,
                ),
              ),
              SizedBox(
                height: 36,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: EdgeInsets.only(right: 36),
                  height: 64,
                  width: 156,
                  child: RaisedButton(
                    highlightElevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(36.0),
                        side: BorderSide(color: Colors.white12)),
                    disabledColor: Colors.black,
                    color: Colors.black,
                    elevation: 2,
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
                        showDialog(context: context, builder: (_)=>loadingAlert());
                        makeRequest();
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
              SizedBox(
                height: 32,
              )
            ],
          ),
        ),
      ),
    );
  }

  getData() async {
    showDialog(context: context, builder: (_) => loadingAlert());
    Map<String, String> headers = {
      'Authorization': widget.login.accessToken,
      'Key': 'CustomerType'
    };
    try {
      var result = await http.get(BASE_URL + API_GET_LOOK_UP, headers: headers);
      if (result.statusCode == 200) {
        var map = json.decode(result.body)['data'];
        List<DropDownSingleItem> lists = List.generate(map.length, (index) {
          return DropDownSingleItem.fromMap(map[index]);
        });
        for (DropDownSingleItem item in lists) {
          switch (item.DataKey) {
            case 'CustomerType':
              TypeArray.add(item);
              break;
          }
        }

        _firstNameController.text = widget.customer.FirstName;
        _lastNameController.text = widget.customer.LastName;
        int counter = 0;
        for(DropDownSingleItem item in TypeArray){
          if(item.DataValue==widget.customer.Type) {
            TypeDropdown = counter;
            break;
            } else {
            counter++;
          }
        }
        _businessTypeController.text = widget.customer.BusinessName;
        _primaryPhoneController.text = widget.customer.PrimaryPhone;
        _cellPhoneController.text = widget.customer.SecondaryPhone;
        _emailController.text = widget.customer.EmailAddress;
        _streetController.text = widget.customer.Street;
        _cityController.text = widget.customer.City;
        _stateController.text = widget.customer.State;
        _zipController.text = widget.customer.ZipCode;

        setState(() {

        });
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
      }
    } catch (error) {
      Navigator.of(context).pop();
    }
  }

  Future getZipData(String pattern) async {
    if (pattern.isNotEmpty) {
      Map<String, String> headers = {
        'key': _zipController.text,
        'appname': "GrateApp",
      };

      var result = await http.get(
          "http://zipcodelookup.rmrcloud.com/1.0/GetCityZipCodeLookupList",
          headers: headers);
      if (result.statusCode == 200) {
        try {
          var map = json.decode(result.body);
          List<Zip> _zipList = List.generate(map.length, (index) {
            return Zip.fromMap(map[index]);
          });
          setState(() {
            _isGettingZipCodes = false;
          });
          return _zipList;
        } catch (error) {
          setState(() {
            _isGettingZipCodes = false;
          });
          return [];
        }
      } else {
        setState(() {
          _isGettingZipCodes = false;
        });
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        return [];
      }
    } else {
      setState(() {
        _isGettingZipCodes = false;
      });
    }
  }

  void _checkBasementData() async {
    List<BasementReport> basementsDatas = await dbHelper.getBasementData();
    if (basementsDatas.isNotEmpty && basementsDatas.length != 0) {
      showPopup(
          basementsDatas[0].header.replaceAll("\n", ""), basementsDatas[0].id);
    } else {}
  }

  void showPopup(String header, int id) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.all(0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Container(
              width: 600,
              height: 600,
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  Image.asset('images/no_internet.gif', fit: BoxFit.cover),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 64,
                            child: OutlineButton(
                              highlightElevation: 2,
                              color: Colors.black,
                              textColor: Colors.white,
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                "Discard",
                                style: new TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontFamily: "Roboto"),
                              ),
                              onPressed: () {
                                DBHelper dbHelper = new DBHelper();
                                dbHelper.delete(
                                    id, DBInfo.TABLE_BASEMENT_INSPECTION);
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 64,
                            child: RaisedButton(
                              highlightElevation: 2,
                              disabledColor: Colors.black,
                              color: Colors.black,
                              elevation: 2,
                              textColor: Colors.white,
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                "Sync",
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontFamily: "Roboto"),
                              ),
                              onPressed: () {
                                _syncBaseData(header, id);
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  _syncBaseData(String header, id) async {
    showDialog(context: context, builder: (context) => alertLoading());
    await saveInspectionReport(header, context, widget.login, id);
    Navigator.of(context).pop();
  }

  alertLoading() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: SimpleDialog(
        contentPadding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 400,
                height: 400,
                child: Image.asset(
                  "images/success.gif",
                  fit: BoxFit.cover,
                  scale: 1.5,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8)),
                          color: Colors.black,
                        ),
                        height: 48,
                        child: Center(
                          child: Text(
                            "Close",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  makeRequest() async {
    try {
      Map<String, String> data = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'authorization': widget.login.accessToken,
        'FirstName': '${_firstNameController.text}',
        'LastName': '${_lastNameController.text}',
        'BusinessName': '${_businessTypeController.text}',
        'Type': TypeArray[TypeDropdown].DataValue,
        'PrimaryPhone': '${_primaryPhoneController.text}',
        'CellNo': '${_cellPhoneController.text}',
        'email': '${_emailController.text}',
        'Street': '${_streetController.text}',
        'City': '${_cityController.text}',
        'State': '${_stateController.text}',
        'ZipCode': '${_zipController.text}',
        'IsLead': 'false',
        "LeadSource": "-1",
        "Id": "${widget.customer.Id}",
      };
      http.post(BASE_URL + API_SAVE_CUSTOMER, headers: data).then((response) {
        print(json.encode(data));
        if (response.statusCode == 200) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          widget.backToDashboard(0);
          showMessage(context, "Congratulations!", "${widget.customer.Name}'s profile updated successfully",
              Colors.green, Icons.check);
        } else {
          Navigator.of(context).pop();
          showMessage(context, "Error!", "Something went wrong",
              Colors.redAccent, Icons.warning);
        }
      });
    } catch (error) {
      Navigator.of(context).pop();
      showMessage(context, "Error!", "Something went wrong",
          Colors.redAccent, Icons.warning);
    }
  }
//-----------------------Offline DB-----------------------
}
