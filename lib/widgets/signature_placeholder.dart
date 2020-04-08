import 'package:flutter/material.dart';

class SignaturePlaceholder extends StatelessWidget {

  String url;

  SignaturePlaceholder({this.url});


  @override
  Widget build(BuildContext context) {
    return url!=null
    ? FadeInImage.assetNetwork(
    placeholder: "images/loading.gif",
    image: url,
    fit: BoxFit.cover,
    ):Container(
      color:
      Colors.grey.shade200,
      child: Center(
        child: Text("Tap To Sign"),
      ),
    );
  }
}
