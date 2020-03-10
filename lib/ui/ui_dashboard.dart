import 'dart:async';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/drawer/side_nav.dart';
import 'package:flutter_grate_app/model/customer_details.dart';
import 'package:flutter_grate_app/sqflite/database_info.dart';
import 'package:flutter_grate_app/sqflite/db_helper.dart';
import 'package:flutter_grate_app/sqflite/model/BasementReport.dart';
import 'package:flutter_grate_app/sqflite/model/Login.dart';
import 'package:flutter_grate_app/sqflite/model/user.dart';
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
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../flutter_connectivity.dart';
import '../utils.dart';
import 'fragment_recommended_level.dart';
import 'fragment_update_estimate.dart';

class DashboardUI extends StatefulWidget {
  Login login;
  LoggedInUser loggedInUser;

  DashboardUI(this.login, this.loggedInUser);

  @override
  _DashboardUIState createState() => _DashboardUIState();
}

class _DashboardUIState extends State<DashboardUI>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String searchKey = "";
  Widget fragment;
  GlobalKey<SideNavUIState> _keySideNav = GlobalKey();
  DBHelper dbHelper = new DBHelper();
  LoggedInUser loggedInUser;

  @override
  void initState() {
    super.initState();
    fragment = new DashboardFragment(
      login: widget.login,
      goToCustomerDetails: _goToCustomerDetails,
      loggedInUser: widget.loggedInUser,
      goToSearch: _goToSearch,
    );
  }

  void connectionChanged(dynamic hasConnection) {
    if(!hasConnection) {
      showAPIResponse(context, "No Internet Connection", Color(COLOR_DANGER));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async => false,
        child: ModalProgressHUD(
          child: SafeArea(
            child: Row(
              children: <Widget>[
                SideNavUI(
                  refreshEvent: _refresh,
                  key: _keySideNav,
                  login: widget.login,
                  loggedInUser: widget.loggedInUser,
                ),
                Expanded(
                  child: fragment,
                ),
              ],
            ),
          ),
          inAsyncCall: _isLoading,
          color: Colors.black,
          progressIndicator: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(
              Colors.white,
            ),
          ),
          dismissible: false,
        ),
      ),
    );
  }

  _refresh(int index) {
    setState(() {
      switch (index) {
        case 0:
          fragment = new DashboardFragment(
            login: widget.login,
            goToCustomerDetails: _goToCustomerDetails,
            loggedInUser: widget.loggedInUser,
            goToSearch: _goToSearch,
          );
          break;
        case 1:
          fragment = AddCustomerFragment(
            backToDashboard: _backToDashboard,
            login: widget.login,
            isLoading: _showLoading,
            loggedInUser: widget.loggedInUser,
          );
          break;
        case 2:
          fragment = ChangePasswordFragment(
            backToDashboard: _backToDashboard,
            login: widget.login,
          );
          break;
        case 3:
          fragment = LogoutFragment(
            showLoading: _showLoading,
            backToDashboard: _backToDashboard,
            login: widget.login,
          );
          break;
      }
    });
  }

  _showLoading(bool flag) {
    setState(() {
      _isLoading = flag;
    });
  }

  _backToDashboard(int value) {
    setState(() {
      _keySideNav.currentState.updateSelection(value);
      fragment = new DashboardFragment(
        login: widget.login,
        goToCustomerDetails: _goToCustomerDetails,
        loggedInUser: widget.loggedInUser,
        goToSearch: _goToSearch,
      );
    });
  }

  _goToSearch(String searchText) {
    this.searchKey = searchText;
    setState(() {
      fragment = new SearchResultFragment(
        searchText: searchText,
        login: widget.login,
        gotoDetails: _goToCustomerDetailsFromSearch,
        backToDashboard: _backToDashboard,
      );
    });
  }

  _backToSearch(String searchText) {
    setState(() {
      fragment = new SearchResultFragment(
        searchText: searchText,
        login: widget.login,
        gotoDetails: _goToCustomerDetailsFromSearch,
        backToDashboard: _backToDashboard,
      );
    });
  }

  _backToCustomerDetails(CustomerDetails customer) {
    setState(() {
      fragment = new CustomerDetailsFragment(
        login: widget.login,
        loggedInUser: widget.loggedInUser,
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
        login: widget.login,
        loggedInUser: widget.loggedInUser,
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
          login: widget.login,
          loggedInUser: widget.loggedInUser,
          backToCustomerDetailsFromEstimate: _backToCustomerDetailsFromEstimate,
          customer: customer);
    });
  }

  _goToUpdateEstimate(CustomerDetails customer) {
    setState(() {
      fragment = UpdateEstimateFragment(
          login: widget.login,
          loggedInUser: widget.loggedInUser,
          backToCustomerDetailsFromEstimate: _backToCustomerDetailsFromEstimate,
          customer: customer);
    });
  }

  _backToCustomerDetailsFromEstimate(CustomerDetails customer) {
    setState(() {
      fragment = new CustomerDetailsFragment(
        login: widget.login,
        loggedInUser: widget.loggedInUser,
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
          login: widget.login,
          loggedInUser: widget.loggedInUser,
          backToCustomerDetails: _backToCustomerDetails,
          customer: customer);
    });
  }

  _goToUpdateBasementInspectionReport(CustomerDetails customer) {
    setState(() {
      fragment = UpdateBasementReportFragment(
          login: widget.login,
          loggedInUser: widget.loggedInUser,
          backToCustomerDetails: _backToCustomerDetails,
          customer: customer);
    });
  }

  _goToAddRecommendedLevel(CustomerDetails customer) {
    setState(() {
      fragment = RecommendedLevel(
          login: widget.login,
          loggedInUser: widget.loggedInUser,
          backToCustomerDetails: _backToCustomerDetails,
          customer: customer);
    });
  }

  _goToCustomerDetails(String customerID) {
    setState(() {
      fragment = new CustomerDetailsFragment(
        login: widget.login,
        loggedInUser: widget.loggedInUser,
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
        login: widget.login,
        loggedInUser: widget.loggedInUser,
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
