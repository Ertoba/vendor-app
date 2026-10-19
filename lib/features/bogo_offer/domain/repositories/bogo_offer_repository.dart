import 'dart:convert';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:sixam_mart_store/features/bogo_offer/domain/repositories/bogo_offer_repository_interface.dart';
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
import 'package:sixam_mart_store/util/app_constants.dart';
import 'package:get/get.dart';

class BogoOfferRepository implements BogoOfferRepositoryInterface {
  final ApiClient apiClient;
  BogoOfferRepository({required this.apiClient});

  @override
  Future<BogoOfferModel?> getBogoOfferList(String offset, {String? search, String? type}) async {
    BogoOfferModel? bogoOfferModel;
    Response response = await apiClient.getData(
      '${AppConstants.bogoOfferListUri}?offset=$offset&limit=25&type=${type ?? 'all'}&search=${search ?? ''}',
    );
    if(response.statusCode == 200) {
      bogoOfferModel = BogoOfferModel.fromJson(response.contentMap);
    }
    return bogoOfferModel;
  }

  @override
  Future<BogoOffer?> getBogoOfferDetails(int offerId) async {
    BogoOffer? bogoOffer;
    Response response = await apiClient.getData('${AppConstants.bogoOfferDetailsUri}$offerId');
    if(response.statusCode == 200) {
      bogoOffer = BogoOffer.fromJson(response.contentMap);
    }
    return bogoOffer;
  }

  @override
  Future<BogoOfferJoinResponseModel?> joinBogoOffer(int offerId, List<Map<String, dynamic>> buyItems, List<Map<String, dynamic>> getItems) async {
    BogoOfferJoinResponseModel? bogoOfferJoinResponseModel;
    Response response = await apiClient.postData('${AppConstants.bogoOfferJoinUri}$offerId', {
      'buy_items': buyItems,
      'get_items': getItems,
    });
    if(response.statusCode == 200) {
      bogoOfferJoinResponseModel = BogoOfferJoinResponseModel.fromJson(response.contentMap);
      bogoOfferJoinResponseModel.message ??= response.apiMessage;
    }
    return bogoOfferJoinResponseModel;
  }

  @override
  Future<BogoOfferJoinResponseModel?> resubmitBogoOffer(int offerId, List<Map<String, dynamic>> buyItems, List<Map<String, dynamic>> getItems) async {
    BogoOfferJoinResponseModel? bogoOfferJoinResponseModel;
    Response response = await apiClient.postData('${AppConstants.bogoOfferResubmitUri}$offerId', {
      'buy_items': buyItems,
      'get_items': getItems,
    });
    if(response.statusCode == 200) {
      bogoOfferJoinResponseModel = BogoOfferJoinResponseModel.fromJson(response.contentMap);
      bogoOfferJoinResponseModel.message ??= response.apiMessage;
    }
    return bogoOfferJoinResponseModel;
  }

  @override
  Future<ResponseModel?> leaveBogoOffer(int offerId) async {
    ResponseModel? responseModel;
    Response response = await apiClient.deleteData('${AppConstants.bogoOfferLeaveUri}$offerId');
    if(response.statusCode == 200) {
      responseModel = ResponseModel(true, response.apiMessage);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel?> respondToBogoOffer(int offerId, {required String status, String? rejectionReason}) async {
    ResponseModel? responseModel;
    Response response = await apiClient.postData('${AppConstants.bogoOfferRespondUri}$offerId', {
      'status': status,
      if(rejectionReason != null && rejectionReason.isNotEmpty) 'rejection_reason': rejectionReason,
    });
    if(response.statusCode == 200) {
      responseModel = ResponseModel(true, response.apiMessage);
    }
    return responseModel;
  }

  /// The endpoint is still named `foods` — it is shared with StackFood — but it
  /// returns whatever the store sells, so the rows are parsed as [Item].
  @override
  Future<List<Item>?> getBogoOfferItems({String? search}) async {
    List<Item>? items;
    Response response = await apiClient.getData(
      '${AppConstants.bogoOfferItemsUri}${search != null && search.isNotEmpty ? '?search=$search' : ''}',
    );
    if(response.statusCode == 200) {
      final dynamic content = response.content;
      List<dynamic> rows = response.dataList;
      if(rows.isEmpty && content is Map) {
        final dynamic keyed = content['items'] ?? content['foods'];
        if(keyed is List) {
          rows = keyed;
        }
      }

      items = [];
      for(final dynamic row in rows) {
        if(row is! Map) {
          continue;
        }
        final Map<String, dynamic> item = Map<String, dynamic>.from(row);
        if(item['is_available'] == false) {
          continue;
        }

        item['store_category_name'] ??= item['category_name'];
        final Item parsed = Item.fromJson(item);
        _applyVariations(parsed, item);
        items.add(parsed);
      }
    }
    return items;
  }

  /// This endpoint describes variations in its own shape, and [Item.fromJson] reads
  /// none of it: `uses_food_variations` says which system the item is on, food-style
  /// groups arrive under `variations` rather than `food_variations`, and the flat
  /// `type` / `price` rows that [Variation] expects arrive under
  /// `variation_combinations`, with `choice_options` naming them.
  ///
  /// Left to itself [Item.fromJson] picks a system from the store's module and parses
  /// whatever sits in `variations`, which turns a food group into a legacy row whose
  /// `type` is the group's select mode — the sheet then offers a single option called
  /// "single" or "multi", and nothing the vendor picks ever matches it. So rebuild
  /// both lists from the raw row.
  void _applyVariations(Item item, Map<String, dynamic> json) {
    final List<Map<String, dynamic>> groups = _variationRows(json['variations']);

    if(json['uses_food_variations'] == true && groups.isNotEmpty && groups.first['values'] is List) {
      item.foodVariations = groups.map(FoodVariation.fromJson).toList();

      /// A food item can still carry the legacy pair as leftovers — Pepperoni Pizza
      /// does — and it would otherwise drive the sheet's picker instead.
      item.variations = null;
      item.choiceOptions = null;
      return;
    }

    item.foodVariations = null;
    final List<Map<String, dynamic>> combinations = _variationRows(json['variation_combinations']);
    if(combinations.isNotEmpty) {
      item.variations = combinations.map(Variation.fromJson).toList();
    } else if(groups.isNotEmpty) {
      item.variations = groups.map(Variation.fromJson).toList();
    }
  }

  /// The lists arrive as JSON arrays, or as a JSON-encoded string for items whose
  /// column is cast to text.
  List<Map<String, dynamic>> _variationRows(dynamic raw) {
    dynamic decoded = raw;
    if(raw is String && raw.trim().isNotEmpty) {
      try {
        decoded = jsonDecode(raw);
      } catch(_) {
        return const [];
      }
    }
    if(decoded is! List) {
      return const [];
    }
    return decoded.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList();
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
  Future delete(int? id) {
    throw UnimplementedError();
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
