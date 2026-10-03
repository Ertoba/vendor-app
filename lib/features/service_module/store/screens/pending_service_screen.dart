import 'package:flutter/material.dart';

class PendingServiceScreen extends StatefulWidget {
  final bool fromNotification;
  const PendingServiceScreen({super.key, this.fromNotification = false});

  @override
  State<PendingServiceScreen> createState() => _PendingServiceScreenState();
}

class _PendingServiceScreenState extends State<PendingServiceScreen> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
