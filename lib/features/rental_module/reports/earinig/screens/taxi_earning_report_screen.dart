import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart_store/features/rental_module/reports/controllers/taxi_report_controller.dart';
import 'package:sixam_mart_store/features/rental_module/reports/domain/enum/filter_type.dart';
import 'package:sixam_mart_store/features/rental_module/reports/domain/models/rental_earning_report_model.dart';
import 'package:sixam_mart_store/features/rental_module/reports/earinig/widgets/earning_card_widget.dart';
import 'package:sixam_mart_store/features/rental_module/reports/earinig/widgets/earning_sources_bottom_sheet.dart';
import 'package:sixam_mart_store/features/rental_module/reports/earinig/widgets/earning_trend_chart.dart';
import 'package:sixam_mart_store/features/rental_module/reports/earinig/widgets/transaction_menu_button_widget.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';


class TaxiEarningReportScreen extends StatefulWidget {
  const TaxiEarningReportScreen({super.key});

  @override
  State<TaxiEarningReportScreen> createState() => _TaxiEarningReportScreen();
}

class _TaxiEarningReportScreen extends State<TaxiEarningReportScreen> {
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<int> selectedTransactionNotifier  = ValueNotifier<int>(0);
  final List<GlobalKey> _transactionCategoryKeys = List<GlobalKey>.generate(3, (_) => GlobalKey());
  final Color earningColor = Color(0xFF04BB7B);
  final Color expenseColor = Color(0xFFE6A832);
  final Color profitColor = Color(0xFF245BD1);

  String _getTransactionType(int index) {
    switch (index) {
      case 1:
        return 'expense';
      case 2:
        return 'subscription';
      default:
        return 'earning';
    }
  }

  List<ChartData> _buildTrendData(TaxiReportController taxiReportController) {
    final categories = taxiReportController.getRentalEarningReport?.trend?.categories ?? [];
    final earningSeries = taxiReportController.getRentalEarningReport?.trend?.earningSeries ?? [];
    final int itemCount = categories.length < earningSeries.length ? categories.length : earningSeries.length;

    if (itemCount == 0) {
      return [];
    }

    final List<ChartData> chartData = [];

    if (itemCount == 1) {
      chartData.add(const ChartData(0, '0', 0));
    }

    for (int index = 0; index < itemCount; index++) {
      chartData.add(ChartData(
        chartData.length,
        categories[index],
        earningSeries[index],
      ));
    }

    return chartData;
  }

  void _ensureTransactionCategoryVisible(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? itemContext = _transactionCategoryKeys[index].currentContext;
      if (itemContext != null) {
        Scrollable.ensureVisible(
          itemContext,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    Get.find<TaxiReportController>().setOffset(1);
    Get.find<TaxiReportController>().setType('earning');
    Get.find<TaxiReportController>().initSetDate();
    Get.find<TaxiReportController>().setFilter(FilterType.all.name, isEarningReport : true);

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && !isLoadingTransaction(Get.find<TaxiReportController>().type) && !Get.find<TaxiReportController>().isLoading) {
        int pageSize = (Get.find<TaxiReportController>().pageSize! / 10).ceil();
        if (Get.find<TaxiReportController>().offset < pageSize) {
          Get.find<TaxiReportController>().setOffset(Get.find<TaxiReportController>().offset+1);
          debugPrint('end of the page');
          Get.find<TaxiReportController>().showBottomLoader();
          Get.find<TaxiReportController>().getEarningReport(offset: Get.find<TaxiReportController>().offset.toString(), from: Get.find<TaxiReportController>().from, to: Get.find<TaxiReportController>().to, type: Get.find<TaxiReportController>().type);
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    selectedTransactionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaxiReportController>(builder: (taxiReportController) {

      return Scaffold(
        appBar: CustomAppBarWidget(
          title: 'earning_reports'.tr,
          menuWidget: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            child: PopupMenuButton(
              position: PopupMenuPosition.under,
              itemBuilder: (context) { return <PopupMenuEntry>[
                PopupMenuItem(
                  value: FilterType.all, child: SizedBox(width: 100, child: Text('all_time'.tr, style: robotoRegular)),
                ),
                PopupMenuItem(
                  value: FilterType.thisYear, child: Text('this_year'.tr, style: robotoRegular),
                ),
                PopupMenuItem(
                  value: FilterType.previousYear, child: Text('previous_year'.tr, style: robotoRegular),
                ),
                PopupMenuItem(
                  value: FilterType.thisMonth, child: Text('this_month'.tr, style: robotoRegular),
                ),
                PopupMenuItem(
                  value: FilterType.thisWeek, child: Text('this_week'.tr, style: robotoRegular),
                ),
                PopupMenuItem(
                  value: FilterType.custom, child: Text('custom'.tr, style: robotoRegular),
                ),
              ];},
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
              child: GetBuilder<TaxiReportController>(
                builder: (taxiReportController) {
                  final bool isFiltered = taxiReportController.filterType != FilterType.all.name;

                  return Stack(clipBehavior: Clip.none, children: [
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        color: isFiltered ? Theme.of(context).primaryColor.withValues(alpha: 0.15) : Theme.of(context).primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
                        border: Border.all(color: Theme.of(context).primaryColor, width: isFiltered ? 1.5 : 1),
                      ),
                      child: Icon(Icons.tune_rounded, color: Theme.of(context).colorScheme.secondary, size: 20),
                    ),

                    if (isFiltered) Positioned(top: 4, right: 4,
                      child: Container(width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
                        ),
                      ),
                    ),
                  ]);
                },
              ),
              onSelected: (dynamic value) {
                if (value == FilterType.all) {
                  taxiReportController.setFilter(FilterType.all.name, isEarningReport : true);
                }else if (value == FilterType.thisYear) {
                  taxiReportController.setFilter(FilterType.thisYear.name, isEarningReport : true);
                }else if (value == FilterType.previousYear) {
                  taxiReportController.setFilter(FilterType.previousYear.name, isEarningReport : true);
                }else if (value == FilterType.thisMonth) {
                  taxiReportController.setFilter(FilterType.thisMonth.name, isEarningReport : true);
                }else if (value == FilterType.thisWeek) {
                  taxiReportController.setFilter(FilterType.thisWeek.name, isEarningReport : true);
                } else{
                  taxiReportController.showNewDatePicker(context, isEarningReport: true);
                }
              },
            ),
          ),
        ),

        body: taxiReportController.getRentalEarningReport != null ? SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(children: [

            // summary
            Column(children: [

              /// total earning
              EarningCardWidget(
                cardColor: earningColor.withAlpha(30),
                icon: Images.dollerIcon,
                iconColor: earningColor,
                title: 'total_earnings_with_admin_commission'.tr,
                amount:taxiReportController.getRentalEarningReport?.summary?.totalEarning?.toDouble() ?? 0.0,
                data: taxiReportController.getEarningData(),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault,),

              /// Total Expenses
              EarningCardWidget(
                  cardColor: expenseColor.withAlpha(30),
                  icon: Images.dollerIcon,
                  iconColor: expenseColor,
                  title: 'total_expenses'.tr,
                  amount:taxiReportController.getRentalEarningReport?.summary?.totalExpense?.toDouble() ?? 0.0,
                  data: taxiReportController.getExpenseData()
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault,),


              /// Net Profit
              EarningCardWidget(
                cardColor: profitColor.withAlpha(30),
                icon: Images.walletIconSign,
                iconColor: profitColor,
                title: 'net_profit'.tr,
                amount:taxiReportController.getRentalEarningReport?.summary?.netIncome?.toDouble() ?? 0.0,
                profitText : "${'net_profit'.tr} = ${'total_earnings'.tr} - ${'total_expenses'.tr}",
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault,),

            ]),

            // Earnings Trend
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text("earnings_trend".tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),),
                const SizedBox(height: Dimensions.paddingSizeDefault,),

                (taxiReportController.getRentalEarningReport?.trend?.categories?.length ?? 0) < 1 ?

                SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: context.height * 0.1),
                      child: Text(
                        'no_data_available'.tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6),),
                      ),
                    ),
                  ),
                ) :  showTrendFit(_buildTrendData(taxiReportController).length)? TrendChart(data: _buildTrendData(taxiReportController)) : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [SizedBox(width: 600, child: TrendChart(data: _buildTrendData(taxiReportController)))],)
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault,),

              ],
            ),

            // Recent RecentTransactions
            ValueListenableBuilder(
              valueListenable: selectedTransactionNotifier,
              builder: (context, value, child) {
                final String selectedType = _getTransactionType(value);
                final bool isEarning = selectedType == 'earning';
                final bool isExpense = selectedType == 'expense';
                final int transactionCount = getTransactions(taxiReportController.type)?.length ?? 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("recent_transactions".tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),),
                    const SizedBox(height: Dimensions.paddingSizeDefault,),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: Dimensions.paddingSizeDefault,
                        children: [
                          KeyedSubtree(
                            key: _transactionCategoryKeys[0],
                            child: TransactionsMenuButton(
                              label: 'earnings'.tr, count: taxiReportController.getRentalEarningReport?.summary?.counts?.earning ?? 0, isSelected: value == 0, onTap: () {
                              taxiReportController.setType('earning');
                              selectedTransactionNotifier.value = 0;
                              _ensureTransactionCategoryVisible(0);
                              taxiReportController.setRentalEarningReportTransactions();
                              taxiReportController.getEarningReport(offset: '1', from: taxiReportController.from, to: taxiReportController.to, type: taxiReportController.type, onlyTransaction: true);
                            },
                            ),
                          ),
                          KeyedSubtree(
                            key: _transactionCategoryKeys[1],
                            child: TransactionsMenuButton(
                              label: 'expenses'.tr, count: taxiReportController.getRentalEarningReport?.summary?.counts?.expense ?? 0, isSelected: value == 1, onTap: () {
                              taxiReportController.setType('expense');
                              selectedTransactionNotifier.value = 1;
                              _ensureTransactionCategoryVisible(1);
                              taxiReportController.setRentalEarningReportTransactions();
                              taxiReportController.getEarningReport(offset: '1', from: taxiReportController.from, to: taxiReportController.to, type: taxiReportController.type, onlyTransaction: true);
                            },
                            ),
                          ),
                          KeyedSubtree(
                            key: _transactionCategoryKeys[2],
                            child: TransactionsMenuButton(
                              label: 'subscription'.tr, count: taxiReportController.getRentalEarningReport?.summary?.counts?.subscription ?? 0, isSelected: value == 2, onTap: () {
                              taxiReportController.setType('subscription');
                              selectedTransactionNotifier.value = 2;
                              _ensureTransactionCategoryVisible(2);
                              taxiReportController.setRentalEarningReportTransactions();
                              taxiReportController.getEarningReport(offset: '1', from: taxiReportController.from, to: taxiReportController.to, type: taxiReportController.type, onlyTransaction: true);
                            },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault,),


                    (getTransactions(taxiReportController.type)?.isEmpty ?? false) ? Padding(
                      padding: EdgeInsets.symmetric(vertical: context.height * 0.1),
                      child: Center(
                        child: Text(
                          isEarning ? 'no_earning_found'.tr : isExpense ? 'no_expense_found'.tr : 'no_subscription_found'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.6)),
                        ),
                      ),
                    ) : !isLoadingTransaction(taxiReportController.type) ?  ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                      itemCount: transactionCount,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        TransactionData data = getTransactions(taxiReportController.type)![index];
                        return InkWell(
                          onTap: isEarning ? () {
                            showCustomBottomSheet(child: EarningSourcesBottomSheet(index: index,));
                          } : null,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              boxShadow:[
                                BoxShadow(
                                  color: Theme.of(context).hintColor.withAlpha(50),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Column(children: [

                              Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                  Expanded(
                                    child: RichText(
                                      textAlign: TextAlign.start,
                                      text: TextSpan(
                                        style: robotoBlack.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color),
                                        children: [
                                          TextSpan(
                                            text: 'TXN',
                                            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(170)),
                                          ),
                                          TextSpan(
                                            text: ' #${data.transactionId!.split(' ').last}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // taxiReportController.orderList![index].createdAt!
                                  Text(DateConverterHelper.utcToDateTime(data.date ?? ''), style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(170), fontSize: Dimensions.fontSizeExtraSmall), textAlign: TextAlign.end),

                                ]),
                              ),
                              Divider(height: 1, thickness: 1, color: Theme.of(context).hintColor.withAlpha(100),),

                              Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

                                  Expanded(
                                    child: Text(
                                      isEarning ? 'earning_source'.tr : isExpense ? 'expense_source'.tr : 'subscription'.tr,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(170)),
                                    ),
                                  ),

                                  Column(
                                    children: [
                                      ...[
                                        Container(
                                            padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                            decoration: BoxDecoration(
                                                color: isEarning ? earningColor.withAlpha(30) : Theme.of(context).colorScheme.error.withAlpha(30),
                                                borderRadius:  BorderRadius.circular(Dimensions.radiusSmall)
                                            ),
                                            child: Text(
                                              data.earningFromBadge ?? data.expenseSourceBadge ?? data.transactionType ??  "",
                                              style: robotoRegular.copyWith(color: isEarning ? earningColor : Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeExtraSmall),)
                                        ),
                                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                      ],

                                      if(isEarning || isExpense) ...[
                                        RichText(
                                          textAlign: TextAlign.start,
                                          text: TextSpan(
                                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color),
                                            children: [
                                              TextSpan(
                                                text: data.earningFrom ?? data.expenseSource ?? '',
                                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(170)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                ]),
                              ),

                              Container(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).hintColor.withAlpha(10)
                                ),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                  Expanded(
                                    child: Text(
                                      'transaction_amount'.tr,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(170)),
                                    ),
                                  ),

                                  Text(PriceConverterHelper.convertPrice(data.amount,), style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault), textAlign: TextAlign.end),

                                ]),
                              ),

                            ]),
                          ),
                        );
                      },
                    )  : SizedBox(height:200, child: const Center(child: CircularProgressIndicator())),

                    const SizedBox(height: Dimensions.paddingSizeDefault,),

                  ],
                );
              },
            ),

          ]),
        ) : const Center(child: CircularProgressIndicator()),
      );
    });
  }

  bool isLoadingTransaction(String type){
    if(type == 'earning') {
      return Get.find<TaxiReportController>().getRentalEarningReport?.recentTransactions?.earning == null;
    }
    else if(type == 'expense') {
      return Get.find<TaxiReportController>().getRentalEarningReport?.recentTransactions?.expense == null;
    }
    else if(type == 'subscription') {
      return Get.find<TaxiReportController>().getRentalEarningReport?.recentTransactions?.subscription == null;
    }
    return false;
  }

}
  List<TransactionData>? getTransactions(String type){
    if(type == 'earning') {
      return Get.find<TaxiReportController>().getRentalEarningReport?.recentTransactions?.earning?.data;
    }
    else if(type == 'expense') {
      return Get.find<TaxiReportController>().getRentalEarningReport?.recentTransactions?.expense?.data;
    }
    else if(type == 'subscription') {
      return Get.find<TaxiReportController>().getRentalEarningReport?.recentTransactions?.subscription?.data;
    }
    return null;
  }
