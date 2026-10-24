import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_cancellation_body_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/models/assignable_service_man_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/models/booking_details_model.dart';
import 'package:sixam_mart_store/features/service_module/order/domain/models/booking_model.dart';
import 'package:sixam_mart_store/interface/repository_interface.dart';

abstract class BookingRepositoryInterface extends RepositoryInterface<Object> {
  Future<BookingListModel?> getBookingList({required int limit, required int offset, required String status});
  Future<BookingDetailsModel?> getBookingDetails(int id);
  Future<ResponseModel> updateBookingStatus(int id, String status, {String? cancellationReason, String? otp, List<XFile>? evidenceImages});
  Future<OrderCancellationBodyModel?> getCancelReasons();
  Future<List<AssignableServiceManModel>?> getAssignableServicemen(int bookingId, {String? search});
  Future<ResponseModel> assignServicemen(int bookingId, List<int> servicemanIds);
  Future<List<int>?> getBookingInvoice(int bookingId);
  Future<ResponseModel> updateServiceLocation(int bookingId, String serviceLocationStatus);
  Future<ResponseModel> rescheduleBooking(int bookingId, String scheduleAt);
}
