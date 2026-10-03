import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/api/api_response.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:sixam_mart_store/features/auth/domain/services/auth_service_interface.dart';
import 'package:sixam_mart_store/features/business/domain/models/package_model.dart';
import 'package:sixam_mart_store/features/business/screens/subscription_payment_screen.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/rental_module/profile/controllers/taxi_profile_controller.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';

class AuthService implements AuthServiceInterface {
  final AuthRepositoryInterface authRepositoryInterface;
  AuthService({required this.authRepositoryInterface});

  @override
  Future<Response> login(String? email, String password, String type) async {
    return await authRepositoryInterface.login(email, password, type);
  }

  @override
  Future<Response> registerRestaurant(Map<String, String> data, XFile? logo, XFile? cover, List<MultipartDocument> tinFiles) async {
    return await authRepositoryInterface.registerRestaurant(data, logo, cover, tinFiles);
  }

  @override
  Future<Response> updateToken() async {
    return await authRepositoryInterface.updateToken();
  }

  @override
  Future<bool> saveUserToken(String token, String zoneTopic, String type) async {
    return await authRepositoryInterface.saveUserToken(token, zoneTopic, type);
  }

  @override
  String getUserToken() {
    return authRepositoryInterface.getUserToken();
  }

  @override
  bool isLoggedIn() {
    return authRepositoryInterface.isLoggedIn();
  }

  @override
  Future<bool> clearSharedData() async {
    return await authRepositoryInterface.clearSharedData();
  }

  @override
  Future<void> saveUserNumberAndPassword(String number, String password, String type) async {
    return await authRepositoryInterface.saveUserNumberAndPassword(number, password, type);
  }

  @override
  String getUserNumber() {
    return authRepositoryInterface.getUserNumber();
  }

  @override
  String getUserPassword() {
    return authRepositoryInterface.getUserPassword();
  }

  @override
  String getUserType() {
    return authRepositoryInterface.getUserType();
  }

  @override
  bool isNotificationActive() {
    return authRepositoryInterface.isNotificationActive();
  }

  @override
  Future<void> setNotificationActive(bool isActive) async{
    return await authRepositoryInterface.setNotificationActive(isActive);
  }

  @override
  Future<bool> clearUserNumberAndPassword() async {
    return await authRepositoryInterface.clearUserNumberAndPassword();
  }

  @override
  Future<bool> toggleStoreClosedStatus() async {
    return await authRepositoryInterface.toggleStoreClosedStatus();
  }

  @override
  Future<bool> saveIsStoreRegistration(bool status) async {
    return await authRepositoryInterface.saveIsStoreRegistration(status);
  }

  @override
  bool getIsStoreRegistration() {
    return authRepositoryInterface.getIsStoreRegistration();
  }

  @override
  Future<ResponseModel?> manageLogin(Response response, String type) async {
    if (response.statusCode != 200) {
      return ResponseModel(false, response.statusText);
    }

    /// `{identical_code, message, content: {token, zone_wise_topic, module_type}, errors}`
    final Map<String, dynamic> content = response.contentMap;

    final String? moduleType = content['module_type'];
    setModuleType(moduleType ?? '');

    final dynamic subscribed = content['subscribed'];
    if (subscribed != null) {
      final int? storeId = subscribed['store_id'];
      final int? packageId = subscribed['package_id'];
      if (packageId != null) {
        Get.to(() => SubscriptionPaymentScreen(storeId: storeId!, packageId: packageId));
        return ResponseModel(false, 'please_select_payment_method'.tr);
      }

      if (!await _saveSession(subscribed, type)) {
        return ResponseModel(false, response.apiMessage ?? response.statusText);
      }
      moduleType == 'rental' ? await Get.find<TaxiProfileController>().getProfile() : await Get.find<ProfileController>().getProfile();
      Get.toNamed(RouteHelper.getMySubscriptionRoute(fromNotification: true));
      return null;
    }

    if (!await _saveSession(content, type)) {
      return ResponseModel(false, response.apiMessage ?? response.statusText);
    }
    moduleType == 'rental' ? Get.find<TaxiProfileController>().getProfile() : Get.find<ProfileController>().getProfile();
    return ResponseModel(true, 'successful');
  }

  /// Stores the session from a login payload. Returns false when the payload
  /// carried no token, so the caller can report it instead of crashing.
  Future<bool> _saveSession(dynamic payload, String type) async {
    final String? token = payload['token'];
    if (token == null) {
      return false;
    }
    await saveUserToken(token, payload['zone_wise_topic'] ?? '', type);
    await updateToken();
    return true;
  }

  @override
  Future<PackageModel?> getPackageList({int? moduleId}) async {
    return await authRepositoryInterface.getPackageList(moduleId: moduleId);
  }

  @override
  String getModuleType() {
    return authRepositoryInterface.getModuleType();
  }

  @override
  void setModuleType(String type) {
    authRepositoryInterface.setModuleType(type);
  }

}