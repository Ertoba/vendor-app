import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/service_module/service_reviews/domain/models/service_review_model.dart';
import 'package:sixam_mart_store/features/service_module/service_reviews/domain/services/service_review_service_interface.dart';

class ServiceReviewController extends GetxController implements GetxService {
  final ServiceReviewServiceInterface serviceReviewServiceInterface;
  ServiceReviewController({required this.serviceReviewServiceInterface});

  List<ServiceReviewModel>? _serviceReviewList;
  List<ServiceReviewModel>? get serviceReviewList => _serviceReviewList;

  List<ServiceReviewModel>? _searchReviewList;
  List<ServiceReviewModel>? get searchReviewList => _searchReviewList;

  RatingSummaryModel? _ratingSummary;
  RatingSummaryModel? get ratingSummary => _ratingSummary;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getServiceReviewList(String? searchText, {bool willUpdate = true, int? serviceId}) async {
    if (searchText!.isEmpty) {
      _serviceReviewList = null;
      _isSearching = false;
    } else {
      _searchReviewList = null;
      _isSearching = true;
    }
    if (willUpdate) {
      update();
    }
    ServiceReviewListModel? model = await serviceReviewServiceInterface.getServiceReviewList(offset: '1', search: searchText, serviceId: serviceId);

    if (model != null) {
      if (searchText.isEmpty) {
        _serviceReviewList = [];
        _serviceReviewList!.addAll(model.reviews ?? []);
        _ratingSummary = model.ratingSummary;
      } else {
        _searchReviewList = [];
        _searchReviewList!.addAll(model.reviews ?? []);
      }
    }
    update();
  }

  Future<void> updateReply(int reviewId, String reply) async {
    _isLoading = true;
    update();
    bool isSuccess = await serviceReviewServiceInterface.updateReply(reviewId, reply);
    if (isSuccess) {
      Get.back();
      showCustomSnackBar('reply_updated_successfully'.tr, isError: false);
      getServiceReviewList('');
    }
    _isLoading = false;
    update();
  }

  Future<void> updateReviewStatus(int id, int status) async {
    bool isSuccess = await serviceReviewServiceInterface.updateReviewStatus(id, status);
    if (isSuccess) {
      getServiceReviewList('');
    }
    update();
  }
}
