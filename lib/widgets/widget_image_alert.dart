import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

imageAlert(BuildContext context, String url) {
  return BackdropFilter(
    filter: ImageFilter.blur(sigmaY: 4, sigmaX: 4),
    child: SimpleDialog(
      contentPadding: EdgeInsets.all(0),
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      children: <Widget>[
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width/4,
            height: MediaQuery.of(context).size.width/4,
            decoration: BoxDecoration(
              color: Colors.white
            ),
            child: CachedNetworkImage(
              imageUrl: url==null || url=="null" || url.isEmpty ? "https://crestedcranesolutions.com/wp-content/uploads/2013/07/facebook-profile-picture-no-pic-avatar.jpg" : url,
              fit: BoxFit.cover,
              placeholder: (context, url) => new CupertinoActivityIndicator(),
              errorWidget: (context, url, error) => new Icon(
                Icons.person,
                color: Colors.grey,
                size: 48,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}