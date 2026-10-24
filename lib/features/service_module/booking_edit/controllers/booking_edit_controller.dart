import 'dart:async';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_catalog_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_preview_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_working_line_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/services/booking_edit_service_interface.dart';
import 'package:sixam_mart_store/features/service_module/order/controllers/booking_controller.dart';

class BookingEditController extends GetxController implements GetxService {
  final BookingEditServiceInterface bookingEditServiceInterface;
  BookingEditController({required this.bookingEditServiceInterface});

  List<BookingEditCatalogService>? _catalog;
  List<BookingEditCatalogService>? get catalog => _catalog;

  List<BookingEditWorkingLine>? _workingLines;
  List<BookingEditWorkingLine>? get workingLines => _workingLines;


  int? findMatchingLineIndex(int serviceId, String? variantKey) {
    return bookingEditServiceInterface.findMatchingLineIndex(_workingLines ?? [], serviceId, variantKey);
  }

  void addCatalogEntry(BookingEditCatalogService service, {BookingEditCatalogVariant? variant, int quantity = 1}) {
  }

  void updateWorkingLine(int index, {String? variantKey, String? variantName, double? unitPrice, double? grossPrice, double? discount, required int quantity}) {
  }

  void increaseLine(int index) {
  }

  void decreaseLine(int index) {
  }

  bool removeLine(int index) {
    return true;
  }

  Future<void> refreshPreview({bool debounce = false}) async {

  }

}
