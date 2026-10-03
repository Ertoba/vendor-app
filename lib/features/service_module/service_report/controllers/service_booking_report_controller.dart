import 'package:get/get.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/services/service_booking_report_service_interface.dart';

class ServiceBookingReportController extends GetxController implements GetxService {
  final ServiceBookingReportServiceInterface serviceBookingReportServiceInterface;
  ServiceBookingReportController({required this.serviceBookingReportServiceInterface});

}
