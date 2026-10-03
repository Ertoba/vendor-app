import 'package:get/get.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/services/service_disbursement_service_interface.dart';

class ServiceDisbursementController extends GetxController implements GetxService {
  final ServiceDisbursementServiceInterface serviceDisbursementServiceInterface;
  ServiceDisbursementController({required this.serviceDisbursementServiceInterface});

}
