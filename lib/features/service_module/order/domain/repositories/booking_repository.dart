import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_cancellation_body_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/models/assignable_service_man_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/models/booking_details_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/models/booking_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/repositories/booking_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class BookingRepository implements BookingRepositoryInterface {
  final ApiClient apiClient;
  BookingRepository({required this.apiClient});

  @override
  Future<BookingListModel?> getBookingList({required int limit, required int offset, required String status}) async {
    BookingListModel? model;
    Response response = await apiClient.getData('${AppConstants.bookingListUri}?status=$status&limit=$limit&offset=$offset');
    if (response.statusCode == 200) {
      model = BookingListModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future<BookingDetailsModel?> getBookingDetails(int id) async {
    BookingDetailsModel? model;
    Response response = await apiClient.getData('${AppConstants.bookingDetailsUri}$id');
    if (response.statusCode == 200) {
      model = BookingDetailsModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future<ResponseModel> updateBookingStatus(int id, String status, {String? cancellationReason, String? otp, List<XFile>? evidenceImages}) async {
    ResponseModel responseModel;
    Response response;
    if ((otp != null && otp.isNotEmpty) || (evidenceImages != null && evidenceImages.isNotEmpty)) {
      Map<String, String> fields = {'booking_status': status};
      if (otp != null && otp.isNotEmpty) {
        fields['otp'] = otp;
      }
      List<MultipartBody> multiParts = [];
      for (XFile image in evidenceImages ?? []) {
        multiParts.add(MultipartBody('completion_evidence[]', image));
      }
      response = await apiClient.postMultipartData('${AppConstants.bookingStatusUri}$id', fields, multiParts, handleError: false);
    } else {
      Map<String, dynamic> body = {
        'booking_status': status,
        if (cancellationReason != null && cancellationReason.isNotEmpty) 'cancellation_reason': cancellationReason,
      };
      response = await apiClient.postData('${AppConstants.bookingStatusUri}$id', body, handleError: false);
    }
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, _errorMessage(response));
    }
    return responseModel;
  }

  @override
  Future<OrderCancellationBodyModel?> getCancelReasons() async {
    OrderCancellationBodyModel? orderCancellationBody;
    Response response = await apiClient.getData('${AppConstants.orderCancellationUri}?offset=1&limit=30&type=store');
    if (response.statusCode == 200) {
      orderCancellationBody = OrderCancellationBodyModel.fromJson(response.body);
    }
    return orderCancellationBody;
  }

  @override
  Future<List<AssignableServiceManModel>?> getAssignableServicemen(int bookingId, {String? search}) async {
    List<AssignableServiceManModel>? list;
    String uri = '${AppConstants.bookingAssignableServicemenUri}$bookingId';
    if (search != null && search.isNotEmpty) {
      uri += '?search=$search';
    }
    Response response = await apiClient.getData(uri);
    if (response.statusCode == 200) {
      list = [];
      response.body['servicemen'].forEach((v) => list!.add(AssignableServiceManModel.fromJson(v)));
    }
    return list;
  }

  @override
  Future<ResponseModel> assignServicemen(int bookingId, List<int> servicemanIds) async {
    Response response = await apiClient.postData(
      '${AppConstants.bookingAssignServicemanUri}$bookingId', {'serviceman_ids': servicemanIds}, handleError: false,
    );
    if (response.statusCode == 200) {
      return ResponseModel(true, response.body['message']);
    }
    return ResponseModel(false, _errorMessage(response));
  }

  @override
  Future<List<int>?> getBookingInvoice(int bookingId) async {
    final http.Response response = await http.get(
      Uri.parse('${apiClient.appBaseUrl}${AppConstants.bookingInvoiceUri}$bookingId'),
      headers: apiClient.getHeader(),
    );
    return response.statusCode == 200 ? response.bodyBytes : null;
  }

  @override
  Future<ResponseModel> updateServiceLocation(int bookingId, String serviceLocationStatus) async {
    Response response = await apiClient.postData(
      '${AppConstants.bookingUpdateLocationUri}$bookingId', {'service_location_status': serviceLocationStatus}, handleError: false,
    );
    if (response.statusCode == 200) {
      return ResponseModel(true, response.body['message']);
    }
    return ResponseModel(false, _errorMessage(response));
  }

  @override
  Future<ResponseModel> rescheduleBooking(int bookingId, String scheduleAt) async {
    Response response = await apiClient.postData(
      '${AppConstants.bookingRescheduleUri}$bookingId', {'service_schedule': scheduleAt}, handleError: false,
    );
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

  @override Future<dynamic> add(Object value) async => null;
  @override Future<dynamic> update(Map<String, dynamic> body) async => null;
  @override Future<dynamic> delete(int? id) async => null;
  @override Future<dynamic> getList() async => null;
  @override Future<dynamic> get(int? id) async => null;
}
