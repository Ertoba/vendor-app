class BookingEditBodyModel {
  List<BookingEditLineRequest>? lines;

  BookingEditBodyModel({this.lines});

  Map<String, dynamic> toJson() {
    return {'lines': (lines ?? []).map((line) => line.toJson()).toList()};
  }
}

class BookingEditLineRequest {
  int? detailId;
  int? serviceId;
  String? variantKey;
  int? quantity;

  BookingEditLineRequest({this.detailId, this.serviceId, this.variantKey, this.quantity});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (detailId != null) {
      data['detail_id'] = detailId;
    }
    data['service_id'] = serviceId;
    data['variant_key'] = variantKey ?? '';
    data['quantity'] = quantity;
    return data;
  }
}
