import 'package:get/get.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/service_module/custom_service/domain/models/custom_service_request_model.dart';
import 'package:sixam_mart_store/features/service_module/custom_service/domain/models/provider_offer_model.dart';
import 'package:sixam_mart_store/features/service_module/custom_service/domain/repositories/custom_service_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class CustomServiceRepository implements CustomServiceRepositoryInterface {
  final ApiClient apiClient;
  CustomServiceRepository({required this.apiClient});

  @override
  Future<CustomServiceRequestListModel?> getRequestList({required String type, required String offset}) async {
    CustomServiceRequestListModel? model;
    Response response = await apiClient.getData('${AppConstants.customServiceRequestListUri}?type=$type&limit=10&offset=$offset');
    if (response.statusCode == 200) {
      model = CustomServiceRequestListModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future<CustomServiceRequestDetailsModel?> getRequestDetails(int id) async {
    CustomServiceRequestDetailsModel? model;
    Response response = await apiClient.getData('${AppConstants.customServiceRequestListUri}/$id');
    if (response.statusCode == 200) {
      model = CustomServiceRequestDetailsModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future<ProviderOfferListModel?> getOtherBids(int requestId, {required String offset}) async {
    ProviderOfferListModel? model;
    Response response = await apiClient.getData('${AppConstants.customServiceRequestListUri}/$requestId/other-bids?limit=10&offset=$offset');
    if (response.statusCode == 200) {
      model = ProviderOfferListModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future<ResponseModel> submitBid(int requestId, double offerPrice, String? note) async {
    ResponseModel responseModel;
    Response response = await apiClient.postData(
      '${AppConstants.customServiceRequestListUri}/$requestId/bids',
      {'offer_price': offerPrice, if (note != null && note.isNotEmpty) 'note': note},
      handleError: false,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override
  Future<ResponseModel> withdrawBid(int bidId) async {
    ResponseModel responseModel;
    Response response = await apiClient.deleteData('${AppConstants.customServiceBidUri}/$bidId', handleError: false);
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body['message']);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    return responseModel;
  }

  @override Future<dynamic> add(Object value) async => null;
  @override Future<dynamic> update(Map<String, dynamic> body) async => null;
  @override Future<dynamic> delete(int? id) async => null;
  @override Future<dynamic> getList() async => null;
  @override Future<dynamic> get(int? id) async => null;
}
