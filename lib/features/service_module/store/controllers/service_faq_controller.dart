import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_faq_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/services/service_faq_service_interface.dart';

class ServiceFaqController extends GetxController implements GetxService {
  final ServiceFaqServiceInterface serviceFaqServiceInterface;
  ServiceFaqController({required this.serviceFaqServiceInterface});

  List<ServiceFaq>? _faqList;
  List<ServiceFaq>? get faqList => _faqList;

  bool _isActionLoading = false;
  bool get isActionLoading => _isActionLoading;

  Future<void> getFaqList(int serviceId, {bool reload = true}) async {
    if (reload) {
      _faqList = null;
      update();
    }
    ServiceFaqModel? model = await serviceFaqServiceInterface.getFaqList(serviceId);
    _faqList = model?.faqs ?? [];
    update();
  }

  Future<bool> addFaq(int serviceId, String question, String answer) async {
    _isActionLoading = true;
    update();
    bool isSuccess = await serviceFaqServiceInterface.addFaq(serviceId, question, answer);
    if (isSuccess) {
      await getFaqList(serviceId, reload: false);
    }
    _isActionLoading = false;
    update();
    return isSuccess;
  }

  Future<bool> updateFaq(int serviceId, int faqId, String question, String answer) async {
    _isActionLoading = true;
    update();
    bool isSuccess = await serviceFaqServiceInterface.updateFaq(faqId, question, answer);
    if (isSuccess) {
      await getFaqList(serviceId, reload: false);
    }
    _isActionLoading = false;
    update();
    return isSuccess;
  }

  Future<void> toggleFaqStatus(int serviceId, ServiceFaq faq) async {
    int newStatus = (faq.status == 1) ? 0 : 1;
    bool isSuccess = await serviceFaqServiceInterface.toggleFaqStatus(faq.id!, newStatus);
    if (isSuccess) {
      faq.status = newStatus;
      update();
    }
  }

  Future<void> deleteFaq(int serviceId, int faqId) async {
    _isActionLoading = true;
    update();
    bool isSuccess = await serviceFaqServiceInterface.deleteFaq(faqId);
    if (isSuccess) {
      await getFaqList(serviceId, reload: false);
      showCustomSnackBar('faq_deleted_successfully'.tr, isError: false);
    }
    _isActionLoading = false;
    update();
  }
}
