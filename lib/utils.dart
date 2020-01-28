import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showMessage(BuildContext context, String title, String message,
    Color color, IconData icon) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.GROUNDED,
    backgroundColor: color,
    icon: Icon(
      icon,
      size: 24.0,
      color: Colors.white,
    ),
    duration: Duration(seconds: 4),
    leftBarIndicatorColor: Colors.white70,
    boxShadows: [
      BoxShadow(
        color: color.withOpacity(.5),
        offset: Offset(0.0, 2.0),
        blurRadius: 4.0,
      )
    ],
    title: title,
    message: message,
    shouldIconPulse: false,
  )..show(context);
}

void showAPIResponse(BuildContext context, String title, Color color) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.GROUNDED,
    backgroundColor: color,
    duration: Duration(seconds: 4),
    boxShadows: [
      BoxShadow(
        color: color.withOpacity(1),
        offset: Offset(0.0, 0.0),
        blurRadius: 1.0,
      )
    ],
    title: "Network Response",
    message: title,
  )..show(context);
}

String formatDate(String date) {
  DateFormat inputFormat = DateFormat("yyyy-MM-dd'T'hh:mm:ss");
  DateTime dateTime = inputFormat.parse(date);
  DateFormat outputFormat = DateFormat(
    "MM/dd/yyyy",
  );
  return outputFormat.format(dateTime);
}

final COLOR_DANGER = 0xE54F42;
final COLOR_SUCCESS = 0x38CC76;
final COLOR_WARNING = 0xFFA628;

getDeleteDialog(context) {
  return BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
    child: SimpleDialog(
      contentPadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
                            BorderRadius.only(bottomLeft: Radius.circular(6)),
                        color: Colors.black,
                      ),
                      height: 45,
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
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(6)),
                      color: Colors.deepOrange,
                    ),
                    height: 45,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

errorDialog(context) {
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
                "images/error.jpg",
                fit: BoxFit.cover,
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
                            BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                        color: Colors.black,
                      ),
                      height: 64,
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
                    onTap: ()=> Navigator.of(context).pop(),
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

//var currencyFormat = new NumberFormat.currency(locale: "en_US", name: "USD", decimalDigits: 2);
var currencyFormat = new NumberFormat("#,###.##", "en_US");
var numberFormat = new NumberFormat("#,###", "en_US");
RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
Function mathFunc = (Match match) => '${match[1]},';

const String BASE_URL = "https://api.gratecrm.com/";
const String API_TOKEN = "token";
const String API_USER_BY_USERNAME = "GetUserByUserName";
const String API_EQUIPMENT_LIST = "GetEquipmentListByKey";
const String API_CREATE_ESTIMATE = "CreateEstimate";
const String API_UPLOAD_FILE = "UploadImageFile";
const String API_GET_ESTIMATE = "GetEstimateById";
const String API_GET_LOOK_UP = "GetLookupbyKey";
const String API_GET_ZIP = "GetCityZipCodeLookupList";
const String API_GET_BASEMENT_INSPECTION = "GetCustomerInspectionByCustomerId";
const String API_SAVE_BASEMENT_INSPECTION = "SaveCustomerInspection";
const String API_SAVE_RECOMMENDED_LEVEL = "RecommendedLevel";
const String API_SAVE_CUSTOMER = "SaveCustomer";
const String API_FORGET_PASSWORD = "ForgetPassword";
const String API_CHANGE_PASSWORD = "ChangePassword";
const String API_GET_ALL_CUSTOMER = "GetAllCustomer";
const String API_DELETE_CUSTOMER = "DeleteCustomer";
const String API_UPDATE_CUSTOMER = "GetCustomerByIdWithEstimateList";
const String API_CUSTOMER_UPLOAD = "CustomerImageUpload";
const String API_DUPLICATE_ESTIMATE = "EstimateDuplicate";
const String API_DELETE_ESTIMATE = "DeleteEstimate";
const String API_GENERATE_ESTIMATE = "GenerateEstimate";
const String API_SEND_EMAIL = "SendEmailEstimate";
