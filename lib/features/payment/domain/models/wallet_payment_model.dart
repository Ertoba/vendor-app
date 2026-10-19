import 'package:sixam_mart_store/helper/data_parser_helper.dart';

class WalletPaymentModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<Transactions>? transactions;

  WalletPaymentModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.transactions,
  });

  WalletPaymentModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? page = json['pagination'] is Map
        ? Map<String, dynamic>.from(json['pagination'])
        : null;
    totalSize = DataParserHelper.parseInt(
      page != null ? page['total'] : json['total_size'],
    );
    limit = DataParserHelper.parseInt(
      page != null ? page['per_page'] : json['limit'],
    );
    offset = DataParserHelper.parseInt(
      page != null ? page['current_page'] : json['offset'],
    );
    final dynamic rows = json['data'] ?? json['transactions'];
    if (rows is List) {
      transactions = <Transactions>[];
      for (final dynamic v in rows) {
        transactions!.add(Transactions.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (transactions != null) {
      data['transactions'] = transactions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Transactions {
  int? id;
  String? fromType;
  int? fromId;
  double? currentBalance;
  double? amount;
  String? method;
  String? ref;
  String? createdAt;
  String? updatedAt;
  String? type;
  String? createdBy;
  String? paymentMethod;
  String? status;
  String? paymentTime;

  Transactions({
    this.id,
    this.fromType,
    this.fromId,
    this.currentBalance,
    this.amount,
    this.method,
    this.ref,
    this.createdAt,
    this.updatedAt,
    this.type,
    this.createdBy,
    this.paymentMethod,
    this.status,
    this.paymentTime,
  });

  Transactions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fromType = json['from_type'];
    fromId = json['from_id'];
    currentBalance = json['current_balance']?.toDouble();
    amount = json['amount']?.toDouble();
    method = json['method'];
    ref = json['ref'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    type = json['type'];
    createdBy = json['created_by'];
    paymentMethod = json['payment_method'];
    status = json['status'];
    paymentTime = json['payment_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['from_type'] = fromType;
    data['from_id'] = fromId;
    data['current_balance'] = currentBalance;
    data['amount'] = amount;
    data['method'] = method;
    data['ref'] = ref;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['type'] = type;
    data['created_by'] = createdBy;
    data['payment_method'] = paymentMethod;
    data['status'] = status;
    data['payment_time'] = paymentTime;
    return data;
  }
}
