import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/service_module/provider_config/domain/models/store_setup_model.dart';
import 'package:sixam_mart_store/features/service_module/provider_config/domain/repositories/provider_config_repository_interface.dart';
import 'package:sixam_mart_store/features/service_module/provider_config/domain/services/provider_config_service_interface.dart';

class ProviderConfigService implements ProviderConfigServiceInterface {
  final ProviderConfigRepositoryInterface providerConfigRepositoryInterface;
  ProviderConfigService({required this.providerConfigRepositoryInterface});

  @override
  Future<StoreSetupModel?> getStoreSetup() async {
    return await providerConfigRepositoryInterface.getStoreSetup();
  }

  @override
  Future<ResponseModel> updateStoreSetup(Map<String, dynamic> body) async {
    return await providerConfigRepositoryInterface.updateStoreSetup(body);
  }
}
