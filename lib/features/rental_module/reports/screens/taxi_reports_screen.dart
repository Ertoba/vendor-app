import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/features/rental_module/reports/earinig/screens/taxi_earning_report_screen.dart';
import 'package:sixam_mart_store/features/rental_module/reports/expense/screens/taxi_expense_screen.dart';
import 'package:sixam_mart_store/features/rental_module/reports/tax/screens/taxi_tax_report_screen.dart';
import 'package:sixam_mart_store/features/rental_module/reports/widgets/taxi_report_card_widget.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';

class TaxiReportsScreen extends StatelessWidget {
  const TaxiReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'reports'.tr),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(children: [

          TaxiReportCardWidget(
            title: 'earning_report'.tr,
            subtitle: 'view_and_track_your_business_earning_in_detail'.tr,
            image: Images.expense,
            onTap: () => Get.to(() => const TaxiEarningReportScreen()),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          TaxiReportCardWidget(
            title: 'expense_report'.tr,
            subtitle: 'view_and_track_your_business_expenses_in_detail'.tr,
            image: Images.expense,
            onTap: () => Get.to(() => const TaxiExpenseScreen()),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          TaxiReportCardWidget(
            title: 'tax_report'.tr,
            subtitle: 'view_detailed_tax_calculations_and_payment_records'.tr,
            image: Images.taxReportIcon,
            onTap: () => Get.to(() => const TaxiTaxReportScreen()),
          ),

        ]),
      ),
    );
  }
}
