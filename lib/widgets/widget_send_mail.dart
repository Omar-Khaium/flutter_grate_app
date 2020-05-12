import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_fullpdfview/flutter_fullpdfview.dart';
import 'package:flutter_grate_app/model/attachment.dart';
import 'package:flutter_grate_app/model/customer_details.dart';
import 'package:flutter_grate_app/model/hive/user.dart';
import 'package:flutter_grate_app/utils.dart';
import 'package:flutter_grate_app/widgets/widget_attachment_item.dart';
import 'package:flutter_grate_app/widgets/widget_pdf.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/widgets.dart' as pw;

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
    _BodyEmailController.text =
        _BodyEmailController.text.replaceAll("View Estimate", "View Estimate - ${widget.map['filepath']}");
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
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: FlatButton(
              onPressed: ()=> launch("mailto:${widget.map['EstimateEmailModel']['email']}?subject=${widget.map['EstimateEmailModel']['subject']}&body=${_BodyEmailController.text}"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text("Go to Mail app", style: Theme.of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.black, fontWeight: FontWeight.normal),),
              color: Colors.grey.shade200,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 26),
            child: InkWell(
              onTap: () {
                showDialog(
                    context: context, builder: (context) => loadingAlert());
                postData();
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Icon(
                  Icons.send,
                  color: Colors.black,
                  size: 18,
                ),
              ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton.icon(
                onPressed: pdfFile == null || pdfFile.path.isEmpty
                    ? () {}
                    : () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PdfWidget(
                              file: pdfFile,
                            ),
                        fullscreenDialog: true)),
                color: pdfFile != null && pdfFile.path.isNotEmpty
                    ? Colors.black
                    : Colors.grey,
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24))),
                icon: Icon(
                  MdiIcons.filePdf,
                  color: Colors.white,
                ),
                label: Text(
                  pdfFile != null && pdfFile.path.isNotEmpty
                      ? "View Estimate" : "Loading Estimate",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle
                      .copyWith(color: Colors.white),
                ),
              ),
              FlatButton.icon(
                /*onPressed: () => attachments.length < 5
                    ? _showDialog(context)
                    : _showMaxLimitError(context),*/
                onPressed: pdfFile == null || pdfFile.path.isEmpty
                    ? () {}
                    : (){_printDocument();},
                color: Colors.black,
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24))),
                icon: Icon(
                  MdiIcons.printer,
                  color: Colors.white,
                ),
                label: Text(
                  pdfFile != null && pdfFile.path.isNotEmpty
                      ? "Print" : "Loading PDF",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          /*SizedBox(
            height: 8,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${attachments.length}/5 attachment${attachments.length >= 2 ? "s" : ""}",
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: Colors.black),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Container(
            height: 164,
            decoration: BoxDecoration(color: Colors.grey.shade100),
            child: Align(
              alignment: Alignment.centerLeft,
              child: attachments.length == 0
                  ? Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.attach_file),
                          Text("No Attachment Yet"),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        return AttachmentItem(
                            attachments[index], removeAttachment);
                      },
                      itemCount: attachments.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                    ),
            ),
          )*/
        ],
      ),
    );
  }

  removeAttachment(int index) {
    setState(() {
      attachments.removeAt(index);
    });
  }

  Future<void> _showDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AlertDialog(
              title: Text("Make A choice"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    ListTile(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _openGallery(context);
                      },
                      leading: Icon(Icons.photo_album),
                      title: Text("Gallery"),
                    ),
                    ListTile(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _openCamera();
                      },
                      leading: Icon(Icons.camera_enhance),
                      title: Text("Camera"),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _openCamera() async {
    try {
      File cameraOutput =
          (await ImagePicker.pickImage(source: ImageSource.camera));
      if (cameraOutput != null) {
        setState(() {
          attachments.add(Attachment(
              attachments.length,
              "",
              cameraOutput,
              cameraOutput.path.substring(cameraOutput.path
                  .lastIndexOf("/", cameraOutput.path.lastIndexOf("."))),
              true,
              false,
              user.accessToken));
        });
      }
    } catch (error) {
      print(error.message);
    }
    Navigator.of(context).pop();
  }

  _openGallery(BuildContext context) async {
    File pickFromGallery =
        (await ImagePicker.pickImage(source: ImageSource.gallery));
    if (pickFromGallery != null) {
      setState(() {
        attachments.add(Attachment(
            attachments.length,
            "",
            pickFromGallery,
            pickFromGallery.path.substring(pickFromGallery.path
                .lastIndexOf("/", pickFromGallery.path.lastIndexOf("."))),
            true,
            false,
            user.accessToken));
      });
    }
    Navigator.of(context).pop();
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
        'body': "<p>${_BodyEmailController.text.toString().replaceAll("\r", "").replaceAll("\n", "</br>")}</p>",
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

        if (emailResponse.statusCode==200) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          widget.backToCustomerDetails(0);
          showAPIResponse(
              context, "Email Sent", Colors.green.shade600);
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

  _showMaxLimitError(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return new BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: AlertDialog(
              title: Text(
                "Error",
                style: Theme.of(context).textTheme.title.copyWith(
                    color: Colors.redAccent.shade700,
                    fontWeight: FontWeight.bold),
              ),
              content: Text("You've reached max limit of file attachments."),
              contentTextStyle: Theme.of(context).textTheme.headline.copyWith(
                  color: Colors.grey.shade900, fontWeight: FontWeight.bold),
              actions: <Widget>[
                OutlineButton(
                  textColor: Colors.red,
                  child: Text(
                    "Close",
                    style: Theme.of(context).textTheme.subhead.copyWith(
                        color: Colors.redAccent.shade700,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ));
      },
    );
  }


  void _printDocument() {
    print("printing");
//    Printing.sharePdf(bytes: pdfFile.readAsBytesSync());
    Printing.layoutPdf(
      onLayout: (pageFormat) {
        return pdfFile.readAsBytesSync();
      },
    );
  }
}
