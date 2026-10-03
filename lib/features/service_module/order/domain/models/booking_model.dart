class BookingListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<BookingModel>? bookings;

  BookingListModel({this.totalSize, this.limit, this.offset, this.bookings});

  BookingListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
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
    if (bookings != null) {
      data['bookings'] = bookings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BookingModel {
  int? id;
  String? displayId;
  String? bookingType;
  String? multiBookingType;
  int? parentBookingId;
  bool? isRepeatParent;
  int? childBookingsCount;
  bool? isCustom;
  bool? isCampaign;
  String? bookingStatus;
  String? statusLabel;
  String? activeBookingStatus;
  String? activeStatusLabel;
  String? paymentStatus;
  String? paymentMethod;
  int? scheduled;
  String? scheduleAt;
  int? quantity;
  int? detailsCount;
  List<BookingServiceItemModel>? services;
  double? bookingAmount;
  String? couponCode;
  bool? isReviewed;
  String? currencySymbol;
  BookingProviderModel? provider;
  BookingCustomerModel? customer;
  String? createdAt;

  BookingModel({
    this.id, this.displayId, this.bookingType, this.multiBookingType, this.parentBookingId, this.isRepeatParent,
    this.childBookingsCount, this.isCustom, this.isCampaign, this.bookingStatus, this.statusLabel, this.activeBookingStatus, this.activeStatusLabel, this.paymentStatus, this.paymentMethod,
    this.scheduled, this.scheduleAt, this.quantity, this.detailsCount, this.services, this.bookingAmount,
    this.couponCode, this.isReviewed, this.currencySymbol, this.provider, this.customer, this.createdAt,
  });

  BookingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['display_id']?.toString();
    bookingType = json['booking_type'];
    multiBookingType = json['multi_booking_type'];
    parentBookingId = json['parent_booking_id'];
    isRepeatParent = json['is_repeat_parent'];
    childBookingsCount = json['child_bookings_count'];
    isCustom = json['is_custom'];
    isCampaign = json['is_campaign'];
    bookingStatus = json['booking_status'];
    statusLabel = json['status_label'];
    activeBookingStatus = json['active_booking_status'];
    activeStatusLabel = json['active_status_label'];
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    scheduled = json['scheduled'];
    scheduleAt = json['schedule_at'];
    quantity = json['quantity'];
    detailsCount = json['details_count'];
    if (json['services'] != null) {
      services = <BookingServiceItemModel>[];
      json['services'].forEach((v) => services!.add(BookingServiceItemModel.fromJson(v)));
    }
    bookingAmount = json['booking_amount']?.toDouble();
    couponCode = json['coupon_code'];
    isReviewed = json['is_reviewed'];
    currencySymbol = json['currency_symbol'];
    provider = json['provider'] != null ? BookingProviderModel.fromJson(json['provider']) : null;
    customer = json['customer'] != null ? BookingCustomerModel.fromJson(json['customer']) : null;
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['display_id'] = displayId;
    data['booking_type'] = bookingType;
    data['multi_booking_type'] = multiBookingType;
    data['parent_booking_id'] = parentBookingId;
    data['is_repeat_parent'] = isRepeatParent;
    data['child_bookings_count'] = childBookingsCount;
    data['is_custom'] = isCustom;
    data['is_campaign'] = isCampaign;
    data['booking_status'] = bookingStatus;
    data['status_label'] = statusLabel;
    data['active_booking_status'] = activeBookingStatus;
    data['active_status_label'] = activeStatusLabel;
    data['payment_status'] = paymentStatus;
    data['payment_method'] = paymentMethod;
    data['scheduled'] = scheduled;
    data['schedule_at'] = scheduleAt;
    data['quantity'] = quantity;
    data['details_count'] = detailsCount;
    if (services != null) data['services'] = services!.map((v) => v.toJson()).toList();
    data['booking_amount'] = bookingAmount;
    data['coupon_code'] = couponCode;
    data['is_reviewed'] = isReviewed;
    data['currency_symbol'] = currencySymbol;
    if (provider != null) data['provider'] = provider!.toJson();
    if (customer != null) data['customer'] = customer!.toJson();
    data['created_at'] = createdAt;
    return data;
  }
}

class BookingServiceItemModel {
  String? name;
  String? imageFullUrl;

  BookingServiceItemModel({this.name, this.imageFullUrl});

  BookingServiceItemModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    imageFullUrl = json['image_full_url'];
  }

  Map<String, dynamic> toJson() => {'name': name, 'image_full_url': imageFullUrl};
}

class BookingProviderModel {
  int? id;
  String? name;
  String? phone;
  int? zoneId;
  String? logoFullUrl;
  List<String>? serviceLocation;

  BookingProviderModel({this.id, this.name, this.phone, this.zoneId, this.logoFullUrl, this.serviceLocation});

  BookingProviderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    zoneId = json['zone_id'];
    logoFullUrl = json['logo_full_url'];
    serviceLocation = json['service_location'] != null ? List<String>.from(json['service_location']) : null;
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'phone': phone, 'zone_id': zoneId, 'logo_full_url': logoFullUrl, 'service_location': serviceLocation,
  };
}

class BookingCustomerModel {
  int? id;
  bool? isGuest;
  String? name;
  String? phone;
  String? email;
  String? imageFullUrl;

  BookingCustomerModel({this.id, this.isGuest, this.name, this.phone, this.email, this.imageFullUrl});

  BookingCustomerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isGuest = json['is_guest'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    imageFullUrl = json['image_full_url'];
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'is_guest': isGuest, 'name': name, 'phone': phone, 'email': email, 'image_full_url': imageFullUrl,
  };
}
