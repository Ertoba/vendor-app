import 'package:flutter/material.dart';
import 'package:sixam_mart_store/features/service_module/custom_service/domain/models/custom_service_request_model.dart';

class CustomServiceOfferScreen extends StatefulWidget {
  final int requestId;
  final CustomServiceBidModel? existingBid;
  const CustomServiceOfferScreen({super.key, required this.requestId, this.existingBid});

  @override
  State<CustomServiceOfferScreen> createState() => _CustomServiceOfferScreenState();
}

class _CustomServiceOfferScreenState extends State<CustomServiceOfferScreen> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
