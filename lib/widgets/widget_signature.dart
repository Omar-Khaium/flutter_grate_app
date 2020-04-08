import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:painter/painter.dart';

class SignatureDialog extends StatefulWidget {
  final ValueChanged<PictureDetails> picture;

  SignatureDialog({Key key, this.picture}) : super(key: key);

  @override
  _SignatureDialogState createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> {
  PainterController _controller = new PainterController();
  @override
  void initState() {
    _controller.backgroundColor = Colors.white;
    _controller.drawColor = Colors.black;
    _controller.thickness = 4;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Painter(_controller),
              ),
              Container(
                width: 88,
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(
                      height: 12,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      radius: 32,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                          });
                        },
                        icon: Icon(Icons.refresh, color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 32,
                          child: IconButton(
                            onPressed: () {
                              PictureDetails pictureDetails =
                              _controller.finish();
                              pictureDetails.toPNG().then((value) {
                                widget.picture(pictureDetails);
                                Navigator.of(context).pop();
                              });
                            },
                            icon: Icon(
                              MdiIcons.contentSave,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _pickColor() {
    Color pickerColor = _color;
    Navigator
        .of(context)
        .push(MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('Pick color'),
                backgroundColor: pickerColor,
              ),
              body: Container(
                  alignment: Alignment.center,
                  child: ColorPicker(
                    pickerColor: pickerColor,
                    onColorChanged: (Color c) => pickerColor = c,
                  )));
        }))
        .then((_) {
      setState(() {
        _color = pickerColor;
      });
    });
  }

  Color get _color => _controller.drawColor;


  set _color(Color color) {
    _controller.drawColor = color;
  }
}
