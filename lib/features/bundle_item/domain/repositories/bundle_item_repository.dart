
import 'package:get/get.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/api/api_checker.dart';
import 'package:sixam_mart_store/common/models/api_error.dart';
import 'package:sixam_mart_store/api/api_response.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/bundle_item/domain/models/bundle_item_model.dart';
import 'package:sixam_mart_store/features/bundle_item/domain/repositories/bundle_item_repository_interface.dart';
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

/// The vendor half of the bundle API (§6 of the bundle API guide).
///
/// Two things about it drive the code here. Validation failures come back as
/// **403**, not 422, with the offending field in `errors[].code` — so these
/// calls pass `handleError: false` and read the message themselves rather than
/// letting the client show "Permission denied". And prices are computed
/// server-side: `base_price` and `discounted_price` are read back from the
/// response, never sent.
class BundleItemRepository implements BundleItemRepositoryInterface {
  final ApiClient apiClient;
  BundleItemRepository({required this.apiClient});

  @override
  Future<BundlePackageModel?> getBundleList(String offset, {String? search}) async {
    BundlePackageModel? bundlePackageModel;
    Response response = await apiClient.getData(
      '${AppConstants.bundleListUri}?limit=$_pageLimit&offset=$offset'
      '${search != null && search.isNotEmpty ? '&search=$search' : ''}',
    );
    if(response.statusCode == 200) {
      bundlePackageModel = BundlePackageModel.fromJson(response.contentMap);
      /// `offset` is a page number, so the list screen needs the row total to
      /// work out how many pages are left.
      final PaginationModel? pagination = response.pagination;
      bundlePackageModel.totalSize = pagination?.total ?? bundlePackageModel.bundles?.length;
      bundlePackageModel.currentPage = pagination?.currentPage;
      bundlePackageModel.lastPage = pagination?.lastPage;
    }
    return bundlePackageModel;
  }

  static const int _pageLimit = 25;

  @override
  Future<BundlePackage?> getBundleDetails(int bundleId) async {
    BundlePackage? bundlePackage;
    Response response = await apiClient.getData('${AppConstants.bundleDetailsUri}$bundleId');
    if(response.statusCode == 200) {
      bundlePackage = BundlePackage.fromJson(response.contentMap);
    }
    return bundlePackage;
  }

  @override
  Future<BundleSaveResult?> addBundle(Map<String, String> body, List<MultipartBody> selectedFile) async {
    return _save(AppConstants.bundleStoreUri, body, selectedFile);
  }

  @override
  Future<BundleSaveResult?> updateBundle(int bundleId, Map<String, String> body, List<MultipartBody> selectedFile) async {
    return _save('${AppConstants.bundleUpdateUri}$bundleId', body, selectedFile);
  }

  /// Create answers `201 default_store_201`, update answers `200
  /// default_update_200`, and both return the re-priced bundle — so the caller
  /// gets the server's figures rather than keeping its own preview.
  Future<BundleSaveResult?> _save(String uri, Map<String, String> body, List<MultipartBody> selectedFile) async {
    Response response = await apiClient.postMultipartData(uri, body, selectedFile, handleError: false);
    if(response.statusCode == 200 || response.statusCode == 201) {
      return BundleSaveResult(
        bundle: BundlePackage.fromJson(response.contentMap),
        message: response.apiMessage,
      );
    }

    /// A 403 here is a validation failure, not a permissions one: the real
    /// reason sits in `errors[].code/message` while the top level message is
    /// the generic "Permission denied". [ApiError] already prefers the field
    /// message for that shape, so this shows the rule the vendor broke rather
    /// than swallowing the response.
    ApiChecker.handleError(response.apiError);
    return null;
  }

  @override
  Future<ResponseModel?> changeBundleStatus(int bundleId, int status) async {
    ResponseModel? responseModel;
    Response response = await apiClient.postData(
      '${AppConstants.bundleStatusUri}$bundleId', {'status': status}, handleError: false,
    );
    if(response.statusCode == 200) {
      responseModel = ResponseModel(true, response.apiMessage);
    } else {
      ApiChecker.handleError(response.apiError);
    }
    return responseModel;
  }

  /// The store's own catalogue, shaped for the bundle builder — items, or
  /// services when the token's store is a service provider.
  ///
  /// Unavailable rows are kept rather than dropped: the guide is explicit that a
  /// vendor who cannot find one cannot tell whether it is missing or ineligible,
  /// so the picker greys them instead.
  ///
  /// No `search` is passed. The server filters `name LIKE %search%` against the
  /// item's stored column while the payload's `name` is resolved through
  /// translations, so searching for a name the vendor can see on screen returns
  /// nothing for any item translated into their own locale. Filtering the
  /// fetched rows client-side searches what is actually displayed.
  @override
  Future<List<BundleCatalogueItem>?> getBundleItems({String? search}) async {
    List<BundleCatalogueItem>? items;
    Response response = await apiClient.getData(AppConstants.bundleItemsUri);
    if(response.statusCode == 200) {
      final dynamic keyed = response.contentMap['items'];
      final List<dynamic> rows = keyed is List ? keyed : response.dataList;

      items = [];
      for(final dynamic row in rows) {
        if(row is! Map) {
          continue;
        }
        items.add(_parseCatalogueRow(Map<String, dynamic>.from(row)));
      }
    }
    return items;
  }

  BundleCatalogueItem _parseCatalogueRow(Map<String, dynamic> json) {
    json['store_category_name'] ??= json['category_name'];

    final bool isService = json['is_service'] == true;
    final bool isAvailable = json['is_available'] != false;

    if(!isService) {
      final Item parsed = Item.fromJson(json);
      applyBundleItemVariations(parsed, json);
      return BundleCatalogueItem(item: parsed, isAvailable: isAvailable);
    }

    /// A service row has no `stock`, `add_ons`, `choice_options` or
    /// `uses_food_variations`, so it is built by hand rather than through
    /// [Item.fromJson], which reaches for the store's module to guess a
    /// variation system that a service does not have.
    final List<BundleServiceVariant> variants = decodeMapList(json['variants'])
        .map(BundleServiceVariant.fromJson).toList();

    final Item parsed = Item(
      id: _asInt(json['id']),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      imageFullUrl: json['image_full_url']?.toString(),
      storeCategoryName: json['category_name']?.toString(),
      price: _asDouble(json['price']),
      /// The bundle freezes the gross figure: a bundle is already the promotion,
      /// so the service's own discount is not taken as well.
      discount: 0,
      discountType: 'percent',
    );

    /// Surfaced through the legacy variation list so the shared picker sheet can
    /// offer them as a single-select; the chosen label is turned back into a
    /// `variant_key` by [BundleCatalogueItem.variantNamed].
    parsed.foodVariations = null;
    parsed.choiceOptions = null;
    parsed.variations = variants
        .map((variant) => Variation(type: variant.name, price: variant.price))
        .toList();

    return BundleCatalogueItem(
      item: parsed,
      isAvailable: isAvailable,
      isService: true,
      requiresVariant: json['requires_variant'] == true,
      variants: variants,
    );
  }

  static int? _asInt(dynamic value) {
    if(value is int) return value;
    if(value is double) return value.toInt();
    if(value is String) return int.tryParse(value);
    return null;
  }

  static double? _asDouble(dynamic value) {
    if(value is double) return value;
    if(value is int) return value.toDouble();
    if(value is String) return double.tryParse(value);
    return null;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

  @override
  Future<ResponseModel?> delete(int? id) async {
    ResponseModel? responseModel;
    Response response = await apiClient.deleteData('${AppConstants.bundleDeleteUri}$id', handleError: false);
    if(response.statusCode == 200) {
      responseModel = ResponseModel(true, response.apiMessage);
    }
    return responseModel;
  }

  @override
  Future getList() {
    throw UnimplementedError();
  }

  @override
  Future get(int? id) {
    throw UnimplementedError();
  }
}

/// What a successful create or update hands back: the re-priced bundle and the
/// envelope's own message.
class BundleSaveResult {
  final BundlePackage bundle;
  final String? message;
  const BundleSaveResult({required this.bundle, this.message});
}
