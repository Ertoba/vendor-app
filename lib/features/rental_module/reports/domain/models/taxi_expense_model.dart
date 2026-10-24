class TaxiExpenseModel {
  int? totalSize;
  int? limit;
  String? offset;
  List<Expense>? expense;

  TaxiExpenseModel({this.totalSize, this.limit, this.offset, this.expense});

  TaxiExpenseModel.fromJson(Map<String, dynamic> json) {
    final dynamic pageRaw = json['pagination'];
    final Map<String, dynamic>? page = pageRaw is Map ? Map<String, dynamic>.from(pageRaw) : null;
    totalSize = int.tryParse('${(page != null ? page['total'] : json['total_size'])}');
    limit = int.tryParse('${(page != null ? page['per_page'] : json['limit'])}');
    offset = (page != null ? page['current_page'] : json['offset'])?.toString();
    if ((json['data'] ?? json['expense']) != null) {
      expense = <Expense>[];
      (json['data'] ?? json['expense']).forEach((v) {
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
  String? type;
  double? amount;
  String? description;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  int? restaurantId;
  int? orderId;
  int? tripId;

  Expense({
    this.id,
    this.type,
    this.amount,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.restaurantId,
    this.orderId,
    this.tripId,
  });

  Expense.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    amount = json['amount']?.toDouble();
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    restaurantId = json['restaurant_id'];
    orderId = json['order_id'];
    tripId = json['trip_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['amount'] = amount;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['restaurant_id'] = restaurantId;
    data['order_id'] = orderId;
    data['trip_id'] = tripId;
    return data;
  }
}