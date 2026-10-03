
class SubscriptionModel {
  int? id;
  String? status;
  String? note;
  String? type;
  int? quantity;
  int? userId;
  int? restaurantId;
  double? paidAmount;
  String? createdAt;
  String? updatedAt;

  SubscriptionModel({
    this.id,
    this.status,
    this.note,
    this.type,
    this.quantity,
    this.userId,
    this.restaurantId,
    this.paidAmount,
    this.createdAt,
    this.updatedAt,
  });

  SubscriptionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    note = json['note'];
    type = json['type'];
    quantity = json['quantity'];
    userId = json['user_id'];
    restaurantId = json['restaurant_id'];
    paidAmount = json['paid_amount']?.toDouble();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['note'] = note;
    data['type'] = type;
    data['quantity'] = quantity;
    data['user_id'] = userId;
    data['restaurant_id'] = restaurantId;
    data['paid_amount'] = paidAmount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}