import 'package:get/get.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_booking_report_model.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/repositories/service_booking_report_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class ServiceBookingReportRepository implements ServiceBookingReportRepositoryInterface {
  final ApiClient apiClient;
  ServiceBookingReportRepository({required this.apiClient});

  @override
  Future<ServiceBookingReportModel?> getBookingReport({required int offset, required String filter, required String? from, required String? to, required String? searchText}) async {
    ServiceBookingReportModel? bookingReportModel;
    final String filterQuery = (filter == 'custom' && from != null && to != null && from.isNotEmpty && to.isNotEmpty) ? '&filter=custom&from=$from&to=$to' : '&filter=$filter';
    Response response = await apiClient.getData('${AppConstants.serviceBookingReportUri}?offset=$offset&limit=10$filterQuery&search=${searchText ?? ''}');
    if (response.statusCode == 200) {
      bookingReportModel = ServiceBookingReportModel.fromJson(response.body);
    }
    return bookingReportModel;
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
