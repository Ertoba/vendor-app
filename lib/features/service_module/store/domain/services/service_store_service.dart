import 'package:sixam_mart_store/features/service_module/store/domain/models/pending_service_details_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/pending_service_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_list_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/repositories/service_store_repository_interface.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/services/service_store_service_interface.dart';

class ServiceStoreService implements ServiceStoreServiceInterface {
  final ServiceStoreRepositoryInterface serviceStoreRepositoryInterface;
  ServiceStoreService({required this.serviceStoreRepositoryInterface});

  @override
  Future<PendingServiceModel?> getPendingServiceList(String offset, String type) async {
    return await serviceStoreRepositoryInterface.getPendingServiceList(offset, type);
  }

  @override
  Future<PendingServiceDetailsModel?> getPendingServiceDetails(int id) async {
    return await serviceStoreRepositoryInterface.getPendingServiceDetails(id);
  }

  @override
  Future<bool> deletePendingService(int id) async {
    return await serviceStoreRepositoryInterface.deletePendingService(id);
  }

  @override
  Future<ServiceListModel?> getServiceList({required String offset, required String status, String search = '', int? categoryId}) async {
    return await serviceStoreRepositoryInterface.getServiceList(offset: offset, status: status, search: search, categoryId: categoryId);
  }

  @override
  Future<ServiceModel?> getServiceDetails(int id) async {
    return await serviceStoreRepositoryInterface.getServiceDetails(id);
  }

  @override
  Future<bool> deleteService(int? id) async {
    return await serviceStoreRepositoryInterface.deleteService(id);
  }

  @override
  Future<bool> updateServiceStatus(int? id, int status) async {
    return await serviceStoreRepositoryInterface.updateServiceStatus(id, status);
  }
}
