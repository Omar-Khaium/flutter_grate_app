import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:painter/painter.dart';

class DrawingDialog extends StatefulWidget {
  final ValueChanged<PictureDetails> picture;

  DrawingDialog({Key key, this.picture}) : super(key: key);

  @override
  _DrawingDialogState createState() => _DrawingDialogState();
}

class _DrawingDialogState extends State<DrawingDialog> {
  PainterController _controller = new PainterController();
  bool _isErasing = false;
  Color _lastColor = Colors.black;
  double _lastThickness = 2.0;

  @override
  void initState() {
    _controller.backgroundColor = Colors.white;
    reset();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: new Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 8,
        ),
        body: Container(
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
                      backgroundColor: Colors.white10,
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
                    SizedBox(
                      height: 12,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white10,
                      radius: 32,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _controller.undo();
                          });
                        },
                        icon: Icon(Icons.undo, color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white10,
                      radius: 32,
                      child: IconButton(
                        onPressed: () => _pickColor(),
                        icon: Icon(
                          Icons.color_lens,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white10,
                      radius: 32,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            reset();
                          });
                        },
                        icon: Icon(Icons.brush, color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white10,
                      radius: 32,
                      child: IconButton(
                        onPressed: () {
                          if(!_isErasing) {
                            if (_controller.thickness == 2.0) {
                              _controller.thickness = 6.0;
                            } else if (_controller.thickness == 6.0) {
                              _controller.thickness = 12.0;
                            } else if (_controller.thickness == 12.0) {
                              _controller.thickness = 24.0;
                            } else if (_controller.thickness == 24.0) {
                              _controller.thickness = 2.0;
                            }
                            setState(() {});
                          }
                        },
                        icon: Icon(
                          _controller.thickness == 2.0
                              ? MdiIcons.circleMedium
                              : (_controller.thickness == 6.0
                              ? MdiIcons.circleOutline
                              : (_controller.thickness == 12.0
                              ? MdiIcons.circleDouble
                              : Icons.fiber_manual_record)),
                          color: _isErasing ? Colors.blueAccent.shade100 :Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white10,
                      radius: 32,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _lastColor = _controller.drawColor;
                            _lastThickness = _controller.thickness;
                            _isErasing = true;
                            _controller.drawColor = Colors.white;
                            _controller.thickness = 24;
                          });
                        },
                        icon: Icon(
                          MdiIcons.eraser,
                          color: Colors.white,
                        ),
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
                              widget.picture(pictureDetails);
                              Navigator.of(context).pop();
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
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
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
    })).then((_) {
      setState(() {
        _color = pickerColor;
      });
    });
  }

  Color get _color => _controller.drawColor;

  set _color(Color color) {
    _controller.drawColor = color;
  }

  void reset() {
    _isErasing = false;
    _controller.drawColor = _lastColor;
    _controller.thickness = _lastThickness;
  }
}
