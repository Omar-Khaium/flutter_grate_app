import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:shimmer/shimmer.dart';

class NoInternetConnectionWidget extends StatefulWidget {
  final ValueChanged<bool> isOffline;

  NoInternetConnectionWidget(this.isOffline);

  @override
  _NoInternetConnectionWidgetState createState() => _NoInternetConnectionWidgetState();
}

class _NoInternetConnectionWidgetState extends State<NoInternetConnectionWidget> {

  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() {
          _isKeyboardVisible = visible;
        });
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: EdgeInsets.only(bottom: _isKeyboardVisible ? 0 : 144),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              "images/no_internet.png",
              height: _isKeyboardVisible ? 72 : 224,
              width: _isKeyboardVisible ? 72 : 224,
              fit: BoxFit.cover,
            ),
            _isKeyboardVisible ? Container() : Shimmer.fromColors(
              baseColor: Colors.black54,
              highlightColor: Colors.black12,
              child: ClipRRect(
                borderRadius: new BorderRadius.all(Radius.circular(18)),
                child: Text(
                  "No Internet Connection",
                  style: Theme.of(context)
                      .textTheme
                      .headline
                      .copyWith(color: Colors.black),
                ),
              ),
            ),
            _isKeyboardVisible ? Container() : OutlineButton(
              onPressed: ()=>checkConnectivity(),
              child: Text("Refresh"),
            )
          ],
        ),
      ),
    );
  }

  checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      widget.isOffline(true);
    } else {
      widget.isOffline(false);
    }
  }
}
