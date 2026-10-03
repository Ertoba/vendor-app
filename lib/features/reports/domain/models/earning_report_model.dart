
class EarningReportModel {
  final SummaryModel? summary;
  final TrendsModel? trends;
  TransactionContainer? transactions;
  final int? totalSize;

  EarningReportModel({
    this.summary,
    this.trends,
    this.transactions,
    this.totalSize,
  });

  factory EarningReportModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? page = json['pagination'] is Map ? Map<String, dynamic>.from(json['pagination']) : null;
    // Rows used to arrive under `transactions`; they now sit in `data` with a
    // sibling `pagination`. Flatten the page in so TransactionContainer reads
    // the same keys it always did.
    final dynamic transactionsJson = json['transactions'] ?? (json['data'] is List ? <String, dynamic>{...json, ...?page} : null);
    return EarningReportModel(
      summary: json['summary'] != null ? SummaryModel.fromJson(Map<String, dynamic>.from(json['summary'])) : null,
      trends: json['trends'] != null ? TrendsModel.fromJson(Map<String, dynamic>.from(json['trends'])) : null,
      transactions: transactionsJson != null ? TransactionContainer.fromJson(transactionsJson) : null,
      totalSize: _toInt(page != null ? page['total'] : json['total_size']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary?.toJson(),
      'trends': trends?.toJson(),
      'transactions': transactions?.toJson(),
      'total_size': totalSize,
    };
  }
}

class TransactionContainer {
  final List<TransactionModel> data;
  final PaginationModel? pagination;
  final int? totalSize;
  final int? limit;
  final int? offset;

  TransactionContainer({
    required this.data,
    this.pagination,
    this.totalSize,
    this.limit,
    this.offset,
  });

  factory TransactionContainer.fromJson(dynamic json) {
    if (json is List) {
      return TransactionContainer(
        data: json
            .whereType<Map>()
            .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    }

    if (json is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(json);
      final dynamic rawData = map['data'];

      return TransactionContainer(
        data: rawData is List
            ? rawData
                .whereType<Map>()
                .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
            : <TransactionModel>[],
        pagination: PaginationModel.fromJson(map),
        totalSize: _toInt(map['total_size']) ?? _toInt(map['total']),
        limit: _toInt(map['limit']) ?? _toInt(map['per_page']),
        offset: _toInt(map['offset']) ?? _toInt(map['current_page']),
      );
    }

    return TransactionContainer(data: <TransactionModel>[]);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'pagination': pagination?.toJson(),
      'total_size': totalSize,
      'limit': limit,
      'offset': offset,
    };
  }
}

class TransactionModel {
  final String? transactionId;
  final String? transactionType;
  final String? date;
  final String? source;
  final String? sourceType;
  final String? reference;
  final String? referenceType;
  final String? badge;
  final String? orderId;
  final double? amount;
  final dynamic breakdown;
  final String? type;

  TransactionModel({
    this.transactionId,
    this.transactionType,
    this.date,
    this.source,
    this.sourceType,
    this.reference,
    this.referenceType,
    this.badge,
    this.orderId,
    this.amount,
    this.breakdown,
    this.type,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final bool hasEarningReference = json.containsKey('earning_from') || json.containsKey('earning_source');
    final bool hasExpenseReference = json.containsKey('expense_source');

    return TransactionModel(
      transactionId: json['transaction_id']?.toString(),
      transactionType: json['transaction_type']?.toString(),
      date: json['date']?.toString(),
      source: json['source']?.toString() ?? json['earning_source']?.toString() ?? json['expense_source']?.toString(),
      sourceType: json['source_type']?.toString(),
      reference: json['reference']?.toString()
          ?? json['earning_from']?.toString()
          ?? json['expense_source']?.toString()
          ?? json['earning_source']?.toString()
          ?? json['order_id']?.toString(),
      referenceType: json['reference_type']?.toString()
          ?? (hasExpenseReference
              ? 'expense'
              : hasEarningReference
                  ? 'earning'
                  : json['type']?.toString()),
      badge: json['expense_source_badge']?.toString(),
      orderId: json['order_id']?.toString(),
      amount: _toDouble(json['amount']),
      breakdown: json['breakdown'],
      type: json['type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'transaction_type': transactionType,
      'date': date,
      'source': source,
      'source_type': sourceType,
      'reference': reference,
      'reference_type': referenceType,
      'badge': badge,
      'order_id': orderId,
      'amount': amount,
      'breakdown': breakdown,
      'type': type,
    };
  }
}

class PaginationModel {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final int? from;
  final int? to;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final String? firstPageUrl;
  final String? lastPageUrl;
  final String? path;

  PaginationModel({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.from,
    this.to,
    this.nextPageUrl,
    this.prevPageUrl,
    this.firstPageUrl,
    this.lastPageUrl,
    this.path,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: _toInt(json['current_page']),
      lastPage: _toInt(json['last_page']),
      perPage: _toInt(json['per_page']),
      total: _toInt(json['total']) ?? _toInt(json['total_size']),
      from: _toInt(json['from']),
      to: _toInt(json['to']),
      nextPageUrl: json['next_page_url']?.toString(),
      prevPageUrl: json['prev_page_url']?.toString(),
      firstPageUrl: json['first_page_url']?.toString(),
      lastPageUrl: json['last_page_url']?.toString(),
      path: json['path']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'from': from,
      'to': to,
      'next_page_url': nextPageUrl,
      'prev_page_url': prevPageUrl,
      'first_page_url': firstPageUrl,
      'last_page_url': lastPageUrl,
      'path': path,
    };
  }
}

class SummaryModel {
  final double? totalEarningsWithAdminCommission;
  final double? totalExpenses;
  final double? netProfit;
  final int? totalTransactionExpenseCount;
  final int? totalTransactionEarningCount;
  final int? totalTransactionSubscriptionCount;
  final BreakdownSummaryModel? breakdown;

  SummaryModel({
    this.totalEarningsWithAdminCommission,
    this.totalExpenses,
    this.netProfit,
    this.totalTransactionExpenseCount,
    this.totalTransactionEarningCount,
    this.totalTransactionSubscriptionCount,
    this.breakdown,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    print("----> ${(json['total_earnings'])}");
    print("----> ${_toDouble(json['total_earnings']) ?? _toDouble(json['total_earnings_with_admin_commission'])}");
    return SummaryModel(
      totalEarningsWithAdminCommission: _toDouble(json['total_earnings_with_admin_commission']) ?? _toDouble(json['total_earnings']),
      totalExpenses: _toDouble(json['total_expenses']),
      netProfit: _toDouble(json['net_profit']),
      totalTransactionExpenseCount: _toInt(json['total_transaction_expense_count']),
      totalTransactionEarningCount: _toInt(json['total_transaction_earning_count']),
      totalTransactionSubscriptionCount: _toInt(json['total_transaction_subscription_count']),
      breakdown: json['breakdown'] != null ? BreakdownSummaryModel.fromJson(Map<String, dynamic>.from(json['breakdown'])) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_earnings_with_admin_commission': totalEarningsWithAdminCommission,
      'total_expenses': totalExpenses,
      'net_profit': netProfit,
      'total_transaction_expense_count': totalTransactionExpenseCount,
      'total_transaction_earning_count': totalTransactionEarningCount,
      'total_transaction_subscription_count': totalTransactionSubscriptionCount,
      'breakdown': breakdown?.toJson(),
    };
  }
}

class BreakdownSummaryModel {
  final double? orderSales;
  final double? taxCollected;
  final double? packagingFeeCollected;
  final double? adminCommission;
  final double? discountOnItem;
  final double? subscriptionFee;
  final double? couponContribution;
  final double? freeDelivery;

  BreakdownSummaryModel({
    this.orderSales,
    this.taxCollected,
    this.packagingFeeCollected,
    this.adminCommission,
    this.discountOnItem,
    this.subscriptionFee,
    this.couponContribution,
    this.freeDelivery,
  });

  factory BreakdownSummaryModel.fromJson(Map<String, dynamic> json) {
    return BreakdownSummaryModel(
      orderSales: _toDouble(json['order_sales']),
      taxCollected: _toDouble(json['tax_collected']),
      packagingFeeCollected: _toDouble(json['packaging_fee_collected']) ?? _toDouble(json['extra_packaging_charge']),
      adminCommission: _toDouble(json['admin_commission']),
      discountOnItem: _toDouble(json['discount_on_item']),
      subscriptionFee: _toDouble(json['subscription_fee']),
      couponContribution: _toDouble(json['coupon_contribution']),
      freeDelivery: _toDouble(json['free_delivery']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_sales': orderSales,
      'tax_collected': taxCollected,
      'packaging_fee_collected': packagingFeeCollected,
      'admin_commission': adminCommission,
      'discount_on_item': discountOnItem,
      'subscription_fee': subscriptionFee,
      'coupon_contribution': couponContribution,
      'free_delivery': freeDelivery,
    };
  }
}

class TrendsModel {
  final List<String> categories;
  final List<double> earningSeries;
  final List<double> expenseSeries;

  TrendsModel({
    required this.categories,
    required this.earningSeries,
    required this.expenseSeries,
  });

  factory TrendsModel.fromJson(Map<String, dynamic> json) {
    return TrendsModel(
      categories: (json['categories'] as List? ?? []).map((e) => e.toString()).toList(),
      earningSeries: (json['earning_series'] as List? ?? []).map((e) => _toDouble(e) ?? 0.0).toList(),
      expenseSeries: (json['expense_series'] as List? ?? []).map((e) => _toDouble(e) ?? 0.0).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
      'earning_series': earningSeries,
      'expense_series': expenseSeries,
    };
  }
}

int? _toInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}
