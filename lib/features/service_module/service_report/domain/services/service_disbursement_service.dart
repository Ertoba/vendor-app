import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_disbursement_report_model.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/repositories/service_disbursement_repository_interface.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/services/service_disbursement_service_interface.dart';

class ServiceDisbursementService implements ServiceDisbursementServiceInterface {
  final ServiceDisbursementRepositoryInterface serviceDisbursementRepositoryInterface;
  ServiceDisbursementService({required this.serviceDisbursementRepositoryInterface});

  @override
  Future<ServiceDisbursementReportModel?> getDisbursementReport(int offset) async {
    return await serviceDisbursementRepositoryInterface.getDisbursementReport(offset);
  }
}
