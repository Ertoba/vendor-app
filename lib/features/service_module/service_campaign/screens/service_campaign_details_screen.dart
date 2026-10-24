
import 'package:flutter/material.dart';

class ServiceCampaignDetailsScreen extends StatefulWidget {
  final int id;
  final bool fromNotification;
  const ServiceCampaignDetailsScreen({super.key, required this.id, this.fromNotification = false});

  @override
  State<ServiceCampaignDetailsScreen> createState() => _ServiceCampaignDetailsScreenState();
}

class _ServiceCampaignDetailsScreenState extends State<ServiceCampaignDetailsScreen> {


  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
