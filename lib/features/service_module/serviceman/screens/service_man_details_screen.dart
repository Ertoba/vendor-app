import 'package:flutter/material.dart';
import 'package:sixam_mart_store/features/service_module/serviceman/domain/models/service_man_model.dart';

class ServiceManDetailsScreen extends StatefulWidget {
  final ServiceManModel serviceMan;
  const ServiceManDetailsScreen({super.key, required this.serviceMan});

  @override
  State<ServiceManDetailsScreen> createState() => _ServiceManDetailsScreenState();
}

class _ServiceManDetailsScreenState extends State<ServiceManDetailsScreen> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
