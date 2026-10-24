import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_card.dart';
import 'package:sixam_mart_store/features/rental_module/reports/controllers/taxi_report_controller.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

class TaxiTaxReportScreen extends StatefulWidget {
  const TaxiTaxReportScreen({super.key});

  @override
  State<TaxiTaxReportScreen> createState() => _TaxiTaxReportScreenState();
}

class _TaxiTaxReportScreenState extends State<TaxiTaxReportScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<TaxiReportController>().initTaxReportDate();
    Get.find<TaxiReportController>().setOffset(1);

    Get.find<TaxiReportController>().getTaxReport(
      offset: Get.find<TaxiReportController>().offset.toString(),
      from: Get.find<TaxiReportController>().from, to: Get.find<TaxiReportController>().to,
    );

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<TaxiReportController>().expenses != null
          && !Get.find<TaxiReportController>().isLoading) {
        int pageSize = (Get.find<TaxiReportController>().pageSize! / 10).ceil();
        if (Get.find<TaxiReportController>().offset < pageSize) {
          Get.find<TaxiReportController>().setOffset(Get.find<TaxiReportController>().offset+1);
          debugPrint('end of the page');
          Get.find<TaxiReportController>().showBottomLoader();
          Get.find<TaxiReportController>().getTaxReport(
            offset: Get.find<TaxiReportController>().offset.toString(),
            from: Get.find<TaxiReportController>().from, to: Get.find<TaxiReportController>().to,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'tax_report'.tr,
        menuWidget: InkWell(
          onTap: () => Get.find<TaxiReportController>().showDatePicker(context, isTaxReport: true),
          child: Container(
            margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeExtraSmall, bottom: Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(color: Theme.of(context).primaryColor),
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            child: Icon(Icons.filter_list, color: Theme.of(context).primaryColor),
          ),
        ),
      ),

      body: GetBuilder<TaxiReportController>(builder: (taxiReportController) {
        return taxiReportController.taxReportModel != null && taxiReportController.orders != null  ? SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(children: [

            CustomCard(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(children: [

                Row(children: [

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: const Color(0xffD89D4B).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        const CustomAssetImageWidget(Images.taxOrderIcon, height: 30, width: 30),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text(taxiReportController.taxReportModel!.totalOrders.toString(), style: robotoBlack.copyWith(color: const Color(0xffD89D4B), fontSize: Dimensions.fontSizeLarge)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Text('total_orders'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

                      ]),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: const Color(0xff0661CB).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        const CustomAssetImageWidget(Images.taxAmountIcon, height: 30, width: 30),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Text(PriceConverterHelper.convertPrice(taxiReportController.taxReportModel?.totalOrderAmount), style: robotoBlack.copyWith(color: const Color(0xff0661CB), fontSize: Dimensions.fontSizeLarge)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Text('total_order_amount'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

                      ]),
                    ),
                  ),

                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode ? Theme.of(context).cardColor : const Color(0xffFAF8F5),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Row(children: [
                      const CustomAssetImageWidget(Images.taxReportIcon, height: 50, width: 50),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text(PriceConverterHelper.convertPrice(taxiReportController.taxReportModel?.totalTax), style: robotoBlack.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Text('total_tax_amount'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

                      ]),

                    ]),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    SizedBox(
                      height: 45,
                      child: ListView.builder(
                        itemCount: taxiReportController.taxReportModel?.taxSummary?.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            margin: EdgeInsets.only(right: index == (taxiReportController.taxReportModel?.taxSummary?.length ?? 0) - 1 ? 0 : Dimensions.paddingSizeSmall),
                            width: 240,
                            decoration: BoxDecoration(
                              color: Get.isDarkMode ? Theme.of(context).disabledColor.withValues(alpha: 0.3) : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                              Text(
                                '${taxiReportController.taxReportModel!.taxSummary?[index].taxName} '
                                    '(${(double.parse(taxiReportController.taxReportModel?.taxSummary?[index].taxLabel ?? '0')).toStringAsFixed(1)}%)',
                                style: robotoRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                              Text(PriceConverterHelper.convertPrice(taxiReportController.taxReportModel!.taxSummary?[index].totalTax), style: robotoMedium.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),

                            ]),
                          );
                        },
                      ),
                    ),

                  ]),
                )

              ]),
            ),

            taxiReportController.orders!.isNotEmpty ? ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
              itemCount: taxiReportController.orders?.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return CustomCard(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall + 2),
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text('${'trip_id'.tr} #${taxiReportController.orders?[index].id}', style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6))),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall - 2),

                        Text(PriceConverterHelper.convertPrice(taxiReportController.orders?[index].tripAmount), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall - 2),

                        Text('${'tax'.tr}: ${PriceConverterHelper.convertPrice(taxiReportController.orders?[index].taxAmount)}', style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),

                      ]),
                    ),

                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [

                        Text(DateConverterHelper.utcToDateTime(taxiReportController.orders![index].createdAt!), style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        taxiReportController.orders![index].orderTaxes!.isNotEmpty ? Wrap(
                          alignment: WrapAlignment.end,
                          children: List.generate(
                            taxiReportController.orders![index].orderTaxes?.length ?? 0,
                          (i) => Padding(
                            padding: EdgeInsets.only(right: i == (taxiReportController.orders![index].orderTaxes?.length ?? 0) - 1 ? 0 : Dimensions.paddingSizeSmall),
                            child: Text(
                              '${taxiReportController.orders![index].orderTaxes?[i].taxName} ${i == (taxiReportController.orders![index].orderTaxes?.length ?? 0) - 1 ? '' : ','}',
                              style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6), fontSize: Dimensions.fontSizeSmall),
                            ),
                          ),
                        ),
                        ) : Text('no_tax'.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6), fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.end),
                      ]),

                    ),

                  ]),
                );
              },
            ) : Padding(
              padding: EdgeInsets.only(top: context.height * 0.2),
              child: Center(
                child: Text(
                  'no_tax_report_found'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6)),
                ),
              ),
            ),

          ]),
        ) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
