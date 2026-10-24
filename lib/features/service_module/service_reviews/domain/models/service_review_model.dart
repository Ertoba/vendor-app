import 'package:sixam_mart_store/features/order/domain/models/order_model.dart';

class ServiceReviewListModel {
  int? totalSize;
  String? limit;
  String? offset;
  RatingSummaryModel? ratingSummary;
  List<ServiceReviewModel>? reviews;

  ServiceReviewListModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.ratingSummary,
    this.reviews,
  });

  ServiceReviewListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit']?.toString();
    offset = json['offset']?.toString();
    ratingSummary = json['rating_summary'] != null ? RatingSummaryModel.fromJson(json['rating_summary']) : null;
    if (json['reviews'] != null) {
      reviews = [];
      json['reviews'].forEach((review) => reviews!.add(ServiceReviewModel.fromJson(review)));
    }
  }
}

class RatingSummaryModel {
  double? avgRating;
  int? totalReviews;
  List<RatingBreakdownModel>? breakdown;

  RatingSummaryModel({this.avgRating, this.totalReviews, this.breakdown});

  RatingSummaryModel.fromJson(Map<String, dynamic> json) {
    avgRating = json['avg_rating'] != null ? double.parse(json['avg_rating'].toString()) : 0;
    totalReviews = json['total_reviews'];
    if (json['breakdown'] != null) {
      breakdown = [];
      json['breakdown'].forEach((breakdown) => this.breakdown!.add(RatingBreakdownModel.fromJson(breakdown)));
    }
  }
}

class RatingBreakdownModel {
  String? label;
  int? star;
  int? count;

  RatingBreakdownModel({this.label, this.star, this.count});

  RatingBreakdownModel.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    star = json['star'];
    count = json['count'];
  }
}

class ServiceReviewModel {
  int? id;
  String? reviewId;
  int? serviceId;
  int? bookingId;
  int? rating;
  String? comment;
  List<String>? attachment;
  String? reply;
  String? repliedAt;
  String? serviceName;
  Customer? customer;
  String? reviewDate;
  String? reviewTime;
  String? createdAt;
  String? updatedAt;

  ServiceReviewModel({
    this.id,
    this.reviewId,
    this.serviceId,
    this.bookingId,
    this.rating,
    this.comment,
    this.attachment,
    this.reply,
    this.repliedAt,
    this.serviceName,
    this.customer,
    this.reviewDate,
    this.reviewTime,
    this.createdAt,
    this.updatedAt,
  });

  ServiceReviewModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reviewId = json['review_id'];
    serviceId = json['service_id'];
    bookingId = json['booking_id'];
    rating = json['rating'];
    comment = json['comment'];
    if (json['attachment'] != null) {
      attachment = [];
      json['attachment'].forEach((attachment) => this.attachment!.add(attachment.toString()));
    }
    reply = json['reply'];
    repliedAt = json['replied_at'];
    serviceName = json['service_name'];
    customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    reviewDate = json['review_date'];
    reviewTime = json['review_time'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['review_id'] = reviewId;
    data['service_id'] = serviceId;
    data['booking_id'] = bookingId;
    data['rating'] = rating;
    data['comment'] = comment;
    data['attachment'] = attachment;
    data['reply'] = reply;
    data['replied_at'] = repliedAt;
    data['service_name'] = serviceName;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    data['review_date'] = reviewDate;
    data['review_time'] = reviewTime;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  String get customerName => customer != null ? '${customer!.fName ?? ''} ${customer!.lName ?? ''}'.trim() : '';
  String get displayImage => (attachment != null && attachment!.isNotEmpty) ? attachment!.first : '';
}
