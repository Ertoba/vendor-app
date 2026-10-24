import 'package:sixam_mart_store/features/service_module/service_reviews/domain/models/service_review_model.dart';

abstract class ServiceReviewServiceInterface {
  Future<ServiceReviewListModel?> getServiceReviewList({required String offset, String search = '', int? serviceId});
  Future<bool> updateReply(int reviewId, String reply);
  Future<bool> updateReviewStatus(int id, int status);
}
