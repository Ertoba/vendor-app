enum NotificationType{
  message,
  order,
  general,
  advertisement,
  block,
  unblock,
  subscription,
  //ignore: constant_identifier_names
  product_approve,
  //ignore: constant_identifier_names
  product_rejected,
  withdraw,
  campaign,
  //ignore: constant_identifier_names
  service_booking,
  //ignore: constant_identifier_names
  custom_service_request,
  //ignore: constant_identifier_names
  custom_service_bid_selected,
  //ignore: constant_identifier_names
  custom_service_bid_denied,
  //ignore: constant_identifier_names
  bogo_offer,
  //ignore: constant_identifier_names
  happy_hour,
}

class NotificationBodyModel {
  NotificationType? notificationType;
  int? orderId;
  int? customerId;
  int? deliveryManId;
  int? conversationId;
  String? type;
  int? advertisementId;
  int? campaignId;
  int? happyHourId;
  int? bogoOfferId;

  NotificationBodyModel({
    this.notificationType,
    this.orderId,
    this.customerId,
    this.deliveryManId,
    this.conversationId,
    this.type,
    this.advertisementId,
    this.campaignId,
    this.happyHourId,
    this.bogoOfferId,
  });

  NotificationBodyModel.fromJson(Map<String, dynamic> json) {
    notificationType = convertToEnum(json['order_notification']);
    orderId = json['order_id'];
    customerId = json['customer_id'];
    deliveryManId = json['delivery_man_id'];
    conversationId = json['conversation_id'];
    type = json['type'];
    advertisementId = json['advertisement_id'];
    campaignId = json['data_id'];
    happyHourId = json['happy_hour_id'];
    bogoOfferId = json['bogo_offer_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_notification'] = notificationType.toString();
    data['order_id'] = orderId;
    data['customer_id'] = customerId;
    data['delivery_man_id'] = deliveryManId;
    data['conversation_id'] = conversationId;
    data['type'] = type;
    data['advertisement_id'] = advertisementId;
    data['data_id'] = campaignId;
    data['happy_hour_id'] = happyHourId;
    data['bogo_offer_id'] = bogoOfferId;
    return data;
  }

  NotificationType convertToEnum(String? enumString) {
    final Map<String, NotificationType> enumMap = {
      NotificationType.general.toString(): NotificationType.general,
      NotificationType.order.toString(): NotificationType.order,
      NotificationType.message.toString(): NotificationType.message,
      NotificationType.advertisement.toString(): NotificationType.advertisement,
      NotificationType.block.toString(): NotificationType.block,
      NotificationType.unblock.toString(): NotificationType.unblock,
      NotificationType.subscription.toString(): NotificationType.subscription,
      NotificationType.product_approve.toString(): NotificationType.product_approve,
      NotificationType.product_rejected.toString(): NotificationType.product_rejected,
      NotificationType.withdraw.toString(): NotificationType.withdraw,
      NotificationType.campaign.toString(): NotificationType.campaign,
      NotificationType.service_booking.toString(): NotificationType.service_booking,
      NotificationType.custom_service_request.toString(): NotificationType.custom_service_request,
      NotificationType.custom_service_bid_selected.toString(): NotificationType.custom_service_bid_selected,
      NotificationType.custom_service_bid_denied.toString(): NotificationType.custom_service_bid_denied,
      NotificationType.bogo_offer.toString(): NotificationType.bogo_offer,
      NotificationType.happy_hour.toString(): NotificationType.happy_hour,
    };

    return enumMap[enumString] ?? NotificationType.general;
  }

}
