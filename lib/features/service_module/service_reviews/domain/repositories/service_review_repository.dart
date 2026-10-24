import 'package:get/get.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/features/service_module/service_reviews/domain/models/service_review_model.dart';
import 'package:sixam_mart_store/features/service_module/service_reviews/domain/repositories/service_review_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class ServiceReviewRepository implements ServiceReviewRepositoryInterface {
  final ApiClient apiClient;
  ServiceReviewRepository({required this.apiClient});

  @override
  Future<ServiceReviewListModel?> getServiceReviewList({required String offset, String search = '', int? serviceId}) async {
    ServiceReviewListModel? model;
    Response response = await apiClient.getData(
      '${AppConstants.vendorServiceReviewListUri}?limit=9999&offset=$offset${search.isNotEmpty ? '&search=$search' : ''}${serviceId != null ? '&service_id=$serviceId' : ''}',
    );
    if (response.statusCode == 200) {
      model = ServiceReviewListModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future<bool> updateReply(int reviewId, String reply) async {
    Response response = await apiClient.putData(AppConstants.vendorServiceReviewReplyUri, {'id': reviewId, 'reply': reply});
    return response.statusCode == 200;
  }

  @override
  Future<bool> updateReviewStatus(int id, int status) async {
    Response response = await apiClient.getData('${AppConstants.vendorServiceReviewStatusUri}/$id/$status');
    return response.statusCode == 200;
  }

  @override Future<dynamic> add(Object value) async => null;
  @override Future<dynamic> update(Map<String, dynamic> body) async => null;
  @override Future<dynamic> delete(int? id) async => null;
  @override Future<dynamic> getList() async => null;
  @override Future<dynamic> get(int? id) async => null;
}
