import 'package:sixam_mart_store/features/store/domain/models/attribute_model.dart';

class VariationCombination {
  final String type;
  final bool isBrandModelCompatible;

  const VariationCombination({
    required this.type,
    required this.isBrandModelCompatible,
  });
}

String canonicalVariationType(String value) {
  return value.replaceAll(RegExp(r'\s+'), '');
}

String variationRequestKey(String value) {
  return canonicalVariationType(value).replaceAll('.', '_');
}

List<VariationCombination> buildVariationCombinations(
  List<AttributeModel>? attributes,
) {
  final List<AttributeModel> activeAttributes =
      (attributes ?? <AttributeModel>[])
          .where((attribute) => attribute.active)
          .toList(growable: false);
  if (activeAttributes.isEmpty ||
      activeAttributes.any((attribute) => attribute.variants.isEmpty)) {
    return <VariationCombination>[];
  }

  final int brandIndex = activeAttributes.indexWhere(
    (attribute) => isTechnicalBrandAttribute(attribute.attribute.name),
  );
  final int modelIndex = activeAttributes.indexWhere(
    (attribute) => isTechnicalModelAttribute(attribute.attribute.name),
  );
  final List<String> brands = brandIndex == -1
      ? <String>[]
      : activeAttributes[brandIndex].variants;
  final List<int> indexes = List<int>.filled(activeAttributes.length, 0);
  final int combinationCount = activeAttributes.fold<int>(
    1,
    (count, attribute) => count * attribute.variants.length,
  );
  final List<VariationCombination> combinations = <VariationCombination>[];

  for (
    int combinationIndex = 0;
    combinationIndex < combinationCount;
    combinationIndex++
  ) {
    final List<String> values = List<String>.generate(
      activeAttributes.length,
      (index) => activeAttributes[index].variants[indexes[index]].trim(),
      growable: false,
    );
    final bool compatible =
        brandIndex == -1 ||
        modelIndex == -1 ||
        resolveTechnicalModelBrandIndex(values[modelIndex], brands) ==
            indexes[brandIndex];
    combinations.add(
      VariationCombination(
        type: values.join('-'),
        isBrandModelCompatible: compatible,
      ),
    );

    for (int offset = 0; offset < indexes.length; offset++) {
      final int index = indexes.length - 1 - offset;
      if (indexes[index] < activeAttributes[index].variants.length - 1) {
        indexes[index]++;
        break;
      }
      indexes[index] = 0;
    }
  }
  return combinations;
}

List<String> findUnresolvedTechnicalModels(List<AttributeModel>? attributes) {
  final List<AttributeModel> activeAttributes =
      (attributes ?? <AttributeModel>[])
          .where((attribute) => attribute.active)
          .toList(growable: false);
  final int brandIndex = activeAttributes.indexWhere(
    (attribute) => isTechnicalBrandAttribute(attribute.attribute.name),
  );
  final int modelIndex = activeAttributes.indexWhere(
    (attribute) => isTechnicalModelAttribute(attribute.attribute.name),
  );
  if (brandIndex == -1 || modelIndex == -1) {
    return <String>[];
  }

  final List<String> brands = activeAttributes[brandIndex].variants;
  return activeAttributes[modelIndex].variants
      .where((model) => resolveTechnicalModelBrandIndex(model, brands) == null)
      .toList(growable: false);
}

bool isTechnicalBrandAttribute(String? value) {
  final String normalized = _normalize(value);
  return normalized == 'brand' ||
      normalized == 'ბრენდი' ||
      normalized == 'бренд';
}

bool isTechnicalModelAttribute(String? value) {
  final String normalized = _normalize(value);
  return normalized == 'model' ||
      normalized == 'მოდელი' ||
      normalized == 'модель' ||
      normalized == 'applicablemodel' ||
      normalized == 'compatiblemodel' ||
      normalized == 'ტელეფონისმოდელი';
}

int? resolveTechnicalModelBrandIndex(String model, List<String> brands) {
  if (brands.isEmpty) {
    return null;
  }
  if (brands.length == 1) {
    return 0;
  }

  final String? modelKey = _inferBrandKey(model);
  final String normalizedModel = _normalize(model);
  for (int index = 0; index < brands.length; index++) {
    final String brand = brands[index];
    final String? brandKey = _inferBrandKey(brand);
    if (modelKey != null && modelKey == brandKey) {
      return index;
    }
    final String normalizedBrand = _normalize(brand);
    if (normalizedBrand.isNotEmpty &&
        normalizedModel.contains(normalizedBrand)) {
      return index;
    }
  }
  return null;
}

String? _inferBrandKey(String value) {
  final String lower = value.trim().toLowerCase();
  final String compact = _normalize(value);
  if (lower.contains('iphone') ||
      lower.contains('აიფონ') ||
      lower.contains('айфон') ||
      lower.contains('apple') ||
      RegExp(
        r'^(1[1-9]|2\d)(pro|max|promax|plus|mini|air)?$',
      ).hasMatch(compact)) {
    return 'iphone';
  }
  if (lower.contains('samsung') ||
      lower.contains('სამსუნგ') ||
      lower.contains('самсунг') ||
      lower.contains('galaxy') ||
      RegExp(r'^(a|m|s|f)\d{2,3}[a-z]*$').hasMatch(compact)) {
    return 'samsung';
  }
  for (final String brand in <String>[
    'redmi',
    'poco',
    'xiaomi',
    'honor',
    'huawei',
    'oppo',
    'realme',
    'oneplus',
    'pixel',
    'vivo',
    'nokia',
    'motorola',
    'infinix',
    'tecno',
    'nothing',
  ]) {
    if (compact.contains(brand)) {
      return brand;
    }
  }
  return null;
}

String _normalize(String? value) {
  return (value ?? '').trim().toLowerCase().replaceAll(
    RegExp(r'[\s_\-./]+'),
    '',
  );
}
