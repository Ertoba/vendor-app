class ServiceManModel {
  int? id;
  String? fName;
  String? lName;
  String? fullName;
  String? email;
  String? phone;
  String? imageFullUrl;
  bool? status;
  bool? active;
  String? applicationStatus;
  int? bookingCount;
  String? identityNumber;
  String? identityType;
  List<String>? identityImageFullUrl;
  String? type;
  int? assignedBookingCount;
  int? currentBookings;
  int? totalAssigned;
  int? ongoingBookings;
  int? completedBookings;
  int? canceledBookings;
  ServiceManHistoryModel? history;

  ServiceManModel({
    this.id,
    this.fName,
    this.lName,
    this.fullName,
    this.email,
    this.phone,
    this.imageFullUrl,
    this.status,
    this.active,
    this.applicationStatus,
    this.bookingCount,
    this.identityNumber,
    this.identityType,
    this.identityImageFullUrl,
    this.type,
    this.assignedBookingCount,
    this.currentBookings,
    this.totalAssigned,
    this.ongoingBookings,
    this.completedBookings,
    this.canceledBookings,
    this.history,
  });

  ServiceManModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> serviceman = json['serviceman'] ?? json;
    id = serviceman['id'];
    fName = serviceman['f_name'];
    lName = serviceman['l_name'];
    fullName = serviceman['full_name'];
    email = serviceman['email'];
    phone = serviceman['phone'];
    imageFullUrl = serviceman['image_full_url'];
    status = serviceman['status'];
    active = serviceman['active'];
    applicationStatus = serviceman['application_status'];
    bookingCount = serviceman['booking_count'];
    identityNumber = serviceman['identity_number'];
    identityType = serviceman['identity_type'];
    identityImageFullUrl = serviceman['identity_image_full_url'] != null ? List<String>.from(serviceman['identity_image_full_url']) : null;
    type = serviceman['type'];
    assignedBookingCount = serviceman['assigned_booking_count'];
    currentBookings = serviceman['current_bookings'];
    totalAssigned = serviceman['total_assigned'];
    ongoingBookings = serviceman['ongoing_bookings'];
    completedBookings = serviceman['completed_bookings'];
    canceledBookings = serviceman['canceled_bookings'];
    history = json['history'] != null ? ServiceManHistoryModel.fromJson(json['history']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['full_name'] = fullName;
    data['email'] = email;
    data['phone'] = phone;
    data['image_full_url'] = imageFullUrl;
    data['status'] = status;
    data['active'] = active;
    data['application_status'] = applicationStatus;
    data['booking_count'] = bookingCount;
    data['identity_number'] = identityNumber;
    data['identity_type'] = identityType;
    data['identity_image_full_url'] = identityImageFullUrl;
    data['type'] = type;
    data['assigned_booking_count'] = assignedBookingCount;
    data['current_bookings'] = currentBookings;
    data['total_assigned'] = totalAssigned;
    data['ongoing_bookings'] = ongoingBookings;
    data['completed_bookings'] = completedBookings;
    data['canceled_bookings'] = canceledBookings;
    return data;
  }
}

class ServiceManHistoryModel {
  List<String>? categories;
  List<double>? series;

  ServiceManHistoryModel({this.categories, this.series});

  ServiceManHistoryModel.fromJson(Map<String, dynamic> json) {
    categories = json['categories'] != null ? List<String>.from(json['categories']) : null;
    series = json['series'] != null ? List<double>.from(json['series'].map((value) => value.toDouble())) : null;
  }
}
