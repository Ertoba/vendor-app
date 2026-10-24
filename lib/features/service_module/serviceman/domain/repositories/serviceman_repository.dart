import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/service_module/serviceman/domain/models/service_man_completed_booking_model.dart';
import 'package:sixam_mart_store/features/service_module/serviceman/domain/models/service_man_list_model.dart';
import 'package:sixam_mart_store/features/service_module/serviceman/domain/models/service_man_model.dart';
import 'package:sixam_mart_store/features/service_module/serviceman/domain/repositories/serviceman_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class ServicemanRepository implements ServicemanRepositoryInterface {
  final ApiClient apiClient;
  ServicemanRepository({required this.apiClient});

  @override
  Future<ServiceManListModel?> getServiceManList({required String offset}) async {
    ServiceManListModel? model;
    Response response = await apiClient.getData('${AppConstants.smListUri}?limit=10&offset=$offset');
    if (response.statusCode == 200) {
      model = ServiceManListModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future<ServiceManModel?> getServiceManDetails(int id) async {
    ServiceManModel? model;
    Response response = await apiClient.getData('${AppConstants.smDetailsUri}$id');
    if (response.statusCode == 200) {
      model = ServiceManModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future<ServiceManCompletedBookingListModel?> getServiceManCompletedBookings(int id, {required String offset}) async {
    ServiceManCompletedBookingListModel? model;
    Response response = await apiClient.getData('${AppConstants.smServicesUri}$id?limit=10&offset=$offset');
    if (response.statusCode == 200) {
      model = ServiceManCompletedBookingListModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future<ResponseModel> addServiceMan(ServiceManModel serviceMan, String pass, XFile? image, List<XFile> identities, bool isAdd) async {
    List<MultipartBody> multiParts = [];
    multiParts.add(MultipartBody('image', image));
    for (XFile file in identities) {
      multiParts.add(MultipartBody('identity_image[]', file));
    }

    Map<String, String> fields = {
      'f_name': serviceMan.fName!, 'email': serviceMan.email!, 'phone': serviceMan.phone!,
      'identity_number': serviceMan.identityNumber!, 'identity_type': serviceMan.identityType!,
    };
    if (serviceMan.lName != null && serviceMan.lName!.isNotEmpty) {
      fields['l_name'] = serviceMan.lName!;
    }
    if (pass.isNotEmpty) {
      fields['password'] = pass;
    }

    Response response = await apiClient.postMultipartData(
      isAdd ? AppConstants.addSmUri : '${AppConstants.updateSmUri}${serviceMan.id}', fields, multiParts, handleError: false,
    );
    if (response.statusCode == 200) {
      return ResponseModel(true, response.body['message']);
    }
    return ResponseModel(false, _errorMessage(response));
  }

  @override
  Future<ResponseModel> deleteServiceMan(int id) async {
    Response response = await apiClient.deleteData('${AppConstants.deleteSmUri}$id', handleError: false);
    if (response.statusCode == 200) {
      return ResponseModel(true, response.body['message']);
    }
    return ResponseModel(false, _errorMessage(response));
  }

  @override
  Future<ResponseModel> updateServiceManStatus(int id, int status) async {
    Response response = await apiClient.getData('${AppConstants.updateSmStatusUri}$id/$status', handleError: false);
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
