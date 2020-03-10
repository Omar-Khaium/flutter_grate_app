import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/drawer/sync_nav_item.dart';
import 'package:flutter_grate_app/model/navigation_model.dart';
import 'package:flutter_grate_app/sqflite/database_info.dart';
import 'package:flutter_grate_app/sqflite/db_helper.dart';
import 'package:flutter_grate_app/sqflite/model/BasementReport.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/sqflite/model/user.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';

import '../utils.dart';
import 'collapsing_list_tile.dart';
import 'drawer_theme.dart';

class SideNavUI extends StatefulWidget {
  final ValueChanged<int> refreshEvent;
  final Login login;
  final LoggedInUser loggedInUser;

  const SideNavUI({Key key, this.refreshEvent, this.login, this.loggedInUser})
      : super(key: key);

  @override
  SideNavUIState createState() => SideNavUIState();
}

class SideNavUIState extends State<SideNavUI>
    with SingleTickerProviderStateMixin {
  double maxWidth = 300;
  double maxSize = 16;
  double minWidth = 92;
  double minSize = 0;
  int currentSelectedIndex = 0;
  int lastSelectedIndex = 0;
  bool isCollapsed = false;
  AnimationController _animationController;
  Animation<double> widthAnimation, sizedBoxAnimation;
  String fragmentTitle = "Dashboard";
  Widget fragment;
  Widget lastFragment;
  DBHelper dbHelper = new DBHelper();

  bool isSyncing = false;
  bool needToSync = false;
  List<BasementReport> reports;

  @override
  void initState() {
    super.initState();

    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 300));
    widthAnimation = Tween<double>(begin: maxWidth, end: minWidth)
        .animate(_animationController);
    sizedBoxAnimation = Tween<double>(begin: maxSize, end: minSize)
        .animate(_animationController);
    isSyncing = false;
    refresh();
  }

  updateSelection(int selection) {
    setState(() {
      currentSelectedIndex = selection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget child) {
          return Container(
            width: widthAnimation.value,
            color: drawerBackgroundColor,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 12,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade50.withOpacity(.5),
                  ),
                  child: Row(
                    children: <Widget>[
                      widget.loggedInUser.ProfilePicture == null ||
                              widget.loggedInUser.ProfilePicture.isEmpty
                          ? CircleAvatar(
                              maxRadius: 14,
                              minRadius: 14,
                              backgroundColor: Colors.black,
                              child: Text(
                                widget.loggedInUser.UserName
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: customButtonTextStyle(),
                              ),
                            )
                          : Container(
                              width: 28,
                              height: 28,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: FadeInImage.assetNetwork(
                                  placeholder: "images/loading.gif",
                                  image: widget.loggedInUser.ProfilePicture
                                          .startsWith("/Files")
                                      ? "https://www.gratecrm.com" +
                                          widget.loggedInUser.ProfilePicture
                                      : widget.loggedInUser.ProfilePicture,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                      SizedBox(
                        width: sizedBoxAnimation.value,
                      ),
                      widthAnimation.value >= 290
                          ? SizedBox(
                              width: 192,
                              child: Text(
                                widget.loggedInUser.UserName,
                                style: defaultTextStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : new Container(),
                    ],
                  ),
                ),
                new Divider(
                  thickness: 1,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, counter) {
                          return CollapsingListTile(
                            title: navItems[counter].title,
                            icon: navItems[counter].icon,
                            animationController: _animationController,
                            isSelected: currentSelectedIndex == counter,
                            onTap: () {
                              setState(() {
                                currentSelectedIndex = counter;
                                widget.refreshEvent(currentSelectedIndex);
                              });
                            },
                          );
                        },
                        itemCount: navItems.length,
                      ),
                      needToSync
                          ? SyncNavItem(
                              title: "${isSyncing ? "Syncing" : "Sync"} Data",
                              icon: Icons.sync,
                              animationController: _animationController,
                              onTap: () {
                                syncAlert(reports);
                              },
                            )
                          : Container()
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isCollapsed = !isCollapsed;
                      isCollapsed
                          ? _animationController.forward()
                          : _animationController.reverse();
                    });
                  },
                  child: AnimatedIcon(
                    icon: AnimatedIcons.close_menu,
                    color: Colors.blueGrey.shade800,
                    size: 48,
                    progress: _animationController,
                  ),
                ),
                SizedBox(
                  height: 24,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  //-----------------------Offline DB-----------------------

  void syncAlert(List<BasementReport> list) {
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
                      child: Image.asset('images/sync.gif', fit: BoxFit.cover)),
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
                              color: Colors.grey.shade100,
                              textColor: Colors.white,
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                "Discard",
                                style: Theme.of(context).textTheme.body1.copyWith(color: Colors.black),
                              ),
                              onPressed: () {
                                DBHelper dbHelper = new DBHelper();
                                for (BasementReport item in list) {
                                  dbHelper.delete(item.id,
                                      DBInfo.TABLE_BASEMENT_INSPECTION);
                                }
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
                              color: Colors.blueGrey.shade900,
                              elevation: 2,
                              textColor: Colors.white,
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                "Sync",
                                  style: Theme.of(context).textTheme.body1.copyWith(color: Colors.white)
                              ),
                              onPressed: () {
                                setState(() {
                                  isSyncing = true;
                                });
                                _syncToNetwork(list);
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

  _syncToNetwork(List<BasementReport> list) async {
    Navigator.of(context).pop();
    showDialog(context: context, builder: (context) => loadingAlert());
    for (BasementReport item in list) {
      await saveInspectionReport(
          item.header.replaceAll("\n", ""), context, widget.login, item.id);
      Navigator.of(context).pop();
    }
    setState(() {
      isSyncing = false;
      needToSync = false;
    });
  }

  void refresh() async {
    while (true) {
      reports = await dbHelper.getBasementData();
      if (reports.isNotEmpty && reports.length != 0) {
        setState(() {
          needToSync = true;
        });
      }
    }
  }
//-----------------------Offline DB-----------------------
}
