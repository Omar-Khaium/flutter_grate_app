import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_grate_app/model/attachment.dart';
import 'package:flutter_grate_app/widgets/shimmer_upload.dart';
import 'package:flutter_grate_app/widgets/widget_image_alert.dart';
import 'package:http/http.dart';

import '../utils.dart';

class AttachmentItem extends StatefulWidget {
  final Attachment attachment;
  final ValueChanged<int> removeAt;

  AttachmentItem(this.attachment, this.removeAt);

  @override
  _AttachmentItemState createState() => _AttachmentItemState();
}

class _AttachmentItemState extends State<AttachmentItem> {
  var base64 = const Base64Codec();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.attachment.url.isEmpty) uploadAttachment();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 128,
      margin: EdgeInsets.only(left: 16, top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: ClipRRect(
              child: Image.file(
                widget.attachment.file,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            left: 8,
            child: RaisedButton(
              color: Colors.grey.shade100,
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(8),
              )),
              child: Center(
                child: Text(
                  "View",
                  style: Theme.of(context).textTheme.subtitle.copyWith(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                showDialog(
                  context: context,
                  builder: (context) {
                    return imageAlert(context, widget.attachment.url);
                  },
                );
              },
            ),
          ),
          Center(
            child: widget.attachment.isUploading
                ? Container(
                    child: Center(
                      child: ShimmerUploadIcon(64),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        )),
                  )
                : Container(
                    width: 0,
                    height: 0,
                  ),
          ),
          !widget.attachment.isUploading && !widget.attachment.isUploadSucceed
              ? Container(
                  child: IconButton(
                    icon: Icon(
                      Icons.sync,
                      color: Colors.white,
                      size: 48,
                    ),
                    onPressed: () => uploadAttachment(),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      )),
                )
              : Container(
                  width: 0,
                  height: 0,
                ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () => widget.removeAt(widget.attachment.id),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                    BorderRadius.only(topRight: Radius.circular(8), bottomLeft: Radius.circular(8))),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  uploadAttachment() async {
    setState(() {
      widget.attachment.isUploading = true;
      widget.attachment.isUploadSucceed = false;
    });
    Map<String, String> headers = <String, String>{
      "Authorization": widget.attachment.token
    };

    Map<String, String> body = <String, String>{
      "filename": "attachment.png",
      "filepath": base64.encode(
        widget.attachment.file.readAsBytesSync(),
      )
    };
    var result =
        await post(BASE_URL + API_UPLOAD_FILE, headers: headers, body: body);
    if (result.statusCode == 200) {
      Map map = json.decode(result.body);
      widget.attachment.url = "https://api.gratecrm.com" + map['filePath'];
      widget.attachment.isUploadSucceed = true;
      showAPIResponse(
        context,
        "Attachment Uploaded Successfully",
        Color(COLOR_SUCCESS),
      );
    } else {
      widget.attachment.isUploadSucceed = false;
      showAPIResponse(
        context,
        "Failed To Attach File",
        Color(COLOR_WARNING),
      );
    }
    setState(() {
      widget.attachment.isUploading = false;
    });
  }
}
