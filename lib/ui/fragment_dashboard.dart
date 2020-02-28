import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/model/customer_model.dart';
import 'package:flutter_grate_app/sqflite/database_info.dart';
import 'package:flutter_grate_app/sqflite/db_helper.dart';
import 'package:flutter_grate_app/sqflite/model/BasementReport.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/sqflite/model/user.dart';
import 'package:flutter_grate_app/utils.dart';
import 'package:flutter_grate_app/widgets/customer_list_shimmer.dart';
import 'package:flutter_grate_app/widgets/list_row_item.dart';
import 'package:flutter_grate_app/widgets/list_shimmer_item_customer.dart';
import 'package:flutter_grate_app/widgets/list_shimmer_item_multiline_customer.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:flutter_grate_app/widgets/widget_no_internet.dart';
import 'package:http/http.dart' as http;

class DashboardFragment extends StatefulWidget {
  final ValueChanged<String> goToCustomerDetails;
  final ValueChanged<String> goToSearch;
  final Login login;
  final LoggedInUser loggedInUser;

  DashboardFragment(
      {Key key,
      this.login,
      this.goToCustomerDetails,
      this.goToSearch,
      this.loggedInUser})
      : super(key: key);

  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment>
    with SingleTickerProviderStateMixin {
  List<Customer> arrayList = [];
  Customer customer;

  bool _showPaginationShimmer = false;
  bool isOffline = false;
  ScrollController _scrollController;
  int _pageNo = 0;
  int _totalSize = 0;

  DBHelper dbHelper = new DBHelper();
  var _paginationFocus = FocusNode();
  var _future;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _showPaginationShimmer = false;
    _future = getData();
    _checkBasementData();
    super.initState();
  }

  _scrollListener() async {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        !_showPaginationShimmer) {
      if (_totalSize > arrayList.length) {
        setState(() {
          _showPaginationShimmer = true;
        });
        _paginationFocus.requestFocus();
        await fetchData();
        setState(() {
          _showPaginationShimmer = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      margin: EdgeInsets.only(top: 16, left: 32, right: 32),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Dashboard",
                style: fragmentTitleStyle(),
              ),
              Container(
                width: 256,
                height: 48,
                padding: EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48),
                    color: Colors.grey.shade100),
                child: Center(
                  child: InkWell(
                    child: TextField(
                      cursorColor: Colors.black,
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.grey.shade900, fontSize: 18),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onChanged: (val) {},
                      onSubmitted: (val) {
                        if (val.isNotEmpty) {
                          widget.goToSearch(val);
                        }
                      },
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(style: BorderStyle.none)),
                          disabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(style: BorderStyle.none)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(style: BorderStyle.none)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(style: BorderStyle.none)),
                          errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(style: BorderStyle.none)),
                          hintText: "Search",
                          isDense: true),
                    ),
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.loggedInUser.CompanyName,
                style: new TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 16),
              ),
              Text(
                "${arrayList.length} out of $_totalSize",
                style: new TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 16),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: CupertinoSlidingSegmentedControl(
              children: <int, Widget>{
                0: Padding(
                  child: Text("Leads"),
                  padding: EdgeInsets.all(8),
                ),
                1: Padding(
                  child: Text("Customers"),
                  padding: EdgeInsets.all(8),
                ),
              },
              onValueChanged: onValueChanged,
              groupValue: CURRENTSEGMENT,
              backgroundColor: CupertinoColors.tertiarySystemFill,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Expanded(
            child: FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  try {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: !isOffline
                          ? ListView(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              controller: _scrollController,
                              children: <Widget>[
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  itemCount: arrayList.length,
                                  itemBuilder: (context, index) {
                                    customer = arrayList[index];
                                    return InkWell(
                                      onTap: () {
                                        widget.goToCustomerDetails(
                                            arrayList[index].Id);
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    ListRowItem(
                                                      icon: Icons.person,
                                                      text: customer.Name,
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    ListRowItem(
                                                      icon: Icons.phone,
                                                      text: customer.ContactNum,
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    ListRowItem(
                                                      icon: Icons.email,
                                                      text: customer.Email,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    ListRowItem(
                                                      icon: Icons.pin_drop,
                                                      text: customer.Address,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              deleteMessage(
                                                                  index));
                                                    },
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.grey.shade300,
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: Colors.black,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Divider(),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                _showPaginationShimmer
                                    ? Focus(
                                        autofocus: false,
                                        focusNode: _paginationFocus,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      ShimmerItemCustomer(250),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      ShimmerItemCustomer(125),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      ShimmerItemCustomer(175),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      ShimmerItemMultiLineCustomer(
                                                          300),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 8,
                                ),
                              ],
                            )
                          : NoInternetConnectionWidget(),
                    );
                  } catch (error) {
                    return Container();
                  }
                } else {
                  return Container(
                    child: Center(
                      child: ShimmerDashboardFragment(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future getData() async {
    try {
      Map<String, String> headers = {
        'Authorization': widget.login.accessToken,
        'PageNo': (++_pageNo).toString(),
        'PageSize': '30',
        'ResultType': CURRENTSEGMENT == 1 ? 'Customer' : 'Lead'
      };

      var result =
          await http.get(BASE_URL + API_GET_ALL_CUSTOMER, headers: headers);
      if (result.statusCode == 200) {
        var map = json.decode(result.body);
        var _customersMap = map['data']['CustomerList'];
        _totalSize = map['data']['TotalCustomerCount']['Counter'];
        arrayList = List.generate(_customersMap.length, (index) {
          return Customer.fromMap(_customersMap[index]);
        });
        setState(() {
          isOffline = false;
        });
        return result;
      } else {
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        return [];
      }
    } catch (error) {
      if (error.toString().contains("SocketException")) {
        setState(() {
          isOffline = true;
        });
        showNoInternetConnection(context);
        return [];
      }
    }
  }

  Future fetchData() async {
    try {
      Map<String, String> headers = {
        'Authorization': widget.login.accessToken,
        'PageNo': (++_pageNo).toString(),
        'PageSize': '30',
        'ResultType': CURRENTSEGMENT == 1 ? 'Customer' : 'Lead'
      };

      var result =
          await http.get(BASE_URL + API_GET_ALL_CUSTOMER, headers: headers);
      if (result.statusCode == 200) {
        var map = json.decode(result.body);
        var _customersMap = map['data']['CustomerList'];
        List<Customer> _arrayList =
            List.generate(_customersMap.length, (index) {
          return Customer.fromMap(_customersMap[index]);
        });
        setState(() {
          isOffline = false;
          arrayList.addAll(_arrayList);
        });
        return _arrayList;
      } else {
        setState(() {
          isOffline = false;
        });
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        return [];
      }
    } catch (error) {
      if (error.toString().contains("SocketException")) {
        setState(() {
          isOffline = true;
        });
        showNoInternetConnection(context);
        return [];
      }
    }
  }

  Future resetData() async {
    showDialog(context: context, builder: (context) => loadingAlert());
    try {
      Map<String, String> headers = {
        'Authorization': widget.login.accessToken,
        'PageNo': "1",
        'PageSize': '30',
        'ResultType': CURRENTSEGMENT == 1 ? 'Customer' : 'Lead'
      };

      var result =
          await http.get(BASE_URL + API_GET_ALL_CUSTOMER, headers: headers);
      if (result.statusCode == 200) {
        var map = json.decode(result.body);
        _totalSize = map['data']['TotalCustomerCount']['Counter'];
        var _customersMap = map['data']['CustomerList'];
        List<Customer> _arrayList =
            List.generate(_customersMap.length, (index) {
          return Customer.fromMap(_customersMap[index]);
        });

        setState(() {
          isOffline = false;
          arrayList.clear();
          arrayList.addAll(_arrayList);
        });
        Navigator.of(context).pop();
      } else {
        setState(() {
          isOffline = false;
        });
        Navigator.of(context).pop();
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
      }
    } catch (error) {
      Navigator.of(context).pop();
      if (error.toString().contains("SocketException")) {
        setState(() {
          isOffline = true;
        });
        showNoInternetConnection(context);
      }
    }
  }

  Future deleteCustomer(int index) async {
    try {
      Map<String, String> headers = {
        'Authorization': widget.login.accessToken,
        'customerid': arrayList[index].Id,
      };

      var result =
          await http.delete(BASE_URL + API_DELETE_CUSTOMER, headers: headers);
      if (result.statusCode == 200) {
        arrayList.removeAt(index);
        setState(() {
          isOffline = false;
        });
        return json.decode(result.body)['result'];
      } else {
        setState(() {
          isOffline = false;
        });
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        return [];
      }
    } catch (error) {
      Navigator.of(context).pop();
      if (error.toString().contains("SocketException")) {
        setState(() {
          isOffline = true;
        });
        showNoInternetConnection(context);
      }
    }
  }

  alertSuccess() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: SimpleDialog(
        backgroundColor: Color(0xFF12C06A),
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

  alertFailed() {
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
                  "images/error.gif",
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

  deleteMessage(index) {
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
                  "images/delete.jpg",
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
                          borderRadius:
                              BorderRadius.only(bottomLeft: Radius.circular(8)),
                          color: Colors.black,
                        ),
                        height: 48,
                        child: Center(
                          child: Text(
                            "Cancel",
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
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(8)),
                          color: Colors.deepOrange,
                        ),
                        height: 48,
                        child: Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Delete",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        deleteDialog(index);
                      },
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

  void deleteDialog(int index) async {
    showDialog<void>(context: context, builder: (_) => loadingAlert());
    bool status = await deleteCustomer(index);
    Navigator.of(context).pop();
    if (status) {
      setState(() {});
      showDialog(context: context, builder: (context) => alertSuccess());
    } else {
      showDialog(context: context, builder: (context) => alertFailed());
    }
  }

  Future<void> _refresh() async {
    _pageNo = 0;
    await getData();
  }

  //-----------------------Offline DB-----------------------
  void _checkBasementData() async {
    List<BasementReport> basementsDatas = await dbHelper.getBasementData();
    if (basementsDatas.isNotEmpty && basementsDatas.length != 0) {
      showPopup(basementsDatas);
    } else {}
  }

  void showPopup(List<BasementReport> list) {
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
              width: 400,
              height: 400,
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  Align(
                      alignment: Alignment.center,
                      child: Image.asset('images/no_internet.gif',
                          fit: BoxFit.cover)),
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
                            child: RaisedButton(
                              highlightElevation: 2,
                              color: Colors.deepOrange,
                              textColor: Colors.white,
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                "Discard",
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontFamily: "Roboto"),
                              ),
                              onPressed: () {
                                DBHelper dbHelper = new DBHelper();
                                for (BasementReport item in list) {
                                  dbHelper.delete(item.id,
                                      DBInfo.TABLE_BASEMENT_INSPECTION);
                                }
//                                [0].header.replaceAll("\n", ""),basementsDatas[0].id
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
                              color: Colors.green,
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
                                _syncBaseData(list);
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

  _syncBaseData(List<BasementReport> list) async {
    showDialog(context: context, builder: (context) => alertLoading());

    for (BasementReport item in list) {
      await saveInspectionReport(
          item.header.replaceAll("\n", ""), context, widget.login, item.id);
    }
    Navigator.of(context).pop();
  }

  alertLoading() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: SimpleDialog(
        contentPadding: EdgeInsets.all(0),
        backgroundColor: Color(0xFF12C06A),
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
                  height: 400,
                  width: 400,
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
                        height: 54,
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

  void onValueChanged(int newValue) {
    setState(() {
      CURRENTSEGMENT = newValue;
      resetData();
    });
  }
}
