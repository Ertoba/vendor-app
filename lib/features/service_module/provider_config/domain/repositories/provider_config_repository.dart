import 'package:get/get.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/service_module/provider_config/domain/models/store_setup_model.dart';
import 'package:sixam_mart_store/features/service_module/provider_config/domain/repositories/provider_config_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class ProviderConfigRepository implements ProviderConfigRepositoryInterface {
  final ApiClient apiClient;
  ProviderConfigRepository({required this.apiClient});

  @override
  Future<StoreSetupModel?> getStoreSetup() async {
    StoreSetupModel? model;
    Response response = await apiClient.getData(AppConstants.serviceStoreSetupUri);
    if (response.statusCode == 200) {
      model = StoreSetupModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future<ResponseModel> updateStoreSetup(Map<String, dynamic> body) async {
    ResponseModel responseModel;
    Response response = await apiClient.putData(AppConstants.serviceStoreSetupUri, body, handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override Future<dynamic> add(Object value) async => null;
  @override Future<dynamic> update(Map<String, dynamic> body) async => null;
  @override Future<dynamic> delete(int? id) async => null;
  @override Future<dynamic> getList() async => null;
  @override Future<dynamic> get(int? id) async => null;
}
