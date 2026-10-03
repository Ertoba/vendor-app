import 'package:sixam_mart_store/features/service_module/store/domain/models/service_faq_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/repositories/service_faq_repository_interface.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/services/service_faq_service_interface.dart';

class ServiceFaqService implements ServiceFaqServiceInterface {
  final ServiceFaqRepositoryInterface serviceFaqRepositoryInterface;
  ServiceFaqService({required this.serviceFaqRepositoryInterface});

  @override
  Future<ServiceFaqModel?> getFaqList(int serviceId) async {
    return await serviceFaqRepositoryInterface.getFaqList(serviceId);
  }

  @override
  Future<bool> addFaq(int serviceId, String question, String answer) async {
    return await serviceFaqRepositoryInterface.addFaq(serviceId, question, answer);
  }

  @override
  Future<bool> updateFaq(int faqId, String question, String answer) async {
    return await serviceFaqRepositoryInterface.updateFaq(faqId, question, answer);
  }

  @override
  Future<bool> toggleFaqStatus(int faqId, int status) async {
    return await serviceFaqRepositoryInterface.toggleFaqStatus(faqId, status);
  }

  @override
  Future<bool> deleteFaq(int faqId) async {
    return await serviceFaqRepositoryInterface.deleteFaq(faqId);
  }
}
