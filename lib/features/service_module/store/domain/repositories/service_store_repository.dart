import 'package:get/get.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/pending_service_details_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/pending_service_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_list_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/repositories/service_store_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class ServiceStoreRepository implements ServiceStoreRepositoryInterface {
  final ApiClient apiClient;
  ServiceStoreRepository({required this.apiClient});

  @override
  Future<PendingServiceModel?> getPendingServiceList(String offset, String type) async {
    PendingServiceModel? model;
    Response response = await apiClient.getData('${AppConstants.pendingServiceListUri}?limit=10&offset=$offset&filter=$type');
    if (response.statusCode == 200) {
      model = PendingServiceModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future<PendingServiceDetailsModel?> getPendingServiceDetails(int id) async {
    PendingServiceDetailsModel? model;
    Response response = await apiClient.getData('${AppConstants.pendingServiceDetailsUri}/$id');
    if (response.statusCode == 200) {
      model = PendingServiceDetailsModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future<bool> deletePendingService(int id) async {
    Response response = await apiClient.deleteData('${AppConstants.deletePendingServiceUri}/$id');
    return response.statusCode == 200;
  }

  @override
  Future<ServiceListModel?> getServiceList({required String offset, required String status, String search = '', int? categoryId}) async {
    ServiceListModel? model;
    Response response = await apiClient.getData(
      '${AppConstants.serviceListUri}?limit=10&offset=$offset&status=$status${search.isNotEmpty ? '&search=$search' : ''}${(categoryId != null && categoryId != 0) ? '&category_id=$categoryId' : ''}',
    );
    if (response.statusCode == 200) {
      model = ServiceListModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future<ServiceModel?> getServiceDetails(int id) async {
    ServiceModel? service;
    Response response = await apiClient.getData('${AppConstants.serviceDetailsUri}/$id');
    if (response.statusCode == 200) {
      service = ServiceModel.fromJson(response.body);
    }
    return service;
  }

  @override
  Future<bool> deleteService(int? id) async {
    Response response = await apiClient.deleteData('${AppConstants.deleteServiceUri}/$id');
    return (response.statusCode == 200);
  }

  @override
  Future<bool> updateServiceStatus(int? id, int status) async {
    Response response = await apiClient.getData('${AppConstants.updateServiceStatusUri}/$id/$status');
    return (response.statusCode == 200);
  }

  @override Future<dynamic> add(Object value) async => null;
  @override Future<dynamic> update(Map<String, dynamic> body) async => null;
  @override Future<dynamic> delete(int? id) async => null;
  @override Future<dynamic> getList() async => null;
  @override Future<dynamic> get(int? id) async => null;
}
