import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/bundle_item/domain/models/bundle_item_model.dart';
import 'package:sixam_mart_store/features/bundle_item/domain/repositories/bundle_item_repository.dart';
import 'package:sixam_mart_store/features/bundle_item/domain/repositories/bundle_item_repository_interface.dart';
import 'package:sixam_mart_store/features/bundle_item/domain/services/bundle_item_service_interface.dart';

class BundleItemService implements BundleItemServiceInterface {
  final BundleItemRepositoryInterface bundleItemRepositoryInterface;
  BundleItemService({required this.bundleItemRepositoryInterface});

  @override
  Future<BundlePackageModel?> getBundleList(String offset, {String? search}) async {
    return await bundleItemRepositoryInterface.getBundleList(offset, search: search);
  }

  @override
  Future<BundlePackage?> getBundleDetails(int bundleId) async {
    return await bundleItemRepositoryInterface.getBundleDetails(bundleId);
  }

  @override
  Future<BundleSaveResult?> addBundle(Map<String, String> body, List<MultipartBody> selectedFile) async {
    return await bundleItemRepositoryInterface.addBundle(body, selectedFile);
  }

  @override
  Future<BundleSaveResult?> updateBundle(int bundleId, Map<String, String> body, List<MultipartBody> selectedFile) async {
    return await bundleItemRepositoryInterface.updateBundle(bundleId, body, selectedFile);
  }

  @override
  Future<ResponseModel?> deleteBundle(int bundleId) async {
    return await bundleItemRepositoryInterface.delete(bundleId);
  }

  @override
  Future<ResponseModel?> changeBundleStatus(int bundleId, int status) async {
    return await bundleItemRepositoryInterface.changeBundleStatus(bundleId, status);
  }

  @override
  Future<List<BundleCatalogueItem>?> getBundleItems({String? search}) async {
    return await bundleItemRepositoryInterface.getBundleItems(search: search);
  }
}
