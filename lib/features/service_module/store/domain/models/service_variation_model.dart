import 'package:flutter/material.dart';

/// A single flat service variation row used by the add/update service form.
/// Mirrors the API `variations` JSON array element: `{name, price, discount, discount_type}`.
class ServiceVariationBodyModel {
  TextEditingController? nameController;
  TextEditingController? priceController;
  TextEditingController? discountController;
  int discountTypeIndex; // 0 = percent, 1 = amount

  ServiceVariationBodyModel({
    this.nameController,
    this.priceController,
    this.discountController,
    this.discountTypeIndex = 0,
  });

  String get discountType => discountTypeIndex == 0 ? 'percent' : 'amount';

  Map<String, dynamic> toJson() {
    final double price = double.tryParse(priceController?.text.trim() ?? '') ?? 0;
    final double discount = double.tryParse(discountController?.text.trim() ?? '') ?? 0;
    return {
      'name': nameController?.text.trim() ?? '',
      'price': price,
      'discount': discount,
      'discount_type': discountType,
    };
  }
}
