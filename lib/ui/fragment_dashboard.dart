import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/model/customer_model.dart';
import 'package:flutter_grate_app/model/hive/user.dart';
import 'package:flutter_grate_app/utils.dart';
import 'package:flutter_grate_app/widgets/customer_list_shimmer.dart';
import 'package:flutter_grate_app/widgets/list_row_item.dart';
import 'package:flutter_grate_app/widgets/list_shimmer_item_customer.dart';
import 'package:flutter_grate_app/widgets/list_shimmer_item_multiline_customer.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:flutter_grate_app/widgets/widget_no_internet.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../constraints.dart';

class DashboardFragment extends StatefulWidget {
  final ValueChanged<String> goToCustomerDetails;
  final ValueChanged<String> goToSearch;

  DashboardFragment({this.goToCustomerDetails, this.goToSearch});

  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment>
    with SingleTickerProviderStateMixin {
  List<Customer> arrayList = [];
  Customer customer;

  bool _showPaginationShimmer = false;
  bool offline = false;
  ScrollController _scrollController;
  int _pageNo = 0;
  int _totalSize = 0;

  var _paginationFocus = FocusNode();
  var _future;

  Box<User> userBox;
  User user;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _showPaginationShimmer = false;
    userBox = Hive.box("users");
    user = userBox.getAt(0);
    _future = getData();
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
                user.companyName,
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
                      child: !offline
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
                          : NoInternetConnectionWidget(refreshConnectivity),
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

  refreshConnectivity(bool flag) {
    setState(() {
      offline = flag;
    });
  }

  Future getData() async {
    try {
      Map<String, String> headers = {
        'Authorization': user.accessToken,
        'PageNo': (++_pageNo).toString(),
        'PageSize': '30',
        'ResultType': 'Customer'
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
          offline = false;
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
          offline = true;
        });
        showNoInternetConnection(context);
        return [];
      }
    }
  }

  Future fetchData() async {
    try {
      Map<String, String> headers = {
        'Authorization': user.accessToken,
        'PageNo': (++_pageNo).toString(),
        'PageSize': '30',
        'ResultType': 'Customer'
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
          offline = false;
          arrayList.addAll(_arrayList);
        });
        return _arrayList;
      } else {
        setState(() {
          offline = false;
        });
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        return "[]";
      }
    } catch (error) {
      if (error.toString().contains("SocketException")) {
        setState(() {
          offline = true;
        });
        showNoInternetConnection(context);
        return "[]";
      }
    }
  }

  Future resetData() async {
    showDialog(context: context, builder: (context) => loadingAlert());
    try {
      Map<String, String> headers = {
        'Authorization': user.accessToken,
        'PageNo': "1",
        'PageSize': '30',
        'ResultType': 'Customer'
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
          offline = false;
          arrayList.clear();
          arrayList.addAll(_arrayList);
        });
        Navigator.of(context).pop();
        return "[]";
      } else {
        setState(() {
          offline = false;
        });
        Navigator.of(context).pop();
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        return "[]";
      }
    } catch (error) {
      Navigator.of(context).pop();
      if (error.toString().contains("SocketException")) {
        setState(() {
          offline = true;
        });
        showNoInternetConnection(context);
      }
      return "[]";
    }
  }

  Future deleteCustomer(int index) async {
    try {
      Map<String, String> headers = {
        'Authorization': user.accessToken,
        'customerid': arrayList[index].Id,
      };

      var result =
          await http.delete(BASE_URL + API_DELETE_CUSTOMER, headers: headers);
      if (result.statusCode == 200) {
        arrayList.removeAt(index);
        setState(() {
          offline = false;
        });
        return json.decode(result.body)['result'];
      } else {
        setState(() {
          offline = false;
        });
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        return [];
      }
    } catch (error) {
      Navigator.of(context).pop();
      if (error.toString().contains("SocketException")) {
        setState(() {
          offline = true;
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
}
