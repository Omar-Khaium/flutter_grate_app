import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_grate_app/model/customer_model.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/widgets/custome_back_button.dart';
import 'package:flutter_grate_app/widgets/customer_list_shimmer.dart';
import 'package:flutter_grate_app/widgets/list_row_item.dart';
import 'package:flutter_grate_app/widgets/widget_no_internet.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

class SearchResultFragment extends StatefulWidget {
  final String searchText;
  final Login login;
  final ValueChanged<String> gotoDetails;
  final ValueChanged<int> backToDashboard;

  SearchResultFragment({this.searchText, this.login, this.gotoDetails, this.backToDashboard});

  @override
  _SearchResultFragmentState createState() => _SearchResultFragmentState();
}

class _SearchResultFragmentState extends State<SearchResultFragment> with SingleTickerProviderStateMixin {
  bool _isSearching = true;
  bool offline = false;
  List<Customer> _list;

  StreamController<List<Customer>> _controller =
      StreamController<List<Customer>>();

  @override
  void initState() {
    super.initState();
    getData();
  }

  refreshConnectivity(bool flag) {
    setState(() {
      offline = flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 32, right: 32, top: 16),
      alignment: Alignment.topCenter,
      child: Column(
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
                  Text(_isSearching
                      ? "Searching"
                      : "${_list!=null ? _list.length : "No"} ${_list!= null ? _list.length > 1 ? "results" : "result": "result"} found", style: Theme.of(context).textTheme.title.copyWith(color: Colors.black, fontWeight: FontWeight.bold),)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            child: Divider(),
            margin: EdgeInsets.only(left: 32, right: 32),
          ),
          Expanded(
            child: offline ? NoInternetConnectionWidget(refreshConnectivity) : StreamBuilder(
              stream: _controller.stream,
              initialData: _list,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _list!= null ? _list.length == 0
                      ? Center(
                        child: Image.asset(
                    "images/no_data.png",
                    fit: BoxFit.cover,
                          width: 224,
                          height: 224,
                  ),
                      )
                      : ListView.builder(
                    padding: EdgeInsets.all(16),
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: _list.length,
                    itemBuilder: (context, index) {
                      Customer customer = _list[index];
                      return InkWell(
                        onTap: () {
                          widget.gotoDetails(_list[index].Id);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ListRowItem(
                                        icon: Icons.pin_drop,
                                        text: customer.Address,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(8),
                                  margin: EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade200
                                  ),
                                  child: Text(customer.CustomerType),
                                )
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
                  ) : Container();
                } else {
                  return ShimmerDashboardFragment();
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
        'searchkey': '${widget.searchText}'
      };

      var result = await http.post(BASE_URL + API_SEARCH, headers: headers);
      setState(() {
        _isSearching = false;
        offline = false;
      });
      if (result.statusCode == 200) {
        var map = json.decode(result.body)['CustomerCustomModel'];
        _list = [];
        map.forEach((_item) {
          _list.add(Customer.fromMap(Map<String, dynamic>.from(_item)));
        });
        _controller.sink.add(_list);
      } else {
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        _controller.sink.add([]);
      }
    } catch (error) {
      setState(() {
        _isSearching = false;
        offline = true;
      });
      if (error.toString().contains("SocketException")) {
        showNoInternetConnection(context);
      }
      _controller.sink.add([]);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }
}
