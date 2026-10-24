import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/service_module/serviceman/domain/models/service_man_completed_booking_model.dart';
import 'package:sixam_mart_store/features/service_module/serviceman/domain/models/service_man_list_model.dart';
import 'package:sixam_mart_store/features/service_module/serviceman/domain/models/service_man_model.dart';
import 'package:sixam_mart_store/features/service_module/serviceman/domain/services/serviceman_service_interface.dart';

class ServiceManController extends GetxController implements GetxService {
  final ServicemanServiceInterface servicemanServiceInterface;
  ServiceManController({required this.servicemanServiceInterface});

  List<ServiceManModel>? _serviceManList;
  List<ServiceManModel>? get serviceManList => _serviceManList;

  int? _totalSize;
  int? get totalSize => _totalSize;

  List<String> _offsetList = [];
  int _offset = 1;
  int get offset => _offset;

  ServiceManModel? _serviceManDetails;
  ServiceManModel? get serviceManDetails => _serviceManDetails;

  List<ServiceManCompletedBookingModel>? _completedBookings;
  List<ServiceManCompletedBookingModel>? get completedBookings => _completedBookings;

  int? _completedBookingsTotalSize;
  int? get completedBookingsTotalSize => _completedBookingsTotalSize;

  List<String> _completedBookingsOffsetList = [];
  int _completedBookingsOffset = 1;
  int get completedBookingsOffset => _completedBookingsOffset;

  XFile? _pickedImage;
  XFile? get pickedImage => _pickedImage;

  List<XFile> _pickedIdentities = [];
  List<XFile> get pickedIdentities => _pickedIdentities;

  final List<String> _identityTypeList = ['passport', 'driving_license', 'nid', 'trade_license'];
  List<String> get identityTypeList => _identityTypeList;

  int _identityTypeIndex = 0;
  int get identityTypeIndex => _identityTypeIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSuspended = false;
  bool get isSuspended => _isSuspended;

  Future<void> getServiceManList({required String offset}) async {
    if (offset == '1') {
      _offsetList = [];
      _offset = 1;
      _serviceManList = null;
      update();
    }

    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      ServiceManListModel? model = await servicemanServiceInterface.getServiceManList(offset: offset);
      if (model != null) {
        if (offset == '1') {
          _serviceManList = [];
        }
        _serviceManList!.addAll(model.servicemen ?? []);
        _totalSize = model.totalSize;
        _offset = int.parse(offset) + 1;
      }
      update();
    }
  }

  Future<void> getServiceManDetails(int id) async {
    _serviceManDetails = null;
    _serviceManDetails = await servicemanServiceInterface.getServiceManDetails(id);
    update();
  }

  Future<void> getCompletedBookings({required int id, required String offset}) async {
    if (offset == '1') {
      _completedBookingsOffsetList = [];
      _completedBookingsOffset = 1;
      _completedBookings = null;
      update();
    }

    if (!_completedBookingsOffsetList.contains(offset)) {
      _completedBookingsOffsetList.add(offset);
      ServiceManCompletedBookingListModel? model = await servicemanServiceInterface.getServiceManCompletedBookings(id, offset: offset);
      if (model != null) {
        if (offset == '1') {
          _completedBookings = [];
        }
        _completedBookings!.addAll(model.services ?? []);
        _completedBookingsTotalSize = model.totalSize;
        _completedBookingsOffset = int.parse(offset) + 1;
      }
      update();
    }
  }

  Future<void> addServiceMan(ServiceManModel serviceMan, String pass, bool isAdd) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await servicemanServiceInterface.addServiceMan(serviceMan, pass, _pickedImage, _pickedIdentities, isAdd);
    if (responseModel.isSuccess) {
      Get.back();
      showCustomSnackBar(isAdd ? 'service_man_added_successfully'.tr : 'service_man_updated_successfully'.tr, isError: false);
      getServiceManList(offset: '1');
    } else {
      showCustomSnackBar(responseModel.message ?? 'something_went_wrong'.tr);
    }
    _isLoading = false;
    update();
  }

  Future<void> deleteServiceMan(int id) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await servicemanServiceInterface.deleteServiceMan(id);
    if (responseModel.isSuccess) {
      Get.back();
      showCustomSnackBar('service_man_deleted_successfully'.tr, isError: false);
      getServiceManList(offset: '1');
    } else {
      showCustomSnackBar(responseModel.message ?? 'something_went_wrong'.tr);
    }
    _isLoading = false;
    update();
  }

  void setSuspended(bool isSuspended) {
    _isSuspended = isSuspended;
  }

  void toggleSuspension(int id) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await servicemanServiceInterface.updateServiceManStatus(id, _isSuspended ? 1 : 0);
    if (responseModel.isSuccess) {
      Get.back();
      getServiceManList(offset: '1');
      showCustomSnackBar(_isSuspended ? 'service_man_unsuspended_successfully'.tr : 'service_man_suspended_successfully'.tr, isError: false);
      _isSuspended = !_isSuspended;
    } else {
      showCustomSnackBar(responseModel.message ?? 'something_went_wrong'.tr);
    }
    _isLoading = false;
    update();
  }

  void setIdentityTypeIndex(String? identityType, bool notify) {
    int index0 = servicemanServiceInterface.identityTypeIndex(_identityTypeList, identityType);
    _identityTypeIndex = index0;
    if (notify) {
      update();
    }
  }

  void pickImage(bool isLogo, bool isRemove) async {
    if (isRemove) {
      _pickedImage = null;
      _pickedIdentities = [];
    } else {
      if (isLogo) {
        _pickedImage = await servicemanServiceInterface.pickImageFromGallery();
      } else {
        XFile? pickedIdentitiesImage = await servicemanServiceInterface.pickImageFromGallery();
        if (pickedIdentitiesImage != null) {
          _pickedIdentities.add(pickedIdentitiesImage);
        }
      }
      update();
    }
  }

  void removeIdentityImage(int index) {
    _pickedIdentities.removeAt(index);
    update();
  }
}
