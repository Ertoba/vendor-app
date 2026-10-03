import 'package:sixam_mart_store/helper/data_parser_helper.dart';

class ModulePermissionModel {
  bool? dashboard;
  bool? profile;
  bool? order;
  bool? pos;
  bool? item;
  bool? addon;
  bool? category;
  bool? campaign;
  bool? coupon;
  bool? banner;
  bool? advertisement;
  bool? advertisementList;
  bool? deliveryman;
  bool? deliverymanList;
  bool? serviceman;
  bool? servicemanList;
  bool? wallet;
  bool? walletMethod;
  bool? role;
  bool? employee;
  bool? expenseReport;
  bool? disbursementReport;
  bool? vatReport;
  bool? storeSetup;
  bool? notificationSetup;
  bool? myShop;
  bool? businessPlan;
  bool? reviews;
  bool? chat;
  bool? reels;

  ModulePermissionModel({
    this.dashboard,
    this.profile,
    this.order,
    this.pos,
    this.item,
    this.addon,
    this.category,
    this.campaign,
    this.coupon,
    this.banner,
    this.advertisement,
    this.advertisementList,
    this.deliveryman,
    this.deliverymanList,
    this.serviceman,
    this.servicemanList,
    this.wallet,
    this.walletMethod,
    this.role,
    this.employee,
    this.expenseReport,
    this.disbursementReport,
    this.vatReport,
    this.storeSetup,
    this.notificationSetup,
    this.myShop,
    this.businessPlan,
    this.reviews,
    this.chat,
    this.reels,
  });

  ModulePermissionModel.fromJson(Map<String, dynamic> json) {
    dashboard = DataParserHelper.parseBool(json['dashboard']);
    profile = DataParserHelper.parseBool(json['profile']);
    order = DataParserHelper.parseBool(json['order']);
    pos = DataParserHelper.parseBool(json['pos']);
    item = DataParserHelper.parseBool(json['item']);
    addon = DataParserHelper.parseBool(json['addon']);
    category = DataParserHelper.parseBool(json['category']);
    campaign = DataParserHelper.parseBool(json['campaign']);
    coupon = DataParserHelper.parseBool(json['coupon']);
    banner = DataParserHelper.parseBool(json['banner']);
    advertisement = DataParserHelper.parseBool(json['advertisement']);
    advertisementList = DataParserHelper.parseBool(json['advertisement_list']);
    deliveryman = DataParserHelper.parseBool(json['deliveryman']);
    deliverymanList = DataParserHelper.parseBool(json['deliveryman_list']);
    serviceman = DataParserHelper.parseBool(json['serviceman']);
    servicemanList = DataParserHelper.parseBool(json['serviceman_list']);
    wallet = DataParserHelper.parseBool(json['wallet']);
    walletMethod = DataParserHelper.parseBool(json['wallet_method']);
    role = DataParserHelper.parseBool(json['role']);
    employee = DataParserHelper.parseBool(json['employee']);
    expenseReport = DataParserHelper.parseBool(json['expense_report']);
    disbursementReport = DataParserHelper.parseBool(json['disbursement_report']);
    vatReport = DataParserHelper.parseBool(json['vat_report']);
    storeSetup = DataParserHelper.parseBool(json['store_setup']);
    notificationSetup = DataParserHelper.parseBool(json['notification_setup']);
    myShop = DataParserHelper.parseBool(json['my_shop']);
    businessPlan = DataParserHelper.parseBool(json['business_plan']);
    reviews = DataParserHelper.parseBool(json['reviews']);
    chat = DataParserHelper.parseBool(json['chat']);
    reels = DataParserHelper.parseBool(json['reels']);
  }

  Map<String, bool?> toJson() {
    final Map<String, bool?> data = <String, bool?>{};
    data['dashboard'] = dashboard;
    data['profile'] = profile;
    data['order'] = order;
    data['pos'] = pos;
    data['item'] = item;
    data['addon'] = addon;
    data['category'] = category;
    data['campaign'] = campaign;
    data['coupon'] = coupon;
    data['banner'] = banner;
    data['advertisement'] = advertisement;
    data['advertisement_list'] = advertisementList;
    data['deliveryman'] = deliveryman;
    data['deliveryman_list'] = deliverymanList;
    data['serviceman'] = serviceman;
    data['serviceman_list'] = servicemanList;
    data['wallet'] = wallet;
    data['wallet_method'] = walletMethod;
    data['role'] = role;
    data['employee'] = employee;
    data['expense_report'] = expenseReport;
    data['disbursement_report'] = disbursementReport;
    data['vat_report'] = vatReport;
    data['store_setup'] = storeSetup;
    data['notification_setup'] = notificationSetup;
    data['my_shop'] = myShop;
    data['business_plan'] = businessPlan;
    data['reviews'] = reviews;
    data['chat'] = chat;
    data['reels'] = reels;
    return data;
  }
}
