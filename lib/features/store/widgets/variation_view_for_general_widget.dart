import 'package:flutter/material.dart';
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
import 'package:sixam_mart_store/features/store/domain/utils/variation_key_helper.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class VariationViewForGeneral extends StatelessWidget {
  final Item item;
  final bool? stock;
  const VariationViewForGeneral({
    super.key,
    required this.item,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final List<int> visibleIndexes = compatibleTechnicalVariationIndexes(item);
    return visibleIndexes.isNotEmpty
        ? ListView.builder(
            itemCount: visibleIndexes.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final Variation variation =
                  item.variations![visibleIndexes[index]];
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeExtraSmall,
                ),
                color: Theme.of(context).cardColor,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            variation.type!,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 7,
                          child: Row(
                            children: [
                              Text(
                                ':',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                              const SizedBox(
                                width: Dimensions.paddingSizeSmall,
                              ),

                              Text(
                                PriceConverterHelper.convertPrice(
                                  variation.price,
                                ),
                                style: robotoRegular.copyWith(
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
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          )
        : const SizedBox();
  }
}
