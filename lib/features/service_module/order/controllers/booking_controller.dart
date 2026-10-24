import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_cancellation_body_model.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/models/assignable_service_man_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/models/booking_details_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/models/booking_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/models/running_booking_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/services/booking_service_interface.dart';

class BookingController extends GetxController implements GetxService {
  final BookingServiceInterface bookingServiceInterface;
  BookingController({required this.bookingServiceInterface});

  int _runningIndex = 0;
  int get runningIndex => _runningIndex;
  void setRunningIndex(int index) {
    _runningIndex = index;
    update();
  }

  int _historyIndex = 0;
  int get historyIndex => _historyIndex;
  void setHistoryIndex(int index) {
    _historyIndex = index;
    getPaginatedBookings(1, true);
  }

  List<RunningBookingModel>? _runningBookings;
  List<RunningBookingModel>? get runningBookings => _runningBookings;

  bool _isRunningBookingLoading = false;
  bool get isRunningBookingLoading => _isRunningBookingLoading;

  bool _campaignOnly = false;
  bool get campaignOnly => _campaignOnly;
  void toggleCampaignOnly() {
    _campaignOnly = !_campaignOnly;
    update();
  }

  List<BookingModel> getFilteredBookingList(List<BookingModel> bookingList) {
    return _campaignOnly ? bookingList.where((booking) => booking.isCampaign == true).toList() : bookingList;
  }

  Future<void> getRunningBookings() async {

  }

  List<BookingModel>? _historyBookingList;
  List<BookingModel>? get historyBookingList => _historyBookingList;
  int? _historyTotalSize;
  int? get historyTotalSize => _historyTotalSize;
  final List<int> _historyOffsetList = [];
  int _historyOffset = 1;
  int get historyOffset => _historyOffset;
  bool _paginate = false;
  bool get paginate => _paginate;

  bool _isHistoryBookingLoading = false;
  bool get isHistoryBookingLoading => _isHistoryBookingLoading;

  Future<void> getPaginatedBookings(int offset, bool reload) async {

  }

  void showBottomLoader() {
    _paginate = true;
    update();
  }

  Future<void> getBookingDetails(int id, {bool reload = true}) async {
  }


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _cancelReason = '';
  String? get cancelReason => _cancelReason;
  void setBookingCancelReason(String? reason) {
    _cancelReason = reason;
    update();
  }

  List<Data>? _bookingCancelReasons;
  List<Data>? get bookingCancelReasons => _bookingCancelReasons;

  Future<void> getBookingCancelReasons() async {

  }

  List<XFile> _completionEvidenceImages = [];
  List<XFile> get completionEvidenceImages => _completionEvidenceImages;

  Future<void> pickCompletionEvidenceImage() async {

  }

  void removeCompletionEvidenceImage(int index) {
    _completionEvidenceImages.removeAt(index);
    update();
  }

  void clearCompletionEvidenceImages() {
    _completionEvidenceImages = [];
    update();
  }

  Future<bool> updateBookingStatus(int bookingId, String status, {String? cancellationReason, String? otp, bool back = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await bookingServiceInterface.updateBookingStatus(
      bookingId, status, cancellationReason: cancellationReason, otp: otp, evidenceImages: _completionEvidenceImages,
    );
    if (Get.isDialogOpen == true) {
      Get.back(result: responseModel.isSuccess);
    }
    if (responseModel.isSuccess) {
      if (back) {
        Get.back();
      }
      _completionEvidenceImages = [];
      await getBookingDetails(bookingId, reload: false);
      getRunningBookings();
      Get.find<ProfileController>().getProfile();
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    _isLoading = false;
    update();
    return responseModel.isSuccess;
  }

  List<AssignableServiceManModel>? _assignableServicemen;
  List<AssignableServiceManModel>? get assignableServicemen => _assignableServicemen;

  void resetAssignableServicemen() {
    _assignableServicemen = null;
  }

  bool _isAssignSubmitLoading = false;
  bool get isAssignSubmitLoading => _isAssignSubmitLoading;

  Future<void> getAssignableServicemen(int bookingId, {String? search}) async {
    _assignableServicemen = null;
    update();
    _assignableServicemen = await bookingServiceInterface.getAssignableServicemen(bookingId, search: search);
    update();
  }

  Future<bool> assignServicemenToBooking(int bookingId, List<int> servicemanIds) async {
    _isAssignSubmitLoading = true;
    update();
    ResponseModel responseModel = await bookingServiceInterface.assignServicemen(bookingId, servicemanIds);
    if (responseModel.isSuccess) {
      await getBookingDetails(bookingId, reload: false);
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    _isAssignSubmitLoading = false;
    update();
    return responseModel.isSuccess;
  }

  bool _isServiceLocationLoading = false;
  bool get isServiceLocationLoading => _isServiceLocationLoading;

  Future<bool> updateServiceLocation(int bookingId, String serviceLocationStatus) async {
    _isServiceLocationLoading = true;
    update();
    ResponseModel responseModel = await bookingServiceInterface.updateServiceLocation(bookingId, serviceLocationStatus);
    if (responseModel.isSuccess) {
      await getBookingDetails(bookingId, reload: false);
      showCustomSnackBar(responseModel.message, isError: false);
    } else {
      showCustomSnackBar(responseModel.message, isError: true);
    }
    _isServiceLocationLoading = false;
    update();
    return responseModel.isSuccess;
  }

  bool _isRescheduleLoading = false;
  bool get isRescheduleLoading => _isRescheduleLoading;

}
