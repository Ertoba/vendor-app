class TaxReportModel {
  int? totalSize;
  int? limit;
  String? offset;
  List<TaxSummary>? taxSummary;
  int? totalOrders;
  double? totalOrderAmount;
  double? totalTax;
  List<Orders>? orders;

  TaxReportModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.taxSummary,
    this.totalOrders,
    this.totalOrderAmount,
    this.totalTax,
    this.orders,
  });

  TaxReportModel.fromJson(Map<String, dynamic> json) {
    final dynamic pageRaw = json['pagination'];
    final Map<String, dynamic>? page = pageRaw is Map
        ? Map<String, dynamic>.from(pageRaw)
        : null;
    totalSize = int.tryParse(
      '${page != null ? page['total'] : json['total_size']}',
    );
    limit = int.tryParse('${page != null ? page['per_page'] : json['limit']}');
    offset = (page != null ? page['current_page'] : json['offset'])?.toString();
    final dynamic summaries = json['tax_summary'] ?? json['taxSummary'];
    if (summaries is List) {
      taxSummary = <TaxSummary>[];
      for (final dynamic v in summaries) {
        taxSummary!.add(TaxSummary.fromJson(v));
      }
    }
    totalOrders = json['total_orders'] ?? json['totalOrders'];
    totalOrderAmount = (json['total_order_amount'] ?? json['totalOrderAmount'])
        ?.toDouble();
    totalTax = (json['total_tax'] ?? json['totalTax'])?.toDouble();
    final dynamic rows = json['data'] ?? json['orders'];
    if (rows is List) {
      orders = <Orders>[];
      for (final dynamic v in rows) {
        orders!.add(Orders.fromJson(v));
      }
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
  double? orderAmount;
  double? totalTaxAmount;
  String? orderType;
  String? createdAt;
  String? orderStatus;
  String? paymentStatus;
  List<OrderTaxes>? orderTaxes;

  Orders({
    this.id,
    this.orderAmount,
    this.totalTaxAmount,
    this.orderType,
    this.createdAt,
    this.orderStatus,
    this.paymentStatus,
    this.orderTaxes,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderAmount = json['order_amount']?.toDouble();
    totalTaxAmount = json['total_tax_amount']?.toDouble();
    orderType = json['order_type'];
    createdAt = json['created_at'];
    orderStatus = json['order_status'];
    paymentStatus = json['payment_status'];

    if (json['order_taxes'] != null) {
      orderTaxes = <OrderTaxes>[];
      json['order_taxes'].forEach((v) {
        orderTaxes!.add(OrderTaxes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_amount'] = orderAmount;
    data['total_tax_amount'] = totalTaxAmount;
    data['order_type'] = orderType;
    data['created_at'] = createdAt;
    data['order_status'] = orderStatus;
    data['payment_status'] = paymentStatus;
    if (orderTaxes != null) {
      data['order_taxes'] = orderTaxes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderTaxes {
  int? id;
  int? orderId;
  String? taxName;
  double? taxAmount;
  String? taxType;

  OrderTaxes({
    this.id,
    this.orderId,
    this.taxName,
    this.taxAmount,
    this.taxType,
  });

  OrderTaxes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    taxName = json['tax_name'];
    taxAmount = json['tax_amount']?.toDouble();
    taxType = json['tax_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['order_id'] = orderId;
    data['tax_name'] = taxName;
    data['tax_amount'] = taxAmount;
    data['tax_type'] = taxType;
    return data;
  }
}
