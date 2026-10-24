import 'package:sixam_mart_store/features/service_module/service_reviews/domain/models/service_review_model.dart';
import 'package:sixam_mart_store/features/service_module/service_reviews/domain/repositories/service_review_repository_interface.dart';
import 'package:sixam_mart_store/features/service_module/service_reviews/domain/services/service_review_service_interface.dart';

class ServiceReviewService implements ServiceReviewServiceInterface {
  final ServiceReviewRepositoryInterface serviceReviewRepositoryInterface;
  ServiceReviewService({required this.serviceReviewRepositoryInterface});

  @override
  Future<ServiceReviewListModel?> getServiceReviewList({required String offset, String search = '', int? serviceId}) async {
    return await serviceReviewRepositoryInterface.getServiceReviewList(offset: offset, search: search, serviceId: serviceId);
  }

  @override
  Future<bool> updateReply(int reviewId, String reply) async {
    return await serviceReviewRepositoryInterface.updateReply(reviewId, reply);
  }

  @override
  Future<bool> updateReviewStatus(int id, int status) async {
    return await serviceReviewRepositoryInterface.updateReviewStatus(id, status);
  }
}
