import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_earning_report_model.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_expense_model.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_tax_report_model.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/repositories/service_report_repository_interface.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/services/service_report_service_interface.dart';

class ServiceReportService implements ServiceReportServiceInterface {
  final ServiceReportRepositoryInterface serviceReportRepositoryInterface;
  ServiceReportService({required this.serviceReportRepositoryInterface});

  @override
  Future<ServiceExpenseModel?> getExpenseList({required int offset, required int? storeId, required String? from, required String? to, required String? searchText}) async {
    return await serviceReportRepositoryInterface.getExpenseList(offset: offset, storeId: storeId, from: from, to: to, searchText: searchText);
  }

  @override
  Future<ServiceTaxReportModel?> getTaxReport({required int offset, required String? from, required String? to}) async {
    return await serviceReportRepositoryInterface.getTaxReport(offset: offset, from: from, to: to);
  }

  @override
  Future<ServiceEarningReportModel?> getEarningReport({required int offset, required int? storeId, required int? moduleId, required String filter, required String? from, required String? to, required String type}) async {
    return await serviceReportRepositoryInterface.getEarningReport(offset: offset, storeId: storeId, moduleId: moduleId, filter: filter, from: from, to: to, type: type);
  }
}
