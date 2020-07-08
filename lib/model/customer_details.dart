import 'package:flutter_grate_app/model/estimate.dart';

class CustomerDetails {
  String Id;
  String CustomerId;
  String Title;
  String Type;
  String FirstName;
  String LastName;
  String BusinessName;
  String _CustomerAccountNo;
  String PrimaryPhone;
  String SecondaryPhone;
  String EmailAddress;
  String Street;
  String City;
  String State;
  String ZipCode;
  String _ProfileImage;
  double RecommendedLevel;
  bool HasInspectionReport;
  String EstimateId;
  int EstimateIntId;
  List<Estimate> estimates;

  CustomerDetails(
      this.Id,
      this.CustomerId,
      this.Title,
      this.Type,
      this.FirstName,
      this.LastName,
      this.BusinessName,
      this.PrimaryPhone,
      this.SecondaryPhone,
      this.EmailAddress,
      this.Street,
      this.City,
      this.State,
      this.ZipCode,
      this.RecommendedLevel,
      this.estimates,
      this._ProfileImage,
      {this.EstimateId,
      this.EstimateIntId});

  String get Name {
    return _CheckNames().trim();
  }

  String get ProfileName {
    return _CheckBusinessName().trim();
  }

  String get ProfileImage => _ProfileImage;

  String get CustomerAccountNumber {
    return _CheckCustomerAccountNo().trim();
  }

  set ProfileImage(String value) {
    _ProfileImage = value;
  }

  String get Email {
    return _CheckEmail().trim();
  }

  String get Address {
    return _CheckStreet().trim();
  }

  String get ContactNum {
    return _CheckContactNo().trim();
  }

  bool _validate(String val) {
    return val == null || val.isEmpty ? false : true;
  }

  String _CheckBusinessName() {
    return Type != null && Type == "Commercial"
        ? (BusinessName != null && BusinessName.isNotEmpty
            ? _CheckName(BusinessName)
            : _CheckName(Title) +
                " " +
                _CheckName(FirstName) +
                " " +
                _CheckName(LastName))
        : _CheckName(Title) +
            " " +
            _CheckName(FirstName) +
            " " +
            _CheckName(LastName);
  }

  String _CheckNames() {
    return _CheckName(FirstName) + " " + _CheckName(LastName);
  }

  String _CheckName(String val) {
    return _validate(val) ? val : "";
  }

  String _CheckStreet() {
    return _validate(Street)
        ? Street + "\n" + _CheckCity(false)
        : _CheckCity(true);
  }

  String _CheckCity(bool flag) {
    return _validate(City)
        ? City + ", " + _CheckState(false)
        : (flag ? "\n" + _CheckState(false) : _CheckState(true));
  }

  String _CheckState(bool flag) {
    return _validate(State)
        ? State + " " + _CheckZip(false)
        : (flag ? ", " + _CheckZip(false) : _CheckZip(true));
  }

  String _CheckZip(bool flag) {
    return _validate(ZipCode) ? ZipCode : (flag ? "-" : "");
  }

  String _CheckContactNo() {
    return _validate(PrimaryPhone)
        ? PrimaryPhone
        : (_validate(SecondaryPhone) ? SecondaryPhone : "-");
  }

  String _CheckEmail() {
    return _validate(EmailAddress) ? EmailAddress : "-";
  }

  String _CheckCustomerAccountNo() {
    return _validate(_CustomerAccountNo) ? _CustomerAccountNo : "-";
  }

  CustomerDetails.fromMap(Map<String, dynamic> map) {
    Id = map["CustomerDetails"]['Id'].toString();
    CustomerId = map["CustomerDetails"]['CustomerId'].toString();
    Title = map["CustomerDetails"]['Title'].toString();
    Type = map["CustomerDetails"]['Type'].toString();
    FirstName = map["CustomerDetails"]['FirstName'];
    LastName = map["CustomerDetails"]['LastName'];
    BusinessName = map["CustomerDetails"]['BusinessName'];
    _CustomerAccountNo = map["CustomerDetails"]['AccountNo'];
    PrimaryPhone = map["CustomerDetails"]['PrimaryPhone'];
    SecondaryPhone = map["CustomerDetails"]['CellNo'];
    EmailAddress = map["CustomerDetails"]['EmailAddress'];
    Street = map["CustomerDetails"]['Street'];
    City = map["CustomerDetails"]['City'];
    State = map["CustomerDetails"]['State'];
    ProfileImage = map["CustomerDetails"]['ProfileImage'];
    ZipCode = map["CustomerDetails"]['ZipCode'].toString();
    RecommendedLevel = getRecommendedLevel(
        map["CustomerDetails"]['RecommendedLevel'].toString());
    HasInspectionReport = map["Inspection"];
    var estimateMap = map['EstimateList']['EstimateList'];
    if (estimateMap == null) {
      estimates = [];
    } else {
      estimates = List.generate(estimateMap.length, (index) {
        return Estimate.fromMap(estimateMap[index]);
      });
    }
  }

  double getRecommendedLevel(String level) {
    try {
      return double.parse(level);
    } catch (error) {
      return 0.0;
    }
  }

  bool getInspectionLevel(String level) {
    try {
      return bool.fromEnvironment(level);
    } catch (error) {
      return false;
    }
  }
}
