import 'package:sixam_mart_store/features/service_module/store/domain/models/pending_service_details_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/pending_service_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_list_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_model.dart';

abstract class ServiceStoreServiceInterface {
  Future<PendingServiceModel?> getPendingServiceList(String offset, String type);
  Future<PendingServiceDetailsModel?> getPendingServiceDetails(int id);
  Future<bool> deletePendingService(int id);
  Future<ServiceListModel?> getServiceList({required String offset, required String status, String search, int? categoryId});
  Future<ServiceModel?> getServiceDetails(int id);
  Future<bool> deleteService(int? id);
  Future<bool> updateServiceStatus(int? id, int status);
}
