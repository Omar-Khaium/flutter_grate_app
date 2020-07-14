import 'package:intl/intl.dart';

class Product {
  int id;
  String guid;
  String name;
  String description;
  int quantity;
  double rate;
  double discount = 0;
  double discountPercent = 0;
  bool discountAsPercentage = true;
  double price;
  String date;

  Product(this.id, this.guid, this.name, this.description, this.quantity,
      this.rate, this.discount, this.discountPercent, this.discountAsPercentage, this.price, this.date);

  String get Name {
    return name==null ? "-" : name;
  }

  String get Description {
    return description==null ? "-" : description;
  }

  String get Quantity {
    return quantity==null || quantity==0 ? "1" : quantity.toString();
  }

  String get Discount {
    return discount==null ? "0.0" : discount.toStringAsFixed(2);
  }

  String get Rate {
    return rate==null ? "0.0" : rate.toStringAsFixed(2);
  }

  String get Price {
    return price==null ? "0.0" : price.toStringAsFixed(2);
  }

  String get Date {
    return date==null ? DateFormat('MM/dd/yyyy').format(DateTime.now()) : date;
  }

  Product.fromMap(Map<String, dynamic> map, bool isAutoComplete) {
    id = map['Id'];
    guid = map['EquipmentId'];
    name = map['${isAutoComplete ? 'EquipmentName' : 'EquipName'}'];
    description = map['${isAutoComplete ? 'EquipmentType' : 'EquipmentType'}'];
    quantity = map['${isAutoComplete ? 'QuantityAvailable' : 'Quantity'}'];
    rate = map['${isAutoComplete ? 'RetailPrice' : 'UnitPrice'}'];
    price = map['${isAutoComplete ? 'SupplierCost' : 'TotalPrice'}'];
    discount = map['DiscountAmount']== null ? 0 : map['DiscountAmount'];
    discountPercent = map['DiscountPercent']== null ? 0 : map['DiscountPercent'];
    discountAsPercentage = map['DiscountType']== 'amount' ? false : true;
    date = map['CreatedDate'];
  }

  Product.fromMapForFavourite(Map<String, dynamic> map, bool isAutoComplete) {
    id = map['Id'];
    guid = map['EquipmentId'];
    name = map['${isAutoComplete ? 'Name' : 'Name'}'];
    description = map['${isAutoComplete ? 'Description' : 'Description'}'];
    quantity = map['${isAutoComplete ? 'QuantityAvailable' : 'Quantity'}'];
    rate = map['${isAutoComplete ? 'Retail' : 'Retail'}'];
    price = map['${isAutoComplete ? 'Retail' : 'Retail'}'];
    discount = map['DiscountAmount']== null ? 0 : map['DiscountAmount'];
    discountPercent = map['DiscountPercent']== null ? 0 : map['DiscountPercent'];
    discountAsPercentage = map['DiscountType']== 'amount' ? false : true;
    date = DateFormat('MM/dd/yyyy').format(DateTime.now());
  }

  Map<String, dynamic> toJson() =>
      {
        'EquipmentId' : guid,
        'EquipName' : name,
        'EquipDetail' : description,
        'Quantity' : quantity,
        'UnitPrice' : rate,
        'DiscountAmount' : rate*quantity - price,
        'DiscountPercent' : discountAsPercentage ? discountPercent : 0,
        'DiscountType' : discountAsPercentage ? "percent" : "amount",
        'TotalPrice' : price,
      };
}