import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/service_module/provider_config/domain/models/store_setup_model.dart';
import 'package:sixam_mart_store/interface/repository_interface.dart';

abstract class ProviderConfigRepositoryInterface extends RepositoryInterface<Object> {
  Future<StoreSetupModel?> getStoreSetup();
  Future<ResponseModel> updateStoreSetup(Map<String, dynamic> body);
}
