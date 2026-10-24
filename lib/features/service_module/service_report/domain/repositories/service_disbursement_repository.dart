import 'package:get/get.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_disbursement_report_model.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/repositories/service_disbursement_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class ServiceDisbursementRepository implements ServiceDisbursementRepositoryInterface {
  final ApiClient apiClient;
  ServiceDisbursementRepository({required this.apiClient});

  @override
  Future<ServiceDisbursementReportModel?> getDisbursementReport(int offset) async {
    ServiceDisbursementReportModel? disbursementReportModel;
    Response response = await apiClient.getData('${AppConstants.serviceDisbursementReportUri}?limit=10&offset=$offset');
    if (response.statusCode == 200) {
      disbursementReportModel = ServiceDisbursementReportModel.fromJson(response.body);
    }
    return disbursementReportModel;
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
