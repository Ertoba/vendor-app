import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_disbursement_report_model.dart';
import 'package:sixam_mart_store/interface/repository_interface.dart';

abstract class ServiceDisbursementRepositoryInterface implements RepositoryInterface {
  Future<ServiceDisbursementReportModel?> getDisbursementReport(int offset);
}
