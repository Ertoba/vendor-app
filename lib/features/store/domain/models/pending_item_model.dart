import 'package:sixam_mart_store/helper/data_parser_helper.dart';

class PendingItemModel {
  int? totalSize;
  int? limit;
  String? offset;
  List<Items>? items;

  PendingItemModel({this.totalSize, this.limit, this.offset, this.items});

  PendingItemModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? page = json['pagination'] is Map
        ? Map<String, dynamic>.from(json['pagination'])
        : null;
    totalSize = DataParserHelper.parseInt(
      page != null ? page['total'] : json['total_size'],
    );
    limit = DataParserHelper.parseInt(
      page != null ? page['per_page'] : json['limit'],
    );
    offset = (page != null ? page['current_page'] : json['offset'])?.toString();
    final dynamic rows = json['data'] ?? json['items'];
    if (rows is List) {
      items = <Items>[];
      for (final dynamic v in rows) {
        items!.add(Items.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Items {
  int? id;
  String? name;
  String? imageFullUrl;
  double? price;
  int? isRejected;
  int? itemId;
  List<CategoryIds>? categoryIds;

  Items({
    this.id,
    this.name,
    this.imageFullUrl,
    this.price,
    this.isRejected,
    this.itemId,
    this.categoryIds,
  });

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageFullUrl = json['image_full_url'];
    price = json['price']?.toDouble();
    isRejected = json['is_rejected'];
    itemId = json['item_id'];
    if (json['category_ids'] != null) {
      categoryIds = <CategoryIds>[];
      json['category_ids'].forEach((v) {
        categoryIds!.add(CategoryIds.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image_full_url'] = imageFullUrl;
    data['price'] = price;
    data['is_rejected'] = isRejected;
    data['item_id'] = itemId;
    if (categoryIds != null) {
      data['category_ids'] = categoryIds!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryIds {
  String? id;
  int? position;
  String? name;

  CategoryIds({this.id, this.position, this.name});

  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    position = json['position'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['position'] = position;
    data['name'] = name;
    return data;
  }
}
