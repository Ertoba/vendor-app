class CustomServiceRequestListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<CustomServiceRequestModel>? data;

  CustomServiceRequestListModel({this.totalSize, this.limit, this.offset, this.data});

  CustomServiceRequestListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['data'] != null) {
      data = <CustomServiceRequestModel>[];
      json['data'].forEach((v) {
        data!.add(CustomServiceRequestModel.fromJson(v));
      });
    }
  }
}

class CustomServiceRequestModel {
  int? id;
  int? categoryId;
  String? categoryName;
  String? categoryImageFullUrl;
  int? subCategoryId;
  String? subCategoryName;
  String? bookingDate;
  String? customerName;
  String? customerImageFullUrl;
  String? customerAddress;
  String? bookingTime;
  String? description;
  String? status;
  String? statusLabel;
  int? bidCount;
  bool? isBidded;
  String? createdAt;

  CustomServiceRequestModel({
    this.id, this.categoryId, this.categoryName, this.categoryImageFullUrl, this.subCategoryId,
    this.subCategoryName, this.bookingDate, this.customerName, this.customerImageFullUrl, this.customerAddress,
    this.bookingTime, this.description, this.status, this.statusLabel, this.bidCount, this.isBidded, this.createdAt,
  });

  CustomServiceRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    categoryImageFullUrl = json['category_image_full_url'];
    subCategoryId = json['sub_category_id'];
    subCategoryName = json['sub_category_name'];
    bookingDate = json['booking_date'];
    customerName = json['customer_name'];
    customerImageFullUrl = json['customer_image_full_url'];
    customerAddress = json['customer_address'];
    bookingTime = json['booking_time'];
    description = json['description'];
    status = json['status'];
    statusLabel = json['status_label'];
    bidCount = json['bid_count'];
    isBidded = json['is_bidded'];
    createdAt = json['created_at'];
  }
}

class CustomServiceRequestDetailsModel {
  int? id;
  String? customerName;
  String? customerImageFullUrl;
  dynamic customerLocation;
  String? customerAddress;
  int? categoryId;
  String? categoryName;
  String? categoryImageFullUrl;
  String? subCategoryName;
  String? description;
  String? bookingTime;
  String? createdAt;
  int? bidCount;
  CustomServiceBidModel? bid;
  bool? isExpired;
  bool? isBookingAccepted;

  CustomServiceRequestDetailsModel({
    this.id, this.customerName, this.customerImageFullUrl, this.customerLocation, this.customerAddress,
    this.categoryId, this.categoryName, this.categoryImageFullUrl, this.subCategoryName, this.description,
    this.bookingTime, this.createdAt, this.bidCount, this.bid, this.isExpired, this.isBookingAccepted,
  });

  CustomServiceRequestDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerName = json['customer_name'];
    customerImageFullUrl = json['customer_image_full_url'];
    customerLocation = json['customer_location'];
    customerAddress = json['customer_address'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    categoryImageFullUrl = json['category_image_full_url'];
    subCategoryName = json['sub_category_name'];
    description = json['description'];
    bookingTime = json['booking_time'];
    createdAt = json['created_at'];
    bidCount = json['bid_count'];
    bid = json['bid'] != null ? CustomServiceBidModel.fromJson(json['bid']) : null;
    isExpired = json['is_expired'] ?? false;
    isBookingAccepted = json['is_booking_accepted'] ?? false;
  }
}

class CustomServiceBidModel {
  int? id;
  double? price;
  String? note;
  bool? isBidDenied;

  CustomServiceBidModel({this.id, this.price, this.note, this.isBidDenied});

  CustomServiceBidModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
    note = json['note'];
    isBidDenied = json['is_bid_denied'];
  }
}
