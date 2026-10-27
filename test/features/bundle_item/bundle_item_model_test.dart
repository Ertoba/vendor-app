import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart_store/features/bundle_item/controllers/bundle_item_controller.dart';
import 'package:sixam_mart_store/features/bundle_item/domain/models/bundle_item_model.dart';
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';

/// Payloads copied verbatim from the bundle API guide's captured responses, so
/// these tests fail if the parsing drifts from what the server actually sends.
void main() {
  group('GET /vendor/bundle/list', () {
    // §6.1
    final Map<String, dynamic> content = {
      'data': [
        {
          'id': 9520,
          'name': 'Family Feast Box',
          'description': 'Two favourites, one price',
          'image_full_url': null,
          'start_date': '2026-09-07 11:23:57',
          'end_date': '2026-09-14 12:23:57',
          'base_price': 490,
          'discount_percentage': 10,
          'discounted_price': 441,
          'status': 1,
          'created_by': 'admin',
          'visibility_status': 'running',
          'item_count': 2,
          'items': null,
        },
      ],
    };

    test('parses the vendor list row', () {
      final BundlePackageModel model = BundlePackageModel.fromJson(content);
      expect(model.bundles, hasLength(1));

      final BundlePackage bundle = model.bundles!.first;
      expect(bundle.id, 9520);
      expect(bundle.name, 'Family Feast Box');
      expect(bundle.basePrice, 490);
      expect(bundle.discountPercentage, 10);
      expect(bundle.discountedPrice, 441);
      expect(bundle.itemCount, 2);
      expect(bundle.visibilityStatus, 'running');
      expect(bundle.isActive, isTrue);
      expect(bundle.isCreatedByAdmin, isTrue);
    });

    test(
      'reads the price after discount from the server, not from the percentage',
      () {
        final BundlePackage bundle = BundlePackageModel.fromJson(
          content,
        ).bundles!.first;
        expect(bundle.price, 441);
        expect(bundle.discountAmount, 49);
      },
    );

    test(
      'items is null on the list endpoint, so the card falls back to item_count',
      () {
        final BundlePackage bundle = BundlePackageModel.fromJson(
          content,
        ).bundles!.first;
        expect(bundle.items, isNull);
        expect(bundle.itemImages, isEmpty);
        expect(bundle.itemCount, 2);
      },
    );
  });

  group('GET /vendor/bundle/details/{id}', () {
    // §6.3
    final Map<String, dynamic> content = {
      'id': 9520,
      'name': 'Family Feast Box',
      'base_price': 490,
      'discount_percentage': 10,
      'discounted_price': 441,
      'status': 0,
      'created_by': 'vendor',
      'visibility_status': 'not_visible',
      'item_count': 1,
      'items': [
        {
          'item_id': 101,
          'name': 'Ferrero Rocher Chocolate Box',
          'image_full_url': null,
          'unit_price': 390,
          'variation_summary': '',
          'variations': [],
          'add_on_ids': [],
          'add_on_qtys': [],
        },
      ],
    };

    test('fills items', () {
      final BundlePackage bundle = BundlePackage.fromJson(content);
      expect(bundle.items, hasLength(1));

      final BundleItem item = bundle.items!.first;
      expect(item.itemId, 101);
      expect(item.targetId, 101);
      expect(item.isService, isFalse);
      expect(item.name, 'Ferrero Rocher Chocolate Box');
      expect(item.unitPrice, 390);
      expect(item.quantity, 1);
      expect(item.variationSummary, '');
    });

    test('a line without a quantity is one', () {
      // §6.3's own capture omits the field; §4 and §9.1 both send it.
      expect(BundleItem.fromJson({'item_id': 101}).quantity, 1);
      expect(BundleItem.fromJson({'item_id': 101, 'quantity': 3}).quantity, 3);
    });

    test('status 0 reads as inactive', () {
      expect(BundlePackage.fromJson(content).isActive, isFalse);
      expect(BundlePackage.fromJson(content).isCreatedByAdmin, isFalse);
    });

    test('add-on ids and quantities are parsed as ints', () {
      final BundleItem item = BundleItem.fromJson({
        'item_id': 106,
        'add_on_ids': [3, '4'],
        'add_on_qtys': [1, 2],
      });
      expect(item.addOnIds, [3, 4]);
      expect(item.addOnQtys, [1, 2]);
    });
  });

  group('GET /vendor/bundle/items — variation shapes', () {
    test(
      'uses_food_variations false reads choice_options and variation_combinations',
      () {
        final Map<String, dynamic> json = {
          'id': 106,
          'name': 'Blue Grapes',
          'price': 100,
          'uses_food_variations': false,
          'variations': [],
          'choice_options': [
            {
              'name': 'choice_1',
              'title': 'Size',
              'options': ['Small', 'Large'],
            },
          ],
          'variation_combinations': [
            {'type': 'Small', 'price': '100', 'stock': 5},
            {'type': 'Large', 'price': '150', 'stock': 3},
          ],
        };

        /// Built directly rather than through `Item.fromJson`, which reaches for
        /// SplashController to guess a variation system — the very guess
        /// [applyBundleItemVariations] exists to override.
        final Item item = Item(id: 106, name: 'Blue Grapes', price: 100);
        applyBundleItemVariations(item, json);

        expect(item.foodVariations, isNull);
        expect(item.variations, hasLength(2));
        expect(item.variations!.first.type, 'Small');
        expect(item.variations!.last.price, 150);
        expect(item.choiceOptions, hasLength(1));
        expect(item.choiceOptions!.first.title, 'Size');
      },
    );

    test(
      'uses_food_variations true reads the named groups and drops legacy leftovers',
      () {
        final Map<String, dynamic> json = {
          'id': 107,
          'name': 'Pepperoni Pizza',
          'price': 200,
          'uses_food_variations': true,
          'variations': [
            {
              'name': 'Size',
              'type': 'single',
              'min': '1',
              'max': '1',
              'required': 'on',
              'values': [
                {'label': 'Small', 'optionPrice': '0'},
                {'label': 'Large', 'optionPrice': '50'},
              ],
            },
          ],
          'choice_options': [
            {
              'name': 'choice_1',
              'title': 'leftover',
              'options': ['a'],
            },
          ],
          'variation_combinations': [
            {'type': 'leftover', 'price': '999'},
          ],
        };

        final Item item = Item(id: 107, name: 'Pepperoni Pizza', price: 200);
        applyBundleItemVariations(item, json);

        expect(item.foodVariations, hasLength(1));
        expect(item.foodVariations!.first.name, 'Size');
        expect(item.foodVariations!.first.variationValues, hasLength(2));

        /// The legacy pair would otherwise drive the picker for a food item.
        expect(item.variations, isNull);
        expect(item.choiceOptions, isNull);
      },
    );

    test('a JSON-encoded string list is decoded rather than dropped', () {
      final Map<String, dynamic> json = {
        'id': 108,
        'name': 'Stringified',
        'price': 10,
        'uses_food_variations': false,
        'variation_combinations': '[{"type":"Small","price":"10"}]',
        'choice_options': '[]',
      };

      final Item item = Item(id: 108, name: 'Stringified', price: 10);
      applyBundleItemVariations(item, json);

      expect(item.variations, hasLength(1));
      expect(item.variations!.first.type, 'Small');
    });
  });

  group('POST /vendor/bundle/store — request body', () {
    test('matches the guide\'s multipart example', () {
      // §6.4, the documented curl call.
      final Map<String, String> body = buildBundleRequestBody(
        storeId: '3',
        startDate: '2026-09-08 12:23',
        endDate: '2026-10-07 12:23',
        discountPercentage: '15',
        names: {'default': 'Weekend Combo'},
        descriptions: {'default': 'Two of our best sellers at one price'},
        items: const [
          BundleRequestLine(targetId: 101, isService: false),
          BundleRequestLine(targetId: 106, isService: false),
        ],
      );

      expect(body, {
        'store_id': '3',
        'start_date': '2026-09-08 12:23',
        'end_date': '2026-10-07 12:23',
        'discount_percentage': '15',
        'lang[0]': 'default',
        'name[0]': 'Weekend Combo',
        'description[0]': 'Two of our best sellers at one price',
        'items[0][item_id]': '101',
        'items[0][quantity]': '1',
        'items[1][item_id]': '106',
        'items[1][quantity]': '1',
      });
    });

    test('a service line posts service_id and its variant key', () {
      // §9.3: item_id must be absent, service_id required, variant in variations.
      final Map<String, String> body = buildBundleRequestBody(
        storeId: '3',
        startDate: 'a',
        endDate: 'b',
        discountPercentage: '15',
        names: {'default': 'Home Care Combo'},
        items: const [
          BundleRequestLine(
            targetId: 3,
            isService: true,
            variantKey: 'installation',
          ),
          BundleRequestLine(targetId: 5, isService: true),
        ],
      );

      expect(body['items[0][service_id]'], '3');
      expect(body['items[0][variations][0][variant_key]'], 'installation');
      expect(body.containsKey('items[0][item_id]'), isFalse);

      /// A service with no variant sends none rather than an empty one.
      expect(body['items[1][service_id]'], '5');
      expect(body.containsKey('items[1][variations][0][variant_key]'), isFalse);
    });

    test('additional locales go in as parallel positional entries', () {
      final Map<String, String> body = buildBundleRequestBody(
        storeId: '3',
        startDate: 'a',
        endDate: 'b',
        discountPercentage: '10',
        names: {'default': 'Weekend Combo', 'bn': 'সাপ্তাহিক কম্বো'},
        items: const [
          BundleRequestLine(targetId: 1, isService: false),
          BundleRequestLine(targetId: 2, isService: false),
        ],
      );

      expect(body['lang[0]'], 'default');
      expect(body['name[0]'], 'Weekend Combo');
      expect(body['lang[1]'], 'bn');
      expect(body['name[1]'], 'সাপ্তাহিক কম্বো');
    });

    test('an empty description is omitted rather than sent blank', () {
      final Map<String, String> body = buildBundleRequestBody(
        storeId: '3',
        startDate: 'a',
        endDate: 'b',
        discountPercentage: '0',
        names: {'default': 'X'},
        descriptions: {'default': ''},
        items: const [
          BundleRequestLine(targetId: 1, isService: false),
          BundleRequestLine(targetId: 2, isService: false),
        ],
      );

      expect(body.containsKey('description[0]'), isFalse);
    });

    test('quantity rides inside one entry rather than repeating it', () {
      final Map<String, String> body = buildBundleRequestBody(
        storeId: '3',
        startDate: 'a',
        endDate: 'b',
        discountPercentage: '0',
        names: {'default': 'X'},
        items: const [
          BundleRequestLine(targetId: 101, isService: false, quantity: 3),
          BundleRequestLine(targetId: 106, isService: false),
        ],
      );

      expect(body['items[0][item_id]'], '101');
      expect(body['items[0][quantity]'], '3');
      expect(body['items[1][item_id]'], '106');
      expect(body['items[1][quantity]'], '1');

      /// Two entries, not four — the 2–50 rule counts entries.
      expect(body.keys.where((key) => key.startsWith('items[')), hasLength(4));
    });

    test('prices are never sent — the server computes them', () {
      final Map<String, String> body = buildBundleRequestBody(
        storeId: '3',
        startDate: 'a',
        endDate: 'b',
        discountPercentage: '15',
        names: {'default': 'X'},
        items: const [
          BundleRequestLine(targetId: 1, isService: false),
          BundleRequestLine(targetId: 2, isService: false),
        ],
      );

      expect(body.containsKey('base_price'), isFalse);
      expect(body.containsKey('discounted_price'), isFalse);
      expect(body.containsKey('bundle_price'), isFalse);
    });
  });

  _cardImageTests();
  _moduleGateTests();
  _serviceBundleTests();

  group('selection identity and preview pricing', () {
    BundleSelectedItem selection({
      int id = 1,
      String variation = '',
      List<int> addOnIds = const [],
      List<int> addOnQtys = const [],
    }) {
      return BundleSelectedItem(
        item: Item(id: id, name: 'Item $id'),
        unitPrice: 100,
        variationSummary: variation,
        addOnIds: addOnIds,
        addOnQtys: addOnQtys,
      );
    }

    test('the same item with the same options is one selection', () {
      expect(
        selection(variation: 'Size: Small').selectionKey,
        selection(variation: 'Size: Small').selectionKey,
      );
    });

    test('the same item with different options is a different selection', () {
      expect(
        selection(variation: 'Size: Small').selectionKey,
        isNot(selection(variation: 'Size: Large').selectionKey),
      );
      expect(
        selection(addOnIds: [3], addOnQtys: [1]).selectionKey,
        isNot(selection(addOnIds: [3], addOnQtys: [2]).selectionKey),
      );
    });

    test('add-on order does not change identity', () {
      expect(
        selection(addOnIds: [3, 4], addOnQtys: [1, 2]).selectionKey,
        selection(addOnIds: [4, 3], addOnQtys: [2, 1]).selectionKey,
      );
    });

    test('the line total follows the quantity', () {
      final BundleSelectedItem item = selection()..quantity = 3;
      expect(item.lineTotal, 300);
    });

    test('the discount preview matches the server example', () {
      // §6.4: 490 base at 15 percent comes back as 416.5.
      expect(calculateBundlePrice(490, 15), 416.5);
      // §6.5: the same bundle at 25 percent comes back as 367.5.
      expect(calculateBundlePrice(490, 25), 367.5);
      // §6.1: 490 at 10 percent is 441.
      expect(calculateBundlePrice(490, 10), 441);
    });

    test('the preview never goes negative', () {
      expect(calculateBundlePrice(100, 200), 0);
    });
  });
}

/// The list card's thumbnails. `GET /vendor/bundle/list` sends `items: null`,
/// so a card that only reads the member images has nothing to draw — these pin
/// the fallback that keeps a picture on every row.
void _cardImageTests() {
  group('card thumbnails', () {
    test('a list row falls back to the bundle own thumbnail', () {
      final BundlePackage bundle = BundlePackage.fromJson({
        'id': 9520,
        'image_full_url': 'https://example.test/bundle.webp',
        'item_count': 2,
        'items': null,
      });

      expect(bundle.itemImages, isEmpty);
      expect(bundle.cardImages, ['https://example.test/bundle.webp']);
      expect(bundle.isShowingOwnThumbnail, isTrue);
    });

    test('a details payload uses the member items thumbnails', () {
      final BundlePackage bundle = BundlePackage.fromJson({
        'id': 9520,
        'image_full_url': 'https://example.test/bundle.webp',
        'item_count': 2,
        'items': [
          {'item_id': 1, 'image_full_url': 'https://example.test/a.png'},
          {'item_id': 2, 'image_full_url': 'https://example.test/b.png'},
        ],
      });

      expect(bundle.cardImages, [
        'https://example.test/a.png',
        'https://example.test/b.png',
      ]);
      expect(bundle.isShowingOwnThumbnail, isFalse);
    });

    test(
      'members without an image of their own are skipped, not drawn empty',
      () {
        final BundlePackage bundle = BundlePackage.fromJson({
          'id': 1,
          'image_full_url': 'https://example.test/bundle.webp',
          'items': [
            {'item_id': 1, 'image_full_url': null},
            {'item_id': 2, 'image_full_url': 'https://example.test/b.png'},
          ],
        });

        expect(bundle.cardImages, ['https://example.test/b.png']);
      },
    );

    test('a bundle with no thumbnail at all reports no images', () {
      // The guide's own §6.1 capture has image_full_url null.
      final BundlePackage bundle = BundlePackage.fromJson({
        'id': 9520,
        'image_full_url': null,
        'item_count': 2,
        'items': null,
      });

      expect(bundle.cardImages, isEmpty);
      expect(bundle.isShowingOwnThumbnail, isTrue);
    });
  });
}

/// Which store modules reach the bundle screens at all.
void _moduleGateTests() {
  group('supported module types', () {
    test('covers the item-priced modules', () {
      expect(
        BundleItemController.supportedModuleTypes,
        containsAll(['grocery', 'pharmacy', 'ecommerce', 'food']),
      );
    });

    test('excludes the modules with no per-item price to sum', () {
      for (final String moduleType in ['parcel', 'rental', 'ride-share']) {
        expect(
          BundleItemController.supportedModuleTypes,
          isNot(contains(moduleType)),
          reason: moduleType,
        );
      }
    });

    test('includes service', () {
      /// §9: a service bundle answers on the same endpoints, posting
      /// `service_id` where an item bundle posts `item_id`.
      expect(BundleItemController.supportedModuleTypes, contains('service'));
    });
  });
}

/// Service bundles — §9 of the API guide.
void _serviceBundleTests() {
  group('service bundles', () {
    test('a line names a service, with is_service saying so', () {
      // §9.1, captured.
      final BundleItem line = BundleItem.fromJson({
        'item_id': null,
        'service_id': 3,
        'is_service': true,
        'name': 'Fridge Service',
        'image_full_url': null,
        'unit_price': 100,
        'quantity': 1,
        'variation_summary': '',
        'variations': [],
        'add_on_ids': [],
        'add_on_qtys': [],
      });

      expect(line.isService, isTrue);
      expect(line.serviceId, 3);
      expect(line.itemId, isNull);
      expect(line.targetId, 3);
      expect(line.unitPrice, 100);

      /// A service carries no add-ons.
    });

    test('a service row is recognised even without the is_service flag', () {
      final BundleItem line = BundleItem.fromJson({
        'service_id': 7,
        'name': 'X',
      });
      expect(line.isService, isTrue);
      expect(line.targetId, 7);
    });

    test('a variant carries the key the request has to send back', () {
      // §9.2, captured.
      final BundleServiceVariant variant = BundleServiceVariant.fromJson({
        'variant_key': 'installation',
        'name': 'Installation',
        'price': 150,
        'discount': 30,
        'discount_type': 'amount',
      });

      expect(variant.variantKey, 'installation');
      expect(variant.name, 'Installation');

      /// The gross figure — a bundle is already the promotion, so the service's
      /// own discount is not taken as well.
      expect(variant.price, 150);
    });

    test('a chosen label resolves back to its variant key', () {
      final BundleCatalogueItem row = BundleCatalogueItem(
        item: Item(id: 2, name: 'AC Service'),
        isAvailable: true,
        isService: true,
        requiresVariant: true,
        variants: const [
          BundleServiceVariant(
            variantKey: 'basic-maintenance',
            name: 'Basic Maintenance',
            price: 50,
          ),
          BundleServiceVariant(
            variantKey: 'installation',
            name: 'Installation',
            price: 150,
          ),
        ],
      );

      expect(row.variantNamed('Installation')?.variantKey, 'installation');
      expect(row.variantNamed('Nothing Like It'), isNull);
    });

    test('a service and an item sharing an id are different selections', () {
      BundleSelectedItem of({required bool isService}) => BundleSelectedItem(
        item: Item(id: 3, name: 'Three'),
        unitPrice: 100,
        isService: isService,
      );

      expect(
        of(isService: true).selectionKey,
        isNot(of(isService: false).selectionKey),
      );
    });

    test('the same service under different variants is two selections', () {
      BundleSelectedItem of(String key) => BundleSelectedItem(
        item: Item(id: 3, name: 'AC Service'),
        unitPrice: 100,
        isService: true,
        variantKey: key,
      );

      expect(
        of('installation').selectionKey,
        isNot(of('basic-maintenance').selectionKey),
      );
      expect(of('installation').selectionKey, of('installation').selectionKey);
    });
  });
}
