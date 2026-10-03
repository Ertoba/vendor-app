import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_booking_report_model.dart';

abstract class ServiceBookingReportServiceInterface {
  Future<ServiceBookingReportModel?> getBookingReport({required int offset, required String filter, required String? from, required String? to, required String? searchText});
}
