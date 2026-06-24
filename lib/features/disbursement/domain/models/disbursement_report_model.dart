class DisbursementReportModel {
  int? totalSize;
  String? limit;
  String? offset;
  double? pending;
  double? completed;
  double? canceled;
  int? keepzTotalSize;
  double? keepzCompleted;
  int? completeDay;
  List<Disbursements>? disbursements;
  List<KeepzSettlement>? keepzSettlements;

  DisbursementReportModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.pending,
    this.completed,
    this.canceled,
    this.keepzTotalSize,
    this.keepzCompleted,
    this.completeDay,
    this.disbursements,
    this.keepzSettlements,
  });

  DisbursementReportModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    pending = json['pending']?.toDouble();
    completed = json['completed']?.toDouble();
    canceled = json['canceled']?.toDouble();
    keepzTotalSize = json['keepz_total_size'];
    keepzCompleted = json['keepz_completed']?.toDouble();
    completeDay = json['complete_day'];
    if (json['disbursements'] != null) {
      disbursements = <Disbursements>[];
      json['disbursements'].forEach((v) {
        disbursements!.add(Disbursements.fromJson(v));
      });
    }
    if (json['keepz_settlements'] != null) {
      keepzSettlements = <KeepzSettlement>[];
      json['keepz_settlements'].forEach((v) {
        keepzSettlements!.add(KeepzSettlement.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    data['pending'] = pending;
    data['completed'] = completed;
    data['canceled'] = canceled;
    data['keepz_total_size'] = keepzTotalSize;
    data['keepz_completed'] = keepzCompleted;
    data['complete_day'] = completeDay;
    if (disbursements != null) {
      data['disbursements'] = disbursements!.map((v) => v.toJson()).toList();
    }
    if (keepzSettlements != null) {
      data['keepz_settlements'] = keepzSettlements!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class KeepzSettlement {
  String? paymentRequestId;
  int? orderId;
  int? storeId;
  double? amount;
  String? status;
  String? transactionId;
  String? receiverType;
  String? receiverIdentifierMasked;
  String? paidAt;

  KeepzSettlement({
    this.paymentRequestId,
    this.orderId,
    this.storeId,
    this.amount,
    this.status,
    this.transactionId,
    this.receiverType,
    this.receiverIdentifierMasked,
    this.paidAt,
  });

  KeepzSettlement.fromJson(Map<String, dynamic> json) {
    paymentRequestId = json['payment_request_id'];
    orderId = json['order_id'];
    storeId = json['store_id'];
    amount = json['amount']?.toDouble();
    status = json['status'];
    transactionId = json['transaction_id'];
    receiverType = json['receiver_type'];
    receiverIdentifierMasked = json['receiver_identifier_masked'];
    paidAt = json['paid_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_request_id': paymentRequestId,
      'order_id': orderId,
      'store_id': storeId,
      'amount': amount,
      'status': status,
      'transaction_id': transactionId,
      'receiver_type': receiverType,
      'receiver_identifier_masked': receiverIdentifierMasked,
      'paid_at': paidAt,
    };
  }
}

class Disbursements {
  int? id;
  int? disbursementId;
  int? storeId;
  int? deliveryManId;
  double? disbursementAmount;
  int? paymentMethod;
  String? status;
  String? createdAt;
  String? updatedAt;
  WithdrawMethod? withdrawMethod;

  Disbursements({
    this.id,
    this.disbursementId,
    this.storeId,
    this.deliveryManId,
    this.disbursementAmount,
    this.paymentMethod,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.withdrawMethod,
  });

  Disbursements.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    disbursementId = json['disbursement_id'];
    storeId = json['store_id'];
    deliveryManId = json['delivery_man_id'];
    disbursementAmount = json['disbursement_amount']?.toDouble();
    paymentMethod = json['payment_method'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    withdrawMethod = json['withdraw_method'] != null ? WithdrawMethod.fromJson(json['withdraw_method']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['disbursement_id'] = disbursementId;
    data['store_id'] = storeId;
    data['delivery_man_id'] = deliveryManId;
    data['disbursement_amount'] = disbursementAmount;
    data['payment_method'] = paymentMethod;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (withdrawMethod != null) {
      data['withdraw_method'] = withdrawMethod!.toJson();
    }
    return data;
  }
}

class WithdrawMethod {
  int? id;
  int? storeId;
  int? deliveryManId;
  int? withdrawalMethodId;
  String? methodName;
  MethodFields? methodFields;
  bool? isDefault;
  String? createdAt;
  String? updatedAt;

  WithdrawMethod({
    this.id,
    this.storeId,
    this.deliveryManId,
    this.withdrawalMethodId,
    this.methodName,
    this.methodFields,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  WithdrawMethod.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    deliveryManId = json['delivery_man_id'];
    withdrawalMethodId = json['withdrawal_method_id'];
    methodName = json['method_name'];
    methodFields = json['method_fields'] != null ? MethodFields.fromJson(json['method_fields']) : null;
    isDefault = json['is_default'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['store_id'] = storeId;
    data['delivery_man_id'] = deliveryManId;
    data['withdrawal_method_id'] = withdrawalMethodId;
    data['method_name'] = methodName;
    if (methodFields != null) {
      data['method_fields'] = methodFields!.toJson();
    }
    data['is_default'] = isDefault;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class MethodFields {
  String? transactionId;

  MethodFields({this.transactionId});

  MethodFields.fromJson(Map<String, dynamic> json) {
    transactionId = json['transaction_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transaction_id'] = transactionId;
    return data;
  }
}
