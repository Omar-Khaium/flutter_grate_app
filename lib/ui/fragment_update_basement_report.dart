import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/model/BasementInspection.dart';
import 'package:flutter_grate_app/model/customer_details.dart';
import 'package:flutter_grate_app/model/dropdown_item.dart';
import 'package:flutter_grate_app/sqflite/db_helper.dart';
import 'package:flutter_grate_app/sqflite/model/BasementReport.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/sqflite/model/user.dart';
import 'package:flutter_grate_app/widgets/custome_back_button.dart';
import 'package:flutter_grate_app/widgets/list_row_item.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:uuid/uuid.dart';

import '../utils.dart';

class UpdateBasementReportFragment extends StatefulWidget {
  final Login login;
  final LoggedInUser loggedInUser;
  final CustomerDetails customer;
  final ValueChanged<CustomerDetails> backToCustomerDetails;
  BasementInspection basementInspection;

  UpdateBasementReportFragment(
      {Key key,
      this.login,
      this.loggedInUser,
      this.customer,
      this.backToCustomerDetails})
      : super(key: key);

  @override
  _UpdateBasementReportFragmentState createState() =>
      _UpdateBasementReportFragmentState();
}

class _UpdateBasementReportFragmentState
    extends State<UpdateBasementReportFragment> {
  var _key = GlobalKey<FormState>();
  DBHelper dbHelper = new DBHelper();

  TextEditingController _OutsideRelativeHumidityController =
      new TextEditingController();
  TextEditingController _OutsideTemperatureController =
      new TextEditingController();
  TextEditingController _1stFloorRelativeHumidityController =
      new TextEditingController();
  TextEditingController _1stFloorTemperatureController =
      new TextEditingController();
  TextEditingController _BasementRelativeHumidityController =
      new TextEditingController();
  TextEditingController _BasementTemperatureController =
      new TextEditingController();
  TextEditingController _Other1Controller = new TextEditingController();
  TextEditingController _Other2Controller = new TextEditingController();
  TextEditingController _VisualBasementInspectionOtherController =
      new TextEditingController();
  TextEditingController _NoticedSmellsCommentController =
      new TextEditingController();
  TextEditingController _NoticedMoldsCommentController =
      new TextEditingController();
  TextEditingController _SufferFromRespiratoryCommentController =
      new TextEditingController();
  TextEditingController _ChildrenPlayInTheBasementCommentController =
      new TextEditingController();
  TextEditingController _HavePetsCommentController =
      new TextEditingController();
  TextEditingController _NoticedBugsCommentController =
      new TextEditingController();
  TextEditingController _GetWaterCommentController =
      new TextEditingController();
  TextEditingController _EverSeePipesDrippingCommentController =
      new TextEditingController();
  TextEditingController _AnyRepairsToTryAndFixCommentController =
      new TextEditingController();
  TextEditingController _TestedForRadonInThePast2YearsCommentController =
      new TextEditingController();
  TextEditingController _BasementEvaluationOtherController =
      new TextEditingController();
  TextEditingController _NotesController = new TextEditingController();

  BasementReport basementReport;

//-------------Image---------------
  File _imageFile;

  _openGallery(BuildContext context) async {
    File pickFromGallery =
        (await ImagePicker.pickImage(source: ImageSource.gallery));
    setState(() {
      _imageFile = pickFromGallery;
    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async {
    File pickFromGallery =
        (await ImagePicker.pickImage(source: ImageSource.camera));
    setState(() {
      _imageFile = pickFromGallery;
    });
    Navigator.of(context).pop();
  }

  Future<void> _showDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Make A choice"),
            content: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ListBody(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: GestureDetector(
                        child: Text("Gallery"),
                        onTap: () {
                          _openGallery(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: GestureDetector(
                        child: Text("Camera"),
                        onTap: () {
                          _openCamera(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  //-------------Image---------------

  List<DropDownSingleItem> CurrentOutsideConditionsArray = [],
      HeatArray = [],
      AirArray = [],
      BasementDehumidifierArray = [],
      FoundationTypeArray = [],
      RemoveWaterArray = [],
      LosePowerArray = [],
      LosePowerHowOftenArray = [],
      YesNoArray = [],
      GoDownBasementArray = [],
      RatingArray = [];

  int CurrentOutsideConditionsSelection = 0,
      HeatSelection = 0,
      AirSelection = 0,
      BasementDehumidifierSelection = 0,
      GroundWaterSelection = 0,
      GroundWaterRatingSelection = 0,
      IronBacteriaSelection = 0,
      IronBacteriaRatingSelection = 0,
      CondensationSelection = 0,
      CondensationRatingSelection = 0,
      WallCracksSelection = 0,
      WallCracksRatingSelection = 0,
      FloorCracksSelection = 0,
      FloorCracksRatingSelection = 0,
      ExistingSumpPumpSelection = 0,
      ExistingDrainageSystemSelection = 0,
      ExistingRadonSystemSelection = 0,
      DryerVentToCodeSelection = 0,
      FoundationTypeSelection = 0,
      BulkheadSelection = 0,
      NoticedSmellsOrOdorsSelection = 0,
      NoticedMoldOrMildewSelection = 0,
      BasementGoDownSelection = 0,
      HomeSufferForRespiratoryProblemsSelection = 0,
      ChildrenPlayInBasementSelection = 0,
      PetsGoInBasementSelection = 0,
      NoticedBugsOrRodentsSelection = 0,
      GetWaterSelection = 0,
      RemoveWaterSelection = 0,
      SeeCondensationPipesDrippingSelection = 0,
      RepairsTryAndFixSelection = 0,
      LivingPlanSelection = 0,
      SellPlaningSelection = 0,
      PlansForBasementOnceSelection = 0,
      HomeTestedForRadonSelection = 0,
      LosePowerSelection = 0,
      LosePowerHowOftenSelection = 0;

  String base64Drawing = "";
  String base64PMSignature = "";
  String base64HOSignature = "";
  var base64 = const Base64Codec();

  Map<String, String> headers = <String, String>{};

  String message;

  ImageCache cache = new ImageCache();

  void initState() {
    super.initState();
    cache.clear();
    Future.delayed(Duration.zero, () => getDropDownData());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.only(top: 16, left: 32, right: 32),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  CustomBackButton(
                    onTap: () => widget.backToCustomerDetails(widget.customer),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Text("Basement Inspection Report",
                      style: fragmentTitleStyle()),
                ],
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: <Widget>[
/*--------------------_Customer and Company's Information---------------------*/
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 2,
                          offset: Offset(
                            0,
                            0,
                          ),
                        )
                      ],
                    ),
                    margin: EdgeInsets.all(4),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              ClipRRect(
                                  borderRadius:
                                      new BorderRadius.all(Radius.circular(12)),
                                  child: (widget.customer.ProfileImage !=
                                      null &&
                                      widget
                                          .customer.ProfileImage.isNotEmpty
                                      ? Container(
                                    height: 140,
                                    width: 150,
                                    child:
                                    FadeInImage.assetNetwork(placeholder: "images/loading.gif", image:  buildCustomerImageUrl(
                                        widget
                                            .customer
                                            .CustomerId,
                                        widget
                                            .loggedInUser
                                            .CompanyGUID,
                                        widget.login
                                            .username, Uuid().v1()), fit: BoxFit.cover,),
                                  )
                                      : Icon(
                                    Icons.person,
                                    size: 142,
                                  ))),
                              SizedBox(
                                width: 8,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListRowItem(
                                    icon: Icons.pin_drop,
                                    text: widget.loggedInUser.CompanyAddress,
                                  ),
                                  ListRowItem(
                                    icon: Icons.email,
                                    text:
                                        widget.loggedInUser.CompanyEmailAddress,
                                  ),
                                  ListRowItem(
                                    icon: Icons.phone,
                                    text: widget
                                        .loggedInUser.CompanyContactNumber,
                                  ),
                                  ListRowItem(
                                    icon: MdiIcons.fax,
                                    text: widget.loggedInUser.CompanyFaxNumber,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListRowItem(
                                icon: Icons.event,
                                text:
                                    "${DateFormat('MM/dd/yyyy').format(DateTime.now())}",
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              ListRowItem(
                                icon: Icons.person,
                                text: widget.customer.Name,
                              ),
                              ListRowItem(
                                icon: Icons.pin_drop,
                                text: widget.customer.Address,
                              ),
                              ListRowItem(
                                icon: Icons.phone,
                                text: widget.customer.ContactNum,
                              ),
                              ListRowItem(
                                icon: Icons.email,
                                text: widget.customer.Email,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Column(
                    children: <Widget>[
/*------------------RELATIVE HUMIDITY / TEMPERATURE READINGS------------------*/
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              spreadRadius: 2,
                              offset: Offset(
                                0,
                                0,
                              ),
                            )
                          ],
                        ),
                        margin: EdgeInsets.all(4),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Relative Humidity / Temperature Readings",
                                style: cardTitleStyle(),
                              ),
                              Container(
                                width: 200,
                                margin: EdgeInsets.only(top: 8, bottom: 8),
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: .5,
                                ),
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) =>
                                    CurrentOutsideConditionsSelection == 0 ||
                                            CurrentOutsideConditionsSelection ==
                                                null
                                        ? "Required"
                                        : null,
                                decoration: new InputDecoration(
                                    labelText: "Current Outside Conditions*",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items: List.generate(
                                    CurrentOutsideConditionsArray.length,
                                    (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child: Text(
                                          CurrentOutsideConditionsArray[index]
                                              .DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    CurrentOutsideConditionsSelection = index;
                                  });
                                },
                                value: CurrentOutsideConditionsSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              new TextFormField(
                                controller: _OutsideRelativeHumidityController,
                                validator: (val) =>
                                    val.isEmpty ? "Required" : null,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.phone,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "Outside Relative Humidity *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              new TextFormField(
                                controller: _OutsideTemperatureController,
                                validator: (val) =>
                                    val.isEmpty ? "Required" : null,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: false, signed: false),
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "Outside Temperature *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              new TextField(
                                controller: _1stFloorRelativeHumidityController,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: false, signed: false),
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "1st Floor Relative Humidity",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              new TextField(
                                controller: _1stFloorTemperatureController,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: false, signed: false),
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "1st Floor Temperature",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Current Inside Condition",
                                        style: cardTitleStyle(),
                                      ),
                                      Container(
                                        width: 200,
                                        margin:
                                            EdgeInsets.only(top: 8, bottom: 8),
                                        child: Divider(
                                          color: Colors.grey,
                                          thickness: .5,
                                        ),
                                      ),
                                      DropdownButtonFormField(
                                        isDense: true,
                                        validator: (index) =>
                                            index == 0 || HeatSelection == null
                                                ? "Required"
                                                : null,
                                        decoration: new InputDecoration(
                                            labelText: "Heat*",
                                            labelStyle: customTextStyle(),
                                            hintText: "e.g. hint",
                                            hintStyle: customHintStyle(),
                                            alignLabelWithHint: false,
                                            isDense: true),
                                        items: List.generate(HeatArray.length,
                                            (index) {
                                          return DropdownMenuItem(
                                              value: index,
                                              child: Text(HeatArray[index]
                                                  .DisplayText));
                                        }),
                                        onChanged: (index) {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          setState(() {
                                            HeatSelection = index;
                                          });
                                        },
                                        value: HeatSelection,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      DropdownButtonFormField(
                                        isDense: true,
                                        validator: (index) =>
                                            index == 0 || AirSelection == null
                                                ? "Required"
                                                : null,
                                        decoration: new InputDecoration(
                                            labelText: "Air *",
                                            labelStyle: customTextStyle(),
                                            hintText: "e.g. hint",
                                            hintStyle: customHintStyle(),
                                            alignLabelWithHint: false,
                                            isDense: true),
                                        items: List.generate(AirArray.length,
                                            (index) {
                                          return DropdownMenuItem(
                                              value: index,
                                              child: Text(
                                                  AirArray[index].DisplayText));
                                        }),
                                        onChanged: (index) {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          setState(() {
                                            AirSelection = index;
                                          });
                                        },
                                        value: AirSelection,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      new TextField(
                                        controller:
                                            _BasementRelativeHumidityController,
                                        obscureText: false,
                                        cursorColor: Colors.black,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: false, signed: false),
                                        maxLines: 1,
                                        style: customTextStyle(),
                                        decoration: new InputDecoration(
                                            labelText:
                                                "Basement Relative Humidity",
                                            labelStyle: customTextStyle(),
                                            hintText: "e.g. hint",
                                            hintStyle: customHintStyle(),
                                            alignLabelWithHint: false,
                                            isDense: true),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      new TextField(
                                        controller:
                                            _BasementTemperatureController,
                                        obscureText: false,
                                        cursorColor: Colors.black,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: false, signed: false),
                                        maxLines: 1,
                                        style: customTextStyle(),
                                        decoration: new InputDecoration(
                                            labelText: "Basement Temperature",
                                            labelStyle: customTextStyle(),
                                            hintText: "e.g. hint",
                                            hintStyle: customHintStyle(),
                                            alignLabelWithHint: false,
                                            isDense: true),
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      DropdownButtonFormField(
                                        isDense: true,
                                        validator: (index) => index == 0 ||
                                                BasementDehumidifierSelection ==
                                                    null
                                            ? "Required"
                                            : null,
                                        decoration: new InputDecoration(
                                            labelText:
                                                "Basement Dehumidifier *",
                                            labelStyle: customTextStyle(),
                                            hintText: "e.g. hint",
                                            hintStyle: customHintStyle(),
                                            alignLabelWithHint: false,
                                            isDense: true),
                                        items: List.generate(
                                            BasementDehumidifierArray.length,
                                            (index) {
                                          return DropdownMenuItem(
                                              value: index,
                                              child: Text(
                                                  BasementDehumidifierArray[
                                                          index]
                                                      .DisplayText));
                                        }),
                                        onChanged: (index) {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          setState(() {
                                            BasementDehumidifierSelection =
                                                index;
                                          });
                                        },
                                        value: BasementDehumidifierSelection,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              new TextField(
                                controller: _Other1Controller,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "Other",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              new TextField(
                                controller: _Other2Controller,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "Other",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
/*------------------VISUAL BASEMENT INSPECTION------------------*/
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              spreadRadius: 2,
                              offset: Offset(
                                0,
                                0,
                              ),
                            )
                          ],
                        ),
                        margin: EdgeInsets.all(4),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Visual Basement Inspection",
                                style: cardTitleStyle(),
                              ),
                              Container(
                                width: 200,
                                margin: EdgeInsets.only(top: 8, bottom: 8),
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: .5,
                                ),
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) =>
                                    index == 0 || GroundWaterSelection == null
                                        ? "Required"
                                        : null,
                                decoration: new InputDecoration(
                                    labelText: "Ground Water *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    GroundWaterSelection = index;
                                  });
                                },
                                value: GroundWaterSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                decoration: new InputDecoration(
                                    labelText: "Ground Water Rating (1-10)",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(RatingArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(RatingArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    GroundWaterRatingSelection = index;
                                  });
                                },
                                value: GroundWaterRatingSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) =>
                                    index == 0 || IronBacteriaSelection == null
                                        ? "Required"
                                        : null,
                                decoration: new InputDecoration(
                                    labelText: "Iron Bacteria *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    IronBacteriaSelection = index;
                                  });
                                },
                                value: IronBacteriaSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                decoration: new InputDecoration(
                                    labelText: "Iron Bacteria Rating (1-10)",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(RatingArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(RatingArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    IronBacteriaRatingSelection = index;
                                  });
                                },
                                value: IronBacteriaRatingSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) =>
                                    index == 0 || CondensationSelection == null
                                        ? "Required"
                                        : null,
                                decoration: new InputDecoration(
                                    labelText: "Condensation *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    CondensationSelection = index;
                                  });
                                },
                                value: CondensationSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                decoration: new InputDecoration(
                                    labelText: "Condensation Rating (1-10)",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(RatingArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(RatingArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    CondensationRatingSelection = index;
                                  });
                                },
                                value: CondensationRatingSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) =>
                                    index == 0 || WallCracksSelection == null
                                        ? "Required"
                                        : null,
                                decoration: new InputDecoration(
                                    labelText: "Wall Cracks *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    WallCracksSelection = index;
                                  });
                                },
                                value: WallCracksSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                decoration: new InputDecoration(
                                    labelText: "Wall Cracks Rating (1-10)",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(RatingArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(RatingArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    WallCracksRatingSelection = index;
                                  });
                                },
                                value: WallCracksRatingSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) =>
                                    index == 0 || FloorCracksSelection == null
                                        ? "Required"
                                        : null,
                                decoration: new InputDecoration(
                                    labelText: "Floor Cracks *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    FloorCracksSelection = index;
                                  });
                                },
                                value: FloorCracksSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                decoration: new InputDecoration(
                                    labelText: "Floor Cracks Rating (1-10)",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(RatingArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(RatingArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    FloorCracksRatingSelection = index;
                                  });
                                },
                                value: FloorCracksRatingSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        ExistingSumpPumpSelection == null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText: "Existing Sump Pump *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    ExistingSumpPumpSelection = index;
                                  });
                                },
                                value: ExistingSumpPumpSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        ExistingDrainageSystemSelection == null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText: "Existing Drainage System *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    ExistingDrainageSystemSelection = index;
                                  });
                                },
                                value: ExistingDrainageSystemSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        ExistingRadonSystemSelection == null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText: "Radon System (existing) *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    ExistingRadonSystemSelection = index;
                                  });
                                },
                                value: ExistingRadonSystemSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        DryerVentToCodeSelection == null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText: "Dryer Vent To Code? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    DryerVentToCodeSelection = index;
                                  });
                                },
                                value: DryerVentToCodeSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        FoundationTypeSelection == null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText: "Foundation Type? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items: List.generate(FoundationTypeArray.length,
                                    (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child: Text(FoundationTypeArray[index]
                                          .DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    FoundationTypeSelection = index;
                                  });
                                },
                                value: FoundationTypeSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) =>
                                    index == 0 || BulkheadSelection == null
                                        ? "Required"
                                        : null,
                                decoration: new InputDecoration(
                                    labelText: "Bulkhead? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    BulkheadSelection = index;
                                  });
                                },
                                value: BulkheadSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              new TextField(
                                controller:
                                    _VisualBasementInspectionOtherController,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "Other",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
/*------------------CUSTOMER BASEMENT EVALUATION------------------*/
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              spreadRadius: 2,
                              offset: Offset(
                                0,
                                0,
                              ),
                            )
                          ],
                        ),
                        margin: EdgeInsets.all(4),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Customer Basement Evaluation",
                                style: cardTitleStyle(),
                              ),
                              Container(
                                width: 200,
                                margin: EdgeInsets.only(top: 8, bottom: 8),
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: .5,
                                ),
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        NoticedSmellsOrOdorsSelection == null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText:
                                        "1. Have you ever noticed smells/odors coming from the basement? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    NoticedSmellsOrOdorsSelection = index;
                                  });
                                },
                                value: NoticedSmellsOrOdorsSelection,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              new TextFormField(
                                controller: _NoticedSmellsCommentController,
//                                validator: (val)=> val.isEmpty ? "Required" : null,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "1. Comment",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        NoticedMoldOrMildewSelection == null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText:
                                        "2. Have you ever noticed mold/mildew on any item in the basement? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    NoticedMoldOrMildewSelection = index;
                                  });
                                },
                                value: NoticedMoldOrMildewSelection,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              new TextFormField(
                                controller: _NoticedMoldsCommentController,
//                                validator: (val)=> val.isEmpty ? "Required" : null,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "2. Comment",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        BasementGoDownSelection == null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText:
                                        "3. How often do you go down in the basement? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items: List.generate(GoDownBasementArray.length,
                                    (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child: Text(GoDownBasementArray[index]
                                          .DisplayText));
                                }),
                                onChanged: (index) {
                                  setState(() {
                                    BasementGoDownSelection = index;
                                  });
                                },
                                value: BasementGoDownSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        HomeSufferForRespiratoryProblemsSelection ==
                                            null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText:
                                        "4. Does anyone in the home suffer from respiratory problems? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    HomeSufferForRespiratoryProblemsSelection =
                                        index;
                                  });
                                },
                                value:
                                    HomeSufferForRespiratoryProblemsSelection,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              new TextFormField(
                                controller:
                                    _SufferFromRespiratoryCommentController,
//                                validator: (val)=> val.isEmpty ? "Required" : null,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "4. Comment",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        ChildrenPlayInBasementSelection == null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText:
                                        "5. Do your children play in the basement? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    ChildrenPlayInBasementSelection = index;
                                  });
                                },
                                value: ChildrenPlayInBasementSelection,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              new TextFormField(
                                controller:
                                    _ChildrenPlayInTheBasementCommentController,
//                                validator: (val)=> val.isEmpty ? "Required" : null,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "5. Comment",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        PetsGoInBasementSelection == null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText:
                                        "6. Do you have pets that go in the basement? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    PetsGoInBasementSelection = index;
                                  });
                                },
                                value: PetsGoInBasementSelection,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              new TextFormField(
                                controller: _HavePetsCommentController,
//                                validator: (val)=> val.isEmpty ? "Required" : null,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "6. Comment",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        NoticedBugsOrRodentsSelection == null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText:
                                        "7. Have you ever noticed bugs/rodents in the basement? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    NoticedBugsOrRodentsSelection = index;
                                  });
                                },
                                value: NoticedBugsOrRodentsSelection,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              new TextFormField(
                                controller: _NoticedBugsCommentController,
//                                validator: (val)=> val.isEmpty ? "Required" : null,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "7. Comment",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) =>
                                    index == 0 || GetWaterSelection == null
                                        ? "Required"
                                        : null,
                                decoration: new InputDecoration(
                                    labelText: "8. Do you get water? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    GetWaterSelection = index;
                                  });
                                },
                                value: GetWaterSelection,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              new TextFormField(
                                controller: _GetWaterCommentController,
//                                validator: (val)=> val.isEmpty ? "Required" : null,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText:
                                        "8. How high does the water level get? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                decoration: new InputDecoration(
                                    labelText:
                                        "9. How do you normally remove the water from basement?",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items: List.generate(RemoveWaterArray.length,
                                    (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child: Text(
                                          RemoveWaterArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    RemoveWaterSelection = index;
                                  });
                                },
                                value: RemoveWaterSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        SeeCondensationPipesDrippingSelection ==
                                            null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText:
                                        "10. Do you ever see pipes dripping (condensation)? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    SeeCondensationPipesDrippingSelection =
                                        index;
                                  });
                                },
                                value: SeeCondensationPipesDrippingSelection,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              new TextFormField(
                                controller:
                                    _EverSeePipesDrippingCommentController,
//                                validator: (val)=> val.isEmpty ? "Required" : null,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "10. Comment",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        RepairsTryAndFixSelection == null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText:
                                        "11. Have you done any repairs to try and fix these problems? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    RepairsTryAndFixSelection = index;
                                  });
                                },
                                value: RepairsTryAndFixSelection,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              new TextFormField(
                                controller:
                                    _AnyRepairsToTryAndFixCommentController,
//                                validator: (val)=> val.isEmpty ? "Required" : null,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "11. Comment",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) =>
                                    index == 0 || LivingPlanSelection == null
                                        ? "Required"
                                        : null,
                                decoration: new InputDecoration(
                                    labelText:
                                        "12. How long do you plan on living here? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    LivingPlanSelection = index;
                                  });
                                },
                                value: LivingPlanSelection,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) =>
                                    index == 0 || SellPlaningSelection == null
                                        ? "Required"
                                        : null,
                                decoration: new InputDecoration(
                                    labelText: "12. Are you planning to sell*",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    SellPlaningSelection = index;
                                  });
                                },
                                value: SellPlaningSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                decoration: new InputDecoration(
                                    labelText:
                                        "13. What are your plans for the basement once it is dry?",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    PlansForBasementOnceSelection = index;
                                  });
                                },
                                value: PlansForBasementOnceSelection,
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              DropdownButtonFormField(
                                isDense: true,
                                validator: (index) => index == 0 ||
                                        HomeTestedForRadonSelection == null
                                    ? "Required"
                                    : null,
                                decoration: new InputDecoration(
                                    labelText:
                                        "14. Has your home been tested for radon in the past 2 years? *",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                                items:
                                    List.generate(YesNoArray.length, (index) {
                                  return DropdownMenuItem(
                                      value: index,
                                      child:
                                          Text(YesNoArray[index].DisplayText));
                                }),
                                onChanged: (index) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  setState(() {
                                    HomeTestedForRadonSelection = index;
                                  });
                                },
                                value: HomeTestedForRadonSelection,
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              new TextFormField(
                                controller:
                                    _TestedForRadonInThePast2YearsCommentController,
//                                validator: (val)=> val.isEmpty ? "Required" : null,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "14. Comment",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Expanded(
                                    child: DropdownButtonFormField(
                                      isDense: true,
                                      validator: (index) => index == 0 ||
                                              LosePowerSelection == null
                                          ? "Required"
                                          : null,
                                      decoration: new InputDecoration(
                                          labelText: "15. Do you lose power? *",
                                          labelStyle: customTextStyle(),
                                          hintText: "e.g. hint",
                                          hintStyle: customHintStyle(),
                                          alignLabelWithHint: false,
                                          isDense: true),
                                      items: List.generate(
                                          LosePowerArray.length, (index) {
                                        return DropdownMenuItem(
                                            value: index,
                                            child: Text(LosePowerArray[index]
                                                .DisplayText));
                                      }),
                                      onChanged: (index) {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        setState(() {
                                          LosePowerSelection = index;
                                        });
                                      },
                                      value: LosePowerSelection,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 24,
                                  ),
                                  Expanded(
                                    child: DropdownButtonFormField(
                                      isDense: true,
                                      validator: (index) => index == 0 ||
                                              LosePowerHowOftenSelection == null
                                          ? "Required"
                                          : null,
                                      decoration: new InputDecoration(
                                          labelText: "If so how often? *",
                                          labelStyle: customTextStyle(),
                                          hintText: "e.g. hint",
                                          hintStyle: customHintStyle(),
                                          alignLabelWithHint: false,
                                          isDense: true),
                                      items: List.generate(
                                          LosePowerArray.length, (index) {
                                        return DropdownMenuItem(
                                            value: index,
                                            child: Text(LosePowerArray[index]
                                                .DisplayText));
                                      }),
                                      onChanged: (index) {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        setState(() {
                                          LosePowerHowOftenSelection = index;
                                        });
                                      },
                                      value: LosePowerHowOftenSelection,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              new TextField(
                                controller: _BasementEvaluationOtherController,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                maxLines: 1,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "16. Other",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              spreadRadius: 2,
                              offset: Offset(
                                0,
                                0,
                              ),
                            )
                          ],
                        ),
                        margin: EdgeInsets.all(4),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 200,
                                margin: EdgeInsets.only(top: 8, bottom: 8),
                                child: Divider(
                                  color: Colors.grey,
                                  thickness: .5,
                                ),
                              ),
                              new TextField(
                                controller: _NotesController,
                                obscureText: false,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                minLines: 3,
                                style: customTextStyle(),
                                decoration: new InputDecoration(
                                    labelText: "Notes",
                                    labelStyle: customTextStyle(),
                                    hintText: "e.g. hint",
                                    hintStyle: customHintStyle(),
                                    alignLabelWithHint: false,
                                    isDense: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            if (_key.currentState.validate()) {
                              showDialog(
                                  context: context,
                                  builder: (_) => loadingAlert());
                              _checkConnectivity();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(36)),
                              color: Colors.black,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                  spreadRadius: 4,
                                  offset: Offset(
                                    0,
                                    0,
                                  ),
                                )
                              ],
                            ),
                            padding: EdgeInsets.only(
                                left: 48, right: 48, top: 18, bottom: 18),
                            margin: EdgeInsets.only(right: 16, bottom: 16),
                            child: Text(
                              "Submit",
                              style: customButtonTextStyle(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future getDropDownData() async {
    showDialog(context: context, builder: (_) => loadingAlert());
    Map<String, String> headers = {
      'Authorization': widget.login.accessToken,
      'Key':
          'CurrentOutsideConditions,Heat,Air,BasementDehumidifier,FoundationType,RemoveWater,LosePower,LosePowerHowOften,YesNo,Rating,GoDownBasement'
    };

    var result = await http.get(BASE_URL + API_GET_LOOK_UP, headers: headers);
    if (result.statusCode == 200) {
      var map = json.decode(result.body)['data'];

      List<DropDownSingleItem> _lists = List.generate(map.length, (index) {
        return DropDownSingleItem.fromMap(map[index]);
      });

      for (DropDownSingleItem item in _lists) {
        switch (item.DataKey) {
          case "CurrentOutsideConditions":
            CurrentOutsideConditionsArray.add(item);
            break;
          case "Heat":
            HeatArray.add(item);
            break;
          case "Air":
            AirArray.add(item);
            break;
          case "BasementDehumidifier":
            BasementDehumidifierArray.add(item);
            break;
          case "FoundationType":
            FoundationTypeArray.add(item);
            break;
          case "RemoveWater":
            RemoveWaterArray.add(item);
            break;
          case "LosePower":
            LosePowerArray.add(item);
            break;
          case "LosePowerHowOften":
            LosePowerHowOftenArray.add(item);
            break;
          case "YesNo":
            YesNoArray.add(item);
            break;
          case "Rating":
            RatingArray.add(item);
            break;
          case "GoDownBasement":
            GoDownBasementArray.add(item);
            break;
        }
      }
      getData();
    } else {
      Navigator.of(context).pop();
      showMessage(context, "Network error!", json.decode(result.body),
          Colors.redAccent, Icons.warning);
    }
  }

  Future getData() async {
    Map<String, String> headers = {
      'Authorization': widget.login.accessToken,
      'CustomerId': widget.customer.CustomerId,
    };

    var result = await http.get(BASE_URL + API_GET_BASEMENT_INSPECTION,
        headers: headers);
    if (result.statusCode == 200) {
      var map = json.decode(result.body);
      widget.basementInspection =
          BasementInspection.fromMap(map['CustomerInspectionList']);
      try {
        CurrentOutsideConditionsSelection = checkIndex(
            map['CustomerInspectionList']['CurrentOutsideConditions'],
            CurrentOutsideConditionsArray);
        HeatSelection =
            checkIndex(map['CustomerInspectionList']['Heat'], HeatArray);
        AirSelection =
            checkIndex(map['CustomerInspectionList']['Air'], AirArray);
        BasementDehumidifierSelection = checkIndex(
            map['CustomerInspectionList']['BasementDehumidifier'],
            BasementDehumidifierArray);
        GroundWaterSelection = checkIndex(
            map['CustomerInspectionList']['GroundWater'], YesNoArray);
        GroundWaterRatingSelection = checkIndex(
            map['CustomerInspectionList']['GroundWaterRating'].toString(),
            RatingArray);
        IronBacteriaSelection = checkIndex(
            map['CustomerInspectionList']['IronBacteria'].toString(),
            YesNoArray);
        IronBacteriaRatingSelection = checkIndex(
            map['CustomerInspectionList']['IronBacteriaRating'].toString(),
            RatingArray);
        CondensationSelection = checkIndex(
            map['CustomerInspectionList']['Condensation'].toString(),
            YesNoArray);
        CondensationRatingSelection = checkIndex(
            map['CustomerInspectionList']['CondensationRating'].toString(),
            RatingArray);
        WallCracksSelection = checkIndex(
            map['CustomerInspectionList']['WallCracks'].toString(), YesNoArray);
        WallCracksRatingSelection = checkIndex(
            map['CustomerInspectionList']['WallCracksRating'].toString(),
            RatingArray);
        FloorCracksSelection = checkIndex(
            map['CustomerInspectionList']['FloorCracks'].toString(),
            YesNoArray);
        FloorCracksRatingSelection = checkIndex(
            map['CustomerInspectionList']['FloorCracksRating'].toString(),
            RatingArray);
        ExistingSumpPumpSelection = checkIndex(
            map['CustomerInspectionList']['ExistingSumpPump'], YesNoArray);
        ExistingDrainageSystemSelection = checkIndex(
            map['CustomerInspectionList']['ExistingDrainageSystem'].toString(),
            YesNoArray);
        ExistingRadonSystemSelection = checkIndex(
            map['CustomerInspectionList']['ExistingRadonSystem'].toString(),
            YesNoArray);
        DryerVentToCodeSelection = checkIndex(
            map['CustomerInspectionList']['DryerVentToCode'].toString(),
            YesNoArray);
        FoundationTypeSelection = checkIndex(
            map['CustomerInspectionList']['FoundationType'],
            FoundationTypeArray);
        BulkheadSelection = checkIndex(
            map['CustomerInspectionList']['Bulkhead'].toString(), YesNoArray);
        NoticedSmellsOrOdorsSelection = checkIndex(
            map['CustomerInspectionList']['NoticedSmellsOrOdors'].toString(),
            YesNoArray);
        NoticedMoldOrMildewSelection = checkIndex(
            map['CustomerInspectionList']['NoticedMoldOrMildew'].toString(),
            YesNoArray);
        BasementGoDownSelection = checkIndex(
            map['CustomerInspectionList']['BasementGoDown'].toString(),
            GoDownBasementArray);
        HomeSufferForRespiratoryProblemsSelection = checkIndex(
            map['CustomerInspectionList']['HomeSufferForRespiratory']
                .toString(),
            YesNoArray);
        ChildrenPlayInBasementSelection = checkIndex(
            map['CustomerInspectionList']['ChildrenPlayInBasement'].toString(),
            YesNoArray);
        PetsGoInBasementSelection = checkIndex(
            map['CustomerInspectionList']['PetsGoInBasement'].toString(),
            YesNoArray);
        NoticedBugsOrRodentsSelection = checkIndex(
            map['CustomerInspectionList']['NoticedBugsOrRodents'].toString(),
            YesNoArray);
        GetWaterSelection = checkIndex(
            map['CustomerInspectionList']['GetWater'].toString(), YesNoArray);
        RemoveWaterSelection = checkIndex(
            map['CustomerInspectionList']['RemoveWater'].toString(),
            YesNoArray);
        SeeCondensationPipesDrippingSelection = checkIndex(
            map['CustomerInspectionList']['SeeCondensationPipesDripping'],
            YesNoArray);
        RepairsTryAndFixSelection = checkIndex(
            map['CustomerInspectionList']['RepairsProblems'].toString(),
            YesNoArray);
        LivingPlanSelection = checkIndex(
            map['CustomerInspectionList']['LivingPlan'].toString(), YesNoArray);
        SellPlaningSelection = checkIndex(
            map['CustomerInspectionList']['SellPlaning'].toString(),
            YesNoArray);
        PlansForBasementOnceSelection = checkIndex(
            map['CustomerInspectionList']['PlansForBasementOnce'].toString(),
            YesNoArray);
        HomeTestedForRadonSelection = checkIndex(
            map['CustomerInspectionList']['HomeTestForPastRadon'].toString(),
            YesNoArray);
        LosePowerSelection = checkIndex(
            map['CustomerInspectionList']['LosePower'], LosePowerArray);
        LosePowerHowOftenSelection = checkIndex(
            map['CustomerInspectionList']['LosePowerHowOften'], LosePowerArray);
        _OutsideRelativeHumidityController.text =
            "${map['CustomerInspectionList']['OutsideRelativeHumidity']}";
        _OutsideTemperatureController.text =
            map['CustomerInspectionList']['OutsideTemperature'].toString();
        _1stFloorRelativeHumidityController.text = map['CustomerInspectionList']
                ['FirstFloorRelativeHumidity']
            .toString();
        _1stFloorTemperatureController.text =
            map['CustomerInspectionList']['FirstFloorTemperature'].toString();
        _BasementRelativeHumidityController.text = map['CustomerInspectionList']
                ['BasementRelativeHumidity']
            .toString();
        _BasementTemperatureController.text =
            map['CustomerInspectionList']['BasementTemperature'].toString();
        _Other1Controller.text =
            map['CustomerInspectionList']['RelativeOther1'];
        _Other2Controller.text =
            map['CustomerInspectionList']['RelativeOther2'];
        _VisualBasementInspectionOtherController.text =
            map['CustomerInspectionList']['VisualBasementOther'];
        _NoticedSmellsCommentController.text =
            map['CustomerInspectionList']['NoticedSmellsOrOdorsComment'];
        _NoticedMoldsCommentController.text =
            map['CustomerInspectionList']['NoticedMoldOrMildewComment'];
        _SufferFromRespiratoryCommentController.text =
            map['CustomerInspectionList']['HomeSufferForrespiratoryComment'];
        _ChildrenPlayInTheBasementCommentController.text =
            map['CustomerInspectionList']['ChildrenPlayInBasementComment'];
        _HavePetsCommentController.text =
            map['CustomerInspectionList']['PetsGoInBasementComment'];
        _NoticedBugsCommentController.text =
            map['CustomerInspectionList']['NoticedBugsOrRodentsComment'];
        _GetWaterCommentController.text =
            map['CustomerInspectionList']['GetWaterComment'];
        _EverSeePipesDrippingCommentController.text =
            map['CustomerInspectionList']
                ['SeeCondensationPipesDrippingComment'];
        _AnyRepairsToTryAndFixCommentController.text =
            map['CustomerInspectionList']['RepairsProblemsComment'];
        _TestedForRadonInThePast2YearsCommentController.text =
            map['CustomerInspectionList']['HomeTestForPastRadonComment'];
        _BasementEvaluationOtherController.text =
            map['CustomerInspectionList']['CustomerBasementOther'];
        _NotesController.text = map['CustomerInspectionList']['Notes'];
      } catch (error) {
        Navigator.of(context).pop();
      }
      setState(() {});
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
      showMessage(context, "Network error!", json.decode(result.body),
          Colors.redAccent, Icons.warning);
    }
  }

  Future saveInspectionReport() async {
    try {
      headers['Authorization'] = widget.login.accessToken;
      headers['CustomerId'] = widget.customer.CustomerId;
      headers['companyId'] = widget.loggedInUser.CompanyGUID;
      headers['CurrentOutsideConditions'] =
          CurrentOutsideConditionsArray[CurrentOutsideConditionsSelection]
              .DataValue;
      headers['OutsideRelativeHumidity'] =
          _OutsideRelativeHumidityController.text;
      headers['OutsideTemperature'] = _OutsideTemperatureController.text;
      headers['FirstFloorRelativeHumidity'] =
          _1stFloorRelativeHumidityController.text;
      headers['FirstFloorTemperature'] = _1stFloorTemperatureController.text;
      headers['RelativeOther1'] = _Other1Controller.text;
      headers['RelativeOther2'] = _Other2Controller.text;
      headers['Heat'] = HeatArray[HeatSelection].DataValue;
      headers['Air'] = AirArray[AirSelection].DataValue;
      headers['BasementRelativeHumidity'] =
          _BasementRelativeHumidityController.text;
      headers['BasementTemperature'] = _BasementTemperatureController.text;
      headers['BasementDehumidifier'] =
          BasementDehumidifierArray[BasementDehumidifierSelection].DataValue;
      headers['GroundWater'] = YesNoArray[GroundWaterSelection].DataValue;
      headers['GroundWaterRating'] =
          RatingArray[GroundWaterRatingSelection].DataValue;
      headers['IronBacteria'] = YesNoArray[IronBacteriaSelection].DataValue;
      headers['IronBacteriaRating'] =
          RatingArray[IronBacteriaRatingSelection].DataValue;
      headers['Condensation'] = YesNoArray[CondensationSelection].DataValue;
      headers['CondensationRating'] =
          RatingArray[CondensationRatingSelection].DataValue;
      headers['WallCracks'] = YesNoArray[WallCracksSelection].DataValue;
      headers['WallCracksRating'] =
          RatingArray[WallCracksRatingSelection].DataValue;
      headers['FloorCracks'] = YesNoArray[FloorCracksSelection].DataValue;
      headers['FloorCracksRating'] =
          RatingArray[FloorCracksRatingSelection].DataValue;
      headers['ExistingSumpPump'] =
          YesNoArray[ExistingSumpPumpSelection].DataValue;
      headers['ExistingDrainageSystem'] =
          YesNoArray[ExistingDrainageSystemSelection].DataValue;
      headers['ExistingRadonSystem'] =
          YesNoArray[ExistingRadonSystemSelection].DataValue;
      headers['DryerVentToCode'] =
          YesNoArray[DryerVentToCodeSelection].DataValue;
      headers['FoundationType'] =
          FoundationTypeArray[FoundationTypeSelection].DataValue;
      headers['Bulkhead'] = YesNoArray[BulkheadSelection].DataValue;
      headers['VisualBasementOther'] =
          _VisualBasementInspectionOtherController.text;
      headers['NoticedSmellsOrOdors'] =
          YesNoArray[NoticedSmellsOrOdorsSelection].DataValue;
      headers['NoticedSmellsOrOdorsComment'] =
          _NoticedSmellsCommentController.text;
      headers['NoticedMoldOrMildew'] =
          YesNoArray[NoticedMoldOrMildewSelection].DataValue;
      headers['NoticedMoldOrMildewComment'] =
          _NoticedMoldsCommentController.text;
      headers['BasementGoDown'] =
          GoDownBasementArray[BasementGoDownSelection].DataValue;
      headers['HomeSufferForRespiratory'] =
          YesNoArray[HomeSufferForRespiratoryProblemsSelection].DataValue;
      headers['HomeSufferForrespiratoryComment'] =
          _SufferFromRespiratoryCommentController.text;
      headers['ChildrenPlayInBasement'] =
          YesNoArray[ChildrenPlayInBasementSelection].DataValue;
      headers['ChildrenPlayInBasementComment'] =
          _ChildrenPlayInTheBasementCommentController.text;
      headers['PetsGoInBasement'] =
          YesNoArray[PetsGoInBasementSelection].DataValue;
      headers['PetsGoInBasementComment'] = _HavePetsCommentController.text;
      headers['NoticedBugsOrRodents'] =
          YesNoArray[NoticedBugsOrRodentsSelection].DataValue;
      headers['NoticedBugsOrRodentsComment'] =
          _NoticedBugsCommentController.text;
      headers['GetWater'] = YesNoArray[GetWaterSelection].DataValue;
      headers['GetWaterComment'] = _GetWaterCommentController.text;
      headers['RemoveWater'] = RemoveWaterArray[RemoveWaterSelection].DataValue;
      headers['SeeCondensationPipesDripping'] =
          YesNoArray[SeeCondensationPipesDrippingSelection].DataValue;
      headers['SeeCondensationPipesDrippingComment'] =
          _EverSeePipesDrippingCommentController.text;
      headers['RepairsProblems'] =
          YesNoArray[RepairsTryAndFixSelection].DataValue;
      headers['RepairsProblemsComment'] =
          _AnyRepairsToTryAndFixCommentController.text;
      headers['LivingPlan'] = YesNoArray[LivingPlanSelection].DataValue;
      headers['SellPlaning'] = YesNoArray[SellPlaningSelection].DataValue;
      headers['PlansForBasementOnce'] =
          YesNoArray[PlansForBasementOnceSelection].DataValue;
      headers['HomeTestForPastRadon'] =
          YesNoArray[HomeTestedForRadonSelection].DataValue;
      headers['HomeTestForPastRadonComment'] =
          _TestedForRadonInThePast2YearsCommentController.text;
      headers['LosePower'] = LosePowerArray[LosePowerSelection].DataValue;
      headers['LosePowerHowOften'] =
          LosePowerArray[LosePowerHowOftenSelection].DataValue;
      headers['CustomerBasementOther'] =
          _BasementEvaluationOtherController.text;
      headers['Drawing'] = "";
      headers['Notes'] = _NotesController.text;
      headers['PMSignature'] = "";
      headers['PMSignatureDate'] = "";
      headers['HomeOwnerSignature'] = "";
      headers['HomeOwnerSignatureDate'] = "";
      headers['InspectionPhoto'] = "";

      http
          .post(BASE_URL + API_SAVE_BASEMENT_INSPECTION, headers: headers)
          .then((response) {
        try {
          if (response.statusCode == 200) {
            Navigator.of(context).pop();
            showAPIResponse(
                context, "Basement Inspection Report Updated", Colors.green);
            widget.backToCustomerDetails(widget.customer);
          } else {
            Navigator.of(context).pop();
            showAPIResponse(context, "Something Went Wrong", Colors.red);
          }
        } catch (error) {
          Navigator.of(context).pop();
          showAPIResponse(context, "Error :" + error.toString(), null);
        }
      });
    } catch (error) {
      Navigator.of(context).pop();
      showAPIResponse(context, "Error :" + error.toString(), null);
    }
  }

  int checkIndex(String _text, List<DropDownSingleItem> _list) {
    int counter = 0;
    for (DropDownSingleItem _item in _list) {
      if (_item.DataValue == _text) {
        return counter;
      } else {
        counter++;
      }
    }
    return 0;
  }

  _checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      await saveToDatabase();
      Navigator.pop(context);
    } else {
      await saveInspectionReport();
      Navigator.pop(context);
    }
  }

  saveToDatabase() async {
    try {
      headers['Authorization'] = widget.login.accessToken;
      headers['CustomerId'] = widget.customer.CustomerId;
      headers['companyId'] = widget.loggedInUser.CompanyGUID;
      headers['CurrentOutsideConditions'] =
          CurrentOutsideConditionsArray[CurrentOutsideConditionsSelection]
              .DataValue;
      headers['OutsideRelativeHumidity'] =
          _OutsideRelativeHumidityController.text;
      headers['OutsideTemperature'] = _OutsideTemperatureController.text;
      headers['FirstFloorRelativeHumidity'] =
          _1stFloorRelativeHumidityController.text;
      headers['FirstFloorTemperature'] = _1stFloorTemperatureController.text;
      headers['RelativeOther1'] = _Other1Controller.text;
      headers['RelativeOther2'] = _Other2Controller.text;
      headers['Heat'] = HeatArray[HeatSelection].DataValue;
      headers['Air'] = AirArray[AirSelection].DataValue;
      headers['BasementRelativeHumidity'] =
          _BasementRelativeHumidityController.text;
      headers['BasementTemperature'] = _BasementTemperatureController.text;
      headers['BasementDehumidifier'] =
          BasementDehumidifierArray[BasementDehumidifierSelection].DataValue;
      headers['GroundWater'] = YesNoArray[GroundWaterSelection].DataValue;
      headers['GroundWaterRating'] =
          RatingArray[GroundWaterRatingSelection].DataValue;
      headers['IronBacteria'] = YesNoArray[IronBacteriaSelection].DataValue;
      headers['IronBacteriaRating'] =
          RatingArray[IronBacteriaRatingSelection].DataValue;
      headers['Condensation'] = YesNoArray[CondensationSelection].DataValue;
      headers['CondensationRating'] =
          RatingArray[CondensationRatingSelection].DataValue;
      headers['WallCracks'] = YesNoArray[WallCracksSelection].DataValue;
      headers['WallCracksRating'] =
          RatingArray[WallCracksRatingSelection].DataValue;
      headers['FloorCracks'] = YesNoArray[FloorCracksSelection].DataValue;
      headers['FloorCracksRating'] =
          RatingArray[FloorCracksRatingSelection].DataValue;
      headers['ExistingSumpPump'] =
          YesNoArray[ExistingSumpPumpSelection].DataValue;
      headers['ExistingDrainageSystem'] =
          YesNoArray[ExistingDrainageSystemSelection].DataValue;
      headers['ExistingRadonSystem'] =
          YesNoArray[ExistingRadonSystemSelection].DataValue;
      headers['DryerVentToCode'] =
          YesNoArray[DryerVentToCodeSelection].DataValue;
      headers['FoundationType'] =
          FoundationTypeArray[FoundationTypeSelection].DataValue;
      headers['Bulkhead'] = YesNoArray[BulkheadSelection].DataValue;
      headers['VisualBasementOther'] =
          _VisualBasementInspectionOtherController.text;
      headers['NoticedSmellsOrOdors'] =
          YesNoArray[NoticedSmellsOrOdorsSelection].DataValue;
      headers['NoticedSmellsOrOdorsComment'] =
          _NoticedSmellsCommentController.text;
      headers['NoticedMoldOrMildew'] =
          YesNoArray[NoticedMoldOrMildewSelection].DataValue;
      headers['NoticedMoldOrMildewComment'] =
          _NoticedMoldsCommentController.text;
      headers['BasementGoDown'] =
          GoDownBasementArray[BasementGoDownSelection].DataValue;
      headers['HomeSufferForRespiratory'] =
          YesNoArray[HomeSufferForRespiratoryProblemsSelection].DataValue;
      headers['HomeSufferForrespiratoryComment'] =
          _SufferFromRespiratoryCommentController.text;
      headers['ChildrenPlayInBasement'] =
          YesNoArray[ChildrenPlayInBasementSelection].DataValue;
      headers['ChildrenPlayInBasementComment'] =
          _ChildrenPlayInTheBasementCommentController.text;
      headers['PetsGoInBasement'] =
          YesNoArray[PetsGoInBasementSelection].DataValue;
      headers['PetsGoInBasementComment'] = _HavePetsCommentController.text;
      headers['NoticedBugsOrRodents'] =
          YesNoArray[NoticedBugsOrRodentsSelection].DataValue;
      headers['NoticedBugsOrRodentsComment'] =
          _NoticedBugsCommentController.text;
      headers['GetWater'] = YesNoArray[GetWaterSelection].DataValue;
      headers['GetWaterComment'] = _GetWaterCommentController.text;
      headers['RemoveWater'] = RemoveWaterArray[RemoveWaterSelection].DataValue;
      headers['SeeCondensationPipesDripping'] =
          YesNoArray[SeeCondensationPipesDrippingSelection].DataValue;
      headers['SeeCondensationPipesDrippingComment'] =
          _EverSeePipesDrippingCommentController.text;
      headers['RepairsProblems'] =
          YesNoArray[RepairsTryAndFixSelection].DataValue;
      headers['RepairsProblemsComment'] =
          _AnyRepairsToTryAndFixCommentController.text;
      headers['LivingPlan'] = YesNoArray[LivingPlanSelection].DataValue;
      headers['SellPlaning'] = YesNoArray[SellPlaningSelection].DataValue;
      headers['PlansForBasementOnce'] =
          YesNoArray[PlansForBasementOnceSelection].DataValue;
      headers['HomeTestForPastRadon'] =
          YesNoArray[HomeTestedForRadonSelection].DataValue;
      headers['HomeTestForPastRadonComment'] =
          _TestedForRadonInThePast2YearsCommentController.text;
      headers['LosePower'] = LosePowerArray[LosePowerSelection].DataValue;
      headers['LosePowerHowOften'] =
          LosePowerArray[LosePowerHowOftenSelection].DataValue;
      headers['CustomerBasementOther'] =
          _BasementEvaluationOtherController.text;
      headers['Drawing'] = "";
      headers['Notes'] = _NotesController.text;
      headers['PMSignature'] = "";
      headers['PMSignatureDate'] = "";
      headers['HomeOwnerSignature'] = "";
      headers['HomeOwnerSignatureDate'] = "";
      headers['InspectionPhoto'] = "";
      basementReport = new BasementReport(null, json.encode(headers));
      BasementReport basementreport =
          await dbHelper.saveBasementReport(basementReport);

      if (basementreport == null) {
        showMessage(
            context,
            "Offline Database ERROR!",
            "Failed to save in offline-database.",
            Colors.redAccent,
            Icons.error_outline);
      } else {
        showMessage(context, "Success!", "Offline Database Saved Successfully!",
            Colors.greenAccent, Icons.done);

        widget.backToCustomerDetails(widget.customer);
      }
    } catch (error) {
      print(error);
    }
  }
}
