import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/enum/filter_type.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_earning_report_model.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_expense_model.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/models/service_tax_report_model.dart';
import 'package:sixam_mart_store/features/service_module/service_report/domain/services/service_report_service_interface.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';

class ServiceReportController extends GetxController implements GetxService {
  final ServiceReportServiceInterface serviceReportServiceInterface;
  ServiceReportController({required this.serviceReportServiceInterface});

  String _type = 'earning';
  String get type => _type;


}
