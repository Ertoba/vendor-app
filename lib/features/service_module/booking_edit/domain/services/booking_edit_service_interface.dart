import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_catalog_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_line_body_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_preview_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_working_line_model.dart';

abstract class BookingEditServiceInterface {
  List<BookingEditWorkingLine> prepareWorkingList(List<BookingEditCurrentLine>? source);
  BookingEditWorkingLine buildLineFromCatalogEntry(BookingEditCatalogService service, {BookingEditCatalogVariant? variant, int quantity = 1});
  int? findMatchingLineIndex(List<BookingEditWorkingLine> lines, int serviceId, String? variantKey);
  BookingEditBodyModel buildEditBody(List<BookingEditWorkingLine> lines);

  Future<BookingEditCatalogResponseModel?> getEditCatalog(int bookingId);
  Future<BookingEditPreviewResult> previewEdit(int bookingId, Map<String, dynamic> body);
  Future<ResponseModel> updateEdit(int bookingId, Map<String, dynamic> body);
}
