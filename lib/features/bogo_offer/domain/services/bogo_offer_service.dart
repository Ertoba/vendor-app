import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:sixam_mart_store/features/bogo_offer/domain/repositories/bogo_offer_repository_interface.dart';
import 'package:sixam_mart_store/features/bogo_offer/domain/services/bogo_offer_service_interface.dart';
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';

class BogoOfferService implements BogoOfferServiceInterface {
  final BogoOfferRepositoryInterface bogoOfferRepositoryInterface;
  BogoOfferService({required this.bogoOfferRepositoryInterface});

  @override
  Future<BogoOfferModel?> getBogoOfferList(String offset, {String? search, String? type}) async {
    return await bogoOfferRepositoryInterface.getBogoOfferList(offset, search: search, type: type);
  }

  @override
  Future<BogoOffer?> getBogoOfferDetails(int offerId) async {
    return await bogoOfferRepositoryInterface.getBogoOfferDetails(offerId);
  }

  @override
  Future<BogoOfferJoinResponseModel?> joinBogoOffer(int offerId, List<Map<String, dynamic>> buyItems, List<Map<String, dynamic>> getItems) async {
    return await bogoOfferRepositoryInterface.joinBogoOffer(offerId, buyItems, getItems);
  }

  @override
  Future<BogoOfferJoinResponseModel?> resubmitBogoOffer(int offerId, List<Map<String, dynamic>> buyItems, List<Map<String, dynamic>> getItems) async {
    return await bogoOfferRepositoryInterface.resubmitBogoOffer(offerId, buyItems, getItems);
  }

  @override
  Future<ResponseModel?> leaveBogoOffer(int offerId) async {
    return await bogoOfferRepositoryInterface.leaveBogoOffer(offerId);
  }

  @override
  Future<ResponseModel?> respondToBogoOffer(int offerId, {required String status, String? rejectionReason}) async {
    return await bogoOfferRepositoryInterface.respondToBogoOffer(offerId, status: status, rejectionReason: rejectionReason);
  }

  @override
  Future<List<Item>?> getBogoOfferItems({String? search}) async {
    return await bogoOfferRepositoryInterface.getBogoOfferItems(search: search);
  }
}
