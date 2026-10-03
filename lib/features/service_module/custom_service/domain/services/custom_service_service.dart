import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/service_module/custom_service/domain/models/custom_service_request_model.dart';
import 'package:sixam_mart_store/features/service_module/custom_service/domain/models/provider_offer_model.dart';
import 'package:sixam_mart_store/features/service_module/custom_service/domain/repositories/custom_service_repository_interface.dart';
import 'package:sixam_mart_store/features/service_module/custom_service/domain/services/custom_service_service_interface.dart';

class CustomServiceService implements CustomServiceServiceInterface {
  final CustomServiceRepositoryInterface customServiceRepositoryInterface;
  CustomServiceService({required this.customServiceRepositoryInterface});

  @override
  Future<CustomServiceRequestListModel?> getRequestList({required String type, required String offset}) async {
    return await customServiceRepositoryInterface.getRequestList(type: type, offset: offset);
  }

  @override
  Future<CustomServiceRequestDetailsModel?> getRequestDetails(int id) async {
    return await customServiceRepositoryInterface.getRequestDetails(id);
  }

  @override
  Future<ProviderOfferListModel?> getOtherBids(int requestId, {required String offset}) async {
    return await customServiceRepositoryInterface.getOtherBids(requestId, offset: offset);
  }

  @override
  Future<ResponseModel> submitBid(int requestId, double offerPrice, String? note) async {
    return await customServiceRepositoryInterface.submitBid(requestId, offerPrice, note);
  }

  @override
  Future<ResponseModel> withdrawBid(int bidId) async {
    return await customServiceRepositoryInterface.withdrawBid(bidId);
  }
}
