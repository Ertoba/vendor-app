import 'package:get/get.dart';
import 'package:sixam_mart_store/features/category/controllers/category_controller.dart';
import 'package:sixam_mart_store/features/category/domain/models/category_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/pending_service_details_model.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/pending_service_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_list_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/services/service_store_service_interface.dart';

class ServiceStoreController extends GetxController implements GetxService {
  final ServiceStoreServiceInterface serviceStoreServiceInterface;
  ServiceStoreController({required this.serviceStoreServiceInterface});

  List<Service>? _serviceList;
  List<Service>? get serviceList => _serviceList;

  int? _serviceSize;
  int? get serviceSize => _serviceSize;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFabVisible = true;
  bool get isFabVisible => _isFabVisible;

  List<String> _serviceOffsetList = [];
  int _serviceOffset = 1;
  int get serviceOffset => _serviceOffset;


  List<String>? _categoryNameList;
  List<String>? get categoryNameList => _categoryNameList;
  List<int>? _categoryIdList;
  int _categoryIndex = 0;
  int get categoryIndex => _categoryIndex;
  int? _categoryId = 0;
  int? get categoryId => _categoryId;

  bool _isSearchVisible = false;
  bool get isSearchVisible => _isSearchVisible;
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  Future<void> getServiceCategories({bool isUpdate = true}) async {
    await Get.find<CategoryController>().getCategoryList();
    _categoryNameList = ['all'];
    _categoryIdList = [0];
    for (CategoryModel cat in Get.find<CategoryController>().categoryList ?? []) {
      _categoryNameList!.add(cat.name!);
      _categoryIdList!.add(cat.id!);
    }
    if (isUpdate) update();
  }

  void setCategory({required int index}) {
    _categoryIndex = index;
    _categoryId = _categoryIdList![index];
    getServiceList(
      offset: '1',
      status: 'all',
      categoryId: _categoryIndex != 0 ? _categoryIdList![_categoryIndex] : null,
    );
    update();
  }

  void setCategoryForSearch({required int index}) {
    _categoryIndex = index;
    _categoryId = _categoryIdList![index];
    update();
  }

  void setSearchVisibility() {
    _isSearchVisible = !_isSearchVisible;
    update();
  }

  void resetFilters() {
    _categoryIndex = 0;
    _categoryId = 0;
    _isSearching = false;
    _isSearchVisible = false;
    update();
    getServiceList(offset: '1', status: 'all');
  }

  Future<void> getServiceList({
    required String offset,
    required String status,
    String search = '',
    int? categoryId,
    bool willUpdate = true,
  }) async {
    _isSearching = search.isNotEmpty;
    if (offset == '1') {
      _serviceOffsetList = [];
      _serviceOffset = 1;
      _serviceList = null;
      if (willUpdate) update();
    }

    if (!_serviceOffsetList.contains(offset)) {
      _serviceOffsetList.add(offset);
      ServiceListModel? model = await serviceStoreServiceInterface.getServiceList(
        offset: offset,
        status: status,
        search: search,
        categoryId: categoryId,
      );
      if (model != null) {
        if (offset == '1') {
          _serviceList = [];
        }
        _serviceList!.addAll(model.services!);
        _serviceSize = model.totalSize;
        _serviceOffset = int.parse(offset) + 1;
      }
      _isLoading = false;
      update();
    }
  }

  ServiceModel? _serviceDetails;
  ServiceModel? get serviceDetails => _serviceDetails;

  Future<ServiceModel?> getServiceDetails(int id, {bool isUpdate = true}) async {
    _isLoading = true;
    _serviceDetails = null;
    if (isUpdate) update();
    ServiceModel? service = await serviceStoreServiceInterface.getServiceDetails(id);
    _serviceDetails = service;
    if (service != null) {
      setAvailability(service.status == 1);
    }
    _isLoading = false;
    update();
    return service;
  }

  bool _isAvailable = true;
  bool get isAvailable => _isAvailable;

  void setAvailability(bool isAvailable) {
    _isAvailable = isAvailable;
  }

  void toggleServiceAvailable(int? id) async {
    bool isSuccess = await serviceStoreServiceInterface.updateServiceStatus(id, _isAvailable ? 0 : 1);
    if (isSuccess) {
      _isAvailable = !_isAvailable;
      getServiceList(offset: '1', status: 'all');
      showCustomSnackBar('service_status_updated_successfully'.tr, isError: false);
    }
    update();
  }

  Future<void> deleteService(int? id) async {
    _isLoading = true;
    update();
    bool isSuccess = await serviceStoreServiceInterface.deleteService(id);
    if (isSuccess) {
      Get.back();
      showCustomSnackBar('service_deleted_successfully'.tr, isError: false);
      getServiceList(offset: '1', status: 'all');
    }
    _isLoading = false;
    update();
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void setFabVisible(bool visible) {
    _isFabVisible = visible;
    update();
  }


  List<PendingService>? _pendingServices;
  List<PendingService>? get pendingServices => _pendingServices;

  final List<String> statusList = ['all', 'pending', 'rejected'];

  List<String> _offsetList = [];
  int _offset = 1;
  int get offset => _offset;

  int? _pageSize;
  int? get pageSize => _pageSize;

  String _type = 'all';
  String get type => _type;

  Future<void> getPendingServiceList(String offset, String type, {bool canNotify = true}) async {
    if (offset == '1') {
      _offsetList = [];
      _offset = 1;
      _pendingServices = null;
      if (canNotify) update();
    }

    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      PendingServiceModel? model = await serviceStoreServiceInterface.getPendingServiceList(offset, type);
      if (model != null) {
        if (offset == '1') {
          _pendingServices = [];
        }
        _pendingServices!.addAll(model.services!);
        _pageSize = model.totalSize;
        _offset = int.parse(offset) + 1;
      }
      update();
    }
  }

  void setType(String type) {
    _type = type;
    getPendingServiceList('1', type);
  }


  PendingServiceDetailsModel? _pendingServiceDetails;
  PendingServiceDetailsModel? get pendingServiceDetails => _pendingServiceDetails;

  Future<void> getPendingServiceDetails(int id) async {
    _pendingServiceDetails = null;
    update();
    _pendingServiceDetails = await serviceStoreServiceInterface.getPendingServiceDetails(id);
    update();
  }

  Future<bool> deletePendingService(int id) async {
    _isLoading = true;
    update();
    bool isSuccess = await serviceStoreServiceInterface.deletePendingService(id);
    if (isSuccess) {
      showCustomSnackBar('pending_service_deleted_successfully'.tr, isError: false);
      getPendingServiceList('1', _type);
    }
    _isLoading = false;
    update();
    return isSuccess;
  }
}
