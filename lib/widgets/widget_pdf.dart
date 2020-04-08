import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fullpdfview/flutter_fullpdfview.dart';
import 'package:flutter_grate_app/model/customer_details.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/sqflite/model/user.dart';
import 'package:flutter_grate_app/utils.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class SendMailFragment extends StatefulWidget {
  Map map;
  String estimateId;
  String urlPDFPath = "";
  Login accessToken;
  LoggedInUser loggedInUser;
  CustomerDetails customerId;
  ValueChanged<int> backToCustomerDetails;

  SendMailFragment(this.map, this.estimateId, this.accessToken, this.customerId,
      this.backToCustomerDetails);

  @override
  _SendMailFragmentState createState() => _SendMailFragmentState();
}

class _SendMailFragmentState extends State<SendMailFragment> {
  TextEditingController _ToEmailController = new TextEditingController();
  TextEditingController _CCEmailController = new TextEditingController();
  TextEditingController _SubjectEmailController = new TextEditingController();
  TextEditingController _BodyEmailController = new TextEditingController();

  String emailUrl = "";
  File pdfFile;

  @override
  void initState() {
    super.initState();
    getFileFromUrl(widget.map['filepath']).then((f) {
      setState(() {
        widget.urlPDFPath = f.path;
      });
    });

    _ToEmailController.text = widget.map['EstimateEmailModel']['email'];
    _SubjectEmailController.text = widget.map['EstimateEmailModel']['subject'];
    _BodyEmailController.text = widget.map['EstimateEmailModel']['bodycontent'];
    _BodyEmailController.text = _BodyEmailController.text.replaceAll("\r\nView Estimate\r\n", "");
  }

  Future<File> getFileFromUrl(String url) async {
    try {
      var data = await get(url);
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/mypdfonline.pdf");

      pdfFile = await file.writeAsBytes(bytes);
      return pdfFile;
    } catch (e) {
      throw Exception("Error opening url file");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Send Mail",
          style: Theme.of(context).textTheme.headline.copyWith(
              color: Colors.grey.shade900, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 26),
            child: GestureDetector(
              onTap: () {
                showDialog(
                    context: context, builder: (context) => loadingAlert());
                postData();
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade900,
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          )
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ListView(
              padding: EdgeInsets.only(left: 16, right: 16),
              shrinkWrap: false,
              scrollDirection: Axis.vertical,
              children: <Widget>[
                TextField(
                  controller: _ToEmailController,
                  cursorColor: Colors.black87,
                  enabled: true,
                  keyboardType: TextInputType.emailAddress,
                  maxLines: 1,
                  style: customTextStyle(),
                  decoration: new InputDecoration(
                    labelText: "To",
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black87)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    errorText: _ToEmailController.text.isNotEmpty
                        ? null
                        : "* Required",
                    hintStyle: customHintStyle(),
                    isDense: true,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                TextField(
                  controller: _CCEmailController,
                  cursorColor: Colors.black87,
                  enabled: true,
                  keyboardType: TextInputType.emailAddress,
                  maxLines: 1,
                  style: customTextStyle(),
                  decoration: new InputDecoration(
                    labelText: "cc",
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black87)),
                    hintStyle: customHintStyle(),
                    isDense: true,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                TextField(
                  controller: _SubjectEmailController,
                  cursorColor: Colors.black87,
                  enabled: true,
                  keyboardType: TextInputType.emailAddress,
                  maxLines: 1,
                  onChanged: (val) {
                    setState(() {});
                  },
                  style: customTextStyle(),
                  decoration: new InputDecoration(
                    labelText: "Subject",
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black87)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    errorText: _SubjectEmailController.text.isNotEmpty
                        ? null
                        : "* Required",
                    hintStyle: customHintStyle(),
                    isDense: true,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                TextField(
                  controller: _BodyEmailController,
                  cursorColor: Colors.black87,
                  enabled: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: 8,
                  onChanged: (val) {
                    setState(() {});
                  },
                  style: customTextStyle(),
                  decoration: new InputDecoration(
                    labelText: "Body",
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black87)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    errorText: _BodyEmailController.text.isNotEmpty
                        ? null
                        : "* Required",
                    hintStyle: customHintStyle(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(
            thickness: 2,
          ),
          Expanded(
            flex: 1,
            child: pdfFile!=null
                ? OrientationBuilder(
                    builder: (context, orientation) {
                      return PDFView(
                      filePath: pdfFile.path,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: false,
                    );
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          )
        ],
      ),
    );
  }

  Future<String> postData() async {
    try {
      Map<String, String> data = {
        'Authorization': widget.accessToken.accessToken,
        'customerid': widget.customerId.CustomerId,
        'invoiceid': widget.estimateId.toString(),
        'toemail': _ToEmailController.text.toString(),
        'ccmail': _CCEmailController.text.toString(),
        'subject': _SubjectEmailController.text.toString(),
        'body': _BodyEmailController.text.toString(),
      };

      var url = "https://api.gratecrm.com/SendEmailEstimate";
      post(url, headers: data).then((response) {
        if (response.statusCode == 200) {
          Map map = json.decode(response.body);
          get(map['EmailUrl']).then((responseResults) {
            if (responseResults.statusCode == 200) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              widget.backToCustomerDetails(0);
              showAPIResponse(
                  context, "Email Successfully Sent", Colors.green.shade600);
            } else {
              Navigator.of(context).pop();
              showAPIResponse(context, "Email Not Sent", Colors.red.shade600);
            }
          });
        } else {
          Navigator.of(context).pop();
          showAPIResponse(
              context, json.decode(response.body), Colors.red.shade600);
        }
      });
    } catch (error) {
      Navigator.of(context).pop();
    }
  }
}
