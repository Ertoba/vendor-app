import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_model.dart';
import 'package:sixam_mart_store/features/order/helper/eta_helper.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class OrderWidget extends StatelessWidget {
  final OrderModel orderModel;
  final bool hasDivider;
  final bool isRunning;
  final bool showStatus;

  const OrderWidget({
    super.key,
    required this.orderModel,
    required this.hasDivider,
    required this.isRunning,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String formattedDate = DateConverterHelper.utcToDateTime(orderModel.createdAt!);
    final String formattedPrice = PriceConverterHelper.convertPrice(orderModel.orderAmount);
    final ({String? day, String window, bool overdue})? etaWindow = EtaHelper.windowLabel(orderModel);

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: theme.cardColor,
        border: Border.all(color: theme.hintColor.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          onTap: () => Get.toNamed(RouteHelper.getOrderDetailsRoute(orderModel.id)),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault), // Single padding layer
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TOP ROW: Order ID & Status Badge ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('order'.tr, style: robotoRegular.copyWith(color: theme.hintColor)),
                        Text(' # ${orderModel.id}', style: robotoBold),
                        Text(
                          ' (${orderModel.detailsCount} ${orderModel.detailsCount! < 2 ? 'item'.tr : 'items'.tr})',
                          style: robotoRegular.copyWith(color: theme.hintColor),
                        ),
                        if (orderModel.edited ?? false)
                          Text(
                            ' ${'edited'.tr}',
                            style: robotoMedium.copyWith(
                              color: Colors.blueAccent,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                      ],
                    ),
                    _StatusBadge(status: orderModel.orderStatus),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                // --- CREATED DATE ---
                Text(
                  formattedDate,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: theme.textTheme.bodyLarge!.color!.withValues(alpha: 0.5),
                  ),
                ),

                // --- ESTIMATED DELIVERY WINDOW (only where the platform promises one) ---
                if (etaWindow != null) ...[
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Row(children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: etaWindow.overdue ? Colors.orange : theme.primaryColor,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Flexible(
                      child: Text(
                        etaWindow.day != null ? '${etaWindow.day}, ${etaWindow.window}' : etaWindow.window,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: etaWindow.overdue ? Colors.orange : theme.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ]),
                ],

                const Divider(),

                // --- BOTTOM ROW: Order Type & Payment ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'order_type'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: theme.hintColor,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Text(
                            orderModel.orderType == 'delivery' ? 'home_delivery'.tr : orderModel.orderType!.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: orderModel.orderType == 'delivery'
                                  ? Colors.indigo
                                  : orderModel.orderType == 'take_away'
                                      ? Colors.orangeAccent
                                      : theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _getPaymentMethodText(orderModel.paymentMethod),
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Text(formattedPrice, style: robotoBold),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Pure helper method extracted outside the build tree logic
  String _getPaymentMethodText(String? paymentMethod) {
    if (paymentMethod == 'cash_on_delivery') return 'amount'.tr;
    if (paymentMethod == 'wallet') return 'wallet_payment'.tr;
    if (paymentMethod == 'cash') return 'cash'.tr;
    if (paymentMethod == 'digital_payment') return 'digital_payment'.tr;
    return paymentMethod?.replaceAll('_', ' ') ?? '';
  }
}

// Extracted const sub-widget to isolate status badge repaints
class _StatusBadge extends StatelessWidget {
  final String? status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (status == 'pending') {
      color = Colors.blueAccent;
    } else if (status == 'confirmed') {
      color = Colors.teal;
    } else if (status == 'delivered') {
      color = Colors.indigo;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      alignment: Alignment.center,
      child: Text(
        status == 'picked_up' ? '${'item'.tr} ${'on_the_way'.tr}' : (status?.tr ?? ''),
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: color,
        ),
      ),
    );
  }
}
