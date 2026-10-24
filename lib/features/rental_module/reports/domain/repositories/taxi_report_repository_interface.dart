import 'package:sixam_mart_store/features/rental_module/reports/domain/models/rental_earning_report_model.dart';
import 'package:sixam_mart_store/features/rental_module/reports/domain/models/taxi_tax_report_model.dart';
import 'package:sixam_mart_store/interface/repository_interface.dart';

abstract class TaxiReportRepositoryInterface implements RepositoryInterface {
  Future<dynamic> getExpenseList({required int offset, required int? restaurantId, required String? from, required String? to, required String? searchText,});
  Future<TaxiTaxReportModel?> getTaxReport({required int offset, required String? from, required String? to,});
  Future<RentalEarningReportModel?> getEarningReport({required int offset, required int restaurantId, required String? from, required String? to, required String type,});
}
