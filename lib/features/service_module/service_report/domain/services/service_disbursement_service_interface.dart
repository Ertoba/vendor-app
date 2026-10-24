import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_disbursement_report_model.dart';

abstract class ServiceDisbursementServiceInterface {
  Future<ServiceDisbursementReportModel?> getDisbursementReport(int offset);
}
