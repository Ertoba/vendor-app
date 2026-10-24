import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_catalog_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_line_body_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_preview_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/models/booking_edit_working_line_model.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/repositories/booking_edit_repository_interface.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/domain/services/booking_edit_service_interface.dart';

class BookingEditService implements BookingEditServiceInterface {
  final BookingEditRepositoryInterface bookingEditRepositoryInterface;
  BookingEditService({required this.bookingEditRepositoryInterface});

  @override
  List<BookingEditWorkingLine> prepareWorkingList(List<BookingEditCurrentLine>? source) {
    List<BookingEditWorkingLine> list = [];
    if (source != null) {
      for (BookingEditCurrentLine line in source) {
        list.add(BookingEditWorkingLine(
          detailId: line.detailId,
          origQuantity: line.origQuantity ?? line.quantity,
          serviceId: line.serviceId ?? 0,
          serviceName: line.serviceName,
          variantKey: line.variantKey,
          variantName: line.variantName,
          unitPrice: line.unitPrice ?? 0,
          grossPrice: line.grossPrice,
          discount: line.discount,
          quantity: line.quantity ?? 1,
          missing: line.missing ?? false,
          imageFullUrl: line.imageFullUrl,
        ));
      }
    }
    return list;
  }

  @override
  BookingEditWorkingLine buildLineFromCatalogEntry(BookingEditCatalogService service, {BookingEditCatalogVariant? variant, int quantity = 1}) {
    return BookingEditWorkingLine(
      serviceId: service.id ?? 0,
      serviceName: service.name,
      variantKey: variant?.key,
      variantName: variant?.name,
      unitPrice: variant?.unitPrice ?? service.unitPrice ?? 0,
      grossPrice: variant?.grossPrice ?? service.grossPrice,
      discount: variant?.discount ?? service.discount,
      quantity: quantity,
      imageFullUrl: service.imageFullUrl,
    );
  }

  @override
  int? findMatchingLineIndex(List<BookingEditWorkingLine> lines, int serviceId, String? variantKey) {
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].serviceId == serviceId && (lines[i].variantKey ?? '') == (variantKey ?? '')) {
        return i;
      }
    }
    return null;
  }

  @override
  BookingEditBodyModel buildEditBody(List<BookingEditWorkingLine> lines) {
    return BookingEditBodyModel(
      lines: lines.map((line) => BookingEditLineRequest(
        detailId: line.detailId,
        serviceId: line.serviceId,
        variantKey: line.variantKey,
        quantity: line.quantity,
      )).toList(),
    );
  }

  @override
  Future<BookingEditCatalogResponseModel?> getEditCatalog(int bookingId) {
    return bookingEditRepositoryInterface.getEditCatalog(bookingId);
  }

  @override
  Future<BookingEditPreviewResult> previewEdit(int bookingId, Map<String, dynamic> body) {
    return bookingEditRepositoryInterface.previewEdit(bookingId, body);
  }

  @override
  Future<ResponseModel> updateEdit(int bookingId, Map<String, dynamic> body) {
    return bookingEditRepositoryInterface.updateEdit(bookingId, body);
  }
}
