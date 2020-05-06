import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fullpdfview/flutter_fullpdfview.dart';

class PdfWidget extends StatelessWidget {
  const PdfWidget({this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Estimate"),
        centerTitle: false,
        backgroundColor: Colors.blueGrey.shade900,
        elevation: 4,
      ),
      body: PDFView(
        filePath: file.path,
        fitEachPage: true,
        backgroundColor: bgcolors.BLACK,
      ),
    );
  }
}
