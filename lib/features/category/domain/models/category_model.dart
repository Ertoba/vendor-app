import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';

class CategoryModel {
  int? id;
  String? name;
  String? image;
  int? parentId;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? priority;
  String? slug;
  int? featured;
  int? productsCount;
  int? childesCount;
  String? imageFullUrl;
  List<Translation>? translations;

  CategoryModel({
    this.id,
    this.name,
    this.image,
    this.parentId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.priority,
    this.slug,
    this.featured,
    this.productsCount,
    this.childesCount,
    this.imageFullUrl,
    this.translations,
  });

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    parentId = json['parent_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    priority = json['priority'];
    slug = json['slug'];
    featured = json['featured'];
    productsCount = json['items_count'] ?? json['products_count'];
    childesCount = json['childs_count'];
    imageFullUrl = json['image_full_url'];
    if (json['translations'] != null) {
      translations = <Translation>[];
      json['translations'].forEach((v) {
        translations!.add(Translation.fromJson(v));
      });
    }
  }
}
