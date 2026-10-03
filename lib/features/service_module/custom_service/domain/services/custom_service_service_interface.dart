import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/service_module/custom_service/domain/models/custom_service_request_model.dart';
import 'package:sixam_mart_store/features/service_module/custom_service/domain/models/provider_offer_model.dart';

abstract class CustomServiceServiceInterface {
  Future<CustomServiceRequestListModel?> getRequestList({required String type, required String offset});
  Future<CustomServiceRequestDetailsModel?> getRequestDetails(int id);
  Future<ProviderOfferListModel?> getOtherBids(int requestId, {required String offset});
  Future<ResponseModel> submitBid(int requestId, double offerPrice, String? note);
  Future<ResponseModel> withdrawBid(int bidId);
}
