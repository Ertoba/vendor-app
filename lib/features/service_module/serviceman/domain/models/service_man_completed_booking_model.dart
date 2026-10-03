class ServiceManCompletedBookingListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<ServiceManCompletedBookingModel>? services;

  ServiceManCompletedBookingListModel({this.totalSize, this.limit, this.offset, this.services});

  ServiceManCompletedBookingListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['services'] != null) {
      services = <ServiceManCompletedBookingModel>[];
      json['services'].forEach((v) {
        services!.add(ServiceManCompletedBookingModel.fromJson(v));
      });
    }
  }
}

class ServiceManCompletedBookingModel {
  int? bookingId;
  String? displayId;
  String? bookingType;
  String? scheduleAt;
  num? bookingAmount;
  List<String>? services;

  ServiceManCompletedBookingModel({
    this.bookingId,
    this.displayId,
    this.bookingType,
    this.scheduleAt,
    this.bookingAmount,
    this.services,
  });

  ServiceManCompletedBookingModel.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    displayId = json['display_id'];
    bookingType = json['booking_type'];
    scheduleAt = json['schedule_at'];
    bookingAmount = json['booking_amount'];
    services = json['services'] != null ? List<String>.from(json['services']) : null;
  }
}
