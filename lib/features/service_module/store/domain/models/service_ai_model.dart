// Response models for the `/vendor/service/ai/*` auto-fill endpoints.
// Every endpoint returns `{ "data": { … } }`.

class ServiceTitleDesModel {
  String? title;
  String? description;

  ServiceTitleDesModel({this.title, this.description});

  ServiceTitleDesModel.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'] ?? json;
    title = data['title'];
    description = data['description'];
  }
}

class ServiceSeoModel {
  String? metaTitle;
  String? metaDescription;

  ServiceSeoModel({this.metaTitle, this.metaDescription});

  ServiceSeoModel.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'] ?? json;
    metaTitle = data['meta_title'];
    metaDescription = data['meta_description'];
  }
}

class ServiceGeneralSetupModel {
  String? categoryId;
  String? subCategoryId;

  ServiceGeneralSetupModel({this.categoryId, this.subCategoryId});

  ServiceGeneralSetupModel.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'] ?? json;
    categoryId = data['category_id']?.toString();
    subCategoryId = data['sub_category_id']?.toString();
  }
}

class ServicePriceVariationModel {
  double? basePrice;
  double? minBidPrice;
  List<ServiceAiVariation>? variations;

  ServicePriceVariationModel({this.basePrice, this.minBidPrice, this.variations});

  ServicePriceVariationModel.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'] ?? json;
    basePrice = data['base_price'] != null ? double.tryParse(data['base_price'].toString()) : null;
    minBidPrice = data['min_bid_price'] != null ? double.tryParse(data['min_bid_price'].toString()) : null;
    if (data['variations'] != null && data['variations'] is List) {
      variations = [];
      data['variations'].forEach((v) {
        variations!.add(ServiceAiVariation.fromJson(v));
      });
    }
  }
}

class ServiceAiVariation {
  String? name;
  double? price;
  double? discount;
  String? discountType;

  ServiceAiVariation({this.name, this.price, this.discount, this.discountType});

  ServiceAiVariation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : 0;
    discount = json['discount'] != null ? double.tryParse(json['discount'].toString()) : 0;
    discountType = json['discount_type'];
  }
}

class ServiceTagsModel {
  List<String> tags;

  ServiceTagsModel({this.tags = const []});

  ServiceTagsModel.fromJson(Map<String, dynamic> json) : tags = [] {
    final dynamic data = json['data'] ?? json;
    if (data['tags'] != null && data['tags'] is List) {
      for (final t in data['tags']) {
        if (t != null) tags.add(t.toString());
      }
    }
  }
}

class ServiceTitleSuggestionModel {
  List<String> titles;

  ServiceTitleSuggestionModel({this.titles = const []});

  ServiceTitleSuggestionModel.fromJson(Map<String, dynamic> json) : titles = [] {
    final dynamic data = json['data'] ?? json;
    if (data['titles'] != null && data['titles'] is List) {
      for (final t in data['titles']) {
        if (t != null) titles.add(t.toString());
      }
    }
  }
}
