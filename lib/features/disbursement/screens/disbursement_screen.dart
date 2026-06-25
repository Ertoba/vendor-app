import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/disbursement/controllers/disbursement_controller.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/features/disbursement/widgets/disbursement_status_card_widget.dart';
import 'package:sixam_mart_store/features/disbursement/widgets/keepz_settlement_list_widget.dart';

class DisbursementScreen extends StatefulWidget {
  const DisbursementScreen({super.key});

  @override
  State<DisbursementScreen> createState() => _DisbursementScreenState();
}

class _DisbursementScreenState extends State<DisbursementScreen> {
  final JustTheController keepzToolTip = JustTheController();

  @override
  void initState() {
    super.initState();

    Get.find<DisbursementController>().getDisbursementReport(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'disbursement'.tr,
        isBackButtonExist: true,
        menuWidget: Container(
          height: 35, width: 35,
          margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
            ),
          child: GetBuilder<ProfileController>(builder: (profileController) {
            return Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 2, color: Theme.of(context).cardColor)),
              margin: const EdgeInsets.all(1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: CustomImageWidget(
                  image: (profileController.profileModel != null && Get.find<AuthController>().isLoggedIn()) ? profileController.profileModel!.imageFullUrl ?? '' : '',
                  width: 35, height: 35, fit: BoxFit.cover,
                ),
              ),
            );
          }),
        ),
      ),

      body: GetBuilder<DisbursementController>(builder: (disbursementController) {
        return disbursementController.disbursementReportModel != null ? SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            SizedBox(
              height: 160,
              child: Align(
                alignment: Alignment.centerLeft,
                child: DisbursementStatusCardWidget(
                  amount: disbursementController.disbursementReportModel!.keepzCompleted ?? 0,
                  text: 'keepz_split_completed'.tr,
                  isCompleted: true,
                  completeToolTip: keepzToolTip,
                ),
              ),
            ),

            KeepzSettlementListWidget(
              settlements: disbursementController.disbursementReportModel!.keepzSettlements,
            ),

          ]),
          ) : const Center(child: CircularProgressIndicator());
        }
      ),

    );
  }
}
