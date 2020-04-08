import 'package:flutter/material.dart';
import 'package:flutter_grate_app/drawer/drawer_theme.dart';

class DrawingPlaceholder extends StatelessWidget {
  String url;

  DrawingPlaceholder({this.url});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: url != null
          ? FadeInImage.assetNetwork(
              placeholder: "images/loading.gif",
              image: url,
              fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
            )
          : Text(
              "Tap To Draw",
              style: Theme.of(context).textTheme.subtitle.copyWith(color: Colors.grey),
            ),
    );
  }
}
