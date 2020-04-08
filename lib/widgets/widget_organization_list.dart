import 'package:flutter/material.dart';

class QuickMenu extends StatelessWidget {
  final Icon iconData;
  final String text;

  QuickMenu(this.iconData, this.text);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
          height: 50,
          color: Colors.white,
          child: Table(
            children: [
              TableRow(children: [iconData, Text(text)]),
            ],
          )),
    );
  }
}
