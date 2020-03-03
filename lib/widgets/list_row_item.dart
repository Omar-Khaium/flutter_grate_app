import 'package:flutter/material.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';

class ListRowItem extends StatelessWidget {
  String text;
  IconData icon;

  ListRowItem({this.icon, this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: Colors.grey,),
        SizedBox(width: 16,),
        Container(width: MediaQuery.of(context).size.width/4.5,child: Text(text, style: listTextStyle(),overflow: TextOverflow.ellipsis,)),
      ],
    );
  }
}
