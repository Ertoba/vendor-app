import 'package:sixam_mart_store/features/rental_module/reports/domain/models/rental_earning_report_model.dart';
import 'package:sixam_mart_store/features/rental_module/reports/domain/models/taxi_expense_model.dart';
import 'package:sixam_mart_store/features/rental_module/reports/domain/models/taxi_tax_report_model.dart';
import 'package:sixam_mart_store/features/rental_module/reports/domain/repositories/taxi_report_repository_interface.dart';
import 'package:sixam_mart_store/features/rental_module/reports/domain/services/taxi_report_service_interface.dart';

class TaxiReportService implements TaxiReportServiceInterface {
  final TaxiReportRepositoryInterface reportRepositoryInterface;
  TaxiReportService({required this.reportRepositoryInterface});

  @override
  Future<TaxiExpenseModel?> getExpenseList({required int offset, required int? restaurantId, required String? from, required String? to,  required String? searchText}) async {
    return await reportRepositoryInterface.getExpenseList(offset: offset, restaurantId: restaurantId, from: from, to: to, searchText: searchText);
  }

  @override
  Future<TaxiTaxReportModel?> getTaxReport({required int offset, required String? from, required String? to}) async {
    return await reportRepositoryInterface.getTaxReport(offset: offset, from: from, to: to);
  }

  @override
  Future<RentalEarningReportModel?> getEarningReport({required int offset, required int restaurantId, required String? from, required String? to, required String type,}) async {
    return await reportRepositoryInterface.getEarningReport(offset: offset, restaurantId: restaurantId, from: from, to: to, type: type,);
  }
}
