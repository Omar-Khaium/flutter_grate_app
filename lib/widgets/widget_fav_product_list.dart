import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grate_app/model/hive/user.dart';
import 'package:flutter_grate_app/model/product.dart';
import 'package:flutter_grate_app/utils.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FavouriteProductListUI extends StatefulWidget {
  ValueChanged<Product> sendData;

  FavouriteProductListUI(this.sendData);

  @override
  _FavouriteProductListUIState createState() => _FavouriteProductListUIState();
}

class _FavouriteProductListUIState extends State<FavouriteProductListUI> {
  List<Product> _list = [];

  Box<User> userBox;
  User user;

  @override
  void initState() {
    userBox = Hive.box("users");
    user = userBox.getAt(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFavouriteList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return new SafeArea(
            child: new Scaffold(
              appBar: AppBar(
                title: Text("Favourite Product List"),
              ),
              backgroundColor: Colors.white,
              body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: _list != null && _list.length == 0
                    ? Center(
                        child: Image.asset(
                          'images/no_data.png',
                          height: 256,
                          width: 256,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => Divider(
                              color: Colors.black,
                              thickness: .4,
                            ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _list.length,
                        itemBuilder: (BuildContext context, index) {
                          return Container(
                            child: ListTile(
                              onTap: () {
                                widget.sendData(_list[index]);
                                Navigator.of(context).pop();
                              },
                              leading: Icon(MdiIcons.cube),
                              title: Text(
                                _list[index].name == ""
                                    ? "No Product Found"
                                    : _list[index].name,
                                style: new TextStyle(
                                    fontSize: 24,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(_list[index].description == ""
                                  ? "No Description Found"
                                  : _list[index].description),
                              trailing: Text(
                                '\$ ${_list[index].rate.toStringAsFixed(2)}',
                                style: new TextStyle(fontSize: 18),
                              ),
                            ),
                          );
                        }),
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CupertinoActivityIndicator(
                animating: true,
                radius: 14,
              ),
            ),
          );
        }
      },
    );
  }

  Future getFavouriteList() async {
    try {
      Map<String, String> headers = {
        'Authorization': user.accessToken,
      };
      var url = "https://api.gratecrm.com/GetFavouriteEquipmentList";
      var result = await http.get(url, headers: headers);
      if (result.statusCode == 200) {
        Map map = json.decode(result.body);
        _list = List.generate(map['model'].length, (index) {
          return Product.fromMapForFavourite(map['model'][index], false);
        });
        return result;
      } else {
        showMessage(context, "Network error!", json.decode(result.body),
            Colors.redAccent, Icons.warning);
        return {};
      }
    } catch (error) {
      print(error);
    }
  }
}
