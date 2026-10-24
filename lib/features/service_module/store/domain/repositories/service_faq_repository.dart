import 'package:get/get.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_faq_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/repositories/service_faq_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class ServiceFaqRepository implements ServiceFaqRepositoryInterface {
  final ApiClient apiClient;
  ServiceFaqRepository({required this.apiClient});

  @override
  Future<ServiceFaqModel?> getFaqList(int serviceId) async {
    ServiceFaqModel? model;
    Response response = await apiClient.getData('${AppConstants.serviceFaqListUri}/$serviceId');
    if (response.statusCode == 200) {
      model = ServiceFaqModel.fromJson(response.body);
    }
    return model;
  }

  @override
  Future<bool> addFaq(int serviceId, String question, String answer) async {
    Response response = await apiClient.postMultipartData(
      '${AppConstants.serviceFaqStoreUri}/$serviceId',
      {'question': question, 'answer': answer}, [],
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> updateFaq(int faqId, String question, String answer) async {
    Response response = await apiClient.postMultipartData(
      '${AppConstants.serviceFaqUpdateUri}/$faqId',
      {'question': question, 'answer': answer}, [],
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> toggleFaqStatus(int faqId, int status) async {
    Response response = await apiClient.getData('${AppConstants.serviceFaqStatusUri}/$faqId/$status');
    return response.statusCode == 200;
  }

  @override
  Future<bool> deleteFaq(int faqId) async {
    Response response = await apiClient.deleteData('${AppConstants.serviceFaqDeleteUri}/$faqId');
    return response.statusCode == 200;
  }

  @override Future<dynamic> add(Object value) async => null;
  @override Future<dynamic> update(Map<String, dynamic> body) async => null;
  @override Future<dynamic> delete(int? id) async => null;
  @override Future<dynamic> getList() async => null;
  @override Future<dynamic> get(int? id) async => null;
}
