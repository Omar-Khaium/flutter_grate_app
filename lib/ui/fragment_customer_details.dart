import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_grate_app/model/customer_details.dart';
import 'package:flutter_grate_app/model/estimate.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/sqflite/model/user.dart';
import 'package:flutter_grate_app/widgets/custome_back_button.dart';
import 'package:flutter_grate_app/widgets/customer_details_shimmer.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:flutter_grate_app/widgets/widget_image_alert.dart';
import 'package:flutter_grate_app/widgets/widget_no_internet.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:uuid/uuid.dart';

import '../utils.dart';

class CustomerDetailsFragment extends StatefulWidget {
  final Login login;
  final String customerID;
  final String searchText;
  final ValueChanged<int> backToDashboard;
  final ValueChanged<String> backToSearch;
  final ValueChanged<CustomerDetails> goToAddBasementReport;
  final ValueChanged<CustomerDetails> goToUpdateBasementReport;
  final ValueChanged<CustomerDetails> goToAddEstimate;
  final ValueChanged<CustomerDetails> goToUpdateEstimate;
  final ValueChanged<CustomerDetails> goToRecommendedLevel;
  final ValueChanged<CustomerDetails> goToEditCustomer;
  final bool fromSearch;
  CustomerDetails customer;
  LoggedInUser loggedInUser;

  CustomerDetailsFragment(
      {Key key,
      this.login,
      this.customerID,
      this.searchText,
      this.customer,
      this.backToDashboard,
      this.backToSearch,
      this.goToAddBasementReport,
      this.goToUpdateBasementReport,
      this.goToAddEstimate,
      this.goToUpdateEstimate,
      this.goToRecommendedLevel,
      this.goToEditCustomer,
      this.fromSearch,
      this.loggedInUser})
      : super(key: key);

  @override
  _CustomerDetailsFragmentState createState() =>
      _CustomerDetailsFragmentState();
}

class _CustomerDetailsFragmentState extends State<CustomerDetailsFragment> with SingleTickerProviderStateMixin{
  List<Estimate> _list;
  var _base64Image;

  StreamController<List<Estimate>> _controller =
      StreamController<List<Estimate>>();
  File _imageFile;
  bool offline = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> _showDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Make A choice"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  ListTile(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      widget.customer.ProfileImage = null;
                      _openGallery();
                    },
                    leading: Icon(Icons.photo_album),
                    title: Text("Gallery"),
                  ),
                  ListTile(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      widget.customer.ProfileImage = null;
                      _openCamera();
                    },
                    leading: Icon(Icons.camera_enhance),
                    title: Text("Camera"),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) => Container(
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
                    onTap: () => widget.fromSearch
                        ? widget.backToSearch(widget.searchText)
                        : widget.backToDashboard(0),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/2,
                    child: Text(
                        "${offline ? "Offline" : widget.customer == null ? "Loading" : "${widget.customer.ProfileName}'s Profile"}",
                        style: fragmentTitleStyle(), overflow: TextOverflow.ellipsis,),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Expanded(
              child: StreamBuilder(
                stream: _controller.stream,
                initialData: _list,
                builder: (context, snapshot) {
                  try {
                    if (snapshot.hasData) {
                      return offline
                          ? NoInternetConnectionWidget(refreshConnectivity)
                          : Column(
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    Material(
                                      elevation: 4,
                                      child: Container(
                                        width: double.infinity,
                                        height: widget.customer.Type == null ||
                                                widget.customer.Type.isEmpty
                                            ? 220
                                            : 256,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 16, right: 16, top: 8),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Stack(
                                                    children: <Widget>[
                                                      ClipRRect(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          12)),
                                                          child: Container(
                                                            child: _imageFile !=
                                                                    null
                                                                ? Image.file(
                                                                    _imageFile,
                                                                    width: 128,
                                                                    height: 128,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : (widget.customer.ProfileImage !=
                                                                            null &&
                                                                        widget
                                                                            .customer
                                                                            .ProfileImage
                                                                            .isNotEmpty
                                                                    ? InkWell(
                                                              onTap: ()=>showDialog(context: context, builder: (context)=> imageAlert(context, buildCustomerImageUrl(
                                                                  widget.customer.CustomerId,
                                                                  widget.loggedInUser.CompanyGUID,
                                                                  widget.login.username,
                                                                  Uuid().v1()))),
                                                                      child: Container(
                                                                          height:
                                                                              128,
                                                                          width:
                                                                              128,
                                                                          child: FadeInImage
                                                                              .assetNetwork(
                                                                            placeholder:
                                                                                "images/loading.gif",
                                                                            image: buildCustomerImageUrl(
                                                                                widget.customer.CustomerId,
                                                                                widget.loggedInUser.CompanyGUID,
                                                                                widget.login.username,
                                                                                Uuid().v1()),
                                                                            fit: BoxFit
                                                                                .cover,
                                                                          ),
                                                                        ),
                                                                    )
                                                                    : Icon(
                                                                        Icons
                                                                            .person,
                                                                        size:
                                                                            142,
                                                                      )),
                                                            color: Colors
                                                                .grey.shade100,
                                                          )),
                                                      Positioned(
                                                        top: 4,
                                                        right: 4,
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.black54,
                                                          child: InkWell(
                                                            child: Icon(
                                                              MdiIcons.imageEdit,
                                                              size: 18,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onTap: () {
                                                              _showDialog(
                                                                  context);
                                                            },
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: 24,
                                                  ),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        widget.customer.Name,
                                                        style: Theme.of(context).textTheme.title.copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      widget.customer.Type ==
                                                                  null ||
                                                              widget.customer
                                                                  .Type.isEmpty
                                                          ? Container()
                                                          : SizedBox(
                                                              height: 8,
                                                            ),
                                                      widget.customer.Type ==
                                                                  null ||
                                                              widget.customer
                                                                  .Type.isEmpty
                                                          ? Container()
                                                          : Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Icon(MdiIcons
                                                                    .bagChecked),
                                                                SizedBox(
                                                                  width: 6,
                                                                ),
                                                                Text(
                                                                  widget
                                                                      .customer
                                                                      .Type,
                                                                  style: new TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ],
                                                            ),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Icon(Icons.email),
                                                          SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            widget
                                                                .customer.Email,
                                                            style:
                                                                new TextStyle(
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Icon(Icons.call),
                                                          SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                              widget.customer
                                                                  .ContactNum,
                                                              style:
                                                                  new TextStyle(
                                                                      fontSize:
                                                                          16)),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 8,
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Icon(Icons
                                                              .location_on),
                                                          SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            widget.customer
                                                                .Address,
                                                            style:
                                                                listTextStyle(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              CircleAvatar(
                                                backgroundColor: Colors.grey.shade100,
                                                child: IconButton(
                                                  icon: Icon(MdiIcons.accountEdit, color: Colors.black),
                                                  onPressed: () =>
                                                      widget.goToEditCustomer(
                                                          widget.customer),
                                                ),
                                              )
                                            ],
                                          ),
                                          Container(
                                            height: orientation ==
                                                    Orientation.landscape
                                                ? 136
                                                : 144,
                                            margin: EdgeInsets.only(top: 10),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: RaisedButton(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    elevation: 8,
                                                    onPressed: () {
                                                      if (widget.customer
                                                          .HasInspectionReport) {
                                                        widget
                                                            .goToUpdateBasementReport(
                                                                widget
                                                                    .customer);
                                                      } else {
                                                        widget
                                                            .goToAddBasementReport(
                                                                widget
                                                                    .customer);
                                                      }
                                                    },
                                                    color: Colors.black,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              18),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Icon(
                                                                widget.customer
                                                                        .HasInspectionReport
                                                                    ? MdiIcons
                                                                        .fileDocumentOutline
                                                                    : MdiIcons
                                                                        .plusBoxMultiple,
                                                                color: Colors
                                                                    .white,
                                                                size: 42),
                                                            SizedBox(
                                                              height: 16,
                                                            ),
                                                            Text(
                                                              "${widget.customer.HasInspectionReport ? "View" : "Add"} Basement Report",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .body1
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 16,
                                                ),
                                                Expanded(
                                                  child: RaisedButton(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    elevation: 8,
                                                    onPressed: () {
                                                      widget
                                                          .goToRecommendedLevel(
                                                              widget.customer);
                                                    },
                                                    color: Colors.black,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              18),
                                                      child: Center(
                                                        child: InkWell(
                                                          onTap: () {
                                                            widget.goToRecommendedLevel(
                                                                widget
                                                                    .customer);
                                                          },
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              Icon(
                                                                getRecommendedLevelIcon(widget
                                                                    .customer
                                                                    .RecommendedLevel
                                                                    .toInt()),
                                                                color: Colors
                                                                    .white,
                                                                size: 42,
                                                              ),
                                                              SizedBox(
                                                                height: 16,
                                                              ),
                                                              Text(
                                                                "Recommended Level",
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .body1
                                                                    .copyWith(
                                                                        color: Colors
                                                                            .white),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 16,
                                                ),
                                                Expanded(
                                                  child: RaisedButton(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    elevation: 8,
                                                    onPressed: () {
                                                      widget.goToAddEstimate(
                                                          widget.customer);
                                                    },
                                                    color: Colors.black,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              18),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Icon(
                                                                Icons.pie_chart,
                                                                color: Colors
                                                                    .white,
                                                                size: 42),
                                                            SizedBox(
                                                              height: 16,
                                                            ),
                                                            Text(
                                                              "Add Estimate",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .body1
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .white),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Expanded(
                                  child: _list.length == 0
                                      ? Image.asset(
                                          "images/no_data.png",
                                          fit: BoxFit.cover,
                                        )
                                      : ListView.builder(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Table(
                                                    columnWidths: {
                                                      0: FlexColumnWidth(3.25),
                                                      1: FlexColumnWidth(1.75),
                                                      2: FlexColumnWidth(1),
                                                    },
                                                    defaultVerticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .middle,
                                                    children: [
                                                      TableRow(children: [
                                                        TableCell(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Row(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(MdiIcons
                                                                      .identifier),
                                                                  SizedBox(
                                                                    width: 16,
                                                                  ),
                                                                  Text(
                                                                    _list[index]
                                                                        .InvoiceId,
                                                                    style:
                                                                        listTextStyle(),
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Row(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(MdiIcons
                                                                      .text),
                                                                  SizedBox(
                                                                    width: 16,
                                                                  ),
                                                                  Flexible(
                                                                    child: Text(
                                                                      _list[index]
                                                                          .Description,
                                                                      style:
                                                                          listTextStyle(),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Row(
                                                                children: <
                                                                    Widget>[
                                                                  Icon(MdiIcons
                                                                      .calendarClock),
                                                                  SizedBox(
                                                                    width: 16,
                                                                  ),
                                                                  Text(
                                                                    _list[index]
                                                                        .CreatedDate,
                                                                    style:
                                                                        listTextStyle(),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: <
                                                                    Widget>[
                                                                  Icon(MdiIcons
                                                                      .layers),
                                                                  SizedBox(
                                                                    width: 16,
                                                                  ),
                                                                  Text(
                                                                    _list[index]
                                                                        .Quantity,
                                                                    style:
                                                                        listTextStyle(),
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: <
                                                                    Widget>[
                                                                  Icon(MdiIcons
                                                                      .cashUsdOutline),
                                                                  SizedBox(
                                                                    width: 16,
                                                                  ),
                                                                  Text(
                                                                    "${_list[index].Price == null || _list[index].Price == "0.0" ? 0.0 : currencyFormat.format(double.parse(_list[index].Price))}",
                                                                    style:
                                                                        listTextStyle(),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <
                                                                  Widget>[
                                                                CircleAvatar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .grey
                                                                          .shade300,
                                                                  child:
                                                                      InkWell(
                                                                    child: Icon(
                                                                      Icons
                                                                          .content_copy,
                                                                      color: Colors
                                                                          .black,
                                                                      size: 18,
                                                                    ),
                                                                    onTap: () {
                                                                      duplicateDialog(
                                                                          index);
                                                                    },
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 8,
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) =>
                                                                                deleteMessage(index));
                                                                  },
                                                                  child:
                                                                      CircleAvatar(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey
                                                                            .shade300,
                                                                    child: Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color: Colors
                                                                          .black,
                                                                      size: 18,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ])
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Divider(),
                                                ],
                                              ),
                                              onTap: () {
                                                widget.customer.EstimateId =
                                                    _list[index].InvoiceId;
                                                widget.customer.EstimateIntId =
                                                    int.parse(_list[index].Id);
                                                widget.goToUpdateEstimate(
                                                    widget.customer);
                                              },
                                            );
                                          },
                                          itemCount: _list.length,
                                        ),
                                ),
                              ],
                            );
                    } else {
                      return offline
                          ? NoInternetConnectionWidget(refreshConnectivity)
                          : ShimmerCustomerDetailsFragment();
                    }
                  } catch (error) {
                    return offline
                        ? NoInternetConnectionWidget(refreshConnectivity)
                        : Center(
                            child: Text(
                              "Something went wrong...",
                              style: listTextStyle(),
                            ),
                          );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  refreshConnectivity(bool flag) {
    setState(() {
      offline = flag;
    });
  }

  _openGallery() async {
    File pickFromGallery =
        (await ImagePicker.pickImage(source: ImageSource.gallery));
    setState(() {
      _imageFile = pickFromGallery;
      _base64Image = base64Encode(_imageFile.readAsBytesSync());
    });
    Navigator.of(context).pop();
    showDialog(context: context, builder: (_) => loadingAlert());
    uploadCustomerImage();
  }

  _openCamera() async {
    File pickFromCamera =
        (await ImagePicker.pickImage(source: ImageSource.camera));
    setState(() {
      _imageFile = pickFromCamera;
      _base64Image = base64Encode(_imageFile.readAsBytesSync());
    });
    Navigator.of(context).pop();
    showDialog(context: context, builder: (_) => loadingAlert());
    uploadCustomerImage();
  }

  Future getData() async {
    try {
      Map<String, String> headers = {
        'Authorization': widget.login.accessToken,
        'CustomerIntId': '${widget.customerID}',
        'PageNo': '1',
        'PageSize': '10',
      };

      var result =
          await http.get(BASE_URL + API_UPDATE_CUSTOMER, headers: headers);
      setState(() {
        offline = false;
      });
      if (result.statusCode == 200) {
        widget.customer = CustomerDetails.fromMap(json.decode(result.body));
        _list = [];
        _list.addAll(widget.customer.estimates);
        setState(() {
          offline = false;
        });
        _controller.sink.add(_list);
      } else {
        setState(() {
          offline = false;
        });
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        _controller.sink.add([]);
      }
    } catch (error) {
      if (error.toString().contains("SocketException")) {
        setState(() {
          offline = true;
        });
        showNoInternetConnection(context);
      }
      _controller.sink.add([]);
    }
  }

  uploadCustomerImage() async {
    try {
      Map<String, String> headers = {
        'Authorization': widget.login.accessToken,
        'CustomerId': '${widget.customerID}',
      };
      Map<String, String> body = <String, String>{
        "filename": "Demo-File.png",
        "filepath": _base64Image
      };

      var response = await http.post(BASE_URL + API_CUSTOMER_UPLOAD,
          headers: headers, body: body);
      setState(() {
        offline = false;
      });
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        showMessage(
            context,
            "Profile Picture",
            "Successfully updated ${widget.customer.Name}'s profile picture",
            Colors.green,
            Icons.check);
      } else {
        Navigator.of(context).pop();
        showMessage(context, "Error!", "Something went wrong", Colors.redAccent,
            Icons.warning);
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

  Future duplicateEstimate(int index) async {
    try {
      Map<String, String> headers = {
        'Authorization': widget.login.accessToken,
        'EstimateId': _list[index].Id,
        'CompanyId': widget.loggedInUser.CompanyGUID,
      };

      var result =
          await http.post(BASE_URL + API_DUPLICATE_ESTIMATE, headers: headers);
      if (result.statusCode == 200) {
        Map map = json.decode(result.body);
        setState(() {
          offline = false;
        });
        return map['Result'];
      } else {
        setState(() {
          offline = false;
        });
        return false;
      }
    } catch (error) {
      Navigator.of(context).pop();
      if (error.toString().contains("SocketException")) {
        setState(() {
          offline = true;
        });
        showNoInternetConnection(context);
      }
      return false;
    }
  }

  IconData getRecommendedLevelIcon(int level) {
    switch (level) {
      case 0:
        {
          return MdiIcons.numeric0Box;
        }
        break;
      case 1:
        {
          return MdiIcons.numeric1Box;
        }
        break;
      case 2:
        {
          return MdiIcons.numeric2Box;
        }
        break;
      case 3:
        {
          return MdiIcons.numeric3Box;
        }
        break;
      case 4:
        {
          return MdiIcons.numeric4Box;
        }
        break;
      case 5:
        {
          return MdiIcons.numeric5Box;
        }
        break;
      case 6:
        {
          return MdiIcons.numeric6Box;
        }
        break;
      default:
        {
          return MdiIcons.numeric0Box;
        }
    }
  }

  void deleteDialog(int index) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => loadingAlert(),
    );
    try {
      bool status = await deleteEstimate(index);
      Navigator.of(context).pop();
      if (status) {
        _list.removeAt(index);
        _controller.sink.add(_list);
        showDialog(context: context, builder: (context) => deleteSuccess());
      } else {
        showDialog(context: context, builder: (context) => deleteFailed());
      }
    } catch (error) {
      Navigator.of(context).pop();
      showNoInternetConnection(context);
    }
  }

  void duplicateDialog(int index) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => loadingAlert(),
    );
    try {
      bool status = await duplicateEstimate(index);
      await getData();
      Navigator.of(context).pop();
      showAPIResponse(
          context,
          status ? "Duplicated Successfully!" : "Failed to Duplicated!",
          Color(status ? COLOR_SUCCESS : COLOR_DANGER));
    } catch (error) {
      Navigator.of(context).pop();
      if (error.toString().contains("SocketException")) {
        setState(() {
          offline = true;
        });
        showNoInternetConnection(context);
      } else {
        showAPIResponse(context, "Failed to Duplicated!", Color(COLOR_DANGER));
      }
    }
  }

  Future deleteEstimate(int index) async {
    try {
      Map<String, String> headers = {
        'Authorization': widget.login.accessToken,
        'EstimateId': _list[index].Id
      };

      var result =
          await http.delete(BASE_URL + API_DELETE_ESTIMATE, headers: headers);
      setState(() {
        offline = false;
      });
      return json.decode(result.body)['result'];
    } catch (error) {
      if (error.toString().contains("SocketException")) {
        setState(() {
          offline = true;
        });
        showNoInternetConnection(context);
      }
      return null;
    }
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

  deleteSuccess() {
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

  deleteFailed() {
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

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
