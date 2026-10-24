import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_earning_report_model.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_tax_report_model.dart';
import 'package:sixam_mart_store/interface/repository_interface.dart';

abstract class ServiceReportRepositoryInterface implements RepositoryInterface {
  Future<dynamic> getExpenseList({required int offset, required int? storeId, required String? from, required String? to, required String? searchText});
  Future<ServiceTaxReportModel?> getTaxReport({required int offset, required String? from, required String? to});
  Future<ServiceEarningReportModel?> getEarningReport({required int offset, required int? storeId, required int? moduleId, required String filter, required String? from, required String? to, required String type});
}
