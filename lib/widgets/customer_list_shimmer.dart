import 'package:flutter/material.dart';
import 'package:flutter_grate_app/widgets/list_shimmer_item_multiline_customer.dart';

import 'list_shimmer_item_customer.dart';

class ShimmerDashboardFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width/4.5;
    return ListView(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [0, 1, 2, 3, 4, 5, 6, 7,8,9]
              .map(
                (_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ShimmerItemCustomer(width),
                              SizedBox(
                                height: 8,
                              ),
                              ShimmerItemCustomer(width-100),
                              SizedBox(
                                height: 8,
                              ),
                              ShimmerItemCustomer(width-64),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ShimmerItemMultiLineCustomer(width),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Divider(),
                  ],
                ),
              )
              .toList(),
        )
      ],
    );
  }
}
