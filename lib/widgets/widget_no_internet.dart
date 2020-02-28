import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NoInternetConnectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 144),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset("images/no_internet.png", height: 224,width: 224, fit: BoxFit.cover,),
            Shimmer.fromColors(
              baseColor: Colors.black54,
              highlightColor: Colors.black12,
              child:
              ClipRRect(
                borderRadius: new BorderRadius.all(Radius.circular(18)),
                child: Text("No Internet Connection", style: Theme.of(context).textTheme.headline.copyWith(color: Colors.black),),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
