import 'dart:convert';

import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';

/// A page of the store's bundles, from `GET /vendor/bundle/list`.
///
/// `offset` is a 1-based page number despite its name, and the page info comes
/// back in the envelope's `pagination` block rather than in the payload.
class BundlePackageModel {
  int? totalSize;
  int? currentPage;
  int? lastPage;
  List<BundlePackage>? bundles;

  BundlePackageModel({this.totalSize, this.currentPage, this.lastPage, this.bundles});

  BundlePackageModel.fromJson(Map<String, dynamic> json) {
    final dynamic rows = json['data'];
    if(rows is List) {
      bundles = rows.whereType<Map>().map((row) => BundlePackage.fromJson(Map<String, dynamic>.from(row))).toList();
    }
  }
}

/// One bundle as the vendor sees it — the shape shared by `/vendor/bundle/list`,
/// `/vendor/bundle/details/{id}` and the create/update responses.
///
/// The vendor shape is not the customer one: the price after discount is
/// `discounted_price` (the customer's is `final_price`), and there are no
/// happy-hour fields, because a vendor is looking at what they built rather
/// than at today's price.
class BundlePackage {
  int? id;
  String? name;
  String? description;
  String? imageFullUrl;
  String? startDate;
  String? endDate;
  double? basePrice;
  double? discountPercentage;
  double? discountedPrice;
  int? status;
  String? createdBy;
  String? visibilityStatus;
  int? itemCount;
  List<BundleItem>? items;

  /// Every locale's `name` / `description` row, as the details endpoint sends
  /// them alongside the columns already resolved through the request's
  /// `X-localization`. The edit form fills one tab per language from these.
  List<Translation>? translations;

  BundlePackage({
    this.id, this.name, this.description, this.imageFullUrl, this.startDate, this.endDate,
    this.basePrice, this.discountPercentage, this.discountedPrice, this.status, this.createdBy,
    this.visibilityStatus, this.itemCount, this.items, this.translations,
  });

  BundlePackage.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    name = json['name']?.toString();
    description = json['description']?.toString();
    imageFullUrl = json['image_full_url']?.toString();
    startDate = json['start_date']?.toString();
    endDate = json['end_date']?.toString();
    basePrice = _asDouble(json['base_price']);
    discountPercentage = _asDouble(json['discount_percentage']);
    discountedPrice = _asDouble(json['discounted_price']);
    status = _asInt(json['status']);
    createdBy = json['created_by']?.toString();
    visibilityStatus = json['visibility_status']?.toString();
    itemCount = _asInt(json['item_count']);

    /// Null on the list endpoints, filled on details and on a create/update reply.
    final dynamic rows = json['items'];
    if(rows is List) {
      items = rows.whereType<Map>().map((row) => BundleItem.fromJson(Map<String, dynamic>.from(row))).toList();
    }

    /// Sent on details and on a create/update reply; absent on the list.
    final dynamic translationRows = json['translations'];
    if(translationRows is List) {
      translations = translationRows.whereType<Map>()
          .map((row) => Translation.fromJson(Map<String, dynamic>.from(row))).toList();
    }
  }

  /// Locale -> value for one translated column, e.g. `name` or `description`.
  ///
  /// Empty rows are dropped rather than kept as blanks: a blank would overwrite
  /// the field it was meant to preserve when the form posts it back.
  Map<String, String> translationsFor(String key) {
    final Map<String, String> values = {};
    for(final Translation row in translations ?? const <Translation>[]) {
      final String locale = row.locale ?? '';
      final String value = row.value ?? '';
      if(row.key == key && locale.isNotEmpty && value.isNotEmpty) {
        values[locale] = value;
      }
    }
    return values;
  }

  bool get isActive => status == 1;

  /// Admin-built bundles are still fully editable by the store, so this only
  /// labels where the bundle came from.
  bool get isCreatedByAdmin => createdBy == 'admin';

  double get price => discountedPrice ?? basePrice ?? 0;

  /// Server-computed, so it is never re-derived here.
  double get discountAmount => (basePrice ?? 0) - price;

  List<String> get itemImages => (items ?? const <BundleItem>[])
      .map((item) => item.imageFullUrl ?? '').where((image) => image.isNotEmpty).toList();

  List<String> get cardImages {
    final List<String> images = itemImages;
    if(images.isNotEmpty) {
      return images;
    }
    return (imageFullUrl ?? '').isNotEmpty ? [imageFullUrl!] : const [];
  }

  bool get isShowingOwnThumbnail => itemImages.isEmpty;

  String get validity {
    final String start = _readableDate(startDate);
    final String end = _readableDate(endDate);
    if(start.isEmpty || end.isEmpty) {
      return start.isEmpty ? end : start;
    }
    return '$start  ~  $end';
  }

  static String _readableDate(String? raw) {
    if(raw == null || raw.trim().isEmpty) {
      return '';
    }
    try {
      return DateConverterHelper.dateTimeStringToDateTime(raw);
    } catch(_) {
      return raw;
    }
  }
}

/// One member of a bundle, from the `items[]` the details endpoint fills in.
///
/// `unit_price` is the price frozen when the bundle was built, so it can differ
/// from the item's price in the picker catalogue today. That is deliberate — the
/// bundle is billed on what it was priced at.
class BundleItem {
  int? itemId;
  int? serviceId;
  bool isService = false;
  String? name;
  String? imageFullUrl;
  double? unitPrice;
  int? quantity;
  String? variationSummary;
  String? addOnSummary;
  List<Map<String, dynamic>>? variations;
  List<int>? addOnIds;
  List<int>? addOnQtys;

  BundleItem({
    this.itemId, this.serviceId, this.isService = false, this.name, this.imageFullUrl, this.unitPrice,
    this.quantity, this.variationSummary, this.addOnSummary, this.variations, this.addOnIds, this.addOnQtys,
  });

  BundleItem.fromJson(Map<String, dynamic> json) {
    /// A line names exactly one target: `item_id` or `service_id`, with
    /// `is_service` saying which. The database enforces it with a CHECK, so a
    /// row carrying both or neither should never arrive.
    itemId = _asInt(json['item_id']);
    serviceId = _asInt(json['service_id']);
    isService = json['is_service'] == true || (itemId == null && serviceId != null);
    name = json['name']?.toString();
    imageFullUrl = json['image_full_url']?.toString();
    unitPrice = _asDouble(json['unit_price']);
    quantity = _asInt(json['quantity']) ?? 1;
    variationSummary = json['variation_summary']?.toString();
    addOnSummary = json['add_on_summary']?.toString();
    variations = decodeMapList(json['variations']);
    /// Always empty for a service — a service carries no add-ons.
    addOnIds = _intList(json['add_on_ids']);
    addOnQtys = _intList(json['add_on_qtys']);
  }

  /// Whichever of the two ids this line actually names.
  int? get targetId => isService ? serviceId : itemId;

}

/// One row of the picker catalogue, from `GET /vendor/bundle/items`.
///
/// Unavailable rows are returned rather than filtered out, so the picker can
/// grey them instead of leaving the vendor wondering whether the row is missing
/// or ineligible.
///
/// In a service module the endpoint answers with services, whose shape has no
/// `stock`, `add_ons`, `choice_options` or `uses_food_variations` — a service
/// offers [variants] instead, and [requiresVariant] says whether one must be
/// picked.
class BundleCatalogueItem {
  final Item item;
  final bool isAvailable;
  final bool isService;
  final bool requiresVariant;
  final List<BundleServiceVariant> variants;

  const BundleCatalogueItem({
    required this.item, required this.isAvailable,
    this.isService = false, this.requiresVariant = false, this.variants = const [],
  });

  /// The variant whose name matches [name], for turning a chosen label back into
  /// the `variant_key` the API wants.
  BundleServiceVariant? variantNamed(String name) {
    for(final BundleServiceVariant variant in variants) {
      if(variant.name == name) {
        return variant;
      }
    }
    return null;
  }
}

/// One choice a service offers.
///
/// The line freezes at the variant's `price` — the **gross** figure. A bundle is
/// already the promotion, so the service's own discount is not taken as well.
class BundleServiceVariant {
  final String variantKey;
  final String name;
  final double price;

  const BundleServiceVariant({required this.variantKey, required this.name, required this.price});

  factory BundleServiceVariant.fromJson(Map<String, dynamic> json) {
    return BundleServiceVariant(
      variantKey: json['variant_key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: _asDouble(json['price']) ?? 0,
    );
  }
}

/// One item the vendor has picked for a bundle they are still building.
///
/// The raw fields mirror the details endpoint's `items[]` exactly, so a bundle
/// opened for editing round-trips untouched.
class BundleSelectedItem {
  final Item item;
  final double unitPrice;
  final String variationSummary;
  final List<Map<String, dynamic>> variations;
  final List<int> addOnIds;
  final List<int> addOnQtys;
  final List<String> addOnNames;

  /// A service line posts `service_id` where an item line posts `item_id`, and
  /// carries a `variant_key` instead of variation groups and add-ons.
  final bool isService;
  final String? variantKey;

  int quantity;

  BundleSelectedItem({
    required this.item, required this.unitPrice, this.variationSummary = '', this.quantity = 1,
    this.variations = const [], this.addOnIds = const [], this.addOnQtys = const [], this.addOnNames = const [],
    this.isService = false, this.variantKey,
  });

  double get lineTotal => unitPrice * quantity;

  /// "Tomato Sauce x1" — built from the names the picker knew, so a line
  /// restored from the details endpoint (ids only) shows counts instead.
  String get addOnSummary {
    if(addOnIds.isEmpty) {
      return '';
    }
    if(addOnNames.length == addOnIds.length) {
      return List.generate(addOnIds.length, (index) => '${addOnNames[index]} x${addOnQtys[index]}').join(', ');
    }
    return List.generate(addOnIds.length, (index) => 'x${addOnQtys[index]}').join(', ');
  }

  /// Identifies the exact combination, so picking the same row twice with the
  /// same options bumps its quantity instead of creating a duplicate line.
  ///
  /// The target kind is part of it: a service and an item can share an id
  /// without being the same thing.
  String get selectionKey {
    final List<String> addOnKeys = List.generate(addOnIds.length, (index) => '${addOnIds[index]}:${addOnQtys[index]}')..sort();
    return '${isService ? 'service' : 'item'}:${item.id}|${variantKey ?? ''}|$variationSummary|${addOnKeys.join(',')}';
  }

  /// One `items[]` entry, as [buildBundleRequestBody] posts it.
  BundleRequestLine toRequestLine() {
    return BundleRequestLine(
      targetId: item.id ?? 0,
      isService: isService,
      quantity: quantity,
      variantKey: variantKey,
      /// A service carries no variations/add-ons of its own — its chosen variant
      /// travels as [variantKey] instead. See the comment in
      /// [buildBundleRequestBody].
      variations: isService ? const [] : variations,
      addOnIds: isService ? const [] : addOnIds,
      addOnQtys: isService ? const [] : addOnQtys,
    );
  }
}

/// The client-side preview of what the discount does. The server recomputes both
/// figures from the items and the percentage on save, and its numbers are the
/// ones kept — this only keeps the form's fields moving as the vendor types.
double calculateBundlePrice(double basePrice, double discountPercent) {
  final double discounted = basePrice - (basePrice * discountPercent / 100);
  return discounted < 0 ? 0 : discounted;
}

int? _asInt(dynamic value) {
  if(value is int) return value;
  if(value is double) return value.toInt();
  if(value is String) return int.tryParse(value);
  return null;
}

double? _asDouble(dynamic value) {
  if(value is double) return value;
  if(value is int) return value.toDouble();
  if(value is String) return double.tryParse(value);
  return null;
}

List<int> _intList(dynamic raw) {
  if(raw is! List) {
    return const [];
  }
  return raw.map(_asInt).whereType<int>().toList();
}

/// Lists arrive as JSON arrays, or as a JSON-encoded string on columns cast to text.
List<Map<String, dynamic>> decodeMapList(dynamic raw) {
  dynamic decoded = raw;
  if(raw is String && raw.trim().isNotEmpty) {
    try {
      decoded = jsonDecode(raw);
    } catch(_) {
      return const [];
    }
  }
  if(decoded is! List) {
    return const [];
  }
  return decoded.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList();
}

/// One `items[]` entry of a create or update request.
class BundleRequestLine {
  final int targetId;
  final bool isService;
  final int quantity;
  final String? variantKey;
  final List<Map<String, dynamic>> variations;
  final List<int> addOnIds;
  final List<int> addOnQtys;

  const BundleRequestLine({
    required this.targetId, required this.isService, this.quantity = 1, this.variantKey,
    this.variations = const [], this.addOnIds = const [], this.addOnQtys = const [],
  });
}

/// Builds the multipart fields for `POST /vendor/bundle/store` and
/// `/vendor/bundle/update/{id}`.
///
/// PHP's `lang[]` / `name[]` / `items[][item_id]` arrays are expressed as indexed
/// keys, which is the only way a `Map<String, String>` of multipart fields can
/// carry them — the same convention the service module already uses.
///
/// [names] and [descriptions] are keyed by locale and stay positional with each
/// other. A locale that is not sent falls back to the default-language column
/// rather than to another language's row, so every locale is worth sending.
///
/// Each line names exactly one target — `item_id` or `service_id`, never both,
/// which the database enforces with a `bundle_items_one_target` CHECK.
///
/// TODO: `items[].quantity`, `items[].variations` and `items[].add_on_ids` /
/// `items[].add_on_qtys` are not in §6.4's parameter table, though all of them
/// come back on reads — `quantity` in the `/bundle/{id}` and §9.1 payloads,
/// `variant_key` in §9.3's mapping, `variations` / `add_on_ids` / `add_on_qtys`
/// on regular item lines in the same payloads. The field names and the
/// `items[i][variations][j][name]` / `items[i][variations][j][values][label][k]`
/// nesting below are guessed from the read shape and from the sibling BOGO
/// offer feature's JSON body (`bogo_offer_setup_screen.dart`), which posts the
/// same `BogoSelectedItemResult` data as `variations` / `variation_options` /
/// `add_on_ids` / `add_on_qtys`. Verify against a live server that a quantity
/// above 1 is honoured, that the variant key lands, and that a chosen
/// variation / add-on on a regular item line is actually saved rather than
/// silently ignored.
Map<String, String> buildBundleRequestBody({
  required String storeId,
  required String startDate,
  required String endDate,
  required String discountPercentage,
  required Map<String, String> names,
  Map<String, String> descriptions = const {},
  required List<BundleRequestLine> items,
}) {
  final Map<String, String> body = {
    'store_id': storeId,
    'start_date': startDate,
    'end_date': endDate,
    'discount_percentage': discountPercentage,
  };

  final List<String> locales = names.keys.toList();
  for(int index = 0; index < locales.length; index++) {
    final String locale = locales[index];
    body['lang[$index]'] = locale;
    body['name[$index]'] = names[locale] ?? '';
    /// `description[]` is optional, and an empty entry would blank a description
    /// written elsewhere — so it is only sent where there is one.
    final String description = descriptions[locale] ?? '';
    if(description.isNotEmpty) {
      body['description[$index]'] = description;
    }
  }

  for(int index = 0; index < items.length; index++) {
    final BundleRequestLine line = items[index];
    body['items[$index][${line.isService ? 'service_id' : 'item_id'}]'] = '${line.targetId}';
    body['items[$index][quantity]'] = '${line.quantity}';

    /// A service's chosen variant travels as the first `variations` entry.
    /// Add-ons are not accepted on a service line at all.
    if(line.isService && (line.variantKey ?? '').isNotEmpty) {
      body['items[$index][variations][0][variant_key]'] = line.variantKey!;
    }

    /// A regular item's chosen food-style variation groups — see the TODO above
    /// for why this shape is a guess.
    for(int groupIndex = 0; groupIndex < line.variations.length; groupIndex++) {
      final Map<String, dynamic> variation = line.variations[groupIndex];
      final String? name = variation['name']?.toString();
      if(name != null && name.isNotEmpty) {
        body['items[$index][variations][$groupIndex][name]'] = name;
      }
      final dynamic values = variation['values'];
      final List<dynamic> labels = values is Map ? (values['label'] as List<dynamic>? ?? const []) : const [];
      for(int labelIndex = 0; labelIndex < labels.length; labelIndex++) {
        body['items[$index][variations][$groupIndex][values][label][$labelIndex]'] = '${labels[labelIndex]}';
      }
    }

    for(int addOnIndex = 0; addOnIndex < line.addOnIds.length; addOnIndex++) {
      body['items[$index][add_on_ids][$addOnIndex]'] = '${line.addOnIds[addOnIndex]}';
      body['items[$index][add_on_qtys][$addOnIndex]'] = '${addOnIndex < line.addOnQtys.length ? line.addOnQtys[addOnIndex] : 1}';
    }
  }

  return body;
}


/// Rebuilds an [Item]'s variation lists from a `/vendor/bundle/items` row.
///
/// The endpoint sends **both** variation shapes and lets `uses_food_variations`
/// say which one to read, while [Item.fromJson] instead guesses from the store's
/// module and parses whatever sits in `variations`. Left alone that turns a food
/// group into a legacy row whose `type` is the group's select mode, so the
/// picker offers a single option called "single" or "multi".
///
/// Rendering only the food shape is the other half of the trap: a grocery or
/// pharmacy item would then show no options and price at base.
void applyBundleItemVariations(Item item, Map<String, dynamic> json) {
  if(json['uses_food_variations'] == true) {
    item.foodVariations = decodeMapList(json['variations']).map(FoodVariation.fromJson).toList();
    /// A food item can still carry the legacy pair as leftovers, and it would
    /// otherwise drive the picker instead.
    item.variations = null;
    item.choiceOptions = null;
    return;
  }

  item.foodVariations = null;
  item.variations = decodeMapList(json['variation_combinations'])
      .map(_normaliseVariationRow).map(Variation.fromJson).toList();
  item.choiceOptions = decodeMapList(json['choice_options']).map(ChoiceOptions.fromJson).toList();
}

/// `Variation.fromJson` calls `.toDouble()` on `price` and reads `stock` as an
/// int, both of which throw when the column is cast to text and the value
/// arrives quoted. The row is coerced here rather than in the shared model,
/// which every other feature parses through.
Map<String, dynamic> _normaliseVariationRow(Map<String, dynamic> row) {
  return {
    ...row,
    'price': _asDouble(row['price']) ?? 0.0,
    'stock': _asInt(row['stock']),
  };
}
