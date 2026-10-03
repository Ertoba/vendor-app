import 'package:sixam_mart_store/features/service_module/order/domain/models/booking_model.dart';

class ServiceBookingReportModel {
  int? totalSize;
  int? limit;
  int? offset;
  BookingReportSummary? summary;
  List<BookingModel>? bookings;

  ServiceBookingReportModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.summary,
    this.bookings,
  });

  ServiceBookingReportModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    summary = json['summary'] != null ? BookingReportSummary.fromJson(json['summary']) : null;
    if (json['bookings'] != null) {
      bookings = <BookingModel>[];
      json['bookings'].forEach((v) {
        bookings!.add(BookingModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    if (bookings != null) {
      data['bookings'] = bookings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BookingReportSummary {
  int? total;
  int? completed;
  int? ongoing;
  int? inProgress;
  int? onHold;
  int? canceled;
  double? totalAmount;

  BookingReportSummary({
    this.total,
    this.completed,
    this.ongoing,
    this.inProgress,
    this.onHold,
    this.canceled,
    this.totalAmount,
  });

  BookingReportSummary.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    completed = json['completed'];
    ongoing = json['ongoing'];
    inProgress = json['in_progress'];
    onHold = json['on_hold'];
    canceled = json['canceled'];
    totalAmount = json['total_amount']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['completed'] = completed;
    data['ongoing'] = ongoing;
    data['in_progress'] = inProgress;
    data['on_hold'] = onHold;
    data['canceled'] = canceled;
    data['total_amount'] = totalAmount;
    return data;
  }
}
