import '../utils.dart';

class Estimate {
  String Id;
  String InvoiceId;
  String Description;
  String Quantity;
  String Price;
  String CreatedDate;
  String pdfUrl;

  Estimate(this.Id, this.InvoiceId, this.Description, this.Quantity, this.Price,
      this.pdfUrl, this.CreatedDate);

  Estimate.fromMap(Map<String, dynamic> map) {
    Id = map['Id'].toString();
    InvoiceId = map['InvoiceId'].toString();
    Description = map['Description'].toString();
    Quantity = map['EstimateEqpCount'].toString();
    Price = map['TotalAmount'].toString();
    pdfUrl = map['PDFUrl'].toString();
    CreatedDate = formatDate(map['CreatedDate']);
  }
}
