import 'package:get/get.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_earning_report_model.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_expense_model.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_tax_report_model.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/repositories/service_report_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class ServiceReportRepository implements ServiceReportRepositoryInterface {
  final ApiClient apiClient;
  ServiceReportRepository({required this.apiClient});

  @override
  Future<ServiceExpenseModel?> getExpenseList({required int offset, required int? storeId, required String? from, required String? to, required String? searchText}) async {
    ServiceExpenseModel? expenseModel;
    Response response = await apiClient.getData('${AppConstants.serviceExpenseListUri}?limit=10&offset=$offset&from=$from&to=$to&search=${searchText ?? ''}');
    if (response.statusCode == 200) {
      expenseModel = ServiceExpenseModel.fromJson(response.body);
    }
    return expenseModel;
  }

  @override
  Future<ServiceTaxReportModel?> getTaxReport({required int offset, required String? from, required String? to}) async {
    ServiceTaxReportModel? taxReportModel;
    Response response = await apiClient.getData('${AppConstants.serviceTaxReportUri}?limit=10&offset=$offset&from=$from&to=$to');
    if (response.statusCode == 200) {
      taxReportModel = ServiceTaxReportModel.fromJson(response.body);
    }
    return taxReportModel;
  }

  @override
  Future<ServiceEarningReportModel?> getEarningReport({required int offset, required int? storeId, required int? moduleId, required String filter, required String? from, required String? to, required String type}) async {
    ServiceEarningReportModel? earningReportModel;
    final String filterQuery = (filter == 'custom' && from != null && to != null && from.isNotEmpty && to.isNotEmpty) ? '&filter=custom&from=$from&to=$to' : '&filter=$filter';
    Response response = await apiClient.getData('${AppConstants.serviceEarningReportUri}?module_id=$moduleId&offset=$offset&limit=10$filterQuery&type=$type');
    if (response.statusCode == 200) {
      earningReportModel = ServiceEarningReportModel.fromJson(response.body);
    }
    return earningReportModel;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(int? id) {
    throw UnimplementedError();
  }

  @override
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }
}
