import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_model.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_details_model.dart';

// The default Flutter counter-template test never matched the MILI vendor app.
// These regression tests exercise actual V4.2 payloads used by Vendor screens.
void main() {
  test('V4.2 vendor order ETA round-trips with order status', () {
    final order = OrderModel.fromJson(<String, dynamic>{
      'id': 100275,
      'order_type': 'delivery',
      'order_status': 'pending',
      'eta': <String, dynamic>{
        'overdue': false,
        'from_at': '2026-10-21T13:00:00',
        'window': '13:00–13:30',
      },
    });
    expect(order.id, 100275);
    expect(order.eta?.window, '13:00–13:30');
    expect(order.eta?.overdue, isFalse);
    expect((order.toJson()['eta'] as Map<String, dynamic>)['from_at'],
        '2026-10-21T13:00:00');
  });

  test('BOGO and bundle details round-trip through V4.2 models', () {
    final bogo = OrderDetailsModel.fromJson(<String, dynamic>{
      'id': 12,
      'bogo_offer_id': 8,
      'bogo_group_id': 'bogo-8',
      'is_free_item': 1,
    });
    expect(bogo.isBogoItem, isTrue);
    expect(bogo.isFree, isTrue);
    expect(bogo.isBundleItem, isFalse);
    expect(bogo.toJson()['bogo_group_id'], 'bogo-8');

    final bundle = OrderDetailsModel.fromJson(<String, dynamic>{
      'id': 13,
      'bundle_id': '27',
      'bundle_group_id': 'bundle-27',
      'bundle_name': 'MILI offer',
    });
    expect(bundle.isBogoItem, isFalse);
    expect(bundle.isBundleItem, isTrue);
    expect(bundle.bundleId, 27);
    expect(bundle.toJson()['bundle_name'], 'MILI offer');
  });
}
