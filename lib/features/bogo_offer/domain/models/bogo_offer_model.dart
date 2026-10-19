class BogoOfferModel {
  int? totalSize;
  int? limit;
  int? offset;
  int? all;
  int? notJoined;
  int? pending;
  int? adminRequested;
  int? approved;
  int? rejected;
  List<BogoOffer>? offers;

  BogoOfferModel({
    this.totalSize, this.limit, this.offset, this.all, this.notJoined, this.pending,
    this.adminRequested, this.approved, this.rejected, this.offers,
  });

  BogoOfferModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> counts = json['counts'] is Map
        ? Map<String, dynamic>.from(json['counts']) : json;
    final Map<String, dynamic>? pagination = json['pagination'] is Map
        ? Map<String, dynamic>.from(json['pagination']) : null;

    totalSize = pagination != null ? _toInt(pagination['total']) : _toInt(json['total_size']);
    limit = pagination != null ? _toInt(pagination['per_page']) : _toInt(json['limit']);
    offset = pagination != null ? _toInt(pagination['current_page']) : _toInt(json['offset']);

    all = _toInt(counts['all']);
    notJoined = _toInt(counts['not_joined']);
    pending = _toInt(counts['pending']);
    adminRequested = _toInt(counts['admin_requested']);
    approved = _toInt(counts['approved']);
    rejected = _toInt(counts['rejected']);

    final dynamic rows = json['data'] is List ? json['data'] : json['offers'];
    if(rows is List) {
      offers = [];
      for(final dynamic offer in rows) {
        if(offer is Map) {
          offers!.add(BogoOffer.fromJson(Map<String, dynamic>.from(offer)));
        }
      }
    }
  }

  static int? _toInt(dynamic value) => value == null ? null : (value is int ? value : int.tryParse(value.toString()));
}

class BogoOffer {
  int? id;
  String? slug;
  String? title;
  String? description;
  String? imageFullUrl;
  int? buyQty;
  int? getQty;
  List<String>? orderTypes;
  int? usageLimitTotal;
  int? usageLimitPerCustomer;
  int? totalUses;
  String? startDate;
  String? endDate;
  int? status;
  bool? isExpired;
  bool? isEligible;
  String? ineligibleReason;
  String? enrollmentState;
  BogoEnrollment? enrollment;
  BogoOfferActions? actions;
  String? visibilityStatus;
  String? visibilityLabel;
  List<String>? visibilityReasons;
  String? enrollmentStateLabel;
  String? rejectionNote;

  String? actionsLockedReason;

  BogoOffer({
    this.id, this.slug, this.title, this.description, this.imageFullUrl, this.buyQty, this.getQty,
    this.orderTypes, this.usageLimitTotal, this.usageLimitPerCustomer, this.totalUses, this.startDate,
    this.endDate, this.status, this.isExpired, this.isEligible, this.ineligibleReason, this.enrollmentState,
    this.enrollment, this.actions, this.visibilityStatus, this.visibilityLabel, this.visibilityReasons,
  });

  /// An approved offer the customer app still cannot show — the vendor needs telling why.
  bool get isNotVisibleToCustomers => visibilityStatus == 'not_visible';

  /// An invitation the admin raised that the restaurant has not answered yet.
  bool get isPendingAdminRequest => enrollmentState == 'admin_requested'
      && enrollment?.status == 'pending' && enrollment?.requestedBy == 'admin';

  BogoOffer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    title = json['title'];
    description = json['description'];
    imageFullUrl = json['image_full_url'];
    buyQty = json['buy_qty'];
    getQty = json['get_qty'];
    orderTypes = json['order_types'] != null ? List<String>.from(json['order_types']) : null;
    usageLimitTotal = json['usage_limit_total'];
    usageLimitPerCustomer = json['usage_limit_per_customer'];
    totalUses = json['total_uses'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    status = json['status'];
    isExpired = json['is_expired'];
    isEligible = json['is_eligible'];
    ineligibleReason = json['ineligible_reason'];
    enrollmentState = json['enrollment_state'];
    enrollment = json['enrollment'] != null ? BogoEnrollment.fromJson(json['enrollment']) : null;
    actions = json['actions'] != null ? BogoOfferActions.fromJson(json['actions']) : null;
    enrollmentStateLabel = json['enrollment_state_label'];
    rejectionNote = json['rejection_note'];
    actionsLockedReason = json['actions_locked_reason'];
    visibilityStatus = json['visibility_status'];
    visibilityLabel = json['visibility_label'];
    visibilityReasons = json['visibility_reasons'] != null
        ? List<String>.from(json['visibility_reasons'].map((reason) => reason.toString())) : null;
  }
}

class BogoOfferJoinResponseModel {
  String? message;
  double? bundlePrice;
  String? enrollmentState;

  BogoOfferJoinResponseModel({this.message, this.bundlePrice, this.enrollmentState});

  BogoOfferJoinResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    bundlePrice = double.tryParse(json['bundle_price'].toString());
    enrollmentState = json['enrollment_state'];
  }
}

class BogoOfferActions {
  bool? canJoin;
  bool? canResubmit;
  bool? canRespond;

  bool? canCancel;
  bool? canLeave;

  BogoOfferActions({this.canJoin, this.canResubmit, this.canRespond, this.canCancel, this.canLeave});

  BogoOfferActions.fromJson(Map<String, dynamic> json) {
    canJoin = json['can_join'];
    canResubmit = json['can_resubmit'];
    canRespond = json['can_respond'];
    canCancel = json['can_cancel'];
    canLeave = json['can_leave'];
  }
}

class BogoEnrollment {
  int? id;
  String? status;
  String? requestedBy;
  String? rejectionReason;
  double? bundlePrice;
  String? joinedAt;
  List<BogoEnrollmentItem>? buyItems;
  List<BogoEnrollmentItem>? getItems;

  BogoEnrollment({
    this.id, this.status, this.requestedBy, this.rejectionReason, this.bundlePrice, this.joinedAt,
    this.buyItems, this.getItems,
  });

  BogoEnrollment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    requestedBy = json['requested_by'];
    rejectionReason = json['rejection_reason'];
    bundlePrice = double.tryParse(json['bundle_price'].toString());
    joinedAt = json['joined_at'];
    if(json['buy_items'] != null) {
      buyItems = [];
      json['buy_items'].forEach((item) {
        buyItems!.add(BogoEnrollmentItem.fromJson(item));
      });
    }
    if(json['get_items'] != null) {
      getItems = [];
      json['get_items'].forEach((item) {
        getItems!.add(BogoEnrollmentItem.fromJson(item));
      });
    }
  }
}

class BogoEnrollmentItem {
  int? itemId;
  String? itemName;
  String? itemImageFullUrl;
  double? originalPrice;
  String? variationSummary;
  int? quantity;
  double? price;
  List<dynamic>? variations;
  List<dynamic>? variationOptions;
  List<int>? addOnIds;
  List<int>? addOnQtys;
  List<dynamic>? addOns;

  BogoEnrollmentItem({
    this.itemId, this.itemName, this.itemImageFullUrl, this.quantity, this.price, this.variations,
    this.variationOptions, this.addOnIds, this.addOnQtys, this.addOns,
  });

  BogoEnrollmentItem.fromJson(Map<String, dynamic> json) {
    itemId = json['item_id'] ?? json['food_id'];
    itemName = json['item_name'] ?? json['food_name'];
    itemImageFullUrl = json['item_image_full_url'] ?? json['food_image_full_url'];
    originalPrice = json['original_price'] != null ? double.tryParse(json['original_price'].toString()) : null;
    variationSummary = json['variation_summary'];
    quantity = json['quantity'];
    price = double.tryParse(json['price'].toString());
    variations = json['variations'];
    variationOptions = json['variation_options'];
    addOnIds = json['add_on_ids'] != null ? List<int>.from(json['add_on_ids'].map((v) => int.parse(v.toString()))) : null;
    addOnQtys = json['add_on_qtys'] != null ? List<int>.from(json['add_on_qtys'].map((v) => int.parse(v.toString()))) : null;
    addOns = json['add_ons'];
  }
}


/// One variation group as the join payload expresses it: the group name and the
/// labels chosen inside it. mart's shared order models only carry the legacy
/// `type`/`price` pair, so the food-style shape is defined here with the feature.
class OrderVariation {
  String? name;
  OrderVariationValue? values;

  OrderVariation({this.name, this.values});

  OrderVariation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    values = json['values'] != null ? OrderVariationValue.fromJson(json['values']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if(values != null) {
      data['values'] = values!.toJson();
    }
    return data;
  }
}

class OrderVariationValue {
  List<String?>? label;

  OrderVariationValue({this.label});

  OrderVariationValue.fromJson(Map<String, dynamic> json) {
    label = json['label'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    return data;
  }
}
