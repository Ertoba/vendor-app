import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_booking_report_model.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/repositories/service_booking_report_repository_interface.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/services/service_booking_report_service_interface.dart';

class ServiceBookingReportService implements ServiceBookingReportServiceInterface {
  final ServiceBookingReportRepositoryInterface serviceBookingReportRepositoryInterface;
  ServiceBookingReportService({required this.serviceBookingReportRepositoryInterface});

  @override
  Future<ServiceBookingReportModel?> getBookingReport({required int offset, required String filter, required String? from, required String? to, required String? searchText}) async {
    return await serviceBookingReportRepositoryInterface.getBookingReport(offset: offset, filter: filter, from: from, to: to, searchText: searchText);
  }
}
