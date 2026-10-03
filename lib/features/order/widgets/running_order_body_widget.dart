import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/order_shimmer_widget.dart';
import '../../../common/widgets/order_widget.dart';
import '../../../common/widgets/sliver_delegate.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../../home/widgets/order_button_widget.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/order_controller.dart';

class RunningOrderBodyWidget extends StatelessWidget {
  const RunningOrderBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      child: CustomScrollView(
        slivers: [
          // 1. Static Top Section with Scoped Profile Listener
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: _CampaignFilterSection(),
            ),
          ),

          // 2. Horizontal Header Bar
          GetBuilder<OrderController>(
            id: 'running_header',
            builder: (orderController) {
              if (orderController.runningOrders == null) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(
                  height: 50,
                  rebuildKey: orderController.orderIndex,
                  child: Container(
                    height: 40,
                    color: theme.cardColor,
                    child: ListView.builder(
                      key: const PageStorageKey('running_order_tabs'),
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                      scrollDirection: Axis.horizontal,
                      itemCount: orderController.runningOrders!.length,
                      itemBuilder: (context, index) => OrderButtonWidget(
                        title: orderController.runningOrders![index].status.tr,
                        index: index,
                        orderController: orderController,
                        fromHistory: false,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 3. Main Order List Section
          GetBuilder<OrderController>(
            id: 'running_list',
            builder: (orderController) {
              if (orderController.runningOrders == null) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const OrderShimmerWidget(isEnabled: true),
                    childCount: 10,
                  ),
                );
              }

              final orderList = orderController.currentOrderList;

              if (orderList.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 100),
                    child: Center(child: Text('no_order_found'.tr)),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return OrderWidget(
                      key: ValueKey(orderList[index].id),
                      orderModel: orderList[index],
                      hasDivider: index != orderList.length - 1,
                      isRunning: true,
                    );
                  },
                  childCount: orderList.length
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Extracted Widget to isolate Profile updates
class _CampaignFilterSection extends StatelessWidget {
  const _CampaignFilterSection();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return GetBuilder<ProfileController>(
      builder: (profileController) {
        final hasPermission = profileController.modulePermission?.order ?? false;
        if (!hasPermission) return const SizedBox.shrink();

        return GetBuilder<OrderController>(
          id: 'campaign_checkbox',
          builder: (orderController) {
            return Padding(
              padding: const EdgeInsets.only(
                top: Dimensions.paddingSizeDefault,
                bottom: Dimensions.paddingSizeSmall,
              ),
              child: InkWell(
                onTap: () => orderController.toggleCampaignOnly(),
                child: Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        side: BorderSide(color: theme.disabledColor, width: 1),
                        activeColor: theme.primaryColor,
                        value: orderController.campaignOnly,
                        onChanged: (isActive) => orderController.toggleCampaignOnly(),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(
                      'campaign_orders_only'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: theme.disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
