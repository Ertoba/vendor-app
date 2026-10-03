import 'package:sixam_mart_store/features/service_module/store/domain/models/service_model.dart' show ServiceSeo, ServiceVariation;

class PendingServiceDetailsModel {
  int? id;
  int? serviceId;
  String? name;
  String? shortDescription;
  String? longDescription;
  int? categoryId;
  String? categoryName;
  int? subCategoryId;
  String? subCategoryName;
  double? basePrice;
  double? discount;
  String? discountType;
  List<ServiceVariation>? variations;
  List<String>? tags;
  String? thumbnailFullUrl;
  List<String>? additionalImagesFullUrl;
  int? isRejected;
  String? note;
  String? statusLabel;
  ServiceSeo? seo;

  PendingServiceDetailsModel({
    this.id,
    this.serviceId,
    this.name,
    this.shortDescription,
    this.longDescription,
    this.categoryId,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    this.basePrice,
    this.discount,
    this.discountType,
    this.variations,
    this.tags,
    this.thumbnailFullUrl,
    this.additionalImagesFullUrl,
    this.isRejected,
    this.note,
    this.statusLabel,
    this.seo,
  });

  PendingServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceId = json['service_id'];
    name = json['name'];
    shortDescription = json['short_description'];
    longDescription = json['long_description'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    subCategoryId = json['sub_category_id'];
    subCategoryName = json['sub_category_name'];
    basePrice = json['base_price']?.toDouble();
    discount = json['discount']?.toDouble();
    discountType = json['discount_type'];
    if (json['variations'] != null) {
      variations = <ServiceVariation>[];
      json['variations'].forEach((v) => variations!.add(ServiceVariation.fromJson(v)));
    }
    if (json['tags'] != null) {
      tags = List<String>.from(json['tags']);
    }
    thumbnailFullUrl = json['thumbnail_full_url'];
    additionalImagesFullUrl = json['additional_images_full_url'] != null
        ? List<String>.from(json['additional_images_full_url'])
        : [];
    isRejected = json['is_rejected'];
    note = json['note'];
    statusLabel = json['status_label'];
    seo = json['seo'] != null ? ServiceSeo.fromJson(json['seo']) : null;
  }
}
