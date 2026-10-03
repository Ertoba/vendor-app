import 'package:flutter/material.dart';

class BookingStatusHelper {
  const BookingStatusHelper._();

  static Color color(String? status) {
    switch (status) {
      case 'pending': return Colors.blueAccent;
      case 'accepted': return Colors.cyan;
      case 'confirmed': return Colors.teal;
      case 'ongoing': return Colors.orangeAccent;
      case 'on_hold': return Colors.amber;
      case 'completed': return Colors.indigo;
      default: return Colors.red;
    }
  }

  static bool isClosed(String? status) => status == 'completed' || status == 'canceled';
}
