import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/features/rental_module/profile/controllers/taxi_profile_controller.dart';
import 'package:sixam_mart_store/features/rental_module/reports/domain/enum/filter_type.dart';
import 'package:sixam_mart_store/features/rental_module/reports/domain/models/rental_earning_report_model.dart';
import 'package:sixam_mart_store/features/rental_module/reports/domain/models/taxi_expense_model.dart';
import 'package:sixam_mart_store/features/rental_module/reports/domain/models/taxi_tax_report_model.dart';
import 'package:sixam_mart_store/features/rental_module/reports/domain/services/taxi_report_service_interface.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';

class TaxiReportController extends GetxController implements GetxService {
  final TaxiReportServiceInterface reportServiceInterface;
  TaxiReportController({required this.reportServiceInterface});

  int? _pageSize;
  int? get pageSize => _pageSize;

  List<String> _offsetList = [];

  bool _setCustom = false;
  bool get setCustom => _setCustom;

  int _offset = 1;
  int get offset => _offset;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Expense>? _expenses;
  List<Expense>? get expenses => _expenses;

  late DateTimeRange _selectedDateRange;

  String? _from;
  String? get from => _from;

  String? _to;
  String? get to => _to;

  String? _searchText;
  String? get searchText => _searchText;

  bool _searchMode = false;
  bool get searchMode => _searchMode;

  TaxiTaxReportModel? _taxReportModel;
  TaxiTaxReportModel? get taxReportModel => _taxReportModel;

  List<Orders>? _orders;
  List<Orders>? get orders => _orders;

  String _type = 'earning';
  String get type => _type;

  RentalEarningReportModel? _rentalEarningReport;
  RentalEarningReportModel? get getRentalEarningReport => _rentalEarningReport;

  String filterType = FilterType.all.name;

  void setType(String type) {
    _type = type;
  }

  void setRentalEarningReportTransactions({RecentTransactions? value}) {
    _rentalEarningReport?.recentTransactions  = value;
    update();
  }

  void setFilter(String filterText, {bool transaction = false, bool order = false, bool campaign = false, bool isTaxReport = false, bool isEarningReport = false}) {
    filterType = filterText;
    update();

    if (filterText == FilterType.all.name) {
      _from = DateConverterHelper.dateTimeForCoupon(DateTime.now().subtract(const Duration(days: 2000)));
      _to = DateConverterHelper.dateTimeForCoupon(DateTime.now());
      _setCustom = false;
    } else if (filterText == FilterType.thisYear.name) {
      _from = DateConverterHelper.dateTimeForCoupon(DateTime.now().subtract(const Duration(days: 365)));
      _to = DateConverterHelper.dateTimeForCoupon(DateTime.now());
      _setCustom = false;
    } else if (filterText == FilterType.previousYear.name) {
      DateTime now = DateTime.now();
      _from = DateConverterHelper.dateTimeForCoupon(DateTime(now.year - 1, 1, 1));
      _to = DateConverterHelper.dateTimeForCoupon(DateTime(now.year - 1, 12, 31));
      _setCustom = false;
    } else if (filterText == FilterType.thisMonth.name) {
      DateTime now = DateTime.now();
      _from = DateConverterHelper.dateTimeForCoupon(DateTime(now.year, now.month, 1));
      _to = DateConverterHelper.dateTimeForCoupon(DateTime.now());
      _setCustom = false;
    } else if (filterText == FilterType.thisWeek.name) {
      DateTime now = DateTime.now();
      int currentWeekday = now.weekday;
      _from = DateConverterHelper.dateTimeForCoupon(now.subtract(Duration(days: currentWeekday - 1)));
      _to = DateConverterHelper.dateTimeForCoupon(DateTime.now());
      _setCustom = false;
    }

    if (isTaxReport) {
      getTaxReport(offset: '1', from: _from, to: _to);
    } else if (transaction) {
      // getTransactionReportList(offset: '1', from: _from, to: _to);
    } else if (order) {
      // getOrderReportList(offset: '1', from: _from, to: _to);
    } else if (campaign) {
      // getCampaignReportList(offset: '1', from: _from, to: _to);
    } else if (isEarningReport) {
      getEarningReport(offset: '1', from: _from, to: _to, type: type);
    } else {
      // getFoodReportList(offset: '1', from: _from, to: _to);
    }
  }

  void showNewDatePicker(BuildContext context, {bool? isTaxReport, bool? isEarningReport}) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'done'.tr,
      confirmText: 'done'.tr,
      cancelText: 'cancel'.tr,
      fieldStartLabelText: 'start_date'.tr,
      fieldEndLabelText: 'end_date'.tr,
      errorInvalidRangeText: 'select_range'.tr,
    );

    if (result != null) {
      _selectedDateRange = result;
      _setCustom = true;
      filterType = FilterType.custom.name;

      if (isTaxReport ?? false) {
        _from = DateConverterHelper.dateTimeForTax(_selectedDateRange.start);
        _to = DateConverterHelper.dateTimeForTax(_selectedDateRange.end);
      } else if (isEarningReport ?? false) {
        _from = DateConverterHelper.dateTimeForCoupon(_selectedDateRange.start);
        _to = DateConverterHelper.dateTimeForCoupon(_selectedDateRange.end);
      } else {
        _from = DateConverterHelper.dateTimeForCoupon(_selectedDateRange.start);
        _to = DateConverterHelper.dateTimeForCoupon(_selectedDateRange.end);
      }

      update();

      if (isTaxReport ?? false) {
        getTaxReport(offset: '1', from: _from, to: _to);
      } else if (isEarningReport ?? false) {
        getEarningReport(offset: '1', from: _from, to: _to, type: type);
      } else {
        getExpenseList(offset: '1', from: _from, to: _to, searchText: searchText);
      }
    }
  }

  List<Map<String, Object>> getEarningData() {
    return [
      {
        'label': "trip_earning",
        'value': getRentalEarningReport?.earningBreakdown?.tripStoreEarning ?? 0.0,
      },
      {
        'label': "tax_amount",
        'value': getRentalEarningReport?.earningBreakdown?.taxAmount ?? 0.0,
      },
    ];
  }

  List<Map<String, Object>> getExpenseData() {
    return [
      {
        'label': "trip_commission_paid",
        'value' : getRentalEarningReport?.expenseBreakdown?.vendorExpenseAmount ?? 0.0,
      },
      {
        'label': "subscription_amount",
        'value' : getRentalEarningReport?.expenseBreakdown?.subscriptionAmount ?? 0.0,
      },      {
        'label': "discount_on_trip",
        'value' : getRentalEarningReport?.expenseBreakdown?.discountOnTrip ?? 0.0,
      },
      {
        'label': "coupon_discount",
        'value' : getRentalEarningReport?.expenseBreakdown?.couponDiscount ?? 0.0,
      },
    ];
  }

  void initSetDate() {
    _from = DateConverterHelper.dateTimeForCoupon(DateTime.now().subtract(const Duration(days: 2000)),);
    _to = DateConverterHelper.dateTimeForCoupon(DateTime.now());
    _searchText = '';
    _setCustom = false;
    filterType = FilterType.all.name;
  }

  void initTaxReportDate() {
    _from = DateConverterHelper.dateTimeForTax(DateTime.now().subtract(const Duration(days: 2000)),);
    _to = DateConverterHelper.dateTimeForTax(DateTime.now());
    _setCustom = false;
  }

  void setSearchText({required String offset, required String? from, required String? to, required String searchText}){
    _searchText = searchText;
    _searchMode = !_searchMode;
    getExpenseList(offset: offset.toString(), from: from, to: to, searchText: searchText);
  }

  Future<void> getExpenseList({required String offset, required String? from, required String? to, required String? searchText}) async {

    if(offset == '1') {
      _offsetList = [];
      _offset = 1;
      _expenses = null;
      update();
    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);

      TaxiExpenseModel? expenseModel = await reportServiceInterface.getExpenseList(
        offset: int.parse(offset), from: from, to: to,
        restaurantId: Get.find<TaxiProfileController>().profileModel!.stores!.id, searchText: searchText,
      );
      if (expenseModel != null) {
        if (offset == '1') {
          _expenses = [];
        }
        _expenses!.addAll(expenseModel.expense!);
        _pageSize = expenseModel.totalSize;
        _isLoading = false;
        update();
      }
    } else {
      if (isLoading) {
        _isLoading = false;
        update();
      }
    }
  }


  Future<void> getEarningReport({required String offset,required String? from, required String? to, required String type, bool onlyTransaction = false, }) async {

    if (offset == '1') {
      _offsetList = [];
      _offset = 1;
      _pageSize = null;
      if (!onlyTransaction) {
        _rentalEarningReport = null;
      } else {
        _rentalEarningReport?.recentTransactions = null;
      }
      update();
    }

    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);

      final int? storeId = Get.find<TaxiProfileController>().profileModel?.id;
      if (storeId == null) {
        _isLoading = false;
        update();
        return;
      }

      RentalEarningReportModel? rentalEarningReport = await reportServiceInterface.getEarningReport(offset: int.parse(offset), restaurantId: storeId, from: from, to: to, type: type,);
      if (rentalEarningReport != null) {
        if (getRentalEarningReport != null) {
          _rentalEarningReport!.recentTransactions ??= RecentTransactions(
            earning: Transaction(data: []),
            expense: Transaction(data: []),
            subscription: Transaction(data: []),
          );
          _rentalEarningReport!.recentTransactions!.earning ??= Transaction(data: []);
          _rentalEarningReport!.recentTransactions!.earning!.data!.addAll(rentalEarningReport.recentTransactions?.earning?.data ?? [],);
          _rentalEarningReport!.recentTransactions!.expense ??= Transaction(data: []);
          _rentalEarningReport!.recentTransactions!.expense!.data!.addAll(rentalEarningReport.recentTransactions?.expense?.data ?? [],);
          _rentalEarningReport!.recentTransactions!.subscription ??= Transaction(data: []);
          _rentalEarningReport!.recentTransactions!.subscription!.data!.addAll(rentalEarningReport.recentTransactions?.subscription?.data ?? [],);
          _isLoading = false;
          _pageSize = rentalEarningReport.totalSize;
        } else {
          _rentalEarningReport = rentalEarningReport;
          _isLoading = false;
          _pageSize = rentalEarningReport.totalSize;
        }
        update();
      } else {
        _isLoading = false;
        update();
      }
    } else {
      if (isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  void setOffset(int offset) {
    _offset = offset;
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void showDatePicker(BuildContext context, {required bool isTaxReport}) async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      currentDate: DateTime.now(),
      saveText: 'Done',
    );

    if (result != null) {
      _selectedDateRange = result;

      if(isTaxReport){
        _from = DateConverterHelper.dateTimeForTax(_selectedDateRange.start);
        _to = DateConverterHelper.dateTimeForTax(_selectedDateRange.end);
      }else{
        _from = _selectedDateRange.start.toString().split(' ')[0];
        _to = _selectedDateRange.end.toString().split(' ')[0];
      }

      update();

      if(isTaxReport){
        getTaxReport(offset: '1', from: _from, to: _to);
      }else{
        getExpenseList(offset: '1', from: _from, to: _to, searchText: searchText);
      }

      debugPrint('===$from / ===$to');
    }
  }

  Future<void> getTaxReport({required String offset, required String? from, required String? to}) async {

    if(offset == '1') {
      _offsetList = [];
      _offset = 1;
      _orders = null;
      update();
    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);

      TaxiTaxReportModel? taxReportModel = await reportServiceInterface.getTaxReport(offset: int.parse(offset), from: from, to: to);
      if (taxReportModel != null) {
        if (offset == '1') {
          _orders = [];
        }
        _taxReportModel = taxReportModel;
        _orders!.addAll(taxReportModel.orders!);
        _pageSize = taxReportModel.totalSize;
        _isLoading = false;
        update();
      }
    } else {
      if (isLoading) {
        _isLoading = false;
        update();
      }
    }
  }
}
