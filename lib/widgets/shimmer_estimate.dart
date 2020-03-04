import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/widgets/list_shimmer_item_with_only_icon.dart';
import 'package:flutter_grate_app/widgets/list_shimmer_item_without_icon.dart';
import 'package:shimmer/shimmer.dart';

import 'list_shimmer_item_customer.dart';

class ShimmerAddOrEditEstimate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 2;
    return OrientationBuilder(
      builder: (context, orientation) => ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: ShimmerItemWithoutIcon(width / 2)),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ShimmerItemCustomer(width / 4),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  ShimmerItemCustomer(width / 4),
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
                                  ShimmerItemCustomer(width / 4),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  ShimmerItemCustomer(width / 4),
                                ],
                              ),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ShimmerItemWithoutIcon(width / 6),
                            SizedBox(
                              height: 8,
                            ),
                            ShimmerItemWithoutIcon(width / 5),
                            SizedBox(
                              height: 16,
                            ),
                            ShimmerItemWithoutIcon(width / 4),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 16, bottom: 16),
                  child: DottedBorder(
                    color: Colors.black,
                    strokeWidth: .5,
                    child: ListView.builder(
                        padding: EdgeInsets.all(8),
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              index == 1
                                  ? Container()
                                  : SizedBox(
                                      height: 8,
                                    ),
                              index == 1 ? Container() : Divider(),
                            ],
                          );
                        }),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: orientation == Orientation.landscape
                                  ? 172
                                  : 108,
                              height: orientation == Orientation.landscape
                                  ? 172
                                  : 108,
                              child: Shimmer.fromColors(
                                baseColor: Colors.black12,
                                highlightColor: Colors.white24,
                                child: ClipRRect(
                                  borderRadius:
                                      new BorderRadius.all(Radius.circular(12)),
                                  child: Container(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width:
                              orientation == Orientation.landscape ? 420 : 360,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [0, 1, 2, 3, 4]
                                .map((_) => Container(
                                      margin: EdgeInsets.only(bottom: 16),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          ShimmerItemWithoutIcon(100),
                                          Container(
                                            child: Divider(
                                              color: Colors.grey,
                                              thickness: 1,
                                            ),
                                            width: 24,
                                          ),
                                          ShimmerItemWithoutIcon(100),
                                          Container(
                                            child: Divider(
                                              color: Colors.grey,
                                              thickness: 1,
                                            ),
                                            width: 24,
                                          ),
                                          ShimmerItemWithoutIcon(100),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
/*------------------BASEMENT DRAWING------------------*/
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 2,
                            offset: Offset(
                              0,
                              0,
                            ),
                          )
                        ],
                      ),
                      margin: EdgeInsets.all(4),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ShimmerItemWithoutIcon(width / 2),
                            Container(
                              width: 220,
                              margin: EdgeInsets.only(top: 8, bottom: 8),
                              child: Divider(
                                color: Colors.black,
                                thickness: 2,
                              ),
                            ),
                            AspectRatio(
                              aspectRatio:
                                  MediaQuery.of(context).size.aspectRatio,
                              child: Container(
                                color: Colors.grey.shade100,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
/*------------------Agreement DRAWING------------------*/
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 2,
                            offset: Offset(
                              0,
                              0,
                            ),
                          )
                        ],
                      ),
                      margin: EdgeInsets.all(4),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
