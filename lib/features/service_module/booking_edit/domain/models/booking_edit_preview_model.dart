class BookingEditPreviewModel {
  double? subtotal;
  double? discount;
  double? couponDiscount;
  double? tax;
  String? taxStatus;
  double? additionalCharge;
  double? total;
  double? due;
  List<BookingEditPreviewLine>? lines;

  BookingEditPreviewModel({
    this.subtotal, this.discount, this.couponDiscount, this.tax, this.taxStatus,
    this.additionalCharge, this.total, this.due, this.lines,
  });

  BookingEditPreviewModel.fromJson(Map<String, dynamic> json) {
    subtotal = json['subtotal'] != null ? double.tryParse(json['subtotal'].toString()) : null;
    discount = json['discount'] != null ? double.tryParse(json['discount'].toString()) : null;
    couponDiscount = json['coupon_discount'] != null ? double.tryParse(json['coupon_discount'].toString()) : null;
    tax = json['tax'] != null ? double.tryParse(json['tax'].toString()) : null;
    taxStatus = json['tax_status'];
    additionalCharge = json['additional_charge'] != null ? double.tryParse(json['additional_charge'].toString()) : null;
    total = json['total'] != null ? double.tryParse(json['total'].toString()) : null;
    due = json['due'] != null ? double.tryParse(json['due'].toString()) : null;
    if (json['lines'] != null) {
      lines = <BookingEditPreviewLine>[];
      json['lines'].forEach((v) => lines!.add(BookingEditPreviewLine.fromJson(v)));
    }
  }
}

class BookingEditPreviewLine {
  double? price;
  double? discount;
  double? total;

  BookingEditPreviewLine({this.price, this.discount, this.total});

  BookingEditPreviewLine.fromJson(Map<String, dynamic> json) {
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
    discount = json['discount'] != null ? double.tryParse(json['discount'].toString()) : null;
    total = json['total'] != null ? double.tryParse(json['total'].toString()) : null;
  }
}

class BookingEditPreviewResult {
  final bool isSuccess;
  final String? message;
  final BookingEditPreviewModel? preview;

  BookingEditPreviewResult({required this.isSuccess, this.message, this.preview});
}
