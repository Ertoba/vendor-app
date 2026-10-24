class ServiceTaxReportModel {
  int? totalSize;
  int? limit;
  String? offset;
  List<TaxSummary>? taxSummary;
  int? totalOrders;
  double? totalOrderAmount;
  double? totalTax;
  List<Orders>? orders;

  ServiceTaxReportModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.taxSummary,
    this.totalOrders,
    this.totalOrderAmount,
    this.totalTax,
    this.orders,
  });

  ServiceTaxReportModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset']?.toString();
    if (json['taxSummary'] != null) {
      taxSummary = <TaxSummary>[];
      json['taxSummary'].forEach((v) {
        taxSummary!.add(TaxSummary.fromJson(v));
      });
    }
    totalOrders = json['totalOrders'];
    totalOrderAmount = json['totalOrderAmount']?.toDouble();
    totalTax = json['totalTax']?.toDouble();
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (taxSummary != null) {
      data['taxSummary'] = taxSummary!.map((v) => v.toJson()).toList();
    }
    data['totalOrders'] = totalOrders;
    data['totalOrderAmount'] = totalOrderAmount;
    data['totalTax'] = totalTax;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TaxSummary {
  String? taxName;
  double? totalTax;
  String? taxLabel;

  TaxSummary({this.taxName, this.totalTax, this.taxLabel});

  TaxSummary.fromJson(Map<String, dynamic> json) {
    taxName = json['tax_name'];
    totalTax = json['total_tax']?.toDouble();
    taxLabel = json['tax_label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tax_name'] = taxName;
    data['total_tax'] = totalTax;
    data['tax_label'] = taxLabel;
    return data;
  }
}

class Orders {
  int? id;
  double? bookingAmount;
  double? taxAmount;
  String? bookingType;
  String? createdAt;
  String? bookingStatus;
  String? paymentStatus;

  Orders({
    this.id,
    this.bookingAmount,
    this.taxAmount,
    this.bookingType,
    this.createdAt,
    this.bookingStatus,
    this.paymentStatus,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingAmount = json['booking_amount']?.toDouble();
    taxAmount = json['tax_amount']?.toDouble();
    bookingType = json['booking_type'];
    createdAt = json['created_at'];
    bookingStatus = json['booking_status'];
    paymentStatus = json['payment_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_amount'] = bookingAmount;
    data['tax_amount'] = taxAmount;
    data['booking_type'] = bookingType;
    data['created_at'] = createdAt;
    data['booking_status'] = bookingStatus;
    data['payment_status'] = paymentStatus;
    return data;
  }
}
