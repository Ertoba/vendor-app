class ServiceExpenseModel {
  int? totalSize;
  int? limit;
  String? offset;
  List<Expense>? expense;

  ServiceExpenseModel({this.totalSize, this.limit, this.offset, this.expense});

  ServiceExpenseModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset']?.toString();
    if (json['expense'] != null) {
      expense = <Expense>[];
      json['expense'].forEach((v) {
        expense!.add(Expense.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (expense != null) {
      data['expense'] = expense!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Expense {
  int? id;
  int? storeId;
  int? serviceBookingId;
  String? type;
  double? amount;
  String? createdBy;
  String? createdAt;

  Expense({
    this.id,
    this.storeId,
    this.serviceBookingId,
    this.type,
    this.amount,
    this.createdBy,
    this.createdAt,
  });

  Expense.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    serviceBookingId = json['service_booking_id'];
    type = json['type'];
    amount = json['amount']?.toDouble();
    createdBy = json['created_by'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['store_id'] = storeId;
    data['service_booking_id'] = serviceBookingId;
    data['type'] = type;
    data['amount'] = amount;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    return data;
  }
}
