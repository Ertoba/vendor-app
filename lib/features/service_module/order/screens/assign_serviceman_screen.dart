import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssignServicemanScreen extends StatefulWidget {
  final int bookingId;
  const AssignServicemanScreen({super.key, required this.bookingId});

  static Future<T?> show<T>({required int bookingId}) {
    return Get.bottomSheet<T>(
      AssignServicemanScreen(bookingId: bookingId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<AssignServicemanScreen> createState() => _AssignServicemanScreenState();
}

class _AssignServicemanScreenState extends State<AssignServicemanScreen> {


  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

