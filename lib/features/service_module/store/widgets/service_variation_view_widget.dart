import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_store/features/service_module/store/controllers/service_controller.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class ServiceVariationViewWidget extends StatelessWidget {
  final ServiceController serviceController;
  const ServiceVariationViewWidget({super.key, required this.serviceController});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: serviceController.variationList.length,
        itemBuilder: (context, index) {
          final variation = serviceController.variationList[index];
          return Container(
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
            ),
            child: Column(children: [

              Row(children: [
                Expanded(
                  child: Text('${'variation'.tr} ${index + 1}', style: robotoMedium),
                ),
                InkWell(
                  onTap: () => serviceController.removeVariation(index),
                  child: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error, size: 22),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextFieldWidget(
                hintText: 'name'.tr,
                labelText: 'name'.tr,
                controller: variation.nameController,
                showLabelText: false,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: CustomTextFieldWidget(
                    hintText: 'price'.tr,
                    labelText: 'price'.tr,
                    controller: variation.priceController,
                    isAmount: true,
                    showLabelText: false,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: CustomTextFieldWidget(
                    hintText: 'discount'.tr,
                    labelText: 'discount'.tr,
                    controller: variation.discountController,
                    isAmount: true,
                    showLabelText: false,
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Container(
                width: double.infinity,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: DropdownButton<int>(
                  value: variation.discountTypeIndex,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down),
                  items: [
                    DropdownMenuItem(value: 0, child: Text('percent'.tr, style: robotoRegular)),
                    DropdownMenuItem(value: 1, child: Text('amount'.tr, style: robotoRegular)),
                  ],
                  onChanged: (value) => serviceController.setVariationDiscountType(index, value ?? 0),
                ),
              ),

            ]),
          );
        },
      ),

      CustomButtonWidget(
        buttonText: 'add_variation'.tr,
        icon: Icons.add,
        transparent: true,
        isBorder: true,
        borderColor: Theme.of(context).primaryColor,
        textColor: Theme.of(context).primaryColor,
        iconColor: Theme.of(context).primaryColor,
        onPressed: () => serviceController.addVariation(),
      ),

    ]);
  }
}
