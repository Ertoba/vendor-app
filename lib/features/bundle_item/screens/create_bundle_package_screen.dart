import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/models/config_model.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_tool_tip_widget.dart';
import 'package:sixam_mart_store/features/bogo_offer/widgets/setup_screen_widgets/bogo_item_details_bottom_sheet.dart';
import 'package:sixam_mart_store/features/bundle_item/controllers/bundle_item_controller.dart';
import 'package:sixam_mart_store/features/bundle_item/domain/models/bundle_item_model.dart';
import 'package:sixam_mart_store/features/bundle_item/domain/repositories/bundle_item_repository.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';
import 'package:sixam_mart_store/helper/price_converter_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

part '../widgets/setup_screen_widgets/bundle_item_dropdown_widget.dart';
part '../widgets/setup_screen_widgets/bundle_item_select_field_widget.dart';
part '../widgets/setup_screen_widgets/selected_bundle_item_card_widget.dart';


class CreateBundlePackageScreen extends StatefulWidget {
  final int? bundleId;
  const CreateBundlePackageScreen({super.key, this.bundleId});

  @override
  State<CreateBundlePackageScreen> createState() => _CreateBundlePackageScreenState();
}

class _CreateBundlePackageScreenState extends State<CreateBundlePackageScreen> with TickerProviderStateMixin {
  final List<Language> _languageList = Get.find<SplashController>().configModel?.language ?? [];
  final List<TextEditingController> _nameControllerList = [];
  final List<FocusNode> _nameFocusList = [];
  final TextEditingController _discountController = TextEditingController();

  TabController? _tabController;
  final List<Tab> _tabs = [];


  bool get _isEdit => widget.bundleId != null;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _languageList.length, vsync: this);
    for(final Language language in _languageList) {
      _tabs.add(Tab(text: language.value));
      _nameControllerList.add(TextEditingController());
      _nameFocusList.add(FocusNode());
    }

    final BundleItemController bundleItemController = Get.find<BundleItemController>();
    bundleItemController.resetSetup();
    bundleItemController.getBundleItems(isUpdate: false);

    if(_isEdit) {
      bundleItemController.getBundleDetails(widget.bundleId!, isUpdate: false).then((_) {
        final BundlePackage? bundle = bundleItemController.bundleDetails;
        if(bundle == null || !mounted) {
          return;
        }
        bundleItemController.prefillFrom(bundle);
        _fillNames(bundle);
        _discountController.text = (bundle.discountPercentage ?? 0) == 0 ? '' : _trimZeros(bundle.discountPercentage!);
        setState(() {});
      });
    }
  }

  void _fillNames(BundlePackage bundle) {
    final Map<String, String> translatedNames = bundle.translationsFor('name');
    _savedDescriptions = bundle.translationsFor('description');

    for(int index = 0; index < _nameControllerList.length; index++) {
      final String? translated = translatedNames[_languageList[index].key];
      _nameControllerList[index].text = translated ?? (index == 0 ? (bundle.name ?? '') : '');
    }

    if(_savedDescriptions.isEmpty && (bundle.description ?? '').isNotEmpty && _languageList.isNotEmpty) {
      _savedDescriptions = {_languageList[0].key ?? 'default': bundle.description!};
    }
  }

  Map<String, String> _savedDescriptions = {};

  static String _trimZeros(double value) => value % 1 == 0 ? value.toInt().toString() : value.toString();

  @override
  void dispose() {
    _tabController?.dispose();
    for(final TextEditingController controller in _nameControllerList) {
      controller.dispose();
    }
    for(final FocusNode focusNode in _nameFocusList) {
      focusNode.dispose();
    }
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final BundleItemController bundleItemController = Get.find<BundleItemController>();
    final DateTime now = DateTime.now();
    final DateTime? current = isStart ? bundleItemController.startDateTime : bundleItemController.endDateTime;

    final DateTime firstDate = isStart ? now : (bundleItemController.startDateTime ?? now);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: current != null && !current.isBefore(firstDate) ? current : firstDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    if(pickedDate == null || !mounted) {
      return;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: current != null ? TimeOfDay.fromDateTime(current) : TimeOfDay.now(),
    );
    if(pickedTime == null) {
      return;
    }

    final DateTime dateTime = DateTime(
      pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute,
    );

    if(isStart) {
      bundleItemController.setStartDateTime(dateTime);
    } else {
      bundleItemController.setEndDateTime(dateTime);
    }
  }

  String? _validate(BundleItemController bundleItemController) {
    if(_nameControllerList.isEmpty || _nameControllerList[0].text.trim().isEmpty) {
      return 'please_enter_bundle_name'.tr;
    }
    if(bundleItemController.startDateTime == null || bundleItemController.endDateTime == null) {
      return 'please_select_bundle_schedule'.tr;
    }
    if(!bundleItemController.endDateTime!.isAfter(bundleItemController.startDateTime!)) {
      return 'end_date_must_be_after_start_date'.tr;
    }
    if(!_isEdit && bundleItemController.rawThumbnail == null) {
      return 'please_upload_bundle_thumbnail'.tr;
    }

    /// Read from the field rather than from the controller's parsed number: it
    /// reports 0 both for a vendor who typed zero and for one who typed nothing,
    /// and only the first of those has answered.
    final String discountText = _discountController.text.trim();
    if(discountText.isEmpty) {
      return 'please_enter_discount'.tr;
    }

    /// The field accepts digits and dots, so "1.2.3" is typeable and parses to
    /// nothing. Left alone it falls back to zero and saves a bundle at full
    /// price without ever saying so.
    final double? discount = double.tryParse(discountText);
    if(discount == null) {
      return 'please_enter_a_valid_discount'.tr;
    }
    if(discount < 0 || discount >= BundleItemController.maxDiscountPercentage) {
      return 'the_discount_can_not_reach_percent'.trParams({'percent': '${BundleItemController.maxDiscountPercentage.toInt()}'});
    }
    if(bundleItemController.totalItemEntries < BundleItemController.minBundleItems) {
      return 'a_bundle_needs_at_least_items'.trParams({'count': '${BundleItemController.minBundleItems}'});
    }
    if(bundleItemController.totalItemEntries > BundleItemController.maxBundleItems) {
      return 'a_bundle_can_not_hold_more_than_items'.trParams({'count': '${BundleItemController.maxBundleItems}'});
    }
    return null;
  }

  Future<void> _submit(BundleItemController bundleItemController) async {
    final String? error = _validate(bundleItemController);
    if(error != null) {
      showCustomSnackBar(error);
      return;
    }

    final BundleSaveResult? result = await bundleItemController.saveBundle(
      bundleId: widget.bundleId,
      names: _collectNames(),
      descriptions: _collectDescriptions(),
    );

    if(result != null) {
      Get.back(result: true);
      showCustomSnackBar(result.message, isError: false);
    }
  }

  Map<String, String> _collectNames() {
    final String defaultName = _nameControllerList[0].text.trim();
    final Map<String, String> names = {};
    for(int index = 0; index < _languageList.length; index++) {
      final String locale = _languageList[index].key ?? 'default';
      final String typed = _nameControllerList[index].text.trim();
      names[locale] = typed.isNotEmpty ? typed : defaultName;
    }
    return names;
  }

  Map<String, String> _collectDescriptions() => _savedDescriptions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBarWidget(title: _isEdit ? 'edit_bundle_package'.tr : 'create_bundle_package'.tr),

      body: GetBuilder<BundleItemController>(builder: (bundleItemController) {
        return Column(children: [

          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              _SectionCard(
                title: 'basic_setup'.tr,
                subTitle: 'enter_bundle_name_upload_thumbnail_set_schedule'.tr,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if(_languageList.isNotEmpty) ...[
                    _PortionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      SizedBox(height: 40, child: TabBar(
                        tabAlignment: TabAlignment.start,
                        controller: _tabController,
                        indicatorColor: theme.primaryColor,
                        indicatorWeight: 3,
                        labelColor: theme.primaryColor,
                        unselectedLabelColor: theme.disabledColor,
                        unselectedLabelStyle: robotoRegular.copyWith(color: theme.disabledColor, fontSize: Dimensions.fontSizeSmall),
                        labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: theme.primaryColor),
                        labelPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        tabs: _tabs,
                        onTap: (_) => setState(() {}),
                      )),
                      Divider(height: 1, color: theme.disabledColor.withValues(alpha: 0.2)),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      CustomTextFieldWidget(
                        required: true,
                        hintText: 'bundle_name'.tr,
                        labelText: '${'bundle_name'.tr} (${_languageList[_tabController!.index].value})',
                        controller: _nameControllerList[_tabController!.index],
                        focusNode: _nameFocusList[_tabController!.index],
                        capitalization: TextCapitalization.words,
                        inputAction: TextInputAction.done,
                        showTitle: false,
                      ),
                    ])),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],

                  _PortionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    _DateTimeField(
                      label: 'start_date_time'.tr,
                      value: bundleItemController.startDateTime,
                      onTap: () => _pickDateTime(isStart: true),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    _DateTimeField(
                      label: 'end_date_time'.tr,
                      value: bundleItemController.endDateTime,
                      onTap: () => _pickDateTime(isStart: false),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    _ThumbnailField(bundleItemController: bundleItemController),
                  ])),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              _SectionCard(
                title: 'items_and_price'.tr,
                subTitle: 'bundle_price_updates_automatically_des'.tr,
                child: Column(children: [
                  _PortionCard(child: Column(children: [

                    _PriceField(
                      label: 'total_base_price'.tr,
                      tooltip: 'total_base_price_info'.tr,
                      value: PriceConverterHelper.convertPrice(bundleItemController.totalBasePrice),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    _NotchedLabel(
                      label: '${'discount'.tr} (%)',
                      tooltip: 'discount_info'.tr,
                      required: true,
                      child: CustomTextFieldWidget(
                        controller: _discountController,
                        hintText: '0%',
                        showLabelText: false,
                        isAmount: true,
                        inputType: TextInputType.number,
                        inputAction: TextInputAction.done,
                        showTitle: false,
                        onChanged: bundleItemController.setDiscount,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    _PriceField(
                      label: 'bundle_price'.tr,
                      tooltip: 'bundle_price_info'.tr,
                      value: PriceConverterHelper.convertPrice(bundleItemController.bundlePrice),
                    ),
                  ])),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  _PortionCard(child: _BundleItemSelectField(bundleItemController: bundleItemController))
                ]),
              ),

            ]),
          )),

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            color: theme.cardColor,
            child: SafeArea(top: false, child: CustomButtonWidget(
              buttonText: _isEdit ? 'update'.tr : 'add'.tr,
              isLoading: bundleItemController.isSubmitLoading,
              onPressed: () => _submit(bundleItemController),
            )),
          ),

        ]);
      }),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final Widget child;
  const _SectionCard({this.title, this.subTitle, required this.child});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        if(title != null) ...[
          Text(title!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        ],

        if(subTitle != null) ...[
          Text(subTitle!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.hintColor)),
          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],

        child,
      ]),
    );
  }
}
class _PortionCard extends StatelessWidget {
  final Widget child;
  const _PortionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: child,
    );
  }
}
class _PriceField extends StatelessWidget {
  final String label;
  final String tooltip;
  final String value;
  const _PriceField({required this.label, required this.tooltip, required this.value});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return _NotchedLabel(
      label: label,
      tooltip: tooltip,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: theme.disabledColor.withValues(alpha: 0.3)),
        ),
        child: Text(value, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
      ),
    );
  }
}

class _NotchedLabel extends StatelessWidget {
  final String label;
  final String tooltip;
  final Widget child;

  /// Drawn here, because a field using this label has the text field's own
  /// label switched off and so cannot show an asterisk itself.
  final bool required;
  const _NotchedLabel({required this.label, required this.tooltip, required this.child, this.required = false});

  static const double _labelHalfHeight = 10;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Stack(clipBehavior: Clip.none, children: [

      Padding(padding: const EdgeInsets.only(top: _labelHalfHeight), child: child),

      Positioned(left: Dimensions.paddingSizeSmall, top: 0, child: Container(
        color: Color.alphaBlend(theme.disabledColor.withValues(alpha: 0.06), theme.cardColor),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
        child: Row(mainAxisSize: MainAxisSize.min, children: [

          Text.rich(TextSpan(children: [
            TextSpan(text: label, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.hintColor)),
            if(required)
              TextSpan(text: ' *', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.colorScheme.error)),
          ])),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

          CustomToolTip(message: tooltip, child: Icon(Icons.info, size: 16, color: theme.hintColor)),
        ]),
      )),

    ]);
  }
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  const _DateTimeField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: theme.disabledColor.withValues(alpha: 0.3)),
        ),
        child: Row(children: [

          Expanded(child: value == null ? RichText(text: TextSpan(
            text: label,
            style: robotoRegular.copyWith(color: theme.hintColor),
            children: [TextSpan(text: ' *', style: robotoRegular.copyWith(color: theme.colorScheme.error))],
          )) : Text(
            DateConverterHelper.dateTimeToDateTime(value!),
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
          )),

          Icon(Icons.calendar_month, size: 20, color: theme.hintColor),
        ]),
      ),
    );
  }
}

class _ThumbnailField extends StatelessWidget {
  final BundleItemController bundleItemController;
  const _ThumbnailField({required this.bundleItemController});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: theme.disabledColor.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        RichText(text: TextSpan(
          text: 'thumbnail'.tr,
          style: robotoMedium.copyWith(color: theme.textTheme.bodyLarge?.color),
          children: [TextSpan(text: ' *', style: robotoMedium.copyWith(color: theme.colorScheme.error))],
        )),

        Text(
          'thumbnail_image_format'.trParams({'size': bundleItemController.maxFileSizeText}),
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.hintColor),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Align(alignment: Alignment.center, child: _ThumbnailPicker(bundleItemController: bundleItemController)),
      ]),
    );
  }
}
class _ThumbnailPicker extends StatelessWidget {
  final BundleItemController bundleItemController;
  const _ThumbnailPicker({required this.bundleItemController});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String savedThumbnail = bundleItemController.savedThumbnail ?? '';

    return Stack(children: [

      ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: bundleItemController.rawThumbnail != null ? Image.file(
          File(bundleItemController.rawThumbnail!.path), width: 150, height: 150, fit: BoxFit.cover,
        ) : savedThumbnail.isNotEmpty ? CustomImageWidget(
          image: savedThumbnail, height: 150, width: 150, fit: BoxFit.cover,
        ) : Container(
          height: 150, width: 150,
          decoration: BoxDecoration(
            color: Get.isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(CupertinoIcons.photo_camera_solid, color: theme.disabledColor.withValues(alpha: 0.5), size: 30),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text('click_to_add'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.primaryColor)),
          ]),
        ),
      ),

      Positioned.fill(child: InkWell(
        onTap: () => bundleItemController.pickThumbnail(),
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: const Radius.circular(Dimensions.radiusDefault),
            dashPattern: const [8, 4],
            strokeWidth: 1,
            color: theme.primaryColor.withValues(alpha: 0.5),
          ),
          child: const SizedBox(height: 150, width: 150),
        ),
      )),

    ]);
  }
}
