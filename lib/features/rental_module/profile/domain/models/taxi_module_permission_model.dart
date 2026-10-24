import 'package:sixam_mart_store/helper/data_parser_helper.dart';

class TaxiModulePermissionModel{
  bool? trip;
  bool? vehicle;
  bool? driver;
  bool? marketing;
  bool? storeSetup;
  bool? myWallet;
  bool? profile;
  bool? rentalEmployees;
  bool? myShop;
  bool? reviews;
  bool? chat;
  bool? rentalReport;

  TaxiModulePermissionModel({
    this.trip,
    this.vehicle,
    this.driver,
    this.marketing,
    this.storeSetup,
    this.myWallet,
    this.profile,
    this.rentalEmployees,
    this.myShop,
    this.reviews,
    this.chat,
    this.rentalReport,
  });

  TaxiModulePermissionModel.fromJson(Map<String, dynamic> json) {
    trip = DataParserHelper.parseBool(json['trip']);
    vehicle = DataParserHelper.parseBool(json['vehicle']);
    driver = DataParserHelper.parseBool(json['driver']);
    marketing = DataParserHelper.parseBool(json['marketing']);
    storeSetup = DataParserHelper.parseBool(json['store_setup']);
    myWallet = DataParserHelper.parseBool(json['my_wallet']);
    profile = DataParserHelper.parseBool(json['profile']);
    rentalEmployees = DataParserHelper.parseBool(json['rental_employees']);
    myShop = DataParserHelper.parseBool(json['my_shop']);
    reviews = DataParserHelper.parseBool(json['reviews']);
    chat = DataParserHelper.parseBool(json['chat']);
    rentalReport = DataParserHelper.parseBool(json['rental_report']);
  }

  Map<String, bool?> toJson() {
    final Map<String, bool?> data = <String, bool?>{};
    data['trip'] = trip ;
    data['vehicle'] = vehicle;
    data['driver'] = driver;
    data['marketing'] = marketing;
    data['store_setup'] = storeSetup;
    data['my_wallet'] = myWallet;
    data['profile'] = profile;
    data['rental_employees'] = rentalEmployees;
    data['my_shop'] = myShop;
    data['reviews'] = reviews;
    data['chat'] = chat;
    data['rental_report'] = rentalReport;
    return data;
  }
}