import 'package:flutter/material.dart';
import 'package:flutter_grate_app/utils.dart';
import 'package:uuid/uuid.dart';

class LoadImageWidget extends StatelessWidget {

  final String customerId;
  final String username;
  final String companyGUID;

  LoadImageWidget(this.customerId, this.companyGUID, this.username);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FadeInImage.assetNetwork(
        placeholderCacheHeight: 140,
        placeholderCacheWidth: 150,
        placeholder: "images/loading.gif",
        image: buildCustomerImageUrl(
            customerId,
            companyGUID,
            username,
            Uuid().v1()),
        fit: BoxFit.cover,
      ),
    );
  }
}
