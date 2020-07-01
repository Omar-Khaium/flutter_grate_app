import 'package:flutter/material.dart';
import 'package:flutter_grate_app/drawer/drawer_theme.dart';

import 'list_shimmer_item_without_icon.dart';

class ShimmerSideNavUserInfo extends StatelessWidget {
  double sizedBoxAnimationValue;
  double widthAnimationValue;

  ShimmerSideNavUserInfo(this.sizedBoxAnimationValue, this.widthAnimationValue);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        new CircleAvatar(
          backgroundColor: Colors.grey,
          maxRadius: 14,
          minRadius: 4,
        ),
        SizedBox(
          width: sizedBoxAnimationValue,
        ),
        widthAnimationValue >= 290
            ? ShimmerItemWithoutIcon(100)
            : new Container(),
      ],
    );
  }
}
