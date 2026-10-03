class ProviderOfferListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<ProviderOfferModel>? data;

  ProviderOfferListModel({this.totalSize, this.limit, this.offset, this.data});

  ProviderOfferListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['data'] != null) {
      data = <ProviderOfferModel>[];
      json['data'].forEach((v) {
        data!.add(ProviderOfferModel.fromJson(v));
      });
    }
  }
}

class ProviderOfferModel {
  int? id;
  int? customServiceRequestId;
  double? offerPrice;
  String? note;
  bool? isSelected;
  ProviderInfoModel? provider;

  ProviderOfferModel({this.id, this.customServiceRequestId, this.offerPrice, this.note, this.isSelected, this.provider});

  ProviderOfferModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customServiceRequestId = json['custom_service_request_id'];
    offerPrice = json['offer_price'] != null ? double.tryParse(json['offer_price'].toString()) : null;
    note = json['note'];
    isSelected = json['is_selected'];
    provider = json['provider'] != null ? ProviderInfoModel.fromJson(json['provider']) : null;
  }
}

class ProviderInfoModel {
  int? id;
  String? name;
  String? imageFullUrl;
  double? avgRating;
  int? reviewCount;

  ProviderInfoModel({this.id, this.name, this.imageFullUrl, this.avgRating, this.reviewCount});

  ProviderInfoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    imageFullUrl = json['image_full_url'];
    avgRating = json['avg_rating'] != null ? double.tryParse(json['avg_rating'].toString()) : null;
    reviewCount = json['review_count'];
  }
}
