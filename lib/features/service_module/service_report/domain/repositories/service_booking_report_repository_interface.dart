import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_booking_report_model.dart';
import 'package:sixam_mart_store/interface/repository_interface.dart';

abstract class ServiceBookingReportRepositoryInterface implements RepositoryInterface {
  Future<ServiceBookingReportModel?> getBookingReport({required int offset, required String filter, required String? from, required String? to, required String? searchText});
}
