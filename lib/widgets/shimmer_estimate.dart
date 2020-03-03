import 'package:flutter/material.dart';
import 'package:flutter_grate_app/widgets/list_shimmer_item_with_only_icon.dart';
import 'package:flutter_grate_app/widgets/list_shimmer_item_without_icon.dart';

import 'list_shimmer_item_customer.dart';

class ShimmerAddOrEditEstimate extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: ShimmerItemWithoutIcon(200)),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        ShimmerItemCustomer(256),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        ShimmerItemCustomer(144),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        ShimmerItemCustomer(256),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        ShimmerItemCustomer(144),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ShimmerItemWithoutIcon(100),
                      SizedBox(
                        height: 8,
                      ),
                      ShimmerItemWithoutIcon(150),
                      SizedBox(
                        height: 16,
                      ),
                      ShimmerItemWithoutIcon(200),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ShimmerItemCustomer(128),
                                SizedBox(
                                  height: 8,
                                ),
                                ShimmerItemCustomer(144),
                                SizedBox(
                                  height: 8,
                                ),
                                ShimmerItemCustomer(172),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ShimmerItemCustomer(144),
                                SizedBox(
                                  height: 8,
                                ),
                                ShimmerItemCustomer(100),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                ShimmerItemWithOnlyIcon(),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Divider(),
                      ],
                    );
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
