class BookingEditCatalogResponseModel {
  bool? isEditable;
  String? reason;
  List<BookingEditCurrentLine>? lines;
  List<BookingEditCatalogService>? catalog;

  BookingEditCatalogResponseModel({this.isEditable, this.reason, this.lines, this.catalog});

  BookingEditCatalogResponseModel.fromJson(Map<String, dynamic> json) {
    isEditable = json['is_editable'];
    reason = json['reason'];
    if (json['lines'] != null) {
      lines = <BookingEditCurrentLine>[];
      json['lines'].forEach((v) => lines!.add(BookingEditCurrentLine.fromJson(v)));
    }
    if (json['catalog'] != null) {
      catalog = <BookingEditCatalogService>[];
      json['catalog'].forEach((v) => catalog!.add(BookingEditCatalogService.fromJson(v)));
    }
  }
}

class BookingEditCurrentLine {
  int? detailId;
  int? serviceId;
  String? variantKey;
  String? serviceName;
  String? variantName;
  double? unitPrice;
  double? grossPrice;
  double? discount;
  int? quantity;
  int? origQuantity;
  bool? missing;
  String? imageFullUrl;

  BookingEditCurrentLine({
    this.detailId, this.serviceId, this.variantKey, this.serviceName, this.variantName,
    this.unitPrice, this.grossPrice, this.discount, this.quantity, this.origQuantity, this.missing, this.imageFullUrl,
  });

  BookingEditCurrentLine.fromJson(Map<String, dynamic> json) {
    detailId = json['detail_id'];
    serviceId = json['service_id'];
    variantKey = json['variant_key'];
    serviceName = json['service_name'];
    variantName = json['variant_name'];
    unitPrice = json['unit_price'] != null ? double.tryParse(json['unit_price'].toString()) : null;
    grossPrice = json['gross_price'] != null ? double.tryParse(json['gross_price'].toString()) : null;
    discount = json['discount'] != null ? double.tryParse(json['discount'].toString()) : null;
    quantity = json['quantity'];
    origQuantity = json['orig_quantity'];
    missing = json['missing'] ?? false;
    imageFullUrl = json['image_full_url'];
  }
}

/// One service in the provider's active catalog, available to add to the booking.
class BookingEditCatalogService {
  int? id;
  String? name;
  int? categoryId;
  String? categoryName;
  int? subCategoryId;
  String? subCategoryName;
  double? unitPrice;
  double? grossPrice;
  double? discount;
  List<BookingEditCatalogVariant>? variants;
  String? imageFullUrl;

  BookingEditCatalogService({
    this.id, this.name, this.categoryId, this.categoryName, this.subCategoryId, this.subCategoryName,
    this.unitPrice, this.grossPrice, this.discount, this.variants, this.imageFullUrl,
  });

  bool get hasVariants => variants != null && variants!.isNotEmpty;

  BookingEditCatalogService.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    subCategoryId = json['sub_category_id'];
    subCategoryName = json['sub_category_name'];
    unitPrice = json['unit_price'] != null ? double.tryParse(json['unit_price'].toString()) : null;
    grossPrice = json['gross_price'] != null ? double.tryParse(json['gross_price'].toString()) : null;
    discount = json['discount'] != null ? double.tryParse(json['discount'].toString()) : null;
    if (json['variants'] != null) {
      variants = <BookingEditCatalogVariant>[];
      json['variants'].forEach((v) => variants!.add(BookingEditCatalogVariant.fromJson(v)));
    }
    imageFullUrl = json['image_full_url'];
  }
}

class BookingEditCatalogVariant {
  String? key;
  String? name;
  double? unitPrice;
  double? grossPrice;
  double? discount;

  BookingEditCatalogVariant({this.key, this.name, this.unitPrice, this.grossPrice, this.discount});

  BookingEditCatalogVariant.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    name = json['name'];
    unitPrice = json['unit_price'] != null ? double.tryParse(json['unit_price'].toString()) : null;
    grossPrice = json['gross_price'] != null ? double.tryParse(json['gross_price'].toString()) : null;
    discount = json['discount'] != null ? double.tryParse(json['discount'].toString()) : null;
  }
}
