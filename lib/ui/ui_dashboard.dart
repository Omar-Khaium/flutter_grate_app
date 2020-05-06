import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_grate_app/drawer/side_nav.dart';
import 'package:flutter_grate_app/model/customer_details.dart';
import 'package:flutter_grate_app/ui/fragment_add_basement_report.dart';
import 'package:flutter_grate_app/ui/fragment_add_customer.dart';
import 'package:flutter_grate_app/ui/fragment_add_estimate.dart';
import 'package:flutter_grate_app/ui/fragment_change_password.dart';
import 'package:flutter_grate_app/ui/fragment_customer_details.dart';
import 'package:flutter_grate_app/ui/fragment_dashboard.dart';
import 'package:flutter_grate_app/ui/fragment_edit_customer.dart';
import 'package:flutter_grate_app/ui/fragment_logout.dart';
import 'package:flutter_grate_app/ui/fragment_search_result.dart';
import 'package:flutter_grate_app/ui/fragment_update_basement_report.dart';

import '../utils.dart';
import 'fragment_recommended_level.dart';
import 'fragment_update_estimate.dart';

class DashboardUI extends StatefulWidget {
  @override
  _DashboardUIState createState() => _DashboardUIState();
}

class _DashboardUIState extends State<DashboardUI>
    with SingleTickerProviderStateMixin {
  String searchKey = "";
  Widget fragment;
  GlobalKey<SideNavUIState> _keySideNav = GlobalKey();

  @override
  void initState() {
    fragment = new DashboardFragment(
      goToCustomerDetails: _goToCustomerDetails,
      goToSearch: _goToSearch,
    );
    super.initState();
  }

  void connectionChanged(dynamic hasConnection) {
    if (!hasConnection) {
      showAPIResponse(context, "No Internet Connection", Color(COLOR_DANGER));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async => false,
        child: SafeArea(
          child: Row(
            children: <Widget>[
              SideNavUI(
                refreshEvent: _refresh,
                key: _keySideNav,
              ),
              Expanded(
                child: fragment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _refresh(int index) {
    setState(() {
      switch (index) {
        case 0:
          fragment = new DashboardFragment(
            goToCustomerDetails: _goToCustomerDetails,
            goToSearch: _goToSearch,
          );
          break;
        case 1:
          fragment = AddCustomerFragment(
            backToDashboard: _backToDashboard,
          );
          break;
        case 2:
          fragment = ChangePasswordFragment(
            backToDashboard: _backToDashboard,
          );
          break;
        case 3:
          fragment = LogoutFragment(
            backToDashboard: _backToDashboard,
          );
          break;
      }
    });
  }

  _backToDashboard(int value) {
    setState(() {
      _keySideNav.currentState.updateSelection(value);
      fragment = new DashboardFragment(
        goToCustomerDetails: _goToCustomerDetails,
        goToSearch: _goToSearch,
      );
    });
  }

  _goToSearch(String searchText) {
    this.searchKey = searchText;
    setState(() {
      fragment = new SearchResultFragment(
        searchText: searchText,
        gotoDetails: _goToCustomerDetailsFromSearch,
        backToDashboard: _backToDashboard,
      );
    });
  }

  _backToSearch(String searchText) {
    setState(() {
      fragment = new SearchResultFragment(
        searchText: searchText,
        gotoDetails: _goToCustomerDetailsFromSearch,
        backToDashboard: _backToDashboard,
      );
    });
  }

  _backToCustomerDetails(CustomerDetails customer) {
    setState(() {
      fragment = new CustomerDetailsFragment(
        backToDashboard: _backToDashboard,
        backToSearch: _backToSearch,
        customerID: customer.Id,
        searchText: searchKey,
        customer: customer,
        goToAddEstimate: _goToAddEstimate,
        goToRecommendedLevel: _goToAddRecommendedLevel,
        goToUpdateEstimate: _goToUpdateEstimate,
        goToUpdateBasementReport: _goToUpdateBasementInspectionReport,
        goToAddBasementReport: _goToBasementInspectionReport,
        goToEditCustomer: _goToEditCustomer,
        fromSearch: false,
      );
    });
  }

  _goToEditCustomer(CustomerDetails customer) {
    setState(() {
      fragment = new EditCustomerFragment(
        backToCustomerDetails: _backToCustomerDetails,
        customerID: customer.Id,
        customer: customer,
        goToAddEstimate: _goToAddEstimate,
        goToRecommendedLevel: _goToAddRecommendedLevel,
        goToUpdateEstimate: _goToUpdateEstimate,
        goToUpdateBasementReport: _goToUpdateBasementInspectionReport,
        goToAddBasementReport: _goToBasementInspectionReport,
      );
    });
  }

  _goToAddEstimate(CustomerDetails customer) {
    setState(() {
      fragment = AddEstimateFragment(
          backToCustomerDetailsFromEstimate: _backToCustomerDetailsFromEstimate,
          customer: customer);
    });
  }

  _goToUpdateEstimate(CustomerDetails customer) {
    setState(() {
      fragment = UpdateEstimateFragment(
          backToCustomerDetailsFromEstimate: _backToCustomerDetailsFromEstimate,
          customer: customer);
    });
  }

  _backToCustomerDetailsFromEstimate(CustomerDetails customer) {
    setState(() {
      fragment = new CustomerDetailsFragment(
        backToDashboard: _backToDashboard,
        backToSearch: _backToSearch,
        customerID: customer.Id,
        searchText: searchKey,
        customer: customer,
        goToAddEstimate: _goToAddEstimate,
        goToRecommendedLevel: _goToAddRecommendedLevel,
        goToUpdateEstimate: _goToUpdateEstimate,
        goToUpdateBasementReport: _goToUpdateBasementInspectionReport,
        goToAddBasementReport: _goToBasementInspectionReport,
        goToEditCustomer: _goToEditCustomer,
        fromSearch: false,
      );
    });
  }

  _goToBasementInspectionReport(CustomerDetails customer) {
    setState(() {
      fragment = AddBasementReportFragment(
          backToCustomerDetails: _backToCustomerDetails, customer: customer);
    });
  }

  _goToUpdateBasementInspectionReport(CustomerDetails customer) {
    setState(() {
      fragment = UpdateBasementReportFragment(
          backToCustomerDetails: _backToCustomerDetails, customer: customer);
    });
  }

  _goToAddRecommendedLevel(CustomerDetails customer) {
    setState(() {
      fragment = RecommendedLevel(
          backToCustomerDetails: _backToCustomerDetails, customer: customer);
    });
  }

  _goToCustomerDetails(String customerID) {
    setState(() {
      fragment = new CustomerDetailsFragment(
        backToDashboard: _backToDashboard,
        backToSearch: _backToSearch,
        customerID: customerID,
        searchText: searchKey,
        customer: null,
        goToAddEstimate: _goToAddEstimate,
        goToRecommendedLevel: _goToAddRecommendedLevel,
        goToUpdateEstimate: _goToUpdateEstimate,
        goToUpdateBasementReport: _goToUpdateBasementInspectionReport,
        goToAddBasementReport: _goToBasementInspectionReport,
        goToEditCustomer: _goToEditCustomer,
        fromSearch: false,
      );
    });
  }

  _goToCustomerDetailsFromSearch(String customerID) {
    setState(() {
      fragment = new CustomerDetailsFragment(
        backToDashboard: _backToDashboard,
        backToSearch: _backToSearch,
        customerID: customerID,
        searchText: searchKey,
        customer: null,
        goToAddEstimate: _goToAddEstimate,
        goToRecommendedLevel: _goToAddRecommendedLevel,
        goToUpdateEstimate: _goToUpdateEstimate,
        goToUpdateBasementReport: _goToUpdateBasementInspectionReport,
        goToAddBasementReport: _goToBasementInspectionReport,
        goToEditCustomer: _goToEditCustomer,
        fromSearch: true,
      );
    });
  }
}
