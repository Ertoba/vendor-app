import 'package:get/get.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_catalog_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_preview_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/repositories/booking_edit_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class BookingEditRepository implements BookingEditRepositoryInterface {
  final ApiClient apiClient;
  BookingEditRepository({required this.apiClient});

  @override
  Future<BookingEditCatalogResponseModel?> getEditCatalog(int bookingId) async {
    Response response = await apiClient.getData('${AppConstants.bookingEditCatalogUri}$bookingId', handleError: false);
    if (response.statusCode == 200) {
      return BookingEditCatalogResponseModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<BookingEditPreviewResult> previewEdit(int bookingId, Map<String, dynamic> body) async {
    Response response = await apiClient.postData('${AppConstants.bookingEditPreviewUri}$bookingId', body, handleError: false);
    if (response.statusCode == 200) {
      return BookingEditPreviewResult(isSuccess: true, preview: BookingEditPreviewModel.fromJson(response.body));
    }
    return BookingEditPreviewResult(isSuccess: false, message: _errorMessage(response));
  }

  @override
  Future<ResponseModel> updateEdit(int bookingId, Map<String, dynamic> body) async {
    Response response = await apiClient.postData('${AppConstants.bookingEditUpdateUri}$bookingId', body, handleError: false);
    if (response.statusCode == 200) {
      return ResponseModel(true, response.body['message']);
    }
    return ResponseModel(false, _errorMessage(response));
  }

  String? _errorMessage(Response response) {
    if (response.body != null && response.body['errors'] != null && response.body['errors'].isNotEmpty) {
      return response.body['errors'][0]['message'];
    }
    return response.statusText;
  }
}
