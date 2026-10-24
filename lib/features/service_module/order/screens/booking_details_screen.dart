import 'package:flutter/material.dart';

class BookingDetailsScreen extends StatefulWidget {
  final int bookingId;
  final bool fromNotification;
  const BookingDetailsScreen({super.key, required this.bookingId, this.fromNotification = false});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
