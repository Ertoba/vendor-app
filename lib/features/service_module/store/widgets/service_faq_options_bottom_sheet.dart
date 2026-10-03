import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/confirmation_dialog_widget.dart';
import 'package:sixam_mart_store/features/service_module/store/controllers/service_faq_controller.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_faq_model.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

class ServiceFaqOptionsBottomSheet extends StatelessWidget {
  final int serviceId;
  final ServiceFaq faq;
  final VoidCallback onEdit;
  const ServiceFaqOptionsBottomSheet({super.key, required this.serviceId, required this.faq, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
