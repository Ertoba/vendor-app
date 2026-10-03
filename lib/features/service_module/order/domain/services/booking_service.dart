import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_cancellation_body_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/models/assignable_service_man_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/models/booking_details_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/models/booking_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/repositories/booking_repository_interface.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/services/booking_service_interface.dart';

class BookingService implements BookingServiceInterface {
  final BookingRepositoryInterface bookingRepositoryInterface;
  BookingService({required this.bookingRepositoryInterface});

  @override
  Future<BookingListModel?> getBookingList({required int limit, required int offset, required String status}) async {
    return await bookingRepositoryInterface.getBookingList(limit: limit, offset: offset, status: status);
  }

  @override
  Future<BookingDetailsModel?> getBookingDetails(int id) async {
    return await bookingRepositoryInterface.getBookingDetails(id);
  }

  @override
  Future<ResponseModel> updateBookingStatus(int id, String status, {String? cancellationReason, String? otp, List<XFile>? evidenceImages}) async {
    return await bookingRepositoryInterface.updateBookingStatus(id, status, cancellationReason: cancellationReason, otp: otp, evidenceImages: evidenceImages);
  }

  @override
  Future<OrderCancellationBodyModel?> getCancelReasons() async {
    return await bookingRepositoryInterface.getCancelReasons();
  }

  @override
  Future<List<AssignableServiceManModel>?> getAssignableServicemen(int bookingId, {String? search}) async {
    return await bookingRepositoryInterface.getAssignableServicemen(bookingId, search: search);
  }

  @override
  Future<ResponseModel> assignServicemen(int bookingId, List<int> servicemanIds) async {
    return await bookingRepositoryInterface.assignServicemen(bookingId, servicemanIds);
  }

  @override
  Future<List<int>?> getBookingInvoice(int bookingId) async {
    return await bookingRepositoryInterface.getBookingInvoice(bookingId);
  }

  @override
  Future<ResponseModel> updateServiceLocation(int bookingId, String serviceLocationStatus) async {
    return await bookingRepositoryInterface.updateServiceLocation(bookingId, serviceLocationStatus);
  }

  @override
  Future<ResponseModel> rescheduleBooking(int bookingId, String scheduleAt) async {
    return await bookingRepositoryInterface.rescheduleBooking(bookingId, scheduleAt);
  }
}
