import 'package:sixam_mart_store/helper/data_parser_helper.dart';
class AssignableFoodModel {
  CategoryInfo? category;
  int? unassignedCount;
  int? totalSize;
  int? limit;
  int? offset;
  List<AssignableFood>? foods;

  AssignableFoodModel({this.category, this.unassignedCount, this.totalSize, this.limit, this.offset, this.foods});

  AssignableFoodModel.fromJson(Map<String, dynamic> json) {
    category = json['category'] != null ? CategoryInfo.fromJson(json['category']) : null;
    unassignedCount = json['unassigned_count'];
    final Map<String, dynamic>? page = json['pagination'] is Map ? Map<String, dynamic>.from(json['pagination']) : null;
    totalSize = DataParserHelper.parseInt(page != null ? page['total'] : json['total_size']);
    limit = DataParserHelper.parseInt(page != null ? page['per_page'] : json['limit']);
    offset = DataParserHelper.parseInt(page != null ? page['current_page'] : json['offset']);
    final dynamic list = json['data'] ?? json['foods'] ?? json['items'];
    if (list is List) {
      foods = [];
      for (dynamic v in list) {
        foods!.add(AssignableFood.fromJson(v));
      }
    }
  }
}

class CategoryInfo {
  int? id;
  String? name;

  CategoryInfo({this.id, this.name});

  CategoryInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}

class AssignableFood {
  int? id;
  String? name;
  String? imageFullUrl;
  double? price;
  int? storeCategoryId;
  bool? isAssigned;
  int? variationsCount;

  AssignableFood({
    this.id,
    this.name,
    this.imageFullUrl,
    this.price,
    this.storeCategoryId,
    this.isAssigned,
    this.variationsCount,
  });

  AssignableFood.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageFullUrl = json['image_full_url'];
    price = (json['price'] as num?)?.toDouble();
    storeCategoryId = json['store_category_id'] ?? json['restaurant_category_id'];
    final dynamic assigned = json['is_assigned'];
    isAssigned = assigned == true || assigned == 1;
    variationsCount = json['variations_count'];
  }
}
