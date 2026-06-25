import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/features/disbursement/domain/models/disbursement_report_model.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class KeepzSettlementListWidget extends StatelessWidget {
  final List<KeepzSettlement>? settlements;
  final bool showTitle;
  final EdgeInsetsGeometry padding;

  const KeepzSettlementListWidget({
    super.key,
    required this.settlements,
    this.showTitle = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Dimensions.paddingSizeDefault,
      vertical: Dimensions.paddingSizeLarge,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final List<KeepzSettlement> items = settlements ?? <KeepzSettlement>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Text(
              'keepz_split_history'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeExtraLarge,
            ),
            child: Center(
              child: Text('no_history_available'.tr, style: robotoMedium),
            ),
          )
        else
          ListView.builder(
            padding: padding,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final KeepzSettlement settlement = items[index];
              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      PriceConverterHelper.convertPrice(settlement.amount),
                      style: robotoMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'order_id'.tr}: #${settlement.orderId}',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                        if (settlement.receiverIdentifierMasked?.isNotEmpty ??
                            false)
                          Text(
                            '${settlement.receiverType ?? ''}: ${settlement.receiverIdentifierMasked}',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                      ],
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (settlement.paidAt != null)
                          Text(
                            DateConverterHelper.dateTimeStringForDisbursement(
                              settlement.paidAt!,
                            ),
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraSmall,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeExtraSmall,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusSmall,
                            ),
                            color: Colors.green.withValues(alpha: 0.1),
                          ),
                          child: Text(
                            'completed'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 2, thickness: 1),
                ],
              );
            },
          ),
      ],
    );
  }
}
