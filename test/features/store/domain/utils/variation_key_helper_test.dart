import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart_store/features/store/domain/models/attr.dart';
import 'package:sixam_mart_store/features/store/domain/models/attribute_model.dart';
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

  test(
    'filters the mixed brand and model combinations from the screenshot',
    () {
      final attributes = <AttributeModel>[
        _attribute('ფერი', <String>['თეთრი', 'შავი']),
        _attribute('ბრენდი', <String>['IPHONE', 'SAMSUNG']),
        _attribute('მოდელი', <String>['11 PRO', 'A23']),
      ];

      final combinations = buildVariationCombinations(attributes);
      final visible = combinations
          .where((combination) => combination.isBrandModelCompatible)
          .map((combination) => combination.type)
          .toList();

      expect(combinations, hasLength(8));
      expect(visible, <String>[
        'თეთრი-IPHONE-11 PRO',
        'თეთრი-SAMSUNG-A23',
        'შავი-IPHONE-11 PRO',
        'შავი-SAMSUNG-A23',
      ]);
    },
  );

  test('reports ambiguous models instead of creating a wrong brand pair', () {
    final attributes = <AttributeModel>[
      _attribute('ბრენდი', <String>['IPHONE', 'SAMSUNG']),
      _attribute('მოდელი', <String>['Unknown']),
    ];

    expect(findUnresolvedTechnicalModels(attributes), <String>['Unknown']);
  });
}

AttributeModel _attribute(String name, List<String> variants) {
  return AttributeModel(
    attribute: Attr(name: name),
    active: true,
    controller: TextEditingController(),
    variants: variants,
  );
}
