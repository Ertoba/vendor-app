import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_model.dart';

// Replaces the generated Flutter counter test, which instantiated MyApp
// without the production GetX dependency graph and did not test Vendor V4.2.
void main() {
  test('Vendor V4.2 decodes and persists delivery ETA from order API', () {
    final OrderModel order = OrderModel.fromJson(<String, dynamic>{
      'id': 10,
      'order_type': 'delivery',
      'eta': <String, dynamic>{
        'min': 20,
        'max': 35,
        'unit': 'minute',
        'overdue': false,
        'window': '12:20 - 12:35',
        'from_at': '2026-10-25T12:20:00+04:00',
        'to_at': '2026-10-25T12:35:00+04:00',
      },
    });

    expect(order.eta?.min, 20);
    expect(order.eta?.max, 35);
    expect(order.eta?.overdue, false);
    expect(order.eta?.window, '12:20 - 12:35');
    expect((order.toJson()['eta'] as Map)['from_at'], '2026-10-25T12:20:00+04:00');

    final OrderModel withoutEta = OrderModel.fromJson(<String, dynamic>{
      'id': 11,
      'order_type': 'take_away',
    });
    expect(withoutEta.eta, isNull);
  });

  test('Vendor V4.2 keeps BOGO and Bundle order-item API fields', () {
    final OrderDetailsModel bogo = OrderDetailsModel.fromJson(<String, dynamic>{
      'id': 21,
      'bogo_offer_id': 4,
      'bogo_group_id': 'group-1',
      'is_free_item': 1,
    });
    expect(bogo.isBogoItem, isTrue);
    expect(bogo.isFree, isTrue);
    expect(bogo.isBundleItem, isFalse);
    expect(bogo.toJson()['bogo_group_id'], 'group-1');

    final OrderDetailsModel bundle = OrderDetailsModel.fromJson(<String, dynamic>{
      'id': 22,
      'bundle_id': 7,
      'bundle_group_id': 'bundle-7',
      'bundle_name': 'Family pack',
    });
    expect(bundle.isBundleItem, isTrue);
    expect(bundle.isBogoItem, isFalse);
    expect(bundle.toJson()['bundle_name'], 'Family pack');
  });
}
