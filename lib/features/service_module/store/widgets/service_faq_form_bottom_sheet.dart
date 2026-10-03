import 'package:flutter/material.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_faq_model.dart';


class ServiceFaqFormBottomSheet extends StatefulWidget {
  final int serviceId;
  final ServiceFaq? faq;
  const ServiceFaqFormBottomSheet({super.key, required this.serviceId, this.faq});

  @override
  State<ServiceFaqFormBottomSheet> createState() => _ServiceFaqFormBottomSheetState();
}

class _ServiceFaqFormBottomSheetState extends State<ServiceFaqFormBottomSheet> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
