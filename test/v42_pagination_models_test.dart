import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart_store/features/advertisement/models/advertisement_model.dart';
import 'package:sixam_mart_store/features/category/domain/models/assignable_food_model.dart';
import 'package:sixam_mart_store/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart_store/features/chat/domain/models/message_model.dart';
import 'package:sixam_mart_store/features/disbursement/domain/models/disbursement_method_model.dart';
import 'package:sixam_mart_store/features/order/domain/models/edit_history_log_model.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_cancellation_body_model.dart';
import 'package:sixam_mart_store/features/payment/domain/models/wallet_payment_model.dart';
import 'package:sixam_mart_store/features/reels/domain/models/reel_model.dart';
import 'package:sixam_mart_store/features/reports/domain/models/earning_report_model.dart';
import 'package:sixam_mart_store/features/reports/domain/models/expense_model.dart';
import 'package:sixam_mart_store/features/reports/domain/models/tax_report_model.dart';
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
import 'package:sixam_mart_store/features/store/domain/models/pending_item_model.dart';
import 'package:sixam_mart_store/features/subscription/domain/models/subscription_transaction_model.dart';

Map<String, dynamic> page() => <String, dynamic>{
  'total': 12,
  'per_page': 10,
  'current_page': 2,
};

void main() {
  test('vendor paginated list models accept V4.2 data and pagination', () {
    final PendingItemModel pending = PendingItemModel.fromJson(
      <String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{'id': 1, 'name': 'item', 'price': 2},
        ],
        'pagination': page(),
      },
    );
    final ExpenseBodyModel expense = ExpenseBodyModel.fromJson(
      <String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{'id': 2},
        ],
        'pagination': page(),
      },
    );
    final TaxReportModel tax = TaxReportModel.fromJson(<String, dynamic>{
      'data': <Map<String, dynamic>>[
        <String, dynamic>{'id': 3},
      ],
      'pagination': page(),
    });

    expect(pending.items, hasLength(1));
    expect(pending.totalSize, 12);
    expect(pending.offset, '2');
    expect(expense.expense, hasLength(1));
    expect(expense.totalSize, 12);
    expect(tax.orders, hasLength(1));
    expect(tax.totalSize, 12);
  });

  test('vendor report transactions preserve flattened pagination', () {
    final EarningReportModel report = EarningReportModel.fromJson(
      <String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{'transaction_id': 'tx-1'},
        ],
        'pagination': page(),
      },
    );

    expect(report.transactions!.data, hasLength(1));
    expect(report.transactions!.totalSize, 12);
    expect(report.transactions!.limit, 10);
    expect(report.transactions!.offset, 2);
  });

  test('vendor secondary paginated models accept the new list key', () {
    expect(
      AdvertisementModel.fromJson(<String, dynamic>{
        'data': <dynamic>[],
        'pagination': page(),
        'statistics': <String, dynamic>{},
      }).totalSize,
      12,
    );
    expect(
      AssignableFoodModel.fromJson(<String, dynamic>{
        'data': <dynamic>[],
        'pagination': page(),
      }).foods,
      isEmpty,
    );
    expect(
      ConversationsModel.fromJson(<String, dynamic>{
        'data': <dynamic>[],
        'pagination': page(),
      }).conversations,
      isEmpty,
    );
    expect(
      MessageModel.fromJson(<String, dynamic>{
        'data': <dynamic>[],
        'pagination': page(),
        'status': '1',
      }).status,
      isTrue,
    );
    expect(
      DisbursementMethodBody.fromJson(<String, dynamic>{
        'data': <dynamic>[],
        'pagination': page(),
      }).methods,
      isEmpty,
    );
    expect(
      EditHistoryLogModel.fromJson(<String, dynamic>{
        'data': <dynamic>[],
        'pagination': page(),
      }).editLogs,
      isEmpty,
    );
    expect(
      OrderCancellationBodyModel.fromJson(<String, dynamic>{
        'data': <dynamic>[],
        'pagination': page(),
      }).data,
      isEmpty,
    );
    expect(
      WalletPaymentModel.fromJson(<String, dynamic>{
        'data': <dynamic>[],
        'pagination': page(),
      }).transactions,
      isEmpty,
    );
    expect(
      ReelsModel.fromJson(<String, dynamic>{
        'data': <dynamic>[],
        'pagination': page(),
      }).reels,
      isEmpty,
    );
    expect(
      ItemModel.fromJson(<String, dynamic>{
        'data': <dynamic>[],
        'pagination': page(),
      }).items,
      isEmpty,
    );
    expect(
      SubscriptionTransactionModel.fromJson(<String, dynamic>{
        'data': <dynamic>[],
        'pagination': page(),
      }).transactions,
      isEmpty,
    );
  });

  test('legacy vendor list keys remain supported', () {
    final PendingItemModel model = PendingItemModel.fromJson(<String, dynamic>{
      'items': <dynamic>[],
      'total_size': 0,
      'limit': 20,
      'offset': 1,
    });
    expect(model.items, isEmpty);
    expect(model.totalSize, 0);
    expect(model.offset, '1');
  });
}
