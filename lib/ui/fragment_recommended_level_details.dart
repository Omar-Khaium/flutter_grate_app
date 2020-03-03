import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/model/customer_details.dart';
import 'package:flutter_grate_app/model/video_preview.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/sqflite/model/user.dart';
import 'package:flutter_grate_app/widgets/widget_media_player.dart';
import 'package:flutter_grate_app/widgets/widget_no_internet.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../utils.dart';

class RecommendedLevelDetails extends StatefulWidget {
  final Login login;
  final ValueChanged<int> backToCustomerDetails;
  final LoggedInUser loggedInUser;
  final CustomerDetails customer;
  final int index;

  RecommendedLevelDetails({
    Key key,
    this.login,
    this.loggedInUser,
    this.index,
    this.customer,
    this.backToCustomerDetails,
  }) : super(key: key);

  @override
  _RecommendedLevelDetails createState() => _RecommendedLevelDetails();
}

class _RecommendedLevelDetails extends State<RecommendedLevelDetails> with SingleTickerProviderStateMixin {
  List<String> _videoLinks = [
    "Eb5QhpcRHVg",
    "3HIV1Q8Oxsw",
    "xDPM7n0M9Yw",
    "gat8ZT7nP8s",
    "dwYzWVMLQ_k",
    "bBCM6G5Jvpk",
  ];

  bool isLoading = false;
  bool offline = false;

  var key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Recommended Level ${widget.index}",
          style: Theme.of(context)
              .textTheme
              .title
              .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 8,
        onPressed: offline ? null : () {
          showDialog(context: context, builder: (_) => loadingAlert());
          _save();
        },
        icon: Icon(Icons.save),
        label: Text("Save"),
        backgroundColor: offline ? Colors.grey : Colors.black,
      ),
      backgroundColor: Colors.white,
      body: OrientationBuilder(
        builder: (context, orientation){
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 4,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: <Widget>[
                          ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.fiber_manual_record,
                              color: Colors.grey.shade800,
                              size: 16,
                            ),
                            title: Wrap(
                              children: <Widget>[
                                Text(
                                  "Maintencane",
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 24,
                                      fontWeight: FontWeight.normal,
                                      decoration: (widget.index) >= 6
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                      decorationThickness: 2,
                                      decorationColor: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.fiber_manual_record,
                              color: Colors.grey.shade800,
                              size: 16,
                            ),
                            title: Wrap(
                              children: <Widget>[
                                Text(
                                  "Carbon Monoxide Detector",
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 24,
                                      fontWeight: FontWeight.normal,
                                      decoration: (widget.index) >= 5
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                      decorationThickness: 2,
                                      decorationColor: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.fiber_manual_record,
                              color: Colors.grey.shade800,
                              size: 16,
                            ),
                            title: Wrap(
                              children: <Widget>[
                                Text(
                                  "Moisture Control",
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 24,
                                      fontWeight: FontWeight.normal,
                                      decoration: (widget.index) >= 5
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                      decorationThickness: 2,
                                      decorationColor: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.fiber_manual_record,
                              color: Colors.grey.shade800,
                              size: 16,
                            ),
                            title: Wrap(
                              children: <Widget>[
                                Text(
                                  "Full Wall Protection",
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 24,
                                      fontWeight: FontWeight.normal,
                                      decoration: (widget.index) >= 4
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                      decorationThickness: 2,
                                      decorationColor: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.fiber_manual_record,
                              color: Colors.grey.shade800,
                              size: 16,
                            ),
                            title: Wrap(
                              children: <Widget>[
                                Text(
                                  "Full Perimerter GD System",
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 24,
                                      fontWeight: FontWeight.normal,
                                      decoration: (widget.index) >= 3
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                      decorationThickness: 2,
                                      decorationColor: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.fiber_manual_record,
                              color: Colors.grey.shade800,
                              size: 16,
                            ),
                            title: Wrap(
                              children: <Widget>[
                                Text(
                                  "FastSump Perimeter Inverter & Battery",
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 24,
                                      fontWeight: FontWeight.normal,
                                      decoration: (widget.index) >= 2
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                      decorationThickness: 2,
                                      decorationColor: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.fiber_manual_record,
                              color: Colors.grey.shade800,
                              size: 16,
                            ),
                            title: Wrap(
                              children: <Widget>[
                                Text(
                                  "Secondary Pump",
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 24,
                                      fontWeight: FontWeight.normal,
                                      decoration: (widget.index) >= 2
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                      decorationThickness: 2,
                                      decorationColor: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.fiber_manual_record,
                              color: Colors.grey.shade800,
                              size: 16,
                            ),
                            title: Wrap(
                              children: <Widget>[
                                Text(
                                  "Secondary Fast Sump Liner",
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 24,
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none,
                                      decorationThickness: 2,
                                      decorationColor: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.fiber_manual_record,
                              color: Colors.grey.shade800,
                              size: 16,
                            ),
                            title: Wrap(
                              children: <Widget>[
                                Text(
                                  "Primary FastSump",
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 24,
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none,
                                      decorationThickness: 2,
                                      decorationColor: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.fiber_manual_record,
                              color: Colors.grey.shade800,
                              size: 16,
                            ),
                            title: Wrap(
                              children: <Widget>[
                                Text(
                                  "Pump Geek / Radon Test Kit",
                                  style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 24,
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.none,
                                      decorationThickness: 2,
                                      decorationColor: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
                      child: offline ? NoInternetConnectionWidget(refreshConnectivity) : Stack(
                        children: <Widget>[
                          InkWell(
                            onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>VideoPlayerScreen(url: _videoLinks[widget.index - 1],),fullscreenDialog: true)),
                            child: Image.network(
                              "https://img.youtube.com/vi/${_videoLinks[widget.index - 1]}/maxresdefault.jpg",
                              fit: BoxFit.contain,
                              loadingBuilder: (BuildContext context, Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) {
                                  isLoading = false;
                                  return child;
                                }
                                isLoading = true;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                          isLoading ? Container() : Positioned(
                            left: 0,
                            right: 0,
                            top: orientation == Orientation.landscape ? 144 : 72,
                            child: IconButton(icon: Icon(MdiIcons.youtube, color: Color(0xFFff0000), size: 144,),onPressed: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>VideoPlayerScreen(url: _videoLinks[widget.index - 1],),fullscreenDialog: true)),),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  refreshConnectivity(bool flag) {
    setState(() {
      offline = flag;
    });
  }

  Future _save() async {
    try {
      Map<String, String> headers = {
        'Authorization': widget.login.accessToken,
        'Id': widget.customer.Id,
        'RecommendedLevel': (widget.index).toString(),
        'CompanyId': widget.loggedInUser.CompanyGUID,
      };

      var result = await http.post(BASE_URL + API_SAVE_RECOMMENDED_LEVEL,
          headers: headers);
      if (result.statusCode == 200) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        widget.backToCustomerDetails(0);
        setState(() {});
        showMessage(
            context,
            "Congratulations!",
            "Recommended level is saved as \"Level ${widget.index}\"",
            Colors.green,
            Icons.warning);
      } else {
        Navigator.of(context).pop();
        setState(() {
          offline = false;
        });
        showMessage(context, "Error!", "Something went wrong!!!",
            Colors.redAccent, Icons.warning);
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

  _checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      setState(() {
        offline = true;
      });
    }
  }
}
