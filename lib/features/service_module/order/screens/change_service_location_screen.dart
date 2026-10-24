import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangeServiceLocationScreen extends StatefulWidget {
  final int bookingId;
  final String? currentLocation;
  final List<String>? availableLocations;
  const ChangeServiceLocationScreen({super.key, required this.bookingId, this.currentLocation, this.availableLocations});

  static Future<T?> show<T>({required int bookingId, String? currentLocation, List<String>? availableLocations}) {
    return Get.bottomSheet<T>(
      ChangeServiceLocationScreen(bookingId: bookingId, currentLocation: currentLocation, availableLocations: availableLocations),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<ChangeServiceLocationScreen> createState() => _ChangeServiceLocationScreenState();
}

class _ChangeServiceLocationScreenState extends State<ChangeServiceLocationScreen> {

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
