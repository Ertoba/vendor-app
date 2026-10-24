import 'package:flutter/material.dart';
import 'package:sixam_mart_store/common/widgets/custom_shimmer_widget.dart';
import 'package:sixam_mart_store/util/dimensions.dart';

class ServiceFaqShimmerWidget extends StatelessWidget {
  final int itemCount;
  const ServiceFaqShimmerWidget({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final BoxShadow boxShadow = BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), blurRadius: 10);

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingSizeSmall),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            boxShadow: [boxShadow],
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(children: const [

            /// Status dot
            CustomShimmerWidget(height: 8, width: 8),
            SizedBox(width: Dimensions.paddingSizeSmall),

            /// Question line
            Expanded(child: CustomShimmerWidget(height: 14, width: double.infinity)),
            SizedBox(width: Dimensions.paddingSizeSmall),

            /// Chevron + options
            CustomShimmerWidget(height: 18, width: 18),

          ]),
        );
      },
    );
  }
}
