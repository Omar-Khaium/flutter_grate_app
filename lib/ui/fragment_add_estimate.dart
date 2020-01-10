import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/model/customer_details.dart';
import 'package:flutter_grate_app/model/product.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/sqflite/model/user.dart';
import 'package:flutter_grate_app/widgets/custome_back_button.dart';
import 'package:flutter_grate_app/widgets/drawing_placeholder.dart';
import 'package:flutter_grate_app/widgets/list_row_item.dart';
import 'package:flutter_grate_app/widgets/place_image.dart';
import 'package:flutter_grate_app/widgets/shimmer_estimate.dart';
import 'package:flutter_grate_app/widgets/signature_placeholder.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:flutter_grate_app/widgets/widget_drawing.dart';
import 'package:flutter_grate_app/widgets/widget_signature.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:painter/painter.dart';

import '../utils.dart';

class AddEstimateFragment extends StatefulWidget {
  Login login;
  LoggedInUser loggedInUser;
  CustomerDetails customer;
  ValueChanged<CustomerDetails> backToCustomerDetailsFromEstimate;

  AddEstimateFragment(
      {Key key,
      this.login,
      this.loggedInUser,
      this.customer,
      this.backToCustomerDetailsFromEstimate})
      : super(key: key);

  @override
  _AddEstimateFragmentState createState() => _AddEstimateFragmentState();
}

class _AddEstimateFragmentState extends State<AddEstimateFragment> {
  String dollar = "\$";
  TextEditingController _productNameController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _rateController = new TextEditingController();
  TextEditingController _priceController = new TextEditingController();
  TextEditingController _quantityController = new TextEditingController();
  TextEditingController _discountController = new TextEditingController();
  TextEditingController _noteController = new TextEditingController();
  TextEditingController _EstimateDiscountController =
      new TextEditingController();
  bool _discountModeIsPercentage = true;
  bool _EstimateDiscountModeIsPercentage = false;
  GlobalKey _columnKey = GlobalKey();
  Widget _Drawing = Container();
  List<Product> _productList = [];
  Product selectedProduct;
  int estimateIntId = 0;

  Widget _PMSignature = Container();
  Widget _HOSignature = Container();
  String base64Drawing = "";
  String base64PMSignature = "";
  String base64HOSignature = "";
  String _drawingImagePath = "";
  String _PMSignatureImagePath = "";
  String _HOSignatureImagePath = "";
  String _CameraImagePath = "";
  var base64 = const Base64Codec();
  String message;
  String formattedDate = DateFormat('MM/dd/yyyy').format(DateTime.now());

  String estimateId = "";
  String nextDate = "";
  var _days = ['After 15 days', 'After 30 days', 'After 60 days'];
  var _TaxType = ['Sales Tax', 'Non-Tax', 'Non-Profit'];
  var _currentValueSelected = "After 15 days";
  var _TaxTypeSelectedValue = "Sales Tax";

  double estimateBaseSubTotal = 0.0;
  double estimateDiscountTotal = 0.0;
  double estimateMainSubtotal = 0.0;
  double estimateTaxTotal = 0.0;
  double estimateTotalAmount = 0.0;

  var _future;

  File _imageFile;

  _openCamera() async {
    File cameraOutput =
        (await ImagePicker.pickImage(source: ImageSource.camera));
    setState(() {
      _imageFile = cameraOutput;
    });
  }

  _generateDrawingPicture(PictureDetails picture) {
    _Drawing = PlaceImageFromPicture(picture);
    picture.toPNG().then((val) {
      base64Drawing = base64.encode(val);
    });
  }

  _generatePMSignaturePicture(PictureDetails picture) {
    _PMSignature = PlaceImageFromPicture(picture);
    picture.toPNG().then((val) {
      base64PMSignature = base64.encode(val);
    });
  }

  _generateHOSignaturePicture(PictureDetails picture) {
    _HOSignature = PlaceImageFromPicture(picture);
    picture.toPNG().then((val) {
      base64HOSignature = base64.encode(val);
    });
  }

  @override
  void initState() {

    _future = getGeneratedEstimate();
    _Drawing = DrawingPlaceholder();
    _PMSignature = SignaturePlaceholder();
    _HOSignature = SignaturePlaceholder();
    nextDate =
        DateFormat('MM/dd/yyyy').format(DateTime.now().add(Duration(days: 15)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {

          return new ListView(
                  padding:
                      EdgeInsets.only(top: 16, left: 32, right: 32, bottom: 16),
                  shrinkWrap: false,
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: <Widget>[
                                  CustomBackButton(
                                    onTap: () => widget
                                        .backToCustomerDetailsFromEstimate(
                                            widget.customer),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(snapshot.data.toString(),
                                      style: fragmentTitleStyle()),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Container(
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Creating estimate for, " +
                                        widget.customer.FirstName,
                                    style: new TextStyle(fontSize: 20),
                                  )),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                width: 256,
                                                decoration: new BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    shape: BoxShape.rectangle,
                                                    border: Border.all(
                                                        width: 1.0,
                                                        color: Colors.black26),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                5.0))),
                                                padding: EdgeInsets.all(8),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Icon(Icons.email),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                      widget.customer.Email,
                                                      style:
                                                          estimateTextStyle(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 8),
                                                width: 144,
                                                decoration: new BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    shape: BoxShape.rectangle,
                                                    border: Border.all(
                                                        width: 1.0,
                                                        color: Colors.black26),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                5.0))),
                                                padding: EdgeInsets.all(8),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Icon(
                                                        MdiIcons.calendarMonth),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                      formattedDate.toString(),
                                                      style:
                                                          estimateTextStyle(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                width: 256,
                                                height: 48,
                                                decoration: new BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    shape: BoxShape.rectangle,
                                                    border: Border.all(
                                                        width: 1.0,
                                                        color: Colors.black26),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                5.0))),
                                                padding: EdgeInsets.all(8),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    items: _days.map((String
                                                        dropDownStringItem) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value:
                                                            dropDownStringItem,
                                                        child: Text(
                                                          dropDownStringItem,
                                                          style:
                                                              estimateTextStyle(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (String
                                                        newValueSelected) {
                                                      setState(() {
                                                        this._currentValueSelected =
                                                            newValueSelected;
                                                        switch (
                                                            _currentValueSelected) {
                                                          case "After 15 days":
                                                            {
                                                              nextDate = DateFormat(
                                                                      'MM/dd/yyyy')
                                                                  .format(DateTime
                                                                          .now()
                                                                      .add(Duration(
                                                                          days:
                                                                              15)));
                                                            }
                                                            break;
                                                          case "After 30 days":
                                                            {
                                                              nextDate = DateFormat(
                                                                      'MM/dd/yyyy')
                                                                  .format(DateTime
                                                                          .now()
                                                                      .add(Duration(
                                                                          days:
                                                                              30)));
                                                            }
                                                            break;
                                                          case "After 60 days":
                                                            {
                                                              nextDate = DateFormat(
                                                                      'MM/dd/yyyy')
                                                                  .format(DateTime
                                                                          .now()
                                                                      .add(Duration(
                                                                          days:
                                                                              60)));
                                                            }
                                                            break;
                                                        }
                                                      });
                                                    },
                                                    value:
                                                        _currentValueSelected,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 144,
                                                margin:
                                                    EdgeInsets.only(left: 8),
                                                decoration: new BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    shape: BoxShape.rectangle,
                                                    border: Border.all(
                                                        width: 1.0,
                                                        color: Colors.black26),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                5.0))),
                                                padding: EdgeInsets.all(8),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Icon(
                                                        MdiIcons.calendarMonth),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Text(
                                                      nextDate,
                                                      style:
                                                          estimateTextStyle(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Amount",
                              style: estimateTextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "$dollar ${estimateTotalAmount.toStringAsFixed(2).replaceAllMapped(reg, mathFunc)}",
                              style: fragmentTitleStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Container(
                              child: RaisedButton(
                                highlightElevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(36.0),
                                    side: BorderSide(color: Colors.white12)),
                                disabledColor: Colors.black,
                                color: Colors.black,
                                elevation: 2,
                                textColor: Colors.white,
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, top: 12, bottom: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Icon(Icons.add),
                                    Text(
                                      "Add Product",
                                      style: customButtonTextStyle(),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  _productNameController.text = "";
                                  _descriptionController.text = "";
                                  _quantityController.text = "";
                                  _rateController.text = "";
                                  _discountController.text = "";
                                  _priceController.text = "";
                                  showPopUp();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8, bottom: 8),
                      child: DottedBorder(
                        color: Colors.black,
                        strokeWidth: .5,
                        child: _productList.length == 0
                            ? Container(
                                padding: EdgeInsets.only(top: 16, bottom: 16),
                                child: Center(
                                  child: Text("No Products Found!"),
                                ),
                              )
                            : ListView.separated(
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    thickness: .75,
                                  );
                                },
                                physics: ScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: _productList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: EdgeInsets.all(16),
                                    child: Table(
                                      columnWidths: {
                                        0: FlexColumnWidth(3.5),
                                        1: FlexColumnWidth(1),
                                        2: FlexColumnWidth(.5),
                                      },
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      children: [
                                        TableRow(children: [
                                          TableCell(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Icon(MdiIcons.cubeOutline),
                                                    SizedBox(
                                                      width: 16,
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        _productList[index]
                                                            .Name,
                                                        style: listTextStyle(),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Icon(MdiIcons.text),
                                                    SizedBox(
                                                      width: 16,
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        _productList[index]
                                                            .Description,
                                                        style: listTextStyle(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Icon(
                                                        MdiIcons.calendarClock),
                                                    SizedBox(
                                                      width: 16,
                                                    ),
                                                    Text(
                                                      _productList[index].Date,
                                                      style: listTextStyle(),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          TableCell(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Icon(MdiIcons.layers),
                                                    SizedBox(
                                                      width: 16,
                                                    ),
                                                    Text(
                                                      "${_productList[index].Quantity.replaceAllMapped(reg, mathFunc)}",
                                                      style: listTextStyle(),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Icon(MdiIcons
                                                        .cashUsdOutline),
                                                    SizedBox(
                                                      width: 16,
                                                    ),
                                                    Text(
                                                      "${_productList[index].Rate.replaceAllMapped(reg, mathFunc)}",
                                                      style: listTextStyle(),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          TableCell(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey.shade300,
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.black,
                                                      size: 18,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _productList
                                                            .removeAt(index);
                                                        estimateTotalCalculation();
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ])
                                      ],
                                    ),
                                  );
                                }),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: new BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                          width: 1.0, color: Colors.black26),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0))),
                                  child: InkWell(
                                    child: _imageFile == null
                                        ? Icon(Icons.camera_enhance)
                                        : Image.file(
                                            _imageFile,
                                            fit: BoxFit.cover,
                                          ),
                                    onTap: _openCamera,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 360,
                              child: Table(
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                columnWidths: {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(2),
                                  2: FlexColumnWidth(1),
                                },
                                children: [
                                  TableRow(children: [
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Text("Retail"),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 12, bottom: 12),
                                        child: Divider(
                                          color: Colors.black,
                                          thickness: .5,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            "\$ ${estimateBaseSubTotal.toStringAsFixed(2).replaceAllMapped(reg, mathFunc)}"),
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Text("Discount"),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: TextField(
                                        controller: _EstimateDiscountController,
                                        onChanged: (val) {
                                          setState(() {
                                            estimateTotalCalculation();
                                          });
                                        },
                                        autofocus: false,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                signed: true, decimal: true),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          prefixIcon: IconButton(
                                            icon: Icon(
                                                _EstimateDiscountModeIsPercentage
                                                    ? MdiIcons.sale
                                                    : MdiIcons.cashUsd),
                                            onPressed: () {
                                              setState(() {
                                                _EstimateDiscountModeIsPercentage =
                                                    !_EstimateDiscountModeIsPercentage;
                                                estimateTotalCalculation();
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "\$ ${estimateDiscountTotal.toStringAsFixed(2) == "0.00" ? "" : "-"} ${estimateDiscountTotal.toStringAsFixed(2).replaceAllMapped(reg, mathFunc)}",
                                          style:
                                              TextStyle(color: discountColor()),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Text(
                                        "Subtotal",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 12, bottom: 12),
                                        child: Divider(
                                          color: Colors.black,
                                          thickness: 1,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "\$ ${estimateMainSubtotal.toStringAsFixed(2).replaceAllMapped(reg, mathFunc)}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Text("Tax"),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Container(
                                        decoration: new BoxDecoration(
                                            color: Colors.grey.shade200,
                                            shape: BoxShape.rectangle,
                                            border: Border.all(
                                                width: 1.0,
                                                color: Colors.black26),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))),
                                        padding:
                                            EdgeInsets.only(left: 8, right: 8),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            items: _TaxType.map(
                                                (String dropDownStringItem) {
                                              return DropdownMenuItem<String>(
                                                value: dropDownStringItem,
                                                child: Text(dropDownStringItem),
                                              );
                                            }).toList(),
                                            onChanged:
                                                (String newValueSelected) {
                                              setState(() {
                                                this._TaxTypeSelectedValue =
                                                    newValueSelected;

                                                estimateTotalCalculation();
                                              });
                                            },
                                            value: _TaxTypeSelectedValue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "\$ ${estimateTaxTotal.toStringAsFixed(2) == "0.00" ? "" : "+"} ${estimateTaxTotal.toStringAsFixed(2).replaceAllMapped(reg, mathFunc)}",
                                          style: TextStyle(color: taxColor()),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Text(
                                        "Estimate Toal",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 12, bottom: 12),
                                        child: Divider(
                                          color: Colors.black,
                                          thickness: 1,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      verticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          "\$ ${estimateTotalAmount.toStringAsFixed(2).replaceAllMapped(reg, mathFunc)}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
/*------------------BASEMENT DRAWING------------------*/
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
                                  "Basement Drawing",
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
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height - 200,
                                  color: Colors.grey.shade100,
                                  child: InkWell(
                                    child: _Drawing,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return DrawingDialog(
                                                picture:
                                                    _generateDrawingPicture);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
/*------------------Agreement DRAWING------------------*/
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
                                Text(
                                  "Agreement",
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
                                new TextField(
                                  controller: _noteController,
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
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 256,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return SignatureDialog(
                                                      picture:
                                                          _generatePMSignaturePicture);
                                                },
                                              ),
                                            );
                                          },
                                          child: Container(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Text("PM Signature"),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Expanded(
                                                  child: _PMSignature,
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Center(
                                                  child: Container(
                                                    color: Colors.grey.shade100,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Center(
                                                        child: ListRowItem(
                                                          icon: Icons.event,
                                                          text:
                                                              "${DateFormat('MM/dd/yyyy').format(DateTime.now())}",
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 48,
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return SignatureDialog(
                                                      picture:
                                                          _generateHOSignaturePicture);
                                                },
                                              ),
                                            );
                                          },
                                          child: Container(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Text("Home Owner Signature"),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Expanded(
                                                  child: _HOSignature,
                                                ),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                Center(
                                                  child: Container(
                                                    color: Colors.grey.shade100,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Center(
                                                        child: ListRowItem(
                                                          icon: Icons.event,
                                                          text:
                                                              "${DateFormat('MM/dd/yyyy').format(DateTime.now())}",
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                height: 48,
                                width: 144,
                                child: RaisedButton(
                                  highlightElevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(36.0),
                                      side: BorderSide(color: Colors.white12)),
                                  disabledColor: Colors.black,
                                  color: Colors.black,
                                  elevation: 2,
                                  textColor: Colors.white,
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(
                                    "Save",
                                    style: customButtonTextStyle(),
                                  ),
                                  onPressed: () {
                                    if (_productList.length == 0) {
                                      showError("Product list is empty!");
                                    } else {
                                      showSaving();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
        } else {
          return ShimmerAddOrEditEstimate();
        }
      },
    );
  }

  void showPopUp() {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return new BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  "Add Product/Service",
                  style: new TextStyle(fontSize: 24, color: Colors.black),
                ),
                content: SizedBox(
                  width: 600,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  decoration: new BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                          width: 1.0, color: Colors.black26),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0))),
                                  padding: EdgeInsets.all(8),
                                  child: TypeAheadField(
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                            controller: _productNameController,
                                            autofocus: true,
                                            keyboardType: TextInputType.text,
                                            maxLines: 1,
                                            decoration: new InputDecoration(
                                              labelText: "Product",
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none),
                                              icon: new Icon(
                                                MdiIcons.cube,
                                                color: Colors.grey,
                                              ),
                                              hintStyle: customHintStyle(),
                                              isDense: true,
                                            )),
                                    suggestionsCallback: (pattern) async {
                                      return await getSuggestions(pattern);
                                    },
                                    itemBuilder: (context, suggestion) {
                                      Product product =
                                          Product.fromMap(suggestion, true);
                                      return ListTile(
                                        leading: Icon(MdiIcons.cubeOutline),
                                        title: Text(product.name),
                                        subtitle: Text(product.description),
                                        trailing: Text(
                                            '\$ ${product.rate.toStringAsFixed(2)}'),
                                      );
                                    },
                                    onSuggestionSelected: (suggestion) {
                                      selectedProduct =
                                          Product.fromMap(suggestion, true);
                                      _productNameController.text =
                                          selectedProduct.name;
                                      _descriptionController.text =
                                          selectedProduct.description;
                                      _quantityController.text = "1";
                                      _rateController.text = selectedProduct
                                          .rate
                                          .toStringAsFixed(2);
                                      _discountController.text = "0.0";
                                      _priceController.text = selectedProduct
                                          .rate
                                          .toStringAsFixed(2);
                                    },
                                    hideSuggestionsOnKeyboardHide: true,
                                    hideOnError: true,
                                  ),
                                ),
                                flex: 2,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: new BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                          width: 1.0, color: Colors.black26),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0))),
                                  padding: EdgeInsets.all(8),
                                  child: TextFormField(
                                    controller: _quantityController,
                                    style: customTextStyle(),
                                    cursorColor: Colors.black87,
                                    keyboardType: TextInputType.number,
                                    maxLines: 1,
                                    onChanged: (val) {
                                      calculatePrice().then((price) {
                                        _priceController.text =
                                            double.parse(price.toString())
                                                .roundToDouble()
                                                .toStringAsFixed(2);
                                      });
                                    },
                                    decoration: new InputDecoration(
                                      labelText: "Quantity",
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide.none),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide.none),
                                      icon: new Icon(
                                        MdiIcons.chartBarStacked,
                                        color: Colors.grey,
                                      ),
                                      hintStyle: customHintStyle(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      height: 224,
                                      decoration: new BoxDecoration(
                                          color: Colors.grey.shade200,
                                          shape: BoxShape.rectangle,
                                          border: Border.all(
                                              width: 1.0,
                                              color: Colors.black26),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0))),
                                      padding: EdgeInsets.all(8),
                                      child: TextField(
                                        controller: _descriptionController,
                                        style: customTextStyle(),
                                        cursorColor: Colors.black87,
                                        keyboardType: TextInputType.text,
                                        decoration: new InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Product Description",
                                          icon: Icon(Icons.description),
                                          hintStyle: customHintStyle(),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  key: _columnKey,
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      decoration: new BoxDecoration(
                                          color: Colors.grey.shade200,
                                          shape: BoxShape.rectangle,
                                          border: Border.all(
                                              width: 1.0,
                                              color: Colors.black26),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0))),
                                      padding: EdgeInsets.all(8),
                                      child: TextFormField(
                                        controller: _rateController,
                                        style: customTextStyle(),
                                        cursorColor: Colors.black87,
                                        onChanged: (val) {
                                          calculatePrice().then((price) {
                                            _priceController.text =
                                                double.parse(price.toString())
                                                    .toStringAsFixed(2);
                                          });
                                        },
                                        keyboardType: TextInputType.number,
                                        maxLines: 1,
                                        decoration: new InputDecoration(
                                          labelText: "Rate",
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none),
                                          icon: new Icon(
                                            MdiIcons.chartBarStacked,
                                            color: Colors.grey,
                                          ),
                                          hintStyle: customHintStyle(),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                      decoration: new BoxDecoration(
                                          color: Colors.grey.shade200,
                                          shape: BoxShape.rectangle,
                                          border: Border.all(
                                              width: 1.0,
                                              color: Colors.black26),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0))),
                                      padding: EdgeInsets.all(8),
                                      child: TextFormField(
                                        controller: _discountController,
                                        style: customTextStyle(),
                                        onChanged: (val) {
                                          calculatePrice().then((price) {
                                            _priceController.text =
                                                double.parse(price.toString())
                                                    .toStringAsFixed(2);
                                          });
                                        },
                                        cursorColor: Colors.black87,
                                        keyboardType: TextInputType.number,
                                        maxLines: 1,
                                        autofocus: true,
                                        decoration: new InputDecoration(
                                          labelText: _discountModeIsPercentage
                                              ? "Percentage"
                                              : "Amount",
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none),
                                          icon: IconButton(
                                            icon: Icon(
                                              _discountModeIsPercentage
                                                  ? MdiIcons.filePercent
                                                  : MdiIcons.cashRefund,
                                              color: Colors.grey,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              _discountModeIsPercentage =
                                                  !_discountModeIsPercentage;
                                              setState(() {});
                                            },
                                          ),
                                          hintStyle: customHintStyle(),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                      decoration: new BoxDecoration(
                                          color: Colors.grey.shade200,
                                          shape: BoxShape.rectangle,
                                          border: Border.all(
                                              width: 1.0,
                                              color: Colors.black26),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0))),
                                      padding: EdgeInsets.all(8),
                                      child: TextFormField(
                                        controller: _priceController,
                                        style: customTextStyle(),
                                        cursorColor: Colors.black87,
                                        enabled: false,
                                        onChanged: (val) {
                                          calculatePrice().then((price) {
                                            _priceController.text =
                                                double.parse(price.toString())
                                                    .toStringAsFixed(2);
                                          });
                                        },
                                        keyboardType: TextInputType.number,
                                        maxLines: 1,
                                        decoration: new InputDecoration(
                                          labelText: "Price",
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none),
                                          icon: new Icon(
                                            MdiIcons.cashUsdOutline,
                                            color: Colors.grey,
                                          ),
                                          hintStyle: customHintStyle(),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: <Widget>[
                  Container(
                    width: 128,
                    child: OutlineButton(
                      highlightElevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(36.0),
                          side: BorderSide(color: Colors.white12)),
                      color: Colors.black,
                      textColor: Colors.white,
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "Cancel",
                        style: new TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontFamily: "Roboto"),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Container(
                    width: 128,
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
                        "Save",
                        style: customButtonTextStyle(),
                      ),
                      onPressed: () {
                        selectedProduct.name = _productNameController.text;
                        selectedProduct.description =
                            _descriptionController.text;
                        selectedProduct.quantity =
                            int.parse(_quantityController.text);
                        selectedProduct.rate =
                            double.parse(_rateController.text);
                        selectedProduct.discount =
                            double.parse(_discountController.text);
                        selectedProduct.discountAsPercentage =
                            _discountModeIsPercentage;
                        selectedProduct.price =
                            double.parse(_priceController.text);
                        Navigator.of(context).pop();
                        refreshList(selectedProduct);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void showError(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return new BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AlertDialog(
              title: Text(
                "Error !",
                style: errorTitleTextStyle(),
              ),
              content: Text(message),
              contentTextStyle: estimateTextStyle(),
              actions: <Widget>[
                OutlineButton(
                  textColor: Colors.red,
                  child: Text("Close"),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ));
      },
    );
  }

  void showSaving() async {
    message = "Please wait...";
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  "Saving Estimate",
                  style: estimateTextStyle(),
                ),
                content: Text(message),
                contentTextStyle: estimateTextStyle(),
              );
            },
          ),
        );
      },
    );
    message = "Uploading Camera Image...";
    if (_imageFile != null) {
      await uploadCameraImage();
    }

    message = "Uploading Drawing Image...";
    if (base64Drawing.isNotEmpty) {
      await uploadDrawingImage();
    }

    message = "Uploading Home Owner Signature...";
    if (base64HOSignature.isNotEmpty) {
      await uploadHOSignatureImage();
    }

    message = "Saving Estimate...";
    bool resultStatus = await CreateEstimate();
    Navigator.of(context).pop();
    showAPIResponse(
        context,
        resultStatus ? "Estimate saved Successfully!" : "Failed to Save!",
        Color(resultStatus ? COLOR_SUCCESS : COLOR_DANGER));
    setState(() {});
    if (resultStatus) widget.backToCustomerDetailsFromEstimate(widget.customer);
  }

  Future getSuggestions(String pattern) async {
    if (pattern.isNotEmpty) {
      Map<String, String> headers = {
        'Authorization': widget.login.accessToken,
        'Key': pattern.trim()
      };

      var url = "https://api.rmrcloud.com/GetEquipmentListByKey";
      var result = await http.get(url, headers: headers);
      if (result.statusCode == 200) {
        return json.decode(result.body)['EquipmentList'];
      } else {
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        return [];
      }
    }
  }

  Future<double> calculatePrice() async {
    int quantity =
        _quantityController.text == null || _quantityController.text.isEmpty
            ? 0
            : int.parse(_quantityController.text);
    double rate = _rateController.text == null || _rateController.text.isEmpty
        ? 0
        : double.parse(_rateController.text);
    double discount =
        _discountController.text == null || _discountController.text.isEmpty
            ? 0
            : double.parse(_discountController.text);
    return _discountModeIsPercentage
        ? ((quantity * rate) * (1 - (discount / 100)))
        : ((quantity * rate) - discount);
  }

  Future estimateTotalCalculation() async {
    setState(() {
      double discount = _EstimateDiscountController.text == null ||
              _EstimateDiscountController.text.isEmpty
          ? 0
          : double.parse(_EstimateDiscountController.text);
      estimateBaseSubTotal = getCurrentBaseSubtotal();
      estimateDiscountTotal = _EstimateDiscountModeIsPercentage
          ? (estimateBaseSubTotal * discount / 100)
          : discount;
      estimateMainSubtotal = estimateBaseSubTotal - estimateDiscountTotal;
      estimateTaxTotal = (estimateMainSubtotal *
              (_TaxTypeSelectedValue == _TaxType[0] ? 8.25 : 0)) /
          100;
      estimateTotalAmount = estimateMainSubtotal - estimateTaxTotal;
    });
  }

  getCurrentBaseSubtotal() {
    double price = 0;
    for (Product product in _productList) {
      price += product.price;
    }
    return price;
  }

  Future getGeneratedEstimate() async {
    Map<String, String> headers = {
      'Authorization': widget.login.accessToken,
      'CustomerId': widget.customer.Id,
      'UserId': widget.loggedInUser.UserGUID,
      'CompanyId': widget.loggedInUser.CompanyGUID,
    };

    var url = "https://api.rmrcloud.com/GenerateEstimate";
    var result = await http.post(url, headers: headers);
    if (result.statusCode == 200) {
      estimateIntId = json.decode(result.body)['Invoice']['Id'];
      estimateId = json.decode(result.body)['Invoice']['InvoiceId'];
      return estimateId;
    } else {
      showMessage(context, "Network error!", json.decode(result.body),
          Colors.redAccent, Icons.warning);
      return "";
    }
  }

  Future CreateEstimate() async {
    Map<String, String> headers = {
      'Authorization': widget.login.accessToken,
      'EstimateId': estimateIntId.toString(),
      'DiscountAmount': _EstimateDiscountModeIsPercentage
          ? "0.00"
          : _EstimateDiscountController.text,
      'TotalAmount': estimateTotalAmount.toStringAsFixed(2),
      'Amount': estimateMainSubtotal.toStringAsFixed(2),
      'Tax': estimateTaxTotal.toStringAsFixed(2),
      'Note': _noteController.text,
      'DiscountPercent': _EstimateDiscountModeIsPercentage
          ? _EstimateDiscountController.text
          : "0.00",
      'DiscountType': _EstimateDiscountModeIsPercentage ? "percent" : "amount",
      'DueDate': nextDate,
      'CreatedDate': formattedDate,
      'CustomerId': widget.customer.CustomerId,
      'CompanyId': widget.loggedInUser.CompanyGUID,
      'Drawingimage': _drawingImagePath,
      'Cameraimage': _CameraImagePath,
      'Signimage': _HOSignatureImagePath,
      'Content-Type': "application/json",
    };

    Map<String, List> body = {};
    List<Map<String, dynamic>> map = [];
    for (Product product in _productList) {
      map.add(product.toJson());
    }
    body['ListEstimate'] = map;
    var url = "https://api.rmrcloud.com/CreateEstimate";
    var result =
        await http.post(url, headers: headers, body: json.encode(body));
    print(json.encode(body));
    if (result.statusCode == 200) {
      return json.decode(result.body)['result'];
    } else {
      return false;
    }
  }

  discountColor() {
    return estimateDiscountTotal.toStringAsFixed(2) == "0.00"
        ? Colors.black
        : Colors.green;
  }

  taxColor() {
    return estimateTaxTotal.toStringAsFixed(2) == "0.00"
        ? Colors.black
        : Colors.red;
  }

  Future uploadCameraImage() async {
    var url = "https://api.rmrcloud.com/UploadImageFile";
    Map<String, String> headers = <String, String>{
      "Authorization": widget.login.accessToken
    };
    Map<String, String> body = <String, String>{
      "filename": "file-from-omar.png",
      "filepath": base64.encode(_imageFile.readAsBytesSync())
    };
    var result = await http.post(url, headers: headers, body: body);
    if (result.statusCode == 200) {
      Map map = json.decode(result.body);
      _CameraImagePath = map['filePath'];
      return true;
    } else {
      return false;
    }
  }

  Future uploadDrawingImage() async {
    var url = "https://api.rmrcloud.com/UploadImageFile";
    Map<String, String> headers = <String, String>{
      "Authorization": widget.login.accessToken
    };
    Map<String, String> body = <String, String>{
      "filename": "file-from-omar.png",
      "filepath": base64Drawing
    };
    var result = await http.post(url, headers: headers, body: body);
    if (result.statusCode == 200) {
      Map map = json.decode(result.body);
      _drawingImagePath = map['filePath'];
      return true;
    } else {
      return false;
    }
  }

  Future uploadHOSignatureImage() async {
    var url = "https://api.rmrcloud.com/UploadImageFile";
    Map<String, String> headers = <String, String>{
      "Authorization": widget.login.accessToken
    };
    Map<String, String> body = <String, String>{
      "filename": "file-from-omar.png",
      "filepath": base64HOSignature
    };
    var result = await http.post(url, headers: headers, body: body);
    if (result.statusCode == 200) {
      Map map = json.decode(result.body);
      _HOSignatureImagePath = map['filePath'];
      return true;
    } else {
      return false;
    }
  }

  refreshList(Product selectedProduct) async {
    setState((){
      _productList.add(selectedProduct);
    });
    estimateTotalCalculation();
  }
}
