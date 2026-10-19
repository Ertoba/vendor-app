import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/bundle_item/domain/models/bundle_item_model.dart';
import 'package:sixam_mart_store/features/bundle_item/domain/repositories/bundle_item_repository.dart';
import 'package:sixam_mart_store/features/bundle_item/domain/services/bundle_item_service_interface.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
import 'package:sixam_mart_store/helper/image_size_checker.dart';

class BundleItemController extends GetxController implements GetxService {
  final BundleItemServiceInterface bundleItemServiceInterface;
  BundleItemController({required this.bundleItemServiceInterface});

  /// The API's own limits (§6.4) — a bundle is 2 to 50 items, and the discount
  /// never reaches 99 percent.
  static const int minBundleItems = 2;
  static const int maxBundleItems = 50;
  static const double maxDiscountPercentage = 99;

  static const int pageLimit = 25;

  /// The module types a bundle can belong to.
  ///
  /// A bundle is a fixed set of the store's own lines sold together at one
  /// price, so it needs a per-line price to sum. `parcel`, `rental` and
  /// `ride-share` have none — they are priced per delivery or per trip.
  ///
  /// A service module does, and is supported: a service bundle answers on the
  /// same endpoints, with `service_id` where an item bundle sends `item_id`.
  /// Bundle answers to its own Business Settings switch rather than the
  /// `promotion-module` middleware, which is how it reaches service where BOGO
  /// and happy hour do not.
  static const Set<String> supportedModuleTypes = {'grocery', 'pharmacy', 'ecommerce', 'food', 'service'};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int? _lastPage;

  List<String> _offsetList = [];
  int _offset = 1;
  int get offset => _offset;

  List<BundlePackage>? _bundleList;
  List<BundlePackage>? get bundleList => _bundleList;

  void setOffset(int offset) {
    _offset = offset;
  }

  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  /// `offset` is a 1-based page number, not a row offset — the API guide is
  /// explicit that the name is misleading.
  Future<void> getBundleList({required String offset, String? search, bool isUpdate = true}) async {
    if(offset == '1') {
      _offsetList = [];
      _offset = 1;
      _bundleList = null;
      if(isUpdate) {
        update();
      }
    }

    if(!_offsetList.contains(offset)) {
      _offsetList.add(offset);

      BundlePackageModel? bundlePackageModel = await bundleItemServiceInterface.getBundleList(offset, search: search);
      if(bundlePackageModel != null) {
        if(offset == '1') {
          _bundleList = [];
        }
        _bundleList!.addAll(bundlePackageModel.bundles ?? []);
        _pageSize = bundlePackageModel.totalSize;
        _lastPage = bundlePackageModel.lastPage;
      }
      _isLoading = false;
      update();
    } else if(_isLoading) {
      _isLoading = false;
      update();
    }
  }

  /// True once the list has been read to its end, so the list screen stops
  /// asking for pages the server does not have.
  bool get hasReachedEnd {
    final int lastPage = _lastPage ?? ((_pageSize ?? 0) / pageLimit).ceil();
    return _offset >= lastPage;
  }

  BundlePackage? _bundleDetails;
  BundlePackage? get bundleDetails => _bundleDetails;

  Future<void> getBundleDetails(int bundleId, {bool isUpdate = true}) async {
    _bundleDetails = null;
    if(isUpdate) {
      update();
    }

    _bundleDetails = await bundleItemServiceInterface.getBundleDetails(bundleId);
    update();
  }

  List<BundleCatalogueItem>? _bundleItems;
  List<BundleCatalogueItem>? get bundleItems => _bundleItems;

  Future<void> getBundleItems({String? search, bool isUpdate = true}) async {
    if(isUpdate) {
      update();
    }

    _bundleItems = await bundleItemServiceInterface.getBundleItems(search: search);
    update();
  }

  /// ---------------------------------------------------------------- setup form

  final List<BundleSelectedItem> _selectedItems = [];
  List<BundleSelectedItem> get selectedItems => _selectedItems;

  /// How many `items[]` entries the request will carry. Quantity rides inside an
  /// entry rather than repeating it, so this is simply the number of distinct
  /// lines — what the API's 2–50 rule counts.
  int get totalItemEntries => _selectedItems.length;

  XFile? _rawThumbnail;
  XFile? get rawThumbnail => _rawThumbnail;

  String? _savedThumbnail;
  String? get savedThumbnail => _savedThumbnail;

  bool _isThumbnailValid = true;
  bool get isThumbnailValid => _isThumbnailValid;

  DateTime? _startDateTime;
  DateTime? get startDateTime => _startDateTime;

  DateTime? _endDateTime;
  DateTime? get endDateTime => _endDateTime;

  double _discount = 0;
  double get discount => _discount;

  /// A preview only: the server recomputes both figures from the items and the
  /// percentage on save, and its numbers replace these.
  double get totalBasePrice {
    double total = 0;
    for(final BundleSelectedItem item in _selectedItems) {
      total += item.lineTotal;
    }
    return total;
  }

  double get bundlePrice => calculateBundlePrice(totalBasePrice, _discount);

  void resetSetup() {
    _selectedItems.clear();
    _rawThumbnail = null;
    _savedThumbnail = null;
    _isThumbnailValid = true;
    _startDateTime = null;
    _endDateTime = null;
    _discount = 0;
  }

  /// Fills the setup form from an existing bundle, for the edit flow.
  void prefillFrom(BundlePackage bundle) {
    resetSetup();
    _savedThumbnail = bundle.imageFullUrl;
    _discount = bundle.discountPercentage ?? 0;
    _startDateTime = _parseDate(bundle.startDate);
    _endDateTime = _parseDate(bundle.endDate);

    for(final BundleItem line in bundle.items ?? const <BundleItem>[]) {
      _selectedItems.add(BundleSelectedItem(
        item: Item(
          id: line.targetId,
          name: line.name,
          imageFullUrl: line.imageFullUrl,
          price: line.unitPrice,
        ),
        unitPrice: line.unitPrice ?? 0,
        quantity: line.quantity ?? 1,
        variationSummary: line.variationSummary ?? '',
        variations: line.variations ?? const [],
        addOnIds: line.addOnIds ?? const [],
        addOnQtys: line.addOnQtys ?? const [],
        isService: line.isService,
        /// A service line's chosen variant travels inside `variations`.
        variantKey: line.isService ? _variantKeyOf(line.variations) : null,
      ));
    }

    update();
  }

  static String? _variantKeyOf(List<Map<String, dynamic>>? variations) {
    for(final Map<String, dynamic> variation in variations ?? const <Map<String, dynamic>>[]) {
      final String key = variation['variant_key']?.toString() ?? '';
      if(key.isNotEmpty) {
        return key;
      }
    }
    return null;
  }

  DateTime? _parseDate(String? raw) {
    if(raw == null || raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  void setStartDateTime(DateTime dateTime) {
    _startDateTime = dateTime;
    /// An end that now precedes the start would be rejected by the server, so it
    /// is cleared rather than carried into the request.
    if(_endDateTime != null && !_endDateTime!.isAfter(dateTime)) {
      _endDateTime = null;
    }
    update();
  }

  void setEndDateTime(DateTime dateTime) {
    _endDateTime = dateTime;
    update();
  }

  void setDiscount(String value) {
    _discount = double.tryParse(value.trim()) ?? 0;
    update();
  }

  void addSelectedItem(BundleSelectedItem selection) {
    final int existingIndex = _selectedItems.indexWhere((item) => item.selectionKey == selection.selectionKey);
    if(existingIndex != -1) {
      _selectedItems[existingIndex].quantity += selection.quantity;
    } else {
      _selectedItems.add(selection);
    }
    update();
  }

  void removeSelectedItem(int index) {
    if(index >= 0 && index < _selectedItems.length) {
      _selectedItems.removeAt(index);
      update();
    }
  }

  double get _maxFileSize => Get.find<SplashController>().configModel!.validationConfig!.maxFileSize;

  String get maxFileSizeText => _maxFileSize % 1 == 0 ? _maxFileSize.toInt().toString() : _maxFileSize.toString();

  Future<void> pickThumbnail({bool isRemove = false}) async {
    if(isRemove) {
      _rawThumbnail = null;
      _isThumbnailValid = true;
    } else {
      final XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(xFile != null) {
        _rawThumbnail = xFile;
        _isThumbnailValid = await ImageSize.getImageSizeFromXFile(xFile) <= _maxFileSize;
        if(!_isThumbnailValid) {
          showCustomSnackBar('image_size_exceeds'.trParams({'size': maxFileSizeText}));
        }
      }
    }
    update();
  }

  bool _isSubmitLoading = false;
  bool get isSubmitLoading => _isSubmitLoading;

  Future<BundleSaveResult?> saveBundle({
    int? bundleId,
    required Map<String, String> names,
    required Map<String, String> descriptions,
  }) async {
    if(!_isThumbnailValid) {
      showCustomSnackBar('image_size_exceeds'.trParams({'size': maxFileSizeText}));
      return null;
    }

    _isSubmitLoading = true;
    update();

    final Map<String, String> body = buildBundleRequestBody(
      storeId: '${Get.find<ProfileController>().profileModel?.stores?.id ?? ''}',
      startDate: _apiDate(_startDateTime),
      endDate: _apiDate(_endDateTime),
      discountPercentage: _trimZeros(_discount),
      names: names,
      descriptions: descriptions,
      items: _selectedItems
          .where((item) => item.item.id != null)
          .map((item) => item.toRequestLine()).toList(),
    );

    /// `image` is required on create and optional on update — omitting it keeps
    /// the thumbnail the bundle already has.
    final List<MultipartBody> files = _rawThumbnail != null ? [MultipartBody('image', _rawThumbnail)] : [];

    final BundleSaveResult? result = bundleId != null
        ? await bundleItemServiceInterface.updateBundle(bundleId, body, files)
        : await bundleItemServiceInterface.addBundle(body, files);

    if(result != null) {
      /// The response carries the server-computed prices, so the details screen
      /// shows those rather than the form's preview.
      _bundleDetails = result.bundle;
      await getBundleList(offset: '1', isUpdate: false);
    }

    _isSubmitLoading = false;
    update();
    return result;
  }

  /// `Y-m-d H:i`, the format §6.4 shows.
  String _apiDate(DateTime? dateTime) {
    if(dateTime == null) {
      return '';
    }
    return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}'
        ' ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String _trimZeros(double value) => value % 1 == 0 ? value.toInt().toString() : value.toString();

  bool _isStatusLoading = false;
  bool get isStatusLoading => _isStatusLoading;

  Future<bool> changeBundleStatus(int bundleId, int status) async {
    _isStatusLoading = true;
    update();

    final ResponseModel? responseModel = await bundleItemServiceInterface.changeBundleStatus(bundleId, status);
    final bool isSuccess = responseModel != null;
    if(isSuccess) {
      showCustomSnackBar(responseModel.message, isError: false);
      /// Reflected locally rather than refetched, so the toggle does not snap
      /// back while a reload is in flight.
      _bundleDetails?.status = status;
      final int index = _bundleList?.indexWhere((bundle) => bundle.id == bundleId) ?? -1;
      if(index != -1) {
        _bundleList![index].status = status;
      }
    }

    _isStatusLoading = false;
    update();
    return isSuccess;
  }

  bool _isDeleteLoading = false;
  bool get isDeleteLoading => _isDeleteLoading;

  Future<bool> deleteBundle(int bundleId) async {
    _isDeleteLoading = true;
    update();

    final ResponseModel? responseModel = await bundleItemServiceInterface.deleteBundle(bundleId);
    final bool isSuccess = responseModel != null;
    if(isSuccess) {
      showCustomSnackBar(responseModel.message, isError: false);
      _bundleList?.removeWhere((bundle) => bundle.id == bundleId);
    }

    _isDeleteLoading = false;
    update();
    return isSuccess;
  }
}
