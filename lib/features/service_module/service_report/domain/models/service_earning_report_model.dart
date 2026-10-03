class ServiceEarningReportModel {
  final Summary? summary;
  final Breakdown? earningBreakdown;
  final ExpenseBreakdown? expenseBreakdown;
  final Trend? trend;
  final int? totalSize;
  RecentTransactions? recentTransactions;

  ServiceEarningReportModel({
    this.summary,
    this.earningBreakdown,
    this.expenseBreakdown,
    this.trend,
    this.recentTransactions,
    this.totalSize,
  });

  factory ServiceEarningReportModel.fromJson(Map<String, dynamic> json) => ServiceEarningReportModel(
    totalSize: json["total_size"],
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
    earningBreakdown: json["earning_breakdown"] == null ? null : Breakdown.fromJson(json["earning_breakdown"]),
    expenseBreakdown: json["expense_breakdown"] == null ? null : ExpenseBreakdown.fromJson(json["expense_breakdown"]),
    trend: json["trend"] == null ? null : Trend.fromJson(json["trend"]),
    recentTransactions: json["recent_transactions"] == null ? null : RecentTransactions.fromJson(json["recent_transactions"]),
  );

  Map<String, dynamic> toJson() => {
    "total_size": totalSize,
    "summary": summary?.toJson(),
    "earning_breakdown": earningBreakdown?.toJson(),
    "expense_breakdown": expenseBreakdown?.toJson(),
    "trend": trend?.toJson(),
    "recent_transactions": recentTransactions?.toJson(),
  };
}

class Breakdown {
  final double? bookingStoreEarning;
  final double? bookingStoreEarningPercentage;
  final double? taxAmount;
  final double? taxAmountPercentage;

  Breakdown({
    this.bookingStoreEarning,
    this.bookingStoreEarningPercentage,
    this.taxAmount,
    this.taxAmountPercentage,
  });

  factory Breakdown.fromJson(Map<String, dynamic> json) => Breakdown(
    bookingStoreEarning: num.tryParse(json["booking_store_earning"].toString())?.toDouble(),
    bookingStoreEarningPercentage: num.tryParse(json["booking_store_earning_percentage"].toString())?.toDouble(),
    taxAmount: num.tryParse(json["tax_amount"].toString())?.toDouble(),
    taxAmountPercentage: num.tryParse(json["tax_amount_percentage"].toString())?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "booking_store_earning": bookingStoreEarning,
    "booking_store_earning_percentage": bookingStoreEarningPercentage,
    "tax_amount": taxAmount,
    "tax_amount_percentage": taxAmountPercentage,
  };
}

class ExpenseBreakdown {
  final double? bookingCommission;
  final double? bookingCommissionPercentage;
  final double? vendorExpenseAmount;
  final double? vendorExpenseAmountPercentage;
  final double? discountOnBooking;
  final double? discountOnBookingPercentage;
  final double? couponDiscount;
  final double? couponDiscountPercentage;
  final double? subscriptionAmount;
  final double? subscriptionAmountPercentage;

  ExpenseBreakdown({
    this.bookingCommission,
    this.bookingCommissionPercentage,
    this.vendorExpenseAmount,
    this.vendorExpenseAmountPercentage,
    this.discountOnBooking,
    this.discountOnBookingPercentage,
    this.couponDiscount,
    this.couponDiscountPercentage,
    this.subscriptionAmount,
    this.subscriptionAmountPercentage,
  });

  factory ExpenseBreakdown.fromJson(Map<String, dynamic> json) => ExpenseBreakdown(
    bookingCommission: num.tryParse(json["booking_commission"].toString())?.toDouble(),
    bookingCommissionPercentage: num.tryParse(json["booking_commission_percentage"].toString())?.toDouble(),
    vendorExpenseAmount: num.tryParse(json["vendor_expense_amount"].toString())?.toDouble(),
    vendorExpenseAmountPercentage: num.tryParse(json["vendor_expense_amount_percentage"].toString())?.toDouble(),
    discountOnBooking: num.tryParse(json["discount_on_booking"].toString())?.toDouble(),
    discountOnBookingPercentage: num.tryParse(json["discount_on_booking_percentage"].toString())?.toDouble(),
    couponDiscount: num.tryParse(json["coupon_discount"].toString())?.toDouble(),
    couponDiscountPercentage: num.tryParse(json["coupon_discount_percentage"].toString())?.toDouble(),
    subscriptionAmount: num.tryParse(json["subscription_amount"].toString())?.toDouble(),
    subscriptionAmountPercentage: num.tryParse(json["subscription_amount_percentage"].toString())?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "booking_commission": bookingCommission,
    "booking_commission_percentage": bookingCommissionPercentage,
    "vendor_expense_amount": vendorExpenseAmount,
    "vendor_expense_amount_percentage": vendorExpenseAmountPercentage,
    "discount_on_booking": discountOnBooking,
    "discount_on_booking_percentage": discountOnBookingPercentage,
    "coupon_discount": couponDiscount,
    "coupon_discount_percentage": couponDiscountPercentage,
    "subscription_amount": subscriptionAmount,
    "subscription_amount_percentage": subscriptionAmountPercentage,
  };
}

class RecentTransactions {
  String? activeType;
  Transaction? earning;
  Transaction? expense;
  Transaction? subscription;

  RecentTransactions({
    this.activeType,
    this.earning,
    this.expense,
    this.subscription,
  });

  factory RecentTransactions.fromJson(Map<String, dynamic> json) => RecentTransactions(
    activeType: json["active_type"],
    earning: json["earning"] == null ? null : Transaction.fromJson(json["earning"]),
    expense: json["expense"] == null ? null : Transaction.fromJson(json["expense"]),
    subscription: json["subscription"] == null ? null : Transaction.fromJson(json["subscription"]),
  );

  Map<String, dynamic> toJson() => {
    "active_type": activeType,
    "earning": earning?.toJson(),
    "expense": expense?.toJson(),
    "subscription": subscription?.toJson(),
  };
}

class Transaction {
  final List<TransactionData>? data;

  Transaction({this.data});

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    data: json["data"] == null ? [] : List<TransactionData>.from(json["data"]!.map((x) => TransactionData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class TransactionData {
  final String? transactionId;
  final String? date;
  final String? source;
  final String? sourceType;
  final String? transactionType;
  final String? earningFromBadge;
  final String? earningFrom;
  final String? expenseSourceBadge;
  final String? expenseSource;
  final int? bookingId;
  final double? amount;
  final Map<String, dynamic>? breakdown;

  TransactionData({
    this.transactionId,
    this.date,
    this.source,
    this.sourceType,
    this.transactionType,
    this.earningFromBadge,
    this.earningFrom,
    this.expenseSourceBadge,
    this.expenseSource,
    this.bookingId,
    this.amount,
    this.breakdown,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) => TransactionData(
    transactionId: json["transaction_id"],
    date: json["date"],
    source: json["source"],
    sourceType: json["source_type"],
    transactionType: json["transaction_type"],
    earningFromBadge: json["earning_from_badge"],
    earningFrom: json["earning_from"],
    expenseSourceBadge: json["expense_source_badge"],
    expenseSource: json["expense_source"],
    bookingId: json["booking_id"],
    amount: num.tryParse(json["amount"].toString())?.toDouble(),
    breakdown: json["breakdown"] is Map ? Map<String, dynamic>.from(json["breakdown"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "transaction_id": transactionId,
    "date": date,
    "source": source,
    "source_type": sourceType,
    "transaction_type": transactionType,
    "earning_from_badge": earningFromBadge,
    "earning_from": earningFrom,
    "expense_source_badge": expenseSourceBadge,
    "expense_source": expenseSource,
    "booking_id": bookingId,
    "amount": amount,
    "breakdown": breakdown,
  };
}

class Summary {
  final double? totalEarning;
  final double? previousTotalEarning;
  final double? totalEarningPercentage;
  final bool? totalEarningPositive;
  final double? totalExpense;
  final double? previousTotalExpense;
  final double? totalExpensePercentage;
  final bool? totalExpensePositive;
  final double? netIncome;
  final double? previousNetIncome;
  final double? netIncomePercentage;
  final bool? netIncomePositive;
  final Counts? counts;
  final Breakdown? breakdown;
  final double? bookingCommission;
  final double? bookingCommissionPercentage;
  final double? vendorExpenseAmount;
  final double? vendorExpenseAmountPercentage;
  final double? discountOnBooking;
  final double? discountOnBookingPercentage;
  final double? couponDiscount;
  final double? couponDiscountPercentage;
  final double? subscriptionAmount;
  final double? subscriptionAmountPercentage;

  Summary({
    this.totalEarning,
    this.previousTotalEarning,
    this.totalEarningPercentage,
    this.totalEarningPositive,
    this.totalExpense,
    this.previousTotalExpense,
    this.totalExpensePercentage,
    this.totalExpensePositive,
    this.netIncome,
    this.previousNetIncome,
    this.netIncomePercentage,
    this.netIncomePositive,
    this.counts,
    this.breakdown,
    this.bookingCommission,
    this.bookingCommissionPercentage,
    this.vendorExpenseAmount,
    this.vendorExpenseAmountPercentage,
    this.discountOnBooking,
    this.discountOnBookingPercentage,
    this.couponDiscount,
    this.couponDiscountPercentage,
    this.subscriptionAmount,
    this.subscriptionAmountPercentage,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    totalEarning: num.tryParse(json["total_earning"].toString())?.toDouble(),
    previousTotalEarning: num.tryParse(json["previous_total_earning"].toString())?.toDouble(),
    totalEarningPercentage: num.tryParse(json["total_earning_percentage"].toString())?.toDouble(),
    totalEarningPositive: json["total_earning_positive"],
    totalExpense: num.tryParse(json["total_expense"].toString())?.toDouble(),
    previousTotalExpense: num.tryParse(json["previous_total_expense"].toString())?.toDouble(),
    totalExpensePercentage: num.tryParse(json["total_expense_percentage"].toString())?.toDouble(),
    totalExpensePositive: json["total_expense_positive"],
    netIncome: num.tryParse(json["net_income"].toString())?.toDouble(),
    previousNetIncome: num.tryParse(json["previous_net_income"].toString())?.toDouble(),
    netIncomePercentage: num.tryParse(json["net_income_percentage"].toString())?.toDouble(),
    netIncomePositive: json["net_income_positive"],
    counts: json["counts"] == null ? null : Counts.fromJson(json["counts"]),
    breakdown: json["breakdown"] == null ? null : Breakdown.fromJson(json["breakdown"]),
    bookingCommission: num.tryParse(json["booking_commission"].toString())?.toDouble(),
    bookingCommissionPercentage: num.tryParse(json["booking_commission_percentage"].toString())?.toDouble(),
    vendorExpenseAmount: num.tryParse(json["vendor_expense_amount"].toString())?.toDouble(),
    vendorExpenseAmountPercentage: num.tryParse(json["vendor_expense_amount_percentage"].toString())?.toDouble(),
    discountOnBooking: num.tryParse(json["discount_on_booking"].toString())?.toDouble(),
    discountOnBookingPercentage: num.tryParse(json["discount_on_booking_percentage"].toString())?.toDouble(),
    couponDiscount: num.tryParse(json["coupon_discount"].toString())?.toDouble(),
    couponDiscountPercentage: num.tryParse(json["coupon_discount_percentage"].toString())?.toDouble(),
    subscriptionAmount: num.tryParse(json["subscription_amount"].toString())?.toDouble(),
    subscriptionAmountPercentage: num.tryParse(json["subscription_amount_percentage"].toString())?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "total_earning": totalEarning,
    "previous_total_earning": previousTotalEarning,
    "total_earning_percentage": totalEarningPercentage,
    "total_earning_positive": totalEarningPositive,
    "total_expense": totalExpense,
    "previous_total_expense": previousTotalExpense,
    "total_expense_percentage": totalExpensePercentage,
    "total_expense_positive": totalExpensePositive,
    "net_income": netIncome,
    "previous_net_income": previousNetIncome,
    "net_income_percentage": netIncomePercentage,
    "net_income_positive": netIncomePositive,
    "counts": counts?.toJson(),
    "breakdown": breakdown?.toJson(),
    "booking_commission": bookingCommission,
    "booking_commission_percentage": bookingCommissionPercentage,
    "vendor_expense_amount": vendorExpenseAmount,
    "vendor_expense_amount_percentage": vendorExpenseAmountPercentage,
    "discount_on_booking": discountOnBooking,
    "discount_on_booking_percentage": discountOnBookingPercentage,
    "coupon_discount": couponDiscount,
    "coupon_discount_percentage": couponDiscountPercentage,
    "subscription_amount": subscriptionAmount,
    "subscription_amount_percentage": subscriptionAmountPercentage,
  };
}

class Counts {
  final int? earning;
  final int? expense;
  final int? subscription;

  Counts({
    this.earning,
    this.expense,
    this.subscription,
  });

  factory Counts.fromJson(Map<String, dynamic> json) => Counts(
    earning: json["earning"],
    expense: json["expense"],
    subscription: json["subscription"],
  );

  Map<String, dynamic> toJson() => {
    "earning": earning,
    "expense": expense,
    "subscription": subscription,
  };
}

class Trend {
  final List<String>? categories;
  final List<double>? earningSeries;
  final List<double>? expenseSeries;

  Trend({
    this.categories,
    this.earningSeries,
    this.expenseSeries,
  });

  factory Trend.fromJson(Map<String, dynamic> json) => Trend(
    categories: json["categories"] == null ? [] : List<String>.from(json["categories"]!.map((x) => x)),
    earningSeries: json["earning_series"] == null ? [] : List<double>.from(json["earning_series"]!.map((x) => num.tryParse(x.toString())?.toDouble() ?? 0.0)),
    expenseSeries: json["expense_series"] == null ? [] : List<double>.from(json["expense_series"]!.map((x) => num.tryParse(x.toString())?.toDouble() ?? 0.0)),
  );

  Map<String, dynamic> toJson() => {
    "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x)),
    "earning_series": earningSeries == null ? [] : List<dynamic>.from(earningSeries!.map((x) => x)),
    "expense_series": expenseSeries == null ? [] : List<dynamic>.from(expenseSeries!.map((x) => x)),
  };
}
