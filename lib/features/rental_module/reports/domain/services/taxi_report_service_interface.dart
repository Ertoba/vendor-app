import 'package:sixam_mart_store/features/rental_module/reports/domain/models/rental_earning_report_model.dart';
import 'package:sixam_mart_store/features/rental_module/reports/domain/models/taxi_expense_model.dart';
import 'package:sixam_mart_store/features/rental_module/reports/domain/models/taxi_tax_report_model.dart';

abstract class TaxiReportServiceInterface {
  Future<TaxiExpenseModel?> getExpenseList({required int offset, required int? restaurantId, required String? from, required String? to, required String? searchText});
  Future<TaxiTaxReportModel?> getTaxReport({required int offset, required String? from, required String? to});
  Future<RentalEarningReportModel?> getEarningReport({required int offset, required int restaurantId, required String? from, required String? to, required String type,});
}
