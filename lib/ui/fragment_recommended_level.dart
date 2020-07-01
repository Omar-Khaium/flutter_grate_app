import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_grate_app/model/customer_details.dart';
import 'package:flutter_grate_app/model/hive/user.dart';
import 'package:flutter_grate_app/widgets/custome_back_button.dart';
import 'package:flutter_grate_app/widgets/text_style.dart';
import 'package:hive/hive.dart';

import 'fragment_recommended_level_details.dart';

class RecommendedLevel extends StatefulWidget {
  int selectedLevel = 3;
  final CustomerDetails customer;
  final ValueChanged<CustomerDetails> backToCustomerDetails;

  RecommendedLevel(
      {Key key,
      this.customer,
      this.backToCustomerDetails})
      : super(key: key);

  @override
  _RecommendedLevelState createState() => new _RecommendedLevelState();
}

class _RecommendedLevelState extends State<RecommendedLevel>
    with SingleTickerProviderStateMixin {
  int selectedLevel;

  updateRecommendedLevel(int level) {
    setState(() {
      widget.customer.RecommendedLevel = level.toDouble();
    });
  }

  Box<User> userBox;
  User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.only(top: 16, left: 32, right: 32),
      margin: EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white,Colors.white12, Colors.blue.shade50, Colors.blue.shade100]
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CustomBackButton(
                  onTap: () => widget.backToCustomerDetails(widget.customer),
                ),
                SizedBox(
                  width: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Recommended Level", style: fragmentTitleStyle()),
                    Text(
                      "Choose your plan for " +
                          widget.customer.FirstName +
                          " " +
                          widget.customer.LastName,
                      style: listTextStyleForRecommendedLevel(),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Text(
            "Step towards a " +
                user.companyName +
                " and a nationally backend warranty",
            style: Theme.of(context).textTheme.body1.copyWith(
                color: Colors.black,),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "All of our  " +
                user.companyName +
                " /Crawl space Contractors are trained and certified",
            style: Theme.of(context).textTheme.body1.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 16,
          ),
          Expanded(
              child: Center(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          goToRecommendedLevelDetails(1);
                        },
                        child: Container(
                          decoration: new BoxDecoration(boxShadow: [
                            widget.customer.RecommendedLevel==1 ? BoxShadow(
                              color: Color(0xFFB33A3A).withOpacity(.5),
                                blurRadius: 8,
                                spreadRadius: 2
                            ) :  BoxShadow(
                              color: Colors.transparent,
                            ),
                          ]),
                          child: Card(
                            color: widget.customer.RecommendedLevel==1 ? Colors. white : Colors.transparent,
                            elevation: widget.customer.RecommendedLevel==1 ? 4 : 0,
                            child: Image.asset(
                              'images/level_1.png',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          goToRecommendedLevelDetails(2);
                        },
                        child: Container(
                          decoration: new BoxDecoration(boxShadow: [
                            widget.customer.RecommendedLevel==2 ? BoxShadow(
                                color: Color(0xFF88934F).withOpacity(.5),
                                blurRadius: 8,
                                spreadRadius: 2
                            ) :  BoxShadow(
                              color: Colors.transparent,
                            ),
                          ]),
                          child: Card(
                            color: widget.customer.RecommendedLevel==2 ? Colors. white : Colors.transparent,
                            elevation: widget.customer.RecommendedLevel==2 ? 4 : 0,
                            child: Image.asset(
                              'images/level_2.png',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          goToRecommendedLevelDetails(3);
                        },
                        child: Container(
                          decoration: new BoxDecoration(boxShadow: [
                            widget.customer.RecommendedLevel==3 ? BoxShadow(
                                color: Color(0xFF5D85B8).withOpacity(.5),
                                blurRadius: 8,
                                spreadRadius: 2
                            ) :  BoxShadow(
                              color: Colors.transparent,
                            ),
                          ]),
                          child: Card(
                            color: widget.customer.RecommendedLevel==3 ? Colors. white : Colors.transparent,
                            elevation: widget.customer.RecommendedLevel==3 ? 4 : 0,
                            child: Image.asset(
                              'images/level_3.png',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          goToRecommendedLevelDetails(4);
                        },
                        child: Container(
                          decoration: new BoxDecoration(boxShadow: [
                            widget.customer.RecommendedLevel==4 ? BoxShadow(
                                color: Color(0xFF75849B).withOpacity(.5),
                                blurRadius: 8,
                                spreadRadius: 2
                            ) :  BoxShadow(
                              color: Colors.transparent,
                            ),
                          ]),
                          child: Card(
                            color: widget.customer.RecommendedLevel==4 ? Colors. white : Colors.transparent,
                            elevation: widget.customer.RecommendedLevel==4 ? 4 : 0,
                            child: Image.asset('images/level_4.png',
                                fit: BoxFit.fitWidth),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          goToRecommendedLevelDetails(5);
                        },
                        child: Container(
                          decoration: new BoxDecoration(boxShadow: [
                            widget.customer.RecommendedLevel==5 ? BoxShadow(
                                color: Color(0xFF8E7147).withOpacity(.5),
                                blurRadius: 8,
                                spreadRadius: 2
                            ) :  BoxShadow(
                              color: Colors.transparent,
                            ),
                          ]),
                          child: Card(
                            color: widget.customer.RecommendedLevel==5 ? Colors. white : Colors.transparent,
                            elevation: widget.customer.RecommendedLevel==5 ? 4 : 0,
                            child: Image.asset(
                              'images/level_5.png',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          goToRecommendedLevelDetails(6);
                        },
                        child: Container(
                          decoration: new BoxDecoration(boxShadow: [
                            widget.customer.RecommendedLevel==6 ? BoxShadow(
                                color: Color(0xFF764537).withOpacity(.5),
                                blurRadius: 8,
                                spreadRadius: 2
                            ) :  BoxShadow(
                              color: Colors.transparent,
                            ),
                          ]),
                          child: Card(
                            color: widget.customer.RecommendedLevel==6 ? Colors. white : Colors.transparent,
                            elevation: widget.customer.RecommendedLevel==6 ? 4 : 0,
                            child: Image.asset('images/level_6.png',
                                fit: BoxFit.fitWidth),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  void goToRecommendedLevelDetails(index) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => new RecommendedLevelDetails(
            index: index,
            customer: widget.customer,
            backToCustomerDetails: backToCustomerDetails,
          ),
        ));
  }

  void backToCustomerDetails(int id) {
    widget.backToCustomerDetails(widget.customer);
  }

  @override
  void initState() {
    selectedLevel = widget.selectedLevel;
    userBox = Hive.box("users");
    user = userBox.getAt(0);
  }
}
