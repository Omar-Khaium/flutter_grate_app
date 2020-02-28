import 'dart:convert';
import 'dart:ui';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/sqflite/database_info.dart';
import 'package:flutter_grate_app/sqflite/db_helper.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/widgets/widget_loading.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void showMessage(BuildContext context, String title, String message,
    Color color, IconData icon) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.GROUNDED,
    backgroundColor: color,
    duration: Duration(seconds: 4),
    boxShadows: [
      BoxShadow(
        color: color.withOpacity(.5),
        offset: Offset(0.0, 2.0),
        blurRadius: 4.0,
      )
    ],
    title: title,
    message: message,
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
        color: color,
        offset: Offset(0.0, 0.0),
        blurRadius: 1.0,
      )
    ],
    title: "Network Response",
    message: title,
  )..show(context);
}

void showNoInternetConnection(BuildContext context) {
  Flushbar flush;
  flush = Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.GROUNDED,
    backgroundColor: Colors.red,
    boxShadows: [
      BoxShadow(
        color: Color(COLOR_DANGER),
        offset: Offset(0.0, 0.0),
        blurRadius: 1.0,
      )
    ],
    mainButton: FlatButton(
      child: Icon(Icons.close, color: Colors.white,),
      onPressed: (){
        flush.dismiss(true);
      },
    ),
    title: "No Internet Connection",
    message: "Make sure you're connected with internet",
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
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8)),
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
const String API_SEARCH = "GlobalSearchCustomerAndLead";
 int CURRENTSEGMENT = 0;

Future<bool> saveInspectionReport(
    String header, BuildContext context, Login login, int id) async {
  try {
    Map<String, String> map = new Map<String, String>.from(json.decode(header));
    var response =
        await http.post(BASE_URL + API_SAVE_BASEMENT_INSPECTION, headers: map);
    try {
      if (response.statusCode == 200) {
        DBHelper dbHelper = new DBHelper();
        await dbHelper.delete(id, DBInfo.TABLE_BASEMENT_INSPECTION);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
    ;
  } catch (error) {
    print(error);
    return false;
  }
}

loadingAlert() {
  return WillPopScope(
    onWillPop: () async => false,
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: LoadingWidget(),
    ),
  );
}

String buildCustomerImageUrl(String customerId, String companyId, String username, String guid) {
  return "https://www.gratecrm.com/CustomerImgShow/W=144/H=144/CustomerId=$customerId/UserName=$username/CompanyId=$companyId/Image_Preview.jpg?$guid";
}

String buildEstimateImageUrl(String invoiceId, String companyId, String username, String guid) {
  return "https://www.gratecrm.com/EstimateCameraImgShow/W=144/H=144/InvoiceId=$invoiceId/ImageType=Camera/UserName=$username/CompanyId=$companyId/Image_Preview.jpg?$guid";
}
