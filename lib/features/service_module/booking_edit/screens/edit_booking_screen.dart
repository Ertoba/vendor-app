import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/controllers/booking_edit_controller.dart';
import 'package:sixam_mart_store/features/service_module/booking_edit/widgets/booking_edit_line_widget.dart';
import 'package:sixam_mart_store/features/service_module/order/controllers/booking_controller.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class EditBookingScreen extends StatelessWidget {
  final int bookingId;
  const EditBookingScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
