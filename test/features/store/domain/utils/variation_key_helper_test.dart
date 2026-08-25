import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart_store/features/store/domain/models/attr.dart';
import 'package:sixam_mart_store/features/store/domain/models/attribute_model.dart';
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
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

  test('vendor details keep only compatible stored variations', () {
    final item = Item(
      choiceOptions: <ChoiceOptions>[
        ChoiceOptions(title: 'ბრენდი', options: <String>['IPHONE', 'SAMSUNG']),
        ChoiceOptions(
          title: 'მოდელი',
          options: <String>['IPHONE15PRO', 'SAMSUNGA16'],
        ),
        ChoiceOptions(title: 'ფერი', options: <String>['შავი']),
      ],
      variations: <Variation>[
        Variation(type: 'IPHONE-IPHONE15PRO-შავი', stock: 3),
        Variation(type: 'IPHONE-SAMSUNGA16-შავი', stock: 0),
        Variation(type: 'SAMSUNG-IPHONE15PRO-შავი', stock: 0),
        Variation(type: 'SAMSUNG-SAMSUNGA16-შავი', stock: 4),
      ],
    );

    expect(compatibleTechnicalVariationIndexes(item), <int>[0, 3]);
  });

  test('vendor details filter the four-brand production matrix', () {
    const brands = <String>['IPHONE', 'SAMSUNG', 'REDMI', 'POCO'];
    const models = <String>[
      'IPHONE15PRO',
      'SAMSUNGA16',
      'REDMINOTE12s',
      'POCOC23',
    ];
    final variations = <Variation>[];
    for (final brand in brands) {
      for (final model in models) {
        variations.add(Variation(type: '$brand-$model-შავი', stock: 0));
      }
    }
    final item = Item(
      choiceOptions: <ChoiceOptions>[
        ChoiceOptions(title: 'ბრენდი', options: brands),
        ChoiceOptions(title: 'მოდელი', options: models),
        ChoiceOptions(title: 'ფერი', options: const <String>['შავი']),
      ],
      variations: variations,
    );

    expect(compatibleTechnicalVariationIndexes(item), <int>[0, 5, 10, 15]);
  });

  test('vendor details preserve legacy variations when a model is unresolved', () {
    final item = Item(
      choiceOptions: <ChoiceOptions>[
        ChoiceOptions(title: 'Brand', options: <String>['HUAWEI', 'HONOR']),
        ChoiceOptions(title: 'Model', options: <String>['Nova', 'Magic']),
      ],
      variations: <Variation>[
        Variation(type: 'HUAWEI-Nova', stock: 2),
        Variation(type: 'HUAWEI-Magic', stock: 0),
        Variation(type: 'HONOR-Nova', stock: 0),
        Variation(type: 'HONOR-Magic', stock: 3),
      ],
    );

    expect(compatibleTechnicalVariationIndexes(item), <int>[0, 1, 2, 3]);
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
