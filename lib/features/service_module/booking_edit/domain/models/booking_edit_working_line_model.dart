enum BookingEditLineStatus { unchanged, repriced, newLine }

class BookingEditWorkingLine {
  int? detailId;
  int? origQuantity;
  int serviceId;
  String? serviceName;
  String? variantKey;
  String? variantName;
  double unitPrice;
  double? grossPrice;
  double? discount;
  int quantity;
  bool missing;
  String? imageFullUrl;

  BookingEditWorkingLine({
    this.detailId,
    this.origQuantity,
    required this.serviceId,
    this.serviceName,
    this.variantKey,
    this.variantName,
    required this.unitPrice,
    this.grossPrice,
    this.discount,
    required this.quantity,
    this.missing = false,
    this.imageFullUrl,
  });

  bool get isNew => detailId == null;

  BookingEditLineStatus get status {
    if (isNew) return BookingEditLineStatus.newLine;
    return quantity == origQuantity ? BookingEditLineStatus.unchanged : BookingEditLineStatus.repriced;
  }
}
