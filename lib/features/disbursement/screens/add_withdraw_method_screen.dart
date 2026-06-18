import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/features/disbursement/controllers/disbursement_controller.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_dropdown_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/common/widgets/text_field_widget.dart';

class AddWithDrawMethodScreen extends StatefulWidget {
  const AddWithDrawMethodScreen({super.key});

  @override
  State<AddWithDrawMethodScreen> createState() =>
      _AddWithDrawMethodScreenState();
}

class _AddWithDrawMethodScreenState extends State<AddWithDrawMethodScreen> {
  @override
  void initState() {
    super.initState();

    Get.find<DisbursementController>().setMethod(initCall: true);
  }

  String _fieldTitle(DisbursementController controller, int index) {
    final String inputName = controller.methodFields[index].inputName ?? '';

    if (controller.isKeepzSplitSelected &&
        inputName == DisbursementController.keepzReceiverIdentifierField) {
      return controller.selectedKeepzReceiverType == 'IBAN'
          ? 'keepz_iban'.tr
          : 'keepz_branch_receiver_id'.tr;
    }

    return inputName.replaceAll('_', ' ');
  }

  String _fieldHint(DisbursementController controller, int index) {
    final String inputName = controller.methodFields[index].inputName ?? '';

    if (controller.isKeepzSplitSelected &&
        inputName == DisbursementController.keepzReceiverIdentifierField) {
      return controller.selectedKeepzReceiverType == 'IBAN'
          ? 'GE00BG0000000000000000'
          : '0cac1858-9444-43b2-9a64-a65b472de416';
    }

    return controller.methodFields[index].placeholder ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DisbursementController>(
      builder: (disbursementController) {
        return Scaffold(
          appBar: CustomAppBarWidget(title: 'add_withdraw_method'.tr),

          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("payment_method".tr, style: robotoBold),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 0.3,
                            ),
                          ),
                          child: CustomDropdown<int>(
                            onChange: (int? value, int index) {
                              disbursementController.setMethodId(index);
                              disbursementController.setMethod();
                            },
                            dropdownButtonStyle: DropdownButtonStyle(
                              height: 45,
                              padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeExtraSmall,
                                horizontal: Dimensions.paddingSizeExtraSmall,
                              ),
                              primaryColor: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color,
                            ),
                            dropdownStyle: DropdownStyle(
                              elevation: 10,
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusDefault,
                              ),
                              padding: const EdgeInsets.all(
                                Dimensions.paddingSizeExtraSmall,
                              ),
                            ),
                            items: disbursementController.methodList,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                disbursementController.widthDrawMethods !=
                                            null &&
                                        disbursementController
                                            .widthDrawMethods!
                                            .isNotEmpty
                                    ? disbursementController
                                          .widthDrawMethods![0]
                                          .methodName!
                                    : 'select_payment_method'.tr,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraLarge,
                        ),

                        ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: disbursementController.methodFields.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final String inputName =
                                disbursementController
                                    .methodFields[index]
                                    .inputName ??
                                '';

                            if (disbursementController.isKeepzSplitSelected &&
                                inputName ==
                                    DisbursementController
                                        .keepzReceiverTypeField) {
                              return Column(
                                children: [
                                  _KeepzReceiverTypeSelector(
                                    disbursementController:
                                        disbursementController,
                                  ),
                                  SizedBox(
                                    height:
                                        index !=
                                            disbursementController
                                                    .methodFields
                                                    .length -
                                                1
                                        ? Dimensions.paddingSizeLarge
                                        : 0,
                                  ),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFieldWidget(
                                        titleText: _fieldTitle(
                                          disbursementController,
                                          index,
                                        ),
                                        hintText: _fieldHint(
                                          disbursementController,
                                          index,
                                        ),
                                        controller: disbursementController
                                            .textControllerList[index],
                                        capitalization:
                                            disbursementController
                                                .isKeepzSplitSelected
                                            ? TextCapitalization.characters
                                            : TextCapitalization.words,
                                        inputType:
                                            disbursementController
                                                    .methodFields[index]
                                                    .inputType ==
                                                'phone'
                                            ? TextInputType.phone
                                            : disbursementController
                                                      .methodFields[index]
                                                      .inputType ==
                                                  'number'
                                            ? TextInputType.number
                                            : disbursementController
                                                      .methodFields[index]
                                                      .inputType ==
                                                  'email'
                                            ? TextInputType.emailAddress
                                            : TextInputType.name,
                                        focusNode: disbursementController
                                            .focusList[index],
                                        nextFocus:
                                            index !=
                                                disbursementController
                                                        .methodFields
                                                        .length -
                                                    1
                                            ? disbursementController
                                                  .focusList[index + 1]
                                            : null,
                                        required:
                                            disbursementController
                                                .methodFields[index]
                                                .isRequired ==
                                            1,
                                      ),
                                    ),

                                    disbursementController
                                                .methodFields[index]
                                                .inputType ==
                                            'date'
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              top: 20,
                                            ),
                                            child: IconButton(
                                              onPressed: () async {
                                                DateTime? pickedDate =
                                                    await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime.now(),
                                                      lastDate: DateTime(2100),
                                                    );
                                                if (pickedDate != null) {
                                                  String formattedDate =
                                                      DateConverterHelper.dateTimeForCoupon(
                                                        pickedDate,
                                                      );
                                                  setState(() {
                                                    disbursementController
                                                            .textControllerList[index]
                                                            .text =
                                                        formattedDate;
                                                  });
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.date_range_sharp,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                                if (disbursementController
                                        .isKeepzSplitSelected &&
                                    inputName ==
                                        DisbursementController
                                            .keepzReceiverIdentifierField) ...[
                                  const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  Text(
                                    disbursementController
                                                .selectedKeepzReceiverType ==
                                            'IBAN'
                                        ? 'keepz_iban_hint'.tr
                                        : 'keepz_branch_receiver_id_hint'.tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ],
                                SizedBox(
                                  height:
                                      index !=
                                          disbursementController
                                                  .methodFields
                                                  .length -
                                              1
                                      ? Dimensions.paddingSizeLarge
                                      : 0,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: Get.isDarkMode
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.grey[300]!,
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeExtraLarge,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    child: !disbursementController.isLoading
                        ? CustomButtonWidget(
                            buttonText: 'add_method'.tr,
                            onPressed: () {
                              final String? validationError =
                                  disbursementController
                                      .validateSelectedMethod();

                              if (validationError != null) {
                                showCustomSnackBar(validationError.tr);
                              } else {
                                disbursementController.addWithdrawMethod(
                                  disbursementController
                                      .buildWithdrawMethodPayload(),
                                );
                              }
                            },
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KeepzReceiverTypeSelector extends StatelessWidget {
  final DisbursementController disbursementController;
  const _KeepzReceiverTypeSelector({required this.disbursementController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'keepz_receiver_type'.tr,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Row(
          children: DisbursementController.keepzReceiverTypes.map((type) {
            final bool selected =
                disbursementController.selectedKeepzReceiverType == type;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type == DisbursementController.keepzReceiverTypes.first
                      ? Dimensions.paddingSizeSmall
                      : 0,
                ),
                child: InkWell(
                  onTap: () =>
                      disbursementController.setKeepzReceiverType(type),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusDefault,
                      ),
                      color: selected
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.08)
                          : Theme.of(context).cardColor,
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).primaryColor
                            : Theme.of(
                                context,
                              ).disabledColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type == 'IBAN'
                              ? Icons.account_balance
                              : Icons.storefront,
                          size: 18,
                          color: selected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Flexible(
                          child: Text(
                            type == 'IBAN'
                                ? 'keepz_iban_account'.tr
                                : 'keepz_branch'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoMedium.copyWith(
                              color: selected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          'keepz_split_receiver_default_note'.tr,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }
}
