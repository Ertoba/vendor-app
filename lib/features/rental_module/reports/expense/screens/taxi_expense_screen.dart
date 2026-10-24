import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/features/rental_module/reports/controllers/taxi_report_controller.dart';
import 'package:sixam_mart_store/features/rental_module/reports/expense/widgets/taxi_expense_card_widget.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';

class TaxiExpenseScreen extends StatefulWidget {
  const TaxiExpenseScreen({super.key});

  @override
  State<TaxiExpenseScreen> createState() => _TaxiExpenseScreenState();
}

class _TaxiExpenseScreenState extends State<TaxiExpenseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<TaxiReportController>().initSetDate();
    Get.find<TaxiReportController>().setOffset(1);

    Get.find<TaxiReportController>().getExpenseList(
      offset: Get.find<TaxiReportController>().offset.toString(),
      from: Get.find<TaxiReportController>().from, to: Get.find<TaxiReportController>().to,
      searchText: Get.find<TaxiReportController>().searchText,
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
          Get.find<TaxiReportController>().getExpenseList(
            offset: Get.find<TaxiReportController>().offset.toString(),
            from: Get.find<TaxiReportController>().from, to: Get.find<TaxiReportController>().to,
            searchText: Get.find<TaxiReportController>().searchText,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'expense_report'.tr),
      body: GetBuilder<TaxiReportController>(builder: (expenseController) {
        return Column(children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.radiusDefault, vertical: Dimensions.radiusDefault),
            child: Row(children: [

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
                  child: GetBuilder<TaxiReportController>(builder: (expenseController) {
                    return TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'search_with_trip_id'.tr,
                        suffixIcon: IconButton(
                          icon: Icon(expenseController.searchMode ? Icons.clear : Icons.search),
                          onPressed: (){
                            if(!expenseController.searchMode){
                              if(_searchController.text.isNotEmpty){
                                expenseController.setSearchText(offset: '1', from: Get.find<TaxiReportController>().from, to: Get.find<TaxiReportController>().to, searchText: _searchController.text);
                              }else{
                                showCustomSnackBar('your_search_box_is_empty'.tr);
                              }
                            }else if(expenseController.searchMode){
                              _searchController.text = '';
                              expenseController.setSearchText(offset: '1', from: Get.find<TaxiReportController>().from, to: Get.find<TaxiReportController>().to, searchText: _searchController.text);
                            }
                          },
                        ),
                      ),
                      onSubmitted: (value){
                        if(value.isNotEmpty){
                          expenseController.setSearchText(offset: '1', from: Get.find<TaxiReportController>().from, to: Get.find<TaxiReportController>().to, searchText: value);
                        }else{
                          showCustomSnackBar('your_search_box_is_empty'.tr);
                        }
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              InkWell(
                onTap: () => expenseController.showDatePicker(context, isTaxReport: false),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall)
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall + 1),
                  child: Icon(Icons.calendar_today_outlined, color: Theme.of(context).cardColor),
                ),
              ),

            ]),
          ),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('from'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
            const SizedBox(width: Dimensions.fontSizeExtraSmall),

            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              ),
              child: Text(DateConverterHelper.convertDateToDate(expenseController.from!), style: robotoMedium),
            ),
            const SizedBox(width: 5),

            Text('to'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
            const SizedBox(width: 5),

            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              ),
              child: Text(DateConverterHelper.convertDateToDate(expenseController.to!), style: robotoMedium),
            ),

          ]),

          Expanded(
            child: expenseController.expenses != null ? expenseController.expenses!.isNotEmpty ? ListView.builder(
              controller: scrollController,
              itemCount: expenseController.expenses!.length,
                shrinkWrap: true,
                itemBuilder: (context, index){
              return TaxiExpenseCardWidget(expense: expenseController.expenses![index]);
            }) : Center(child: Text('no_expense_found'.tr, style: robotoMedium)) : const Center(child: CircularProgressIndicator()),
          ),

          expenseController.isLoading ? Center(child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
          )) : const SizedBox(),

        ]);
      }),
    );
  }
}
