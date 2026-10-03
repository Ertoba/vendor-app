import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
import 'package:sixam_mart_store/helper/data_parser_helper.dart';

class OrderDetailsModel {
  int? id;
  int? itemId;
  int? orderId;
  double? price;
  Item? itemDetails;
  List<Variation>? variation;
  List<FoodVariation>? foodVariation;
  List<AddOn>? addOns;
  double? discountOnItem;
  String? discountType;
  int? quantity;
  double? taxAmount;
  String? variant;
  String? createdAt;
  String? updatedAt;
  int? itemCampaignId;
  double? totalAddOnPrice;
  bool? isEditable;
  int? bogoOfferId;
  String? bogoGroupId;
  int? isFreeItem;
  int? bundleId;
  String? bundleGroupId;
  String? bundleName;

  OrderDetailsModel({
    this.id,
    this.itemId,
    this.orderId,
    this.price,
    this.itemDetails,
    this.variation,
    this.foodVariation,
    this.addOns,
    this.discountOnItem,
    this.discountType,
    this.quantity,
    this.taxAmount,
    this.variant,
    this.createdAt,
    this.updatedAt,
    this.itemCampaignId,
    this.totalAddOnPrice,
    this.bogoOfferId,
    this.bogoGroupId,
    this.isFreeItem,
    this.isEditable,
    this.bundleId,
    this.bundleGroupId,
    this.bundleName,
  });

  /// A line that belongs to a BOGO bundle. Bundle lines are priced as a unit, so
  /// their add-ons are already inside the bundle price and must not be re-added.
  bool get isBogoItem => bogoGroupId != null;
  bool get isFree => isFreeItem == 1;

  /// A line that belongs to a product/service bundle package. Mirrors [isBogoItem]:
  /// bundle lines are priced and grouped as a unit under `bundleGroupId`.
  bool get isBundleItem => bundleGroupId != null;

  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    bogoOfferId = json['bogo_offer_id'];
    bogoGroupId = json['bogo_group_id'];
    isFreeItem = json['is_free_item'];
    /// A bundle-package member: every row that shares a `bundle_group_id` is one
    /// copy of the bundle named `bundle_name`. Unlike the cart response, the
    /// order-details endpoint does not fold these into a `bundle_details` object
    /// — each member keeps its own full row (with its own `item_details`).
    bundleId = json['bundle_id'];
    bundleGroupId = json['bundle_group_id'];
    bundleName = json['bundle_name'];
    id = json['id'];
    itemId = json['item_id'];
    orderId = json['order_id'];
    price = json['price'] != null ? json['price']?.toDouble() : 0.0;
    itemDetails = json['item_details'] != null ? Item.fromJson(json['item_details']) : null;
    variation = [];
    foodVariation = [];
    if  ( json [ 'variation' ]  !=   null   &&  json [ 'variation' ]  is   List    &&   ( json [ 'variation' ]  as   List ). isNotEmpty ) {
      final   List   variationList   =   json [ 'variation' ]  as   List ;
      final   firstVariation   =   variationList [ 0 ];
      if  ( firstVariation   !=   null   &&     firstVariation [ 'values' ]  !=   null ) {
        for  ( var   v   in   variationList ) {
          if  ( v   !=   null )  foodVariation  ! . add ( FoodVariation . fromJson ( v ));
        }
      }  else  {
        for  ( var   v   in   variationList ) {
          if  ( v   !=   null )  variation  ! . add ( Variation . fromJson ( v ));
        }
      }
    }
    print("---------order model> ${json [ 'variation' ]}");
    print("---------order model> $variation");
    // if (json['variation'] != null && json['variation'].isNotEmpty) {
    //   if(json['variation'][0]['values'] != null) {
    //     json['variation'].forEach((v) {
    //       foodVariation!.add(FoodVariation.fromJson(v));
    //     });
    //   }else {
    //     json['variation'].forEach((v) {
    //       variation!.add(Variation.fromJson(v));
    //     });
    //   }
    // }
    if (json['add_ons'] != null) {
      addOns = [];
      json['add_ons'].forEach((v) {
        addOns!.add(AddOn.fromJson(v));
      });
    }
    discountOnItem = json['discount_on_item']?.toDouble();
    discountType = json['discount_type'];
    quantity = json['quantity'];
    taxAmount = json['tax_amount']?.toDouble();
    variant = json['variant'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemCampaignId = json['item_campaign_id'];
    totalAddOnPrice = json['total_add_on_price']?.toDouble();
    isEditable = DataParserHelper.parseBool(json['is_editable']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item_id'] = itemId;
    data['order_id'] = orderId;
    data['price'] = price;
    if (itemDetails != null) {
      data['item_details'] = itemDetails!.toJson();
    }
    if (variation != null) {
      data['variation'] = variation!.map((v) => v.toJson()).toList();
    }else if(foodVariation != null) {
      data['variation'] = foodVariation!.map((v) => v.toJson()).toList();
    }
    if (addOns != null) {
      data['add_ons'] = addOns!.map((v) => v.toJson()).toList();
    }
    data['discount_on_item'] = discountOnItem;
    data['discount_type'] = discountType;
    data['quantity'] = quantity;
    data['tax_amount'] = taxAmount;
    data['variant'] = variant;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['item_campaign_id'] = itemCampaignId;
    data['total_add_on_price'] = totalAddOnPrice;
    data['bogo_offer_id'] = bogoOfferId;
    data['bogo_group_id'] = bogoGroupId;
    data['is_free_item'] = isFreeItem;
    data['is_editable'] = isEditable;
    data['bundle_id'] = bundleId;
    data['bundle_group_id'] = bundleGroupId;
    data['bundle_name'] = bundleName;
    return data;
  }
}

class AddOn {
  int? id;
  String? name;
  double? price;
  int? quantity;

  AddOn({this.id, this.name, this.price, this.quantity});

  AddOn.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'] != null ? json['price']?.toDouble() : 0.0;
    quantity = int.parse(json['quantity'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    return data;
  }
}