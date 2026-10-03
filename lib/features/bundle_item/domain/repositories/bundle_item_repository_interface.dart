import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/interface/repository_interface.dart';

abstract class BundleItemRepositoryInterface implements RepositoryInterface {
  Future<dynamic> getBundleList(String offset, {String? search});
  Future<dynamic> getBundleDetails(int bundleId);
  Future<dynamic> addBundle(Map<String, String> body, List<MultipartBody> selectedFile);
  Future<dynamic> updateBundle(int bundleId, Map<String, String> body, List<MultipartBody> selectedFile);
  Future<dynamic> changeBundleStatus(int bundleId, int status);
  Future<dynamic> getBundleItems({String? search});
}
