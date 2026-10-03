import 'package:sixam_mart_store/features/service_module/store/domain/models/service_faq_model.dart';
import 'package:sixam_mart_store/interface/repository_interface.dart';

abstract class ServiceFaqRepositoryInterface extends RepositoryInterface<Object> {
  Future<ServiceFaqModel?> getFaqList(int serviceId);
  Future<bool> addFaq(int serviceId, String question, String answer);
  Future<bool> updateFaq(int faqId, String question, String answer);
  Future<bool> toggleFaqStatus(int faqId, int status);
  Future<bool> deleteFaq(int faqId);
}
