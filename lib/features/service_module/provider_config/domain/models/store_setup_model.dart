class StoreSetupModel {
  StoreSetupBookingTypesModel? bookingTypes;
  StoreSetupServiceLocationModel? serviceLocation;
  StoreSetupServicemanPermissionModel? servicemanPermission;

  StoreSetupModel({this.bookingTypes, this.serviceLocation, this.servicemanPermission});

  StoreSetupModel.fromJson(Map<String, dynamic> json) {
    bookingTypes = json['booking_types'] != null ? StoreSetupBookingTypesModel.fromJson(json['booking_types']) : null;
    serviceLocation = json['service_location'] != null ? StoreSetupServiceLocationModel.fromJson(json['service_location']) : null;
    servicemanPermission = json['serviceman_permission'] != null ? StoreSetupServicemanPermissionModel.fromJson(json['serviceman_permission']) : null;
  }
}

class StoreSetupBookingTypesModel {
  bool? instantBooking;
  bool? repeatBooking;
  bool? scheduleBooking;
  bool? instantBookingEditable;
  bool? repeatBookingEditable;
  bool? scheduleBookingEditable;

  StoreSetupBookingTypesModel({
    this.instantBooking, this.repeatBooking, this.scheduleBooking,
    this.instantBookingEditable, this.repeatBookingEditable, this.scheduleBookingEditable,
  });

  StoreSetupBookingTypesModel.fromJson(Map<String, dynamic> json) {
    instantBooking = json['instant_booking'];
    repeatBooking = json['repeat_booking'];
    scheduleBooking = json['schedule_booking'];
    instantBookingEditable = json['instant_booking_editable'];
    repeatBookingEditable = json['repeat_booking_editable'];
    scheduleBookingEditable = json['schedule_booking_editable'];
  }
}

class StoreSetupServiceLocationModel {
  List<String>? chooseServiceLocation;
  bool? providerPlaceEditable;

  StoreSetupServiceLocationModel({this.chooseServiceLocation, this.providerPlaceEditable});

  StoreSetupServiceLocationModel.fromJson(Map<String, dynamic> json) {
    chooseServiceLocation = json['choose_service_location'] != null ? List<String>.from(json['choose_service_location']) : null;
    providerPlaceEditable = json['provider_place_editable'];
  }
}

class StoreSetupServicemanPermissionModel {
  bool? servicemanCanCancelBooking;
  bool? servicemanCanCancelBookingEditable;

  StoreSetupServicemanPermissionModel({this.servicemanCanCancelBooking, this.servicemanCanCancelBookingEditable});

  StoreSetupServicemanPermissionModel.fromJson(Map<String, dynamic> json) {
    servicemanCanCancelBooking = json['serviceman_can_cancel_booking'];
    servicemanCanCancelBookingEditable = json['serviceman_can_cancel_booking_editable'];
  }
}
