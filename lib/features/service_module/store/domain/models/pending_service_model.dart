class PendingServiceModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<PendingService>? services;

  PendingServiceModel({this.totalSize, this.limit, this.offset, this.services});

  PendingServiceModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['services'] != null) {
      services = <PendingService>[];
      json['services'].forEach((v) {
        services!.add(PendingService.fromJson(v));
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

class PendingService {
  int? id;
  int? serviceId;
  String? name;
  String? thumbnailFullUrl;
  double? basePrice;
  double? discount;
  String? discountType;
  int? categoryId;
  String? categoryName;
  int? isRejected;
  String? statusLabel;
  String? note;
  String? createdAt;

  PendingService({
    this.id,
    this.serviceId,
    this.name,
    this.thumbnailFullUrl,
    this.basePrice,
    this.discount,
    this.discountType,
    this.categoryId,
    this.categoryName,
    this.isRejected,
    this.statusLabel,
    this.note,
    this.createdAt,
  });

  PendingService.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceId = json['service_id'];
    name = json['name'];
    thumbnailFullUrl = json['thumbnail_full_url'];
    basePrice = json['base_price']?.toDouble();
    discount = json['discount']?.toDouble();
    discountType = json['discount_type'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    isRejected = json['is_rejected'];
    statusLabel = json['status_label'];
    note = json['note'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['service_id'] = serviceId;
    data['name'] = name;
    data['thumbnail_full_url'] = thumbnailFullUrl;
    data['base_price'] = basePrice;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['category_id'] = categoryId;
    data['category_name'] = categoryName;
    data['is_rejected'] = isRejected;
    data['status_label'] = statusLabel;
    data['note'] = note;
    data['created_at'] = createdAt;
    return data;
  }
}
