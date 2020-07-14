import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_grate_app/model/attachment.dart';
import 'package:flutter_grate_app/model/customer_details.dart';
import 'package:flutter_grate_app/model/hive/user.dart';
import 'package:flutter_grate_app/utils.dart';
import 'package:flutter_grate_app/widgets/widget_pdf.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

class SendMail extends StatefulWidget {
  Map map;
  String estimateId;
  String urlPDFPath = "";
  CustomerDetails customerId;
  ValueChanged<int> backToCustomerDetails;

  SendMail(
      this.map, this.estimateId, this.customerId, this.backToCustomerDetails);

  @override
  _SendMailState createState() => _SendMailState();
}

class _SendMailState extends State<SendMail>
    with SingleTickerProviderStateMixin {
  TextEditingController _ToEmailController = new TextEditingController();
  TextEditingController _CCEmailController = new TextEditingController();
  TextEditingController _SubjectEmailController = new TextEditingController();
  TextEditingController _BodyEmailController = new TextEditingController();

  List<Attachment> attachments = [];

  String emailUrl = "";
  File pdfFile;
  var base64 = const Base64Codec();

  Box<User> userBox;
  User user;

  Printer selectedPrinter;
  PrintingInfo printingInfo;
  final GlobalKey<State<StatefulWidget>> shareWidget = GlobalKey();

  @override
  void initState() {
    userBox = Hive.box("users");
    user = userBox.getAt(0);

    Printing.info().then((PrintingInfo info) {
      setState(() {
        printingInfo = info;
      });
    });

    super.initState();
    _ToEmailController.text = widget.map['EstimateEmailModel']['email'];
    _SubjectEmailController.text = widget.map['EstimateEmailModel']['subject'];
    _BodyEmailController.text = widget.map['EstimateEmailModel']['bodycontent'];
    _BodyEmailController.text = _BodyEmailController.text.replaceAll(
        "View Estimate", "View Estimate - ${widget.map['filepath']}");
    _saveAsFile();
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
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            child: FlatButton(
              onPressed: pdfFile == null || pdfFile.path.isEmpty
                  ? () {}
                  : () {
                      _printDocument();
                    },
              color: pdfFile != null && pdfFile.path.isNotEmpty
                  ? Colors.grey.shade200
                  : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                pdfFile != null && pdfFile.path.isNotEmpty
                    ? "Print"
                    : "Processing",
                style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.black, fontWeight: FontWeight.normal),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            child: FlatButton(
              onPressed: pdfFile == null || pdfFile.path.isEmpty
                  ? () {}
                  : () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PdfWidget(
                            file: pdfFile,
                          ),
                      fullscreenDialog: true)),
              color: pdfFile != null && pdfFile.path.isNotEmpty
                  ? Colors.grey.shade200
                  : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                pdfFile != null && pdfFile.path.isNotEmpty
                    ? "View Estimate"
                    : "Loading Estimate",
                style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.black, fontWeight: FontWeight.normal),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            child: FlatButton(
              onPressed: () async {
                final String email = widget.map['EstimateEmailModel']['email'];
                final String subject = widget.map['EstimateEmailModel']
                        ['subject'];
                final String body =
                    _BodyEmailController.text;
                String uri =
                    'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri
                    .encodeComponent(body)}';
                if (await canLaunch(uri)) {
                  await launch(uri);
                } else {
                  print("No email client found");
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Go to Mail app",
                style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.black, fontWeight: FontWeight.normal),
              ),
              color: Colors.grey.shade200,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 26, vertical: 9),
            child: FlatButton.icon(
              onPressed: () {
                showDialog(
                    context: context, builder: (context) => loadingAlert());
                postData();
              },
              icon: Icon(
                Icons.mail,
                color: Colors.white,
                size: 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              label: Text(
                "Send",
                style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.white, fontWeight: FontWeight.normal),
              ),
              color: Colors.blue,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(32),
        shrinkWrap: false,
        scrollDirection: Axis.vertical,
        physics: ScrollPhysics(),
        children: <Widget>[
          TextField(
            controller: _ToEmailController,
            cursorColor: Colors.black87,
            enabled: true,
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            style: Theme.of(context)
                .textTheme
                .title
                .copyWith(color: Colors.black, fontWeight: FontWeight.normal),
            decoration: new InputDecoration(
              labelText: "To",
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87)),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              errorText:
                  _ToEmailController.text.isNotEmpty ? null : "* Required",
              filled: true,
              fillColor: Colors.grey.shade100,
              hintStyle: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.grey, fontWeight: FontWeight.normal),
              labelStyle: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              isDense: true,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          TextField(
            controller: _CCEmailController,
            cursorColor: Colors.black87,
            enabled: true,
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            style: Theme.of(context)
                .textTheme
                .title
                .copyWith(color: Colors.black, fontWeight: FontWeight.normal),
            decoration: new InputDecoration(
              labelText: "cc",
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87)),
              filled: true,
              fillColor: Colors.grey.shade100,
              hintStyle: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.grey, fontWeight: FontWeight.normal),
              labelStyle: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              isDense: true,
            ),
          ),
          SizedBox(
            height: 16,
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
            style: Theme.of(context)
                .textTheme
                .title
                .copyWith(color: Colors.black, fontWeight: FontWeight.normal),
            decoration: new InputDecoration(
              labelText: "Subject",
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87)),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              errorText:
                  _SubjectEmailController.text.isNotEmpty ? null : "* Required",
              filled: true,
              fillColor: Colors.grey.shade100,
              hintStyle: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.grey, fontWeight: FontWeight.normal),
              labelStyle: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              isDense: true,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          TextField(
            controller: _BodyEmailController,
            cursorColor: Colors.black87,
            enabled: true,
            keyboardType: TextInputType.multiline,
            maxLines: 10,
            onChanged: (val) {
              setState(() {});
            },
            style: Theme.of(context)
                .textTheme
                .title
                .copyWith(color: Colors.black, fontWeight: FontWeight.normal),
            decoration: new InputDecoration(
              labelText: "Body",
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87)),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              errorText:
                  _BodyEmailController.text.isNotEmpty ? null : "* Required",
              filled: true,
              fillColor: Colors.grey.shade100,
              hintStyle: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.grey, fontWeight: FontWeight.normal),
              labelStyle: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              alignLabelWithHint: true,
              isDense: true,
            ),
          ),
          SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }

  removeAttachment(int index) {
    setState(() {
      attachments.removeAt(index);
    });
  }

  Future<Uint8List> getFileFromUrl(String url) async {
    try {
      var data = await get(url);
      var bytes = data.bodyBytes;
      return bytes;
    } catch (e) {
      throw Exception("Error opening url file");
    }
  }

  Future<void> _saveAsFile() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    pdfFile = File(appDocPath + '/' + 'document.pdf');
    await pdfFile.writeAsBytes(await getFileFromUrl(widget.map['filepath']));
    setState(() {});
  }

  Future<String> postData() async {
    try {
      String imageUrls = "";
      for (Attachment item in attachments) {
        if (item.isUploading) {
          Navigator.of(context).pop();
          return "";
        } else {
          imageUrls += ",${item.url}";
        }
      }
      imageUrls = imageUrls.substring(
          (imageUrls.startsWith(",") ? 1 : 0), imageUrls.length);

      Map<String, String> header = {
        'Authorization': user.accessToken,
        'customerid': widget.customerId.CustomerId,
        'invoiceid': widget.estimateId.toString(),
        'toemail': _ToEmailController.text.toString(),
        'ccmail': _CCEmailController.text.toString(),
        'subject': _SubjectEmailController.text.toString(),
        'body':
            "<p>${_BodyEmailController.text.toString().replaceAll("\r", "").replaceAll("\n", "</br>")}</p>",
        'imageurl': imageUrls,
      };

      var url = "https://api.gratecrm.com/SendEmailEstimate";
      var response = await post(url, headers: header);
      if (response.statusCode == 200) {
        Map map = json.decode(response.body);

        Map<String, String> emailHeader = {
          'Authorization': user.accessToken,
          'customerid': widget.customerId.CustomerId,
          'invoiceid': widget.estimateId.toString(),
        };
        var emailResponse = await get(map['EmailUrl'], headers: emailHeader);

        if (emailResponse.statusCode == 200) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          widget.backToCustomerDetails(0);
          showAPIResponse(context, "Email Sent", Colors.green.shade600);
        } else {
          Navigator.of(context).pop();
          showAPIResponse(context, "Email Not Sent", Colors.red.shade600);
        }
        return "";
      } else {
        Navigator.of(context).pop();
        showAPIResponse(
            context, json.decode(response.body), Colors.red.shade600);
        return "";
      }
    } catch (error) {
      Navigator.of(context).pop();
      return "";
    }
  }

  void _printDocument() {
    Printing.layoutPdf(
      onLayout: (pageFormat) {
        return pdfFile.readAsBytesSync();
      },
    );
  }
}
