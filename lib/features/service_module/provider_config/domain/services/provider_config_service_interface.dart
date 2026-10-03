import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/service_module/provider_config/domain/models/store_setup_model.dart';

abstract class ProviderConfigServiceInterface {
  Future<StoreSetupModel?> getStoreSetup();
  Future<ResponseModel> updateStoreSetup(Map<String, dynamic> body);
}
