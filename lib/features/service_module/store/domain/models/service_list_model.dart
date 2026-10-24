class ServiceListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<Service>? services;

  ServiceListModel({this.totalSize, this.limit, this.offset, this.services});

  ServiceListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'] is int ? json['total_size'] : int.tryParse(json['total_size'].toString());
    limit = json['limit'] is int ? json['limit'] : int.tryParse(json['limit'].toString());
    offset = json['offset'] is int ? json['offset'] : int.tryParse(json['offset'].toString());
    if (json['services'] != null) {
      services = <Service>[];
      json['services'].forEach((v) {
        services!.add(Service.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Service {
  int? id;
  String? name;
  String? slug;
  String? shortDescription;
  String? longDescription;
  String? thumbnailFullUrl;
  List<String>? additionalImagesFullUrl;
  double? basePrice;
  double? discount;
  String? discountType;
  int? recommended;
  int? isApproved;
  int? status;
  int? orderCount;
  double? avgRating;
  int? ratingCount;
  int? moduleId;
  int? storeId;
  String? storeName;
  int? categoryId;
  int? subCategoryId;
  int? storeCategoryId;
  ServiceCategory? category;
  String? createdAt;
  String? updatedAt;

  Service({
    this.id,
    this.name,
    this.slug,
    this.shortDescription,
    this.longDescription,
    this.thumbnailFullUrl,
    this.additionalImagesFullUrl,
    this.basePrice,
    this.discount,
    this.discountType,
    this.recommended,
    this.isApproved,
    this.status,
    this.orderCount,
    this.avgRating,
    this.ratingCount,
    this.moduleId,
    this.storeId,
    this.storeName,
    this.categoryId,
    this.subCategoryId,
    this.storeCategoryId,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    shortDescription = json['short_description'];
    longDescription = json['long_description'];
    thumbnailFullUrl = json['thumbnail_full_url'];
    additionalImagesFullUrl = json['additional_images_full_url'] != null
        ? List<String>.from(json['additional_images_full_url'])
        : [];
    basePrice = json['base_price']?.toDouble();
    discount = json['discount']?.toDouble();
    discountType = json['discount_type'];
    recommended = json['recommended'];
    isApproved = json['is_approved'];
    status = json['status'];
    orderCount = json['order_count'];
    avgRating = json['avg_rating']?.toDouble();
    ratingCount = json['rating_count'];
    moduleId = json['module_id'];
    storeId = json['store_id'];
    storeName = json['store_name'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    storeCategoryId = json['store_category_id'];
    category = json['category'] != null ? ServiceCategory.fromJson(json['category']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['short_description'] = shortDescription;
    data['long_description'] = longDescription;
    data['thumbnail_full_url'] = thumbnailFullUrl;
    data['additional_images_full_url'] = additionalImagesFullUrl;
    data['base_price'] = basePrice;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['recommended'] = recommended;
    data['is_approved'] = isApproved;
    data['status'] = status;
    data['order_count'] = orderCount;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    data['module_id'] = moduleId;
    data['store_id'] = storeId;
    data['store_name'] = storeName;
    data['category_id'] = categoryId;
    data['sub_category_id'] = subCategoryId;
    data['store_category_id'] = storeCategoryId;
    if (category != null) data['category'] = category!.toJson();
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class ServiceCategory {
  int? id;
  String? name;
  String? slug;

  ServiceCategory({this.id, this.name, this.slug});

  ServiceCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug};
  }
}
