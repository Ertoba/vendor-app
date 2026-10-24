import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RescheduleBookingScreen extends StatefulWidget {
  final int bookingId;
  const RescheduleBookingScreen({super.key, required this.bookingId});

  static Future<T?> show<T>({required int bookingId}) {
    return Get.bottomSheet<T>(
      RescheduleBookingScreen(bookingId: bookingId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<RescheduleBookingScreen> createState() => _RescheduleBookingScreenState();
}

class _RescheduleBookingScreenState extends State<RescheduleBookingScreen> {

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
