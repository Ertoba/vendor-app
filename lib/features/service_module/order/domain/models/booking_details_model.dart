import 'package:sixam_mart_store/features/service_module/order/domain/models/booking_model.dart';
import 'package:sixam_mart_store/features/service_module/order/helper/booking_status_helper.dart';

class BookingDetailsModel {
  int? id;
  String? displayId;
  String? bookingType;
  String? multiBookingType;
  int? parentBookingId;
  bool? isRepeatParent;
  int? childBookingsCount;
  bool? isCustom;
  String? bookingStatus;
  String? statusLabel;
  Map<String, String>? statusHistory;
  String? paymentStatus;
  String? paymentMethod;
  String? transactionReference;
  int? scheduled;
  String? scheduleAt;
  int? quantity;
  String? otp;
  String? bookingNote;
  String? cancellationReason;
  String? canceledBy;
  BookingServiceLocationModel? serviceLocation;
  BookingAmountModel? amount;
  String? couponCode;
  bool? isReviewed;
  String? currencySymbol;
  BookingProviderModel? provider;
  BookingCustomerModel? customer;
  List<BookingDetailItemModel>? details;
  List<BookingRepeatLogModel>? repeatLog;
  String? createdAt;
  String? updatedAt;

  List<BookingServiceManModel>? servicemen;

  // --- TODO(verify-api): unconfirmed shapes (both null/empty in the sample response seen so far) ---
  BookingOfflinePaymentModel? offlinePayment;
  List<BookingPartialPaymentModel>? partialPayments;

  BookingDetailsModel({
    this.id, this.displayId, this.bookingType, this.multiBookingType, this.parentBookingId, this.isRepeatParent,
    this.childBookingsCount, this.isCustom, this.bookingStatus, this.statusLabel, this.statusHistory,
    this.paymentStatus, this.paymentMethod, this.transactionReference, this.scheduled, this.scheduleAt,
    this.quantity, this.otp, this.bookingNote, this.cancellationReason, this.canceledBy, this.serviceLocation,
    this.amount, this.couponCode, this.isReviewed, this.currencySymbol, this.provider, this.customer,
    this.details, this.repeatLog, this.createdAt, this.updatedAt, this.servicemen, this.offlinePayment, this.partialPayments,
  });

  bool get canManageBookingStatus {
    if (BookingStatusHelper.isClosed(bookingStatus)) return false;
    if (bookingType == 'repeat' && isRepeatParent == true) return false;
    return true;
  }

  BookingDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['display_id'];
    bookingType = json['booking_type'];
    multiBookingType = json['multi_booking_type'];
    parentBookingId = json['parent_booking_id'];
    isRepeatParent = json['is_repeat_parent'];
    childBookingsCount = json['child_bookings_count'];
    isCustom = json['is_custom'];
    bookingStatus = json['booking_status'];
    statusLabel = json['status_label'];
    statusHistory = json['status_history'] != null ? Map<String, String>.from(json['status_history']) : null;
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    transactionReference = json['transaction_reference'];
    scheduled = json['scheduled'];
    scheduleAt = json['schedule_at'];
    quantity = json['quantity'];
    otp = json['otp']?.toString();
    bookingNote = json['booking_note'];
    cancellationReason = json['cancellation_reason'];
    canceledBy = json['canceled_by'];
    serviceLocation = json['service_location'] != null ? BookingServiceLocationModel.fromJson(json['service_location']) : null;
    amount = json['amount'] != null ? BookingAmountModel.fromJson(json['amount']) : null;
    couponCode = json['coupon_code'];
    isReviewed = json['is_reviewed'];
    currencySymbol = json['currency_symbol'];
    provider = json['provider'] != null ? BookingProviderModel.fromJson(json['provider']) : null;
    customer = json['customer'] != null ? BookingCustomerModel.fromJson(json['customer']) : null;
    if (json['details'] != null) {
      details = <BookingDetailItemModel>[];
      json['details'].forEach((v) {
        details!.add(BookingDetailItemModel.fromJson(v));
      });
    }
    if (json['repeat_log'] != null) {
      repeatLog = <BookingRepeatLogModel>[];
      json['repeat_log'].forEach((v) {
        repeatLog!.add(BookingRepeatLogModel.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];

    if (json['servicemen'] != null) {
      servicemen = <BookingServiceManModel>[];
      json['servicemen'].forEach((v) {
        servicemen!.add(BookingServiceManModel.fromJson(v));
      });
    }

    try {
      offlinePayment = json['offline_payment'] != null ? BookingOfflinePaymentModel.fromJson(json['offline_payment']) : null;
    } catch (_) { offlinePayment = null; }

    try {
      if (json['partial_payments'] != null) {
        partialPayments = <BookingPartialPaymentModel>[];
        for (final v in json['partial_payments']) {
          try { partialPayments!.add(BookingPartialPaymentModel.fromJson(v)); } catch (_) {}
        }
      }
    } catch (_) { partialPayments = null; }
  }
}

class BookingRepeatLogModel {
  int? id;
  String? displayId;
  String? bookingStatus;
  String? scheduleAt;

  BookingRepeatLogModel({this.id, this.displayId, this.bookingStatus, this.scheduleAt});

  BookingRepeatLogModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayId = json['display_id'];
    bookingStatus = json['booking_status'];
    scheduleAt = json['schedule_at'];
  }
}

class BookingServiceManModel {
  int? id;
  String? name;
  String? phone;
  String? imageFullUrl;

  BookingServiceManModel({this.id, this.name, this.phone, this.imageFullUrl});

  BookingServiceManModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    imageFullUrl = json['image_full_url'];
  }
}

class BookingAmountModel {
  double? bookingAmount;
  double? discountAmount;
  double? couponDiscountAmount;
  double? proDiscount;
  double? refBonusAmount;
  double? taxAmount;
  String? taxStatus;
  double? additionalCharge;
  double? partiallyPaidAmount;

  BookingAmountModel({
    this.bookingAmount, this.discountAmount, this.couponDiscountAmount, this.proDiscount, this.refBonusAmount,
    this.taxAmount, this.taxStatus, this.additionalCharge, this.partiallyPaidAmount,
  });

  BookingAmountModel.fromJson(Map<String, dynamic> json) {
    bookingAmount = json['booking_amount']?.toDouble();
    discountAmount = json['discount_amount']?.toDouble();
    couponDiscountAmount = json['coupon_discount_amount']?.toDouble();
    proDiscount = json['pro_discount']?.toDouble();
    refBonusAmount = json['ref_bonus_amount']?.toDouble();
    taxAmount = json['tax_amount']?.toDouble();
    taxStatus = json['tax_status'];
    additionalCharge = json['additional_charge']?.toDouble();
    partiallyPaidAmount = json['partially_paid_amount']?.toDouble();
  }
}

class BookingServiceLocationModel {
  String? getServiceAt;
  String? address;
  double? lat;
  double? lng;

  BookingServiceLocationModel({this.getServiceAt, this.address, this.lat, this.lng});

  BookingServiceLocationModel.fromJson(Map<String, dynamic> json) {
    getServiceAt = json['get_service_at'];
    address = json['address'];
    lat = double.tryParse(json['lat'].toString());
    lng = double.tryParse(json['lng'].toString());
  }
}

class BookingDetailItemModel {
  int? id;
  int? serviceId;
  String? serviceName;
  bool? isCustom;
  int? categoryId;
  int? subCategoryId;
  int? quantity;
  double? price;
  double? originalPrice;
  double? calculatedPrice;
  double? discountAmount;
  String? discountType;
  String? discountBy;
  double? discountPercentage;
  double? taxAmount;
  double? taxPercentage;
  String? taxStatus;
  List<dynamic>? variation;
  String? description;

  BookingDetailItemModel({
    this.id, this.serviceId, this.serviceName, this.isCustom, this.categoryId, this.subCategoryId,
    this.quantity, this.price, this.originalPrice, this.calculatedPrice, this.discountAmount, this.discountType,
    this.discountBy, this.discountPercentage, this.taxAmount, this.taxPercentage, this.taxStatus,
    this.variation, this.description,
  });

  BookingDetailItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceId = json['service_id'];
    serviceName = json['service_name'];
    isCustom = json['is_custom'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    quantity = json['quantity'];
    price = json['price']?.toDouble();
    originalPrice = json['original_price']?.toDouble();
    calculatedPrice = json['calculated_price']?.toDouble();
    discountAmount = json['discount_amount']?.toDouble();
    discountType = json['discount_type'];
    discountBy = json['discount_by'];
    discountPercentage = json['discount_percentage']?.toDouble();
    taxAmount = json['tax_amount']?.toDouble();
    taxPercentage = json['tax_percentage']?.toDouble();
    taxStatus = json['tax_status'];
    variation = json['variation'] != null ? List<dynamic>.from(json['variation']) : null;
    description = json['description'];
  }
}

class BookingOfflinePaymentModel {
  String? methodName;
  List<String>? attachmentFullUrl;
  String? note;

  BookingOfflinePaymentModel({this.methodName, this.attachmentFullUrl, this.note});

  BookingOfflinePaymentModel.fromJson(Map<String, dynamic> json) {
    methodName = json['method_name'];
    attachmentFullUrl = json['attachment_full_url'] != null ? List<String>.from(json['attachment_full_url']) : null;
    note = json['note'];
  }
}

class BookingPartialPaymentModel {
  double? amount;
  String? paymentMethod;
  String? paymentStatus;
  String? createdAt;

  BookingPartialPaymentModel({this.amount, this.paymentMethod, this.paymentStatus, this.createdAt});

  BookingPartialPaymentModel.fromJson(Map<String, dynamic> json) {
    amount = json['amount']?.toDouble();
    paymentMethod = json['payment_method'];
    paymentStatus = json['payment_status'];
    createdAt = json['created_at'];
  }
}
