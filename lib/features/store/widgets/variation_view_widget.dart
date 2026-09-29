import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
import 'package:sixam_mart_store/features/store/domain/utils/variation_key_helper.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VariationView extends StatelessWidget {
  final Item item;
  final bool? stock;
  const VariationView({super.key, required this.item, required this.stock});

  @override
  Widget build(BuildContext context) {
    final List<int> visibleIndexes = compatibleTechnicalVariationIndexes(item);
    return Column(
      children: [
        visibleIndexes.isNotEmpty
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).disabledColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('variations'.tr, style: robotoMedium),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    ListView.builder(
                      itemCount: visibleIndexes.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final Variation variation =
                            item.variations![visibleIndexes[index]];
                        return Row(
                          children: [
                            Text(
                              '${variation.type!}:',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall,
                            ),
                            Text(
                              PriceConverterHelper.convertPrice(
                                variation.price,
                              ),
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                            SizedBox(
                              width: stock!
                                  ? Dimensions.paddingSizeExtraSmall
                                  : 0,
                            ),
                            stock!
                                ? Text(
                                    '(${variation.stock})',
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              )
            : const SizedBox(),

        SizedBox(
          height: visibleIndexes.isNotEmpty ? Dimensions.paddingSizeLarge : 0,
        ),
      ],
    );
  }
}
