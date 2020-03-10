import 'package:flutter/material.dart';
import 'package:flutter_grate_app/drawer/drawer_theme.dart';

class SyncNavItem extends StatefulWidget {

  final String title;
  final IconData icon;
  final AnimationController animationController;
  final Function onTap;

  SyncNavItem({@required this.title, @required this.icon, @required this.animationController, this.onTap});

  @override
  _SyncNavItemState createState() => _SyncNavItemState();
}

class _SyncNavItemState extends State<SyncNavItem> {

  Animation<double> widthAnimation, sizedBoxAnimation;
  double maxWidth = 300;
  double maxSize = 16;
  double minWidth = 92;
  double minSize = 0;

  @override
  void initState() {
    super.initState();
    widthAnimation = Tween<double>(begin: maxWidth, end: minWidth).animate(widget.animationController);
    sizedBoxAnimation = Tween<double>(begin: maxSize, end: minSize).animate(widget.animationController);
  }

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey.shade100;
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Colors.transparent,
          boxShadow: [
            const BoxShadow(
              color: Colors.grey,
              offset: const Offset(0.0, 0.0),
            ),
            const BoxShadow(
              color: Colors.white,
              offset: const Offset(0.0, 0.0),
              spreadRadius: 8,
              blurRadius: 8,
            ),
          ],
        ),
        width: widthAnimation.value,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: <Widget>[
            Icon(widget.icon, color: Colors.blueGrey.shade900.withOpacity(0.8), size: 28,),
            SizedBox(width: sizedBoxAnimation.value,),
            widthAnimation.value >= 290 ? Text(widget.title, style: defaultTextStyle,) : new Container(),
          ],
        ),
      ),
    );
  }
}
