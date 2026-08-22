import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart_store/features/store/domain/utils/variation_key_helper.dart';

void main() {
  test('readable labels use the backend canonical variation key', () {
    expect(canonicalVariationType('iPhone 15 Pro - შავი'), 'iPhone15Pro-შავი');
    expect(
      variationRequestKey('iPhone 15 Pro - 6.7 inch'),
      'iPhone15Pro-6_7inch',
    );
  });

  test('stored and readable variation types resolve to the same SKU', () {
    const stored = 'iPhone15Pro-შავი';
    const readable = 'iPhone 15 Pro-შავი';

    expect(canonicalVariationType(stored), canonicalVariationType(readable));
  });
}
