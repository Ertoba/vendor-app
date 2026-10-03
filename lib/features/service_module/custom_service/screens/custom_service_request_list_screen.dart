import 'package:flutter/material.dart';

class CustomServiceRequestListScreen extends StatefulWidget {
  const CustomServiceRequestListScreen({super.key});

  @override
  State<CustomServiceRequestListScreen> createState() => _CustomServiceRequestListScreenState();
}

class _CustomServiceRequestListScreenState extends State<CustomServiceRequestListScreen> {
  final ScrollController _newRequestScrollController = ScrollController();
  final ScrollController _myBidsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _newRequestScrollController.dispose();
    _myBidsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
