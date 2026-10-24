import 'package:sixam_mart_store/features/service_module/store/domain/models/service_faq_model.dart';

abstract class ServiceFaqServiceInterface {
  Future<ServiceFaqModel?> getFaqList(int serviceId);
  Future<bool> addFaq(int serviceId, String question, String answer);
  Future<bool> updateFaq(int faqId, String question, String answer);
  Future<bool> toggleFaqStatus(int faqId, int status);
  Future<bool> deleteFaq(int faqId);
}
