import 'package:flutter/material.dart';
import 'package:flutter_grate_app/drawer/sync_nav_item.dart';
import 'package:flutter_grate_app/model/hive/basement_report.dart';
import 'package:flutter_grate_app/model/hive/user.dart';
import 'package:flutter_grate_app/model/navigation_model.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:hive/hive.dart';

import '../utils.dart';
import 'collapsing_list_tile.dart';
import 'drawer_theme.dart';

class SideNavUI extends StatefulWidget {
  final ValueChanged<int> refreshEvent;

  const SideNavUI({Key key, this.refreshEvent})
      : super(key: key);

  @override
  SideNavUIState createState() => SideNavUIState();
}

class SideNavUIState extends State<SideNavUI>
    with SingleTickerProviderStateMixin {

  Box<User> userBox;
  User user;

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

  bool isSyncing = false;

  Box<BasementReport> reportBox;

  @override
  void initState() {

    userBox = Hive.box("users");
    reportBox = Hive.box("basement_reports");
    user = userBox.getAt(0);

    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 300));
    widthAnimation = Tween<double>(begin: maxWidth, end: minWidth)
        .animate(_animationController);
    sizedBoxAnimation = Tween<double>(begin: maxSize, end: minSize)
        .animate(_animationController);
    isSyncing = false;
    super.initState();
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
                      user.photo == null ||
                              user.photo.isEmpty
                          ? CircleAvatar(
                              maxRadius: 14,
                              minRadius: 14,
                              backgroundColor: Colors.black,
                              child: Text(
                                "${user.firstName} ${user.lastName}"
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
                                  image: user.photo
                                          .startsWith("/Files")
                                      ? "https://www.gratecrm.com" +
                                          user.photo
                                      : user.photo,
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
                                "${user.firstName} ${user.lastName}",
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
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: ScrollPhysics(),
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
                      reportBox.length!=0
                          ? SyncNavItem(
                              title: "${isSyncing ? "Syncing" : "Sync"} Data",
                              icon: Icons.sync,
                              animationController: _animationController,
                              onTap: () {
                                syncAlert();
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

  void syncAlert() {
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
                                for(int i=0; i < reportBox.length; i++){
                                  reportBox.deleteAt(i);
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
                                _syncToNetwork();
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

  _syncToNetwork() async {
    Navigator.of(context).pop();
    showDialog(context: context, builder: (context) => loadingAlert());

    for(int i=0; i < reportBox.length; i++){
      BasementReport item = reportBox.getAt(i);
      Map<String, String> headers = {};
      headers['Authorization'] = user.accessToken;
      headers['CustomerId'] = item.CustomerId;
      headers['companyId'] = item.CompanyId;
      headers['CurrentOutsideConditions'] =
          item.CurrentOutsideConditions;
      headers['OutsideRelativeHumidity'] =
          item.OutsideRelativeHumidity.toString();
      headers['OutsideTemperature'] = item.OutsideTemperature.toString();
      headers['FirstFloorRelativeHumidity'] = item.FirstFloorRelativeHumidity.toString();
      headers['FirstFloorTemperature'] = item.FirstFloorTemperature.toString();
      headers['RelativeOther1'] = item.RelativeOther1;
      headers['RelativeOther2'] = item.RelativeOther2;
      headers['Heat'] = item.Heat;
      headers['Air'] = item.Air;
      headers['BasementRelativeHumidity'] =item.BasementRelativeHumidity.toString();
      headers['BasementTemperature'] = item.BasementTemperature.toString();
      headers['BasementDehumidifier'] =item.BasementDehumidifier;
      headers['GroundWater'] = item.GroundWater;
      headers['GroundWaterRating'] =item.GroundWaterRating.toString();
      headers['IronBacteria'] = item.IronBacteria;
      headers['IronBacteriaRating'] =item.IronBacteriaRating.toString();
      headers['Condensation'] = item.Condensation;
      headers['CondensationRating'] =item.CondensationRating.toString();
      headers['WallCracks'] = item.WallCracks;
      headers['WallCracksRating'] =item.WallCracksRating.toString();
      headers['FloorCracks'] = item.FloorCracks;
      headers['FloorCracksRating'] =item.FloorCracksRating.toString();
      headers['ExistingSumpPump'] =item.ExistingSumpPump;
      headers['ExistingDrainageSystem'] =item.ExistingDrainageSystem;
      headers['ExistingRadonSystem'] =item.ExistingRadonSystem;
      headers['DryerVentToCode'] =item.DryerVentToCode;
      headers['FoundationType'] =item.FoundationType;
      headers['Bulkhead'] = item.Bulkhead;
      headers['VisualBasementOther'] =item.VisualBasementOther;
      headers['NoticedSmellsOrOdors'] =item.NoticedSmellsOrOdors;
      headers['NoticedSmellsOrOdorsComment'] =item.NoticedSmellsOrOdorsComment;
      headers['NoticedMoldOrMildew'] =item.NoticedMoldOrMildew;
      headers['NoticedMoldOrMildewComment'] =item.NoticedMoldOrMildewComment;
      headers['BasementGoDown'] =item.BasementGoDown;
      headers['HomeSufferForRespiratory'] =item.HomeSufferForRespiratory;
      headers['HomeSufferForrespiratoryComment'] =item.HomeSufferForrespiratoryComment;
      headers['ChildrenPlayInBasement'] =item.ChildrenPlayInBasement;
      headers['ChildrenPlayInBasementComment'] =item.ChildrenPlayInBasementComment;
      headers['PetsGoInBasement'] =item.PetsGoInBasement;
      headers['PetsGoInBasementComment'] = item.PetsGoInBasementComment;
      headers['NoticedBugsOrRodents'] =item.NoticedBugsOrRodents;
      headers['NoticedBugsOrRodentsComment'] =item.NoticedBugsOrRodentsComment;
      headers['GetWater'] = item.GetWater;
      headers['GetWaterComment'] = item.GetWaterComment;
      headers['RemoveWater'] = item.RemoveWater;
      headers['SeeCondensationPipesDripping'] =item.SeeCondensationPipesDripping;
      headers['SeeCondensationPipesDrippingComment'] =item.SeeCondensationPipesDrippingComment;
      headers['RepairsProblems'] =item.RepairsProblems;
      headers['RepairsProblemsComment'] =item.RepairsProblemsComment;
      headers['LivingPlan'] = item.LivingPlan;
      headers['SellPlaning'] = item.SellPlaning;
      headers['PlansForBasementOnce'] =item.PlansForBasementOnce;
      headers['HomeTestForPastRadon'] =item.HomeTestForPastRadon;
      headers['HomeTestForPastRadonComment'] =item.HomeTestForPastRadonComment;
      headers['LosePower'] = item.LosePower;
      headers['LosePowerHowOften'] =item.LosePowerHowOften;
      headers['CustomerBasementOther'] =item.CustomerBasementOther;
      headers['Notes'] = item.Notes;
      await saveInspectionReport(headers);
    }
    reportBox.clear();
    Navigator.of(context).pop();
    setState(() {
      isSyncing = false;
    });
  }
//-----------------------Offline DB-----------------------
}
