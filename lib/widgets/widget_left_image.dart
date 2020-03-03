import 'package:flutter/material.dart';
import 'package:flutter_grate_app/widgets/widget_image_background.dart';

class LeftPanelForLoginWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ImageBackgroundWidget('images/basement.jfif'),
        Container(
          height: double.infinity,
          width: double.infinity,
          child: Container(
            child: Center(
              child: Text(
                "Welcome To GrateApp",
                style: Theme.of(context)
                    .textTheme
                    .display1
                    .copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
