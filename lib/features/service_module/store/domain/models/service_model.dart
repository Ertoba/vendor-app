import 'package:sixam_mart_store/features/service_module/store/domain/models/service_list_model.dart' show ServiceCategory;
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart' show CategoryIds, Translation, Tag;

export 'package:sixam_mart_store/features/service_module/store/domain/models/service_list_model.dart' show ServiceCategory;
export 'package:sixam_mart_store/features/store/domain/models/item_model.dart' show CategoryIds, Translation, Tag;

class ServiceModel {
  int? id;
  String? name;
  String? shortDescription;
  String? longDescription;
  String? imageFullUrl;
  List<String?>? imagesFullUrl;
  List<CategoryIds>? categoryIds;
  int? storeCategoryId;
  double? basePrice;
  double? discount;
  String? discountType;
  int? recommended;
  List<ServiceVariation>? variations;
  List<Translation>? translations;
  List<Tag>? tags;
  String? metaTitle;
  String? metaDescription;
  String? metaImageFullUrl;
  ServiceSeo? seo;
  List<int>? taxVatIds;
  int? isApproved;
  int? status;
  double? avgRating;
  int? ratingCount;
  ServiceCategory? category;
  ServiceCategory? storeCategory;

  ServiceModel({
    this.id,
    this.name,
    this.shortDescription,
    this.longDescription,
    this.imageFullUrl,
    this.imagesFullUrl,
    this.categoryIds,
    this.storeCategoryId,
    this.basePrice,
    this.discount,
    this.discountType,
    this.recommended,
    this.variations,
    this.translations,
    this.tags,
    this.metaTitle,
    this.metaDescription,
    this.metaImageFullUrl,
    this.seo,
    this.taxVatIds,
    this.isApproved,
    this.status,
    this.avgRating,
    this.ratingCount,
    this.category,
    this.storeCategory,
  });

  ServiceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    shortDescription = json['short_description'];
    longDescription = json['long_description'];

    imageFullUrl = json['image_full_url'] ?? json['thumbnail_full_url'];

    final dynamic imageList = json['images_full_url'] ?? json['additional_images_full_url'];
    if (imageList is List) {
      imagesFullUrl = [];
      for (final v in imageList) {
        if (v != null) imagesFullUrl!.add(v.toString());
      }
    }

    if (json['category_ids'] != null) {
      categoryIds = [];
      json['category_ids'].forEach((v) {
        categoryIds!.add(CategoryIds.fromJson(v));
      });
    } else {
      categoryIds = [];
      if (json['category_id'] != null) categoryIds!.add(CategoryIds(id: json['category_id'].toString()));
      if (json['sub_category_id'] != null) categoryIds!.add(CategoryIds(id: json['sub_category_id'].toString()));
    }

    storeCategoryId = json['store_category_id'] != null ? int.tryParse(json['store_category_id'].toString()) : null;
    basePrice = json['base_price'] != null ? double.tryParse(json['base_price'].toString()) : (json['price'] != null ? double.tryParse(json['price'].toString()) : null);
    discount = json['discount'] != null ? double.tryParse(json['discount'].toString()) : null;
    discountType = json['discount_type'];
    recommended = json['recommended'] != null ? int.tryParse(json['recommended'].toString()) : 0;
    if (json['variations'] != null && json['variations'] is List) {
      variations = [];
      json['variations'].forEach((v) {
        variations!.add(ServiceVariation.fromJson(v));
      });
    }
    if (json['translations'] != null) {
      translations = [];
      final dynamic rawTranslations = json['translations'];
      if (rawTranslations is List) {
        for (final v in rawTranslations) {
          translations!.add(Translation.fromJson(v));
        }
      } else if (rawTranslations is Map) {
        rawTranslations.forEach((locale, fields) {
          if (fields is Map) {
            fields.forEach((key, value) {
              translations!.add(Translation(locale: locale.toString(), key: key.toString(), value: value?.toString()));
            });
          }
        });
      }
    }

    if (json['tags'] != null && json['tags'] is List) {
      tags = [];
      json['tags'].forEach((v) {
        if (v is Map<String, dynamic>) {
          tags!.add(Tag.fromJson(v));
        } else if (v != null) {
          tags!.add(Tag(tag: v.toString()));
        }
      });
    }
    seo = json['seo'] != null ? ServiceSeo.fromJson(json['seo']) : null;
    metaTitle = seo?.title ?? json['meta_title'];
    metaDescription = seo?.description ?? json['meta_description'];
    metaImageFullUrl = seo?.imageFullUrl ?? json['meta_image_full_url'] ?? json['meta_image'];
    if (json['tax_ids'] != null) {
      taxVatIds = [];
      json['tax_ids'].forEach((v) {
        taxVatIds!.add(int.parse(v.toString()));
      });
    }
    isApproved = json['is_approved'] != null ? int.tryParse(json['is_approved'].toString()) : null;
    status = json['status'] != null ? int.tryParse(json['status'].toString()) : null;
    avgRating = json['avg_rating'] != null ? double.tryParse(json['avg_rating'].toString()) : null;
    ratingCount = json['rating_count'] != null ? int.tryParse(json['rating_count'].toString()) : null;
    category = json['category'] != null ? ServiceCategory.fromJson(json['category']) : null;
    storeCategory = json['store_category'] != null ? ServiceCategory.fromJson(json['store_category']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['short_description'] = shortDescription;
    data['long_description'] = longDescription;
    data['image_full_url'] = imageFullUrl;
    data['images_full_url'] = imagesFullUrl;
    if (categoryIds != null) {
      data['category_ids'] = categoryIds!.map((v) => v.toJson()).toList();
    }
    data['store_category_id'] = storeCategoryId;
    data['base_price'] = basePrice;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['recommended'] = recommended;
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    if (tags != null) {
      data['tags'] = tags!.map((v) => v.toJson()).toList();
    }
    data['meta_title'] = metaTitle;
    data['meta_description'] = metaDescription;
    data['meta_image_full_url'] = metaImageFullUrl;
    if (seo != null) data['seo'] = seo!.toJson();
    if (taxVatIds != null) {
      data['tax_ids'] = taxVatIds!.map((v) => v.toString()).toList();
    }
    data['is_approved'] = isApproved;
    data['status'] = status;
    data['avg_rating'] = avgRating;
    data['rating_count'] = ratingCount;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (storeCategory != null) {
      data['store_category'] = storeCategory!.toJson();
    }
    return data;
  }
}

class ServiceSeo {
  String? title;
  String? description;
  String? imageFullUrl;
  ServiceMetaData? metaData;

  ServiceSeo({this.title, this.description, this.imageFullUrl, this.metaData});

  ServiceSeo.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    imageFullUrl = json['image_full_url'];
    metaData = json['meta_data'] != null ? ServiceMetaData.fromJson(json['meta_data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['image_full_url'] = imageFullUrl;
    if (metaData != null) data['meta_data'] = metaData!.toJson();
    return data;
  }
}

class ServiceMetaData {
  int? metaIndex;
  int? metaNoFollow;
  int? metaNoArchive;
  int? metaNoSnippet;
  int? metaMaxSnippet;
  int? metaNoImageIndex;
  int? metaMaxImagePreview;
  String? metaMaxSnippetValue;
  int? metaMaxVideoPreview;
  String? metaMaxImagePreviewValue;
  String? metaMaxVideoPreviewValue;

  ServiceMetaData({
    this.metaIndex,
    this.metaNoFollow,
    this.metaNoArchive,
    this.metaNoSnippet,
    this.metaMaxSnippet,
    this.metaNoImageIndex,
    this.metaMaxImagePreview,
    this.metaMaxSnippetValue,
    this.metaMaxVideoPreview,
    this.metaMaxImagePreviewValue,
    this.metaMaxVideoPreviewValue,
  });

  ServiceMetaData.fromJson(Map<String, dynamic> json) {
    metaIndex = _toInt(json['meta_index']);
    metaNoFollow = _toInt(json['meta_no_follow']);
    metaNoArchive = _toInt(json['meta_no_archive']);
    metaNoSnippet = _toInt(json['meta_no_snippet']);
    metaMaxSnippet = _toInt(json['meta_max_snippet']);
    metaNoImageIndex = _toInt(json['meta_no_image_index']);
    metaMaxImagePreview = _toInt(json['meta_max_image_preview']);
    metaMaxSnippetValue = json['meta_max_snippet_value']?.toString();
    metaMaxVideoPreview = _toInt(json['meta_max_video_preview']);
    metaMaxImagePreviewValue = json['meta_max_image_preview_value']?.toString();
    metaMaxVideoPreviewValue = json['meta_max_video_preview_value']?.toString();
  }

  static int? _toInt(dynamic value) => value is int ? value : int.tryParse(value?.toString() ?? '');

  Map<String, dynamic> toJson() {
    return {
      'meta_index': metaIndex,
      'meta_no_follow': metaNoFollow,
      'meta_no_archive': metaNoArchive,
      'meta_no_snippet': metaNoSnippet,
      'meta_max_snippet': metaMaxSnippet,
      'meta_no_image_index': metaNoImageIndex,
      'meta_max_image_preview': metaMaxImagePreview,
      'meta_max_snippet_value': metaMaxSnippetValue,
      'meta_max_video_preview': metaMaxVideoPreview,
      'meta_max_image_preview_value': metaMaxImagePreviewValue,
      'meta_max_video_preview_value': metaMaxVideoPreviewValue,
    };
  }
}

/// Parsed (read-side) representation of a service variation, used for edit pre-fill.
class ServiceVariation {
  String? name;
  double? price;
  double? discount;
  String? discountType;

  ServiceVariation({this.name, this.price, this.discount, this.discountType});

  ServiceVariation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : 0;
    discount = json['discount'] != null ? double.tryParse(json['discount'].toString()) : 0;
    discountType = json['discount_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    return data;
  }
}
