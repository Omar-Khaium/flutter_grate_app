import 'package:hive/hive.dart';

import '../../utils.dart';

part 'user.g.dart';

@HiveType(typeId: TABLE_USER)
class User {
  @HiveField(0)
  int id;
  @HiveField(1)
  String guid;
  @HiveField(2)
  String password;
  @HiveField(3)
  String firstName;
  @HiveField(4)
  String lastName;
  @HiveField(5)
  String photo;
  @HiveField(6)
  String email;
  @HiveField(7)
  bool isRemembered;
  @HiveField(8)
  bool isAuthenticated;
  @HiveField(9)
  String accessToken;
  @HiveField(10)
  int validity;
  @HiveField(11)
  int companyID;
  @HiveField(12)
  String companyGUID;
  @HiveField(13)
  String companyName;
  @HiveField(14)
  String companyEmail;
  @HiveField(15)
  String companyLogo;
  @HiveField(16)
  String companyPhone;
  @HiveField(17)
  String companyFax;
  @HiveField(18)
  String companyStreet;
  @HiveField(19)
  String companyCity;
  @HiveField(20)
  String companyState;
  @HiveField(21)
  String companyZipCode;

  User({this.id, this.guid, this.password, this.firstName, this.lastName,
      this.photo, this.email, this.isRemembered, this.isAuthenticated,
      this.accessToken, this.validity, this.companyID, this.companyGUID,
      this.companyName, this.companyEmail, this.companyLogo, this.companyPhone,
      this.companyFax, this.companyStreet, this.companyCity, this.companyState,
      this.companyZipCode});


  String get companyAddress {
    return _checkStreet().trim();
  }

  String _checkStreet(){
    return _validate(companyStreet) ? companyStreet + "\n" + _checkCity(false) : _checkCity(true);
  }

  String _checkCity(bool flag){
    return _validate(companyCity) ? companyCity + ", " + _checkState(false) : (flag ? "\n" + _checkState(false) : _checkState(true));
  }

  String _checkState(bool flag){
    return _validate(companyState) ? companyState + " " + _checkZip(false) : (flag ? ", " + _checkZip(false) : _checkZip(true));
  }

  String _checkZip(bool flag){
    return _validate(companyZipCode) ? companyZipCode : (flag ? "-" : "");
  }

  bool _validate(String val){
    return val==null || val.isEmpty ? false : true;
  }
}
