import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/features/reels/widgets/reel_preview_dialog_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart_store/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_card.dart';
import 'package:sixam_mart_store/common/widgets/custom_drop_down_button.dart.dart';
import 'package:sixam_mart_store/common/widgets/custom_dropdown_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_ink_well_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_time_picker_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_tool_tip_widget.dart';
import 'package:sixam_mart_store/common/widgets/label_widget.dart';
import 'package:sixam_mart_store/features/addon/controllers/addon_controller.dart';
import 'package:sixam_mart_store/features/ai/controllers/ai_controller.dart';
import 'package:sixam_mart_store/features/ai/widgets/ai_generator_bottom_sheet.dart';
import 'package:sixam_mart_store/features/ai/widgets/animated_border_container.dart';
import 'package:sixam_mart_store/features/category/controllers/category_controller.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/profile/domain/models/profile_model.dart' hide Module;
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/features/store/controllers/store_controller.dart';
import 'package:sixam_mart_store/features/store/domain/models/attribute_model.dart';
import 'package:sixam_mart_store/features/store/domain/models/item_model.dart';
import 'package:sixam_mart_store/features/store/domain/models/variant_type_model.dart';
import 'package:sixam_mart_store/features/store/domain/models/variation_body_model.dart';
import 'package:sixam_mart_store/features/store/widgets/add_item_section_header_widget.dart';
import 'package:sixam_mart_store/features/store/widgets/add_item_section_selector_widget.dart';
import 'package:sixam_mart_store/features/store/widgets/attribute_view_widget.dart';
import 'package:sixam_mart_store/features/store/widgets/food_variation_view_widget.dart';
import 'package:sixam_mart_store/features/store/widgets/meta_seo_item_widget.dart';
import 'package:sixam_mart_store/features/store/widgets/video_upload_widget.dart';
import 'package:sixam_mart_store/helper/data_parser_helper.dart';
import 'package:sixam_mart_store/helper/validate_check.dart';
import 'package:sixam_mart_store/util/debouncer.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

class AddItemScreen extends StatefulWidget {
  final Item? item;
  const AddItemScreen({super.key, required this.item});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> with TickerProviderStateMixin {

  final List<TextEditingController> _nameControllerList = [];
  final List<TextEditingController> _descriptionControllerList = [];
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _maxOrderQuantityController = TextEditingController();
  TextEditingController? _addonController;
  String _nutritionSuggestionText = '';
  String _allergicIngredientsSuggestionText = '';
  final TextEditingController _genericNameSuggestionController = TextEditingController();
  final TextEditingController _metaTitleController = TextEditingController();
  final TextEditingController _metaDescriptionController = TextEditingController();
  final TextEditingController _maxSnippetController = TextEditingController();
  final TextEditingController _maxVideoPreviewController =
      TextEditingController();
  final TextEditingController _productVideoLinkController =
      TextEditingController();

  XFile? _pickedProductVideo;
  String _videoUploadType = 'file';
  String? _existingProductVideoUrl;
  String? _existingProductVideoLink;
  String? _existingProductVideoPreviewUrl;
  bool _removeProductVideo = false;

  final FocusNode _priceNode = FocusNode();
  final FocusNode _discountNode = FocusNode();
  final FocusNode _metaTitleNode = FocusNode();
  final FocusNode _metaDescriptionNode = FocusNode();

  final List<FocusNode> _nameFocusList = [];
  final List<FocusNode> _descriptionFocusList = [];

  late bool _update;
  late bool _discountTypeSelected;
  late Item _item;

  final Module? _module = Get.find<SplashController>().configModel!.moduleConfig!.module;
  final isPharmacy = Get.find<ProfileController>().profileModel!.stores!.module!.moduleType == 'pharmacy';
  final isEcommerce = Get.find<ProfileController>().profileModel!.stores!.module!.moduleType == 'ecommerce';
  final isGrocery = Get.find<ProfileController>().profileModel!.stores!.module!.moduleType == 'grocery';
  final isFood = Get.find<SplashController>().getStoreModuleConfig().newVariation!;

  final List<Language>? _languageList = Get.find<SplashController>().configModel!.language;
  TabController? _tabController;
  final List<Tab> _tabs =[];

  final ValueNotifier<int> selectedSection = ValueNotifier<int>(0);
  final ScrollController _sectionScrollController = ScrollController();
  int _videoWidgetKey = 0;
  final bool vatTaxEnable = Get.find<SplashController>().configModel!.systemTaxType == 'product_wise' && !(Get.find<SplashController>().configModel!.systemTaxIncludeStatus ?? false);

  final Debouncer _resetDebouncer = Debouncer(delay: const Duration(milliseconds: 500));
  final Debouncer _aiTitleDescDebouncer = Debouncer(delay: const Duration(milliseconds: 500));
  final Debouncer _aiOtherDataDebouncer = Debouncer(delay: const Duration(milliseconds: 500));
  final Debouncer _aiVariationDebouncer = Debouncer(delay: const Duration(milliseconds: 500));
  final Debouncer _thumbnailPickDebouncer = Debouncer(delay: const Duration(milliseconds: 500));
  final Debouncer _additionalImagesPickDebouncer = Debouncer(delay: const Duration(milliseconds: 500));
  final Debouncer _metaImagePickDebouncer = Debouncer(delay: const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
    _update = widget.item != null;
    _discountTypeSelected = _update;

    _existingProductVideoUrl = widget.item?.videoFullUrl;
    _existingProductVideoLink = widget.item?.videoLink;
    _existingProductVideoPreviewUrl = widget.item?.videoPreviewUrl;

    if ((_existingProductVideoLink ?? '').trim().isNotEmpty) {
      _videoUploadType = 'link';
      _productVideoLinkController.text = _existingProductVideoLink!;
    }

    storeController.initItemData(
      item: widget.item,
      isFood: isFood,
      isGrocery: isGrocery,
      isPharmacy: isPharmacy,
    );
    categoryController.initCategoryData(widget.item);
    if (Get.find<SplashController>().configModel!.systemTaxType ==
        'product_wise') {
      storeController.getVatTaxList();
    }
    storeController.clearVatTax();

    _tabController = TabController(length: _languageList!.length, vsync: this);
    _tabs.addAll(_languageList.map((lang) => Tab(text: lang.value)));

    for(int index = 0; index < _languageList.length; index++) {
      _nameControllerList.add(TextEditingController());
      _descriptionControllerList.add(TextEditingController());
      _nameFocusList.add(FocusNode());
      _descriptionFocusList.add(FocusNode());
    }

    WidgetsBinding.instance.addPostFrameCallback((_){
      StoreController storeController = Get.find<StoreController>();
      CategoryController categoryController = Get.find<CategoryController>();

      storeController.initItemData(item: widget.item, isFood: isFood, isGrocery: isGrocery, isPharmacy: isPharmacy);
      categoryController.initCategoryData(widget.item);
      if(vatTaxEnable){
        storeController.getVatTaxList();
      }
      storeController.clearVatTax();

      _setGeneralInfoFieldData(widget.item);
      _setPriceVariationFieldData(widget.item);
      _setOtherSetupFieldData(widget.item);

      if(isEcommerce || isGrocery) {
        storeController.getBrandList(widget.item);
      }
      if(isEcommerce) {
        storeController.initializeMetaData(widget.item?.metaData);
      }

      if(isPharmacy) {
        storeController.getSuitableTagList(widget.item);
      }
      storeController.getAttributeList(widget.item);
      storeController.removeImageFromList();
      _setOtherSetupControllerData(storeController, widget.item);
      storeController.setTag('', isClear: true);
      if(widget.item?.tags != null) {
        for(final tag in widget.item!.tags!) {
          storeController.setTag(tag.tag, isUpdate: false);
        }
      }
      _setGeneralInfoControllerData(storeController, widget.item);
      storeController.setDiscountTypeIndex(_discountTypeIndexForItem(widget.item), false);
      if(_update && _isNewVariationEnabled) {
        storeController.setExistingVariation(_item.foodVariations);
      } else if(!_update) {
        storeController.setEmptyVariationList();
      }
    });
  }

  void _setTranslationData(Item? item) {
    for(int index = 0; index < _languageList!.length; index++) {
      _nameControllerList[index].clear();
      _descriptionControllerList[index].clear();

      for(final translation in item?.translations ?? <Translation>[]) {
        if(_languageList[index].key == translation.locale && translation.key == 'name') {
          _nameControllerList[index].text = translation.value ?? '';
        }else if(_languageList[index].key == translation.locale && translation.key == 'description') {
          _descriptionControllerList[index].text = translation.value ?? '';
        }
      }
    }
  }

  void _setGeneralInfoFieldData(Item? item) {
    _setTranslationData(item);
    _genericNameSuggestionController.text = item?.genericName?.isNotEmpty == true ? item!.genericName!.first ?? '' : '';
    _nutritionSuggestionText = '';
    _allergicIngredientsSuggestionText = '';
  }

  int _discountTypeIndexForItem(Item? item) => item?.discountType == 'amount' ? 1 : 0;

  String _discountTextForItem(Item? item) {
    final double discount = item?.discount ?? 0;
    return discount % 1 == 0 ? discount.toInt().toString() : discount.toString();
  }

  void _setPriceVariationFieldData(Item? item) {
    _priceController.text = item?.price?.toString() ?? '';
    _discountController.text = _discountTextForItem(item);
    _stockController.text = item?.stock?.toString() ?? '';
    _maxOrderQuantityController.text = item?.maxOrderQuantity?.toString() ?? '';
  }

  void _setOtherSetupFieldData(Item? item) {
    _tagController.clear();
    _metaTitleController.text = item?.metaTitle ?? '';
    _metaDescriptionController.text = item?.metaDescription ?? '';
    _maxSnippetController.text = item?.metaData?.metaMaxSnippetValue?.toString() ?? '';
    _maxVideoPreviewController.text = item?.metaData?.metaMaxVideoPreviewValue?.toString() ?? '';
  }

  void _setOtherSetupControllerData(StoreController storeController, Item? item) {
    storeController.setAvailableTimeStarts(startTime: item?.availableTimeStarts, willUpdate: false);
    storeController.setAvailableTimeEnds(endTime: item?.availableTimeEnds, willUpdate: false);
  }

  void _setGeneralInfoControllerData(StoreController storeController, Item? item) {
    storeController.setVeg(item?.veg == 1, false);
    storeController.initSetup();

    if(item?.isHalal == 1) {
      storeController.toggleHalal(willUpdate: false);
    }
    if(item?.isBasicMedicine == 1) {
      storeController.toggleBasicMedicine(willUpdate: false);
    }
    if(item?.isPrescriptionRequired == 1) {
      storeController.togglePrescriptionRequired(willUpdate: false);
    }
  }

  Future<void> _resetGeneralInfoStep({
    required StoreController storeController,
    required CategoryController categoryController,
  }) async {
    final Item? item = widget.item;

    _setGeneralInfoFieldData(item);
    await categoryController.initCategoryData(item);
    storeController.initItemData(item: item, isFood: isFood, isGrocery: isGrocery, isPharmacy: isPharmacy);

    if(vatTaxEnable && storeController.vatTaxList == null) {
      await storeController.getVatTaxList();
    }
    storeController.clearVatTax();
    if(item?.taxVatIds != null && item!.taxVatIds!.isNotEmpty) {
      storeController.preloadVatTax(vatTaxList: item.taxVatIds!);
    }

    if(isEcommerce || isGrocery) {
      await storeController.getBrandList(item);
    }

    if(isPharmacy) {
      await storeController.getSuitableTagList(item);
    }

    storeController.resetItemThumbnail(willUpdate: false);
    _setGeneralInfoControllerData(storeController, item);
    storeController.update();
  }

  Future<void> _resetPriceVariationStep(StoreController storeController) async {
    final Item? item = widget.item;

    _setPriceVariationFieldData(item);
    _addonController?.clear();
    await storeController.getAttributeList(item, resetThumbnail: false, resetMedia: false);
    storeController.setDiscountTypeIndex(_discountTypeIndexForItem(item), true);
    if(_update && _isNewVariationEnabled) {
      storeController.setExistingVariation(_item.foodVariations);
      storeController.update();
    } else if(!_update) {
      storeController.setEmptyVariationList();
      storeController.update();
    }
    if(mounted) {
      setState(() {
        _discountTypeSelected = true;
      });
    }
  }

  void _resetOtherSetupStep(StoreController storeController) {
    final Item? item = widget.item;

    _setOtherSetupFieldData(item);
    storeController.setTag('', isClear: true);
    if(item?.tags != null) {
      for(final tag in item!.tags!) {
        storeController.setTag(tag.tag, isUpdate: false);
      }
    }
    storeController.resetItemMedia(item, willUpdate: false);
    storeController.initializeMetaData(item?.metaData);
    _setOtherSetupControllerData(storeController, item);
    storeController.update();

    if(mounted) {
      setState(() {
        _videoWidgetKey++;
      });
    }
  }

  Future<void> _resetCurrentStep({
    required StoreController storeController,
    required CategoryController categoryController,
  }) async {
    if(selectedSection.value == 0) {
      await _resetGeneralInfoStep(
        storeController: storeController,
        categoryController: categoryController
      );
    } else if(selectedSection.value == 1) {
      await _resetPriceVariationStep(storeController);
    } else {
      _resetOtherSetupStep(storeController);
    }

    showCustomSnackBar('reset_successful'.tr, isError: false);
  }

  String _normalizeProductVideoLink(String value) {
    String link = value.trim();
    if (link.isEmpty) {
      return '';
    }
    if (link.startsWith('//')) {
      return 'https:$link';
    }
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(link) &&
        RegExp(r'^(www\.)?[\w.-]+\.[a-zA-Z]{2,}([/?#].*)?$').hasMatch(link)) {
      link = 'https://$link';
    }
    return link;
  }

  bool _isValidProductVideoLink(String value) {
    final String normalized = _normalizeProductVideoLink(value);
    final Uri? uri = Uri.tryParse(normalized);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty &&
        uri.host.contains('.');
  }

  bool _isDirectProductVideoLink(String value) {
    final Uri? uri = Uri.tryParse(_normalizeProductVideoLink(value));
    final String path = uri?.path.toLowerCase() ?? '';
    return path.endsWith('.mp4') ||
        path.endsWith('.webm') ||
        path.endsWith('.ogg');
  }

  Future<void> _pickProductVideo() async {
    final XFile? picked = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );

    if (picked == null) {
      return;
    }

    final String path = picked.path.toLowerCase();
    final bool validExtension =
        path.endsWith('.mp4') ||
        path.endsWith('.webm') ||
        path.endsWith('.ogg');

    if (!validExtension) {
      showCustomSnackBar('unsupported_product_video_format'.tr);
      return;
    }

    final int bytes = await picked.length();
    const int maxBytes = 10 * 1024 * 1024;

    if (bytes > maxBytes) {
      showCustomSnackBar('product_video_max_size'.tr);
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _pickedProductVideo = picked;
      _videoUploadType = 'file';
      _productVideoLinkController.clear();
      _removeProductVideo = false;
    });
  }

  void _selectProductVideoLinkMode() {
    setState(() {
      _pickedProductVideo = null;
      _videoUploadType = 'link';
      _removeProductVideo = false;
    });
  }

  void _removeProductVideoSelection() {
    setState(() {
      _pickedProductVideo = null;
      _productVideoLinkController.clear();
      _removeProductVideo = true;
    });
  }

  Future<void> _previewProductVideo() async {
    if (_pickedProductVideo != null) {
      await Get.dialog(
        ReelPreviewDialogWidget(
          mediaFile: _pickedProductVideo,
          isVideoFile: true,
        ),
      );
      return;
    }

    if (_videoUploadType == 'link') {
      final String link = _productVideoLinkController.text.trim().isNotEmpty
          ? _normalizeProductVideoLink(_productVideoLinkController.text)
          : _normalizeProductVideoLink(_existingProductVideoLink ?? '');

      if (link.isEmpty || !_isValidProductVideoLink(link)) {
        showCustomSnackBar('invalid_product_video_link'.tr);
        return;
      }

      if (_isDirectProductVideoLink(link)) {
        await Get.dialog(ReelPreviewDialogWidget(networkVideoUrl: link));
        return;
      }

      final Uri uri = Uri.parse(link);
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        showCustomSnackBar('invalid_product_video_link'.tr);
      }
      return;
    }

    final String networkVideo =
        (_existingProductVideoPreviewUrl ?? '').trim().isNotEmpty
        ? _existingProductVideoPreviewUrl!
        : (_existingProductVideoUrl ?? '');

    if (networkVideo.trim().isNotEmpty) {
      await Get.dialog(ReelPreviewDialogWidget(networkVideoUrl: networkVideo));
      return;
    }

    final String link = _normalizeProductVideoLink(
      _existingProductVideoLink ?? '',
    );

    if (link.isNotEmpty && _isValidProductVideoLink(link)) {
      await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildProductVideoSection(BuildContext context) {
    final bool hasPickedFile = _pickedProductVideo != null;

    final bool hasExistingFile =
        !_removeProductVideo &&
        (_existingProductVideoUrl ?? '').trim().isNotEmpty &&
        _videoUploadType == 'file';

    final bool hasLink =
        !_removeProductVideo &&
        (_videoUploadType == 'link') &&
        (_productVideoLinkController.text.trim().isNotEmpty ||
            (_existingProductVideoLink ?? '').trim().isNotEmpty);

    final bool hasVideo = hasPickedFile || hasExistingFile || hasLink;

    String? selectedFileName;
    if (_pickedProductVideo != null) {
      selectedFileName = _pickedProductVideo!.path.split(RegExp(r'[\\/]')).last;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Row(
          children: [
            Text('product_video'.tr, style: robotoBold),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
              '(${'optional'.tr})',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          'product_video_optional_hint'.tr,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).disabledColor,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: const [
              BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 5),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickProductVideo,
                      icon: const Icon(Icons.video_library_outlined),
                      label: Text('upload_video_file'.tr),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectProductVideoLinkMode,
                      icon: const Icon(Icons.link),
                      label: Text('use_video_link'.tr),
                    ),
                  ),
                ],
              ),
              if (_videoUploadType == 'link') ...[
                const SizedBox(height: Dimensions.paddingSizeSmall),
                TextField(
                  controller: _productVideoLinkController,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'video_link'.tr,
                    hintText: 'enter_video_link'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    if (_removeProductVideo) {
                      setState(() {
                        _removeProductVideo = false;
                      });
                    } else {
                      setState(() {});
                    }
                  },
                ),
              ],
              if (hasVideo) ...[
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Text(
                          selectedFileName ??
                              (_videoUploadType == 'link'
                                  ? (_productVideoLinkController.text
                                            .trim()
                                            .isNotEmpty
                                        ? _productVideoLinkController.text
                                              .trim()
                                        : (_existingProductVideoLink ?? ''))
                                  : 'product_video_ready'.tr),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular,
                        ),
                      ),
                      IconButton(
                        tooltip: 'preview_video'.tr,
                        onPressed: _previewProductVideo,
                        icon: const Icon(Icons.visibility_outlined),
                      ),
                      IconButton(
                        tooltip: 'remove_video'.tr,
                        onPressed: _removeProductVideoSelection,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _validateDiscount() {
    double price = double.tryParse(_priceController.text) ?? 0.0;
    double discount = double.tryParse(_discountController.text) ?? 0.0;

    if (Get.find<StoreController>().discountTypeIndex == 0) {
      if (discount > 100) {
        showCustomSnackBar('discount_cannot_be_more_than_100'.tr, isError: true);
        _discountController.text = '100';
      }
    } else if (Get.find<StoreController>().discountTypeIndex == 1) {
      if (discount > price) {
        showCustomSnackBar('discount_cannot_be_more_than_price'.tr, isError: true);
        _discountController.text = price.toString();
      }
    }
  }

  bool get _isNewVariationEnabled => Get.find<SplashController>().getStoreModuleConfig().newVariation!;
  bool _hasThumbnail(StoreController storeController) => storeController.rawLogo != null || (_item.imageFullUrl?.trim().isNotEmpty ?? false);

  String get _maxFileSizeText {
    final double maxFileSize = Get.find<SplashController>().configModel!.validationConfig!.maxFileSize;
    if(maxFileSize % 1 == 0) {
      return maxFileSize.toInt().toString();
    }
    return maxFileSize.toString();
  }
  String get _imageSizeErrorText => 'image_size_exceeds'.trParams({'size' : _maxFileSizeText});

  // Single entry point for switching sections so every transition starts from
  // the top of the newly shown section instead of keeping the previous offset.
  void _setSection(int index) {
    if (selectedSection.value != index) {
      selectedSection.value = index;
    }
    _scrollSectionToTop();
  }

  void _scrollSectionToTop() {
    // Wait for the incoming section to lay out; animating before that lets the
    // scroll position auto-correct mid-animation and the scroll visibly jumps.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sectionScrollController.hasClients && _sectionScrollController.offset > 0) {
        _sectionScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic
        );
      }
    });
  }

  void _changeSection({
    required int targetIndex,
    required StoreController storeController,
    required CategoryController categoryController,
  }) {
    final int currentIndex = selectedSection.value;

    if (targetIndex == currentIndex) {
      return;
    }

    if (targetIndex < currentIndex) {
      _setSection(targetIndex);
      return;
    }

    for (int sectionIndex = currentIndex; sectionIndex < targetIndex; sectionIndex++) {
      final String? errorMessage = _validateSection(
        sectionIndex,
        storeController: storeController,
        categoryController: categoryController
      );

      if (errorMessage != null) {
        if (sectionIndex != currentIndex) {
          _setSection(sectionIndex);
        } else {
          _scrollSectionToTop();
        }
        showCustomSnackBar(errorMessage);
        return;
      }
    }

    _setSection(targetIndex);
  }

  String? _validateSection(
    int sectionIndex, {
    required StoreController storeController,
    required CategoryController categoryController,
  }) {
    switch (sectionIndex) {
      case 0:
        return _validateGeneralInfoSection(
          storeController: storeController,
          categoryController: categoryController
        );
      case 1:
        return _validatePriceAndVariationSection(storeController: storeController);
      case 2:
        return _validateOtherSetupSection(storeController: storeController);
      default:
        return null;
    }
  }



  String? _validateGeneralInfoSection({
    required StoreController storeController,
    required CategoryController categoryController,
  }) {
    if (_isEnglishDataIncomplete()) {
      return 'enter_data_for_english'.tr;
    } else if (categoryController.selectedCategoryID == null) {
      return 'select_a_category'.tr;
    } else if (categoryController.isMyCategoryFeatureEnabled && categoryController.myCategories != null && categoryController.myCategories!.isNotEmpty && categoryController.selectedMyCategoryID == null) {
      return 'select_my_category'.tr;
    } else if (vatTaxEnable && storeController.selectedVatTaxIdList.isEmpty) {
      return 'select_vat_tax'.tr;
    } else if (!_hasThumbnail(storeController)) {
      return 'upload_item_thumbnail_image'.tr;
    } else if (storeController.rawLogo != null && !storeController.isItemThumbnailValid) {
      return _imageSizeErrorText;
    }

    return null;
  }

  String? _validatePriceAndVariationSection({
    required StoreController storeController,
  }) {
    final String price = _priceController.text.trim();
    final String discount = _discountController.text.trim();
    final int maxOrderQuantity = int.tryParse(_maxOrderQuantityController.text.trim()) ?? 0;

    if (price.isEmpty) {
      return 'enter_item_price'.tr;
    } else if (!_discountTypeSelected) {
      return 'enter_discount_type'.tr;
    } else if (discount.isEmpty) {
      return 'enter_item_discount'.tr;
    }

    final String? variationError = _validateVariationAndStock(storeController: storeController, discount: discount);
    if (variationError != null) {
      return variationError;
    } else if (_module!.unit! && storeController.unitIndex == null) {
      return 'add_an_unit'.tr;
    } else if (maxOrderQuantity < 0) {
      return 'maximum_item_order_quantity_can_not_be_negative'.tr;
    }

    return null;
  }

  String? _validateOtherSetupSection({
    required StoreController storeController,
  }) {
    final String metaTitle = _metaTitleController.text.trim();
    final String metaDescription = _metaDescriptionController.text.trim();
    final String? videoLinkError = !storeController.toggleVideo ? ValidateCheck.validateUrl(storeController.videoLink ?? '', isRequired: false) : null;
    final bool videoSizeError = storeController.toggleVideo && storeController.rawVideo != null && !storeController.isVideoValid;

    if (isEcommerce && metaTitle.isEmpty) {
      return 'enter_meta_title'.tr;
    } else if (isEcommerce && metaDescription.isEmpty) {
      return 'enter_meta_description'.tr;
    } else if (storeController.pickedMetaImage != null && !storeController.isMetaImageValid) {
      return _imageSizeErrorText;
    } else if (storeController.hasInvalidAdditionalImages) {
      return _imageSizeErrorText;
    } else if (_module?.itemAvailableTime == true && storeController.availableTimeStarts == null) {
      return 'pick_start_time'.tr;
    } else if (_module?.itemAvailableTime == true && storeController.availableTimeEnds == null) {
      return 'pick_end_time'.tr;
    } else if (videoLinkError != null) {
      return videoLinkError;
    } else if (videoSizeError) {
      return "video_size_should_be_reduce".tr;
    }

    return null;
  }

  void _handlePrimaryAction({
    required StoreController storeController,
    required CategoryController categoryController,
  }) {
    if (selectedSection.value < 2) {
      _changeSection(
        targetIndex: selectedSection.value + 1,
        storeController: storeController,
        categoryController: categoryController
      );
      return;
    }

    _submitItem(
      storeController: storeController,
      categoryController: categoryController
    );
  }

  void _moveToFurthestValidSection({
    required StoreController storeController,
    required CategoryController categoryController,
  }) {
    int targetIndex = 0;

    for (int sectionIndex = 0; sectionIndex <= 2; sectionIndex++) {
      final String? errorMessage = _validateSection(
        sectionIndex,
        storeController: storeController,
        categoryController: categoryController
      );

      if (errorMessage != null) {
        targetIndex = sectionIndex;
        break;
      }

      targetIndex = sectionIndex < 2 ? sectionIndex + 1 : 2;
    }

    _setSection(targetIndex);
  }

  String? _validateVariationAndStock({
    required StoreController storeController,
    required String discount,
  }) {
    for (final AttributeModel attr in storeController.attributeList ?? []) {
      if (attr.active && attr.variants.isEmpty) {
        return 'add_at_least_one_variant_for_every_attribute'.tr;
      }
    }

    if (_isNewVariationEnabled) {
      for (final VariationModelBodyModel variationModel in storeController.variationList ?? []) {
        if (variationModel.nameController!.text.trim().isEmpty) {
          return 'enter_name_for_every_variation'.tr;
        }

        if (!variationModel.isSingle) {
          final String minText = variationModel.minController!.text.trim();
          final String maxText = variationModel.maxController!.text.trim();
          final int? minValue = int.tryParse(minText);
          final int? maxValue = int.tryParse(maxText);

          if (minText.isEmpty || maxText.isEmpty || minValue == null || maxValue == null) {
            return 'enter_min_max_for_every_multipart_variation'.tr;
          } else if (minValue < 1) {
            return 'minimum_type_cant_be_less_then_1'.tr;
          } else if (maxValue < minValue) {
            return 'max_type_cant_be_less_then_minimum_type'.tr;
          } else if (maxValue > variationModel.options!.length) {
            return 'max_type_length_should_not_be_more_then_options_length'.tr;
          }
        }

        for (final Option option in variationModel.options ?? []) {
          if (option.optionNameController!.text.trim().isEmpty) {
            return 'enter_option_name_for_every_variation'.tr;
          } else if (option.optionPriceController!.text.trim().isEmpty) {
            return 'enter_option_price_for_every_variation'.tr;
          }
        }
      }
    } else {
      for (final VariantTypeModel variantType in storeController.variantTypeList ?? []) {
        if (variantType.priceController.text.trim().isEmpty) {
          return 'enter_price_for_every_variant'.tr;
        } else if (_module!.stock! && variantType.stockController.text.trim().isEmpty) {
          return 'enter_stock_for_every_variant'.tr;
        }
      }
    }

    if (_module!.stock! && (storeController.variantTypeList?.isEmpty ?? true) && _stockController.text.trim().isEmpty) {
      return 'enter_stock'.tr;
    }

    if (storeController.discountTypeIndex == 1 && (storeController.variantTypeList?.isNotEmpty ?? false)) {
      final double discountValue = double.tryParse(discount) ?? 0;
      for (final VariantTypeModel variantType in storeController.variantTypeList!) {
        final double? variantPrice = double.tryParse(variantType.priceController.text.trim());
        if (variantPrice != null && variantPrice < discountValue) {
          return 'discount_cant_be_more_then_minimum_variation_price'.tr;
        }
      }
    }

    return null;
  }

  bool _isEnglishDataIncomplete() {
    for (int index = 0; index < _languageList!.length; index++) {
      if (_languageList[index].key == 'en') {
        return _nameControllerList[index].text.trim().isEmpty
            || _descriptionControllerList[index].text.trim().isEmpty;
      }
    }

    return false;
  }

  void _submitItem({
    required StoreController storeController,
    required CategoryController categoryController,
  }) {
    for (int sectionIndex = 0; sectionIndex <= 2; sectionIndex++) {
      final String? errorMessage = _validateSection(
        sectionIndex,
        storeController: storeController,
        categoryController: categoryController
      );

      if (errorMessage != null) {
        _setSection(sectionIndex);
        showCustomSnackBar(errorMessage);
        return;
      }
    }

    final String price = _priceController.text.trim();
    final String discount = _discountController.text.trim();
    final int maxOrderQuantity = int.tryParse(_maxOrderQuantityController.text.trim()) ?? 0;
    final String metaTitle = _metaTitleController.text.trim();
    final String metaDescription = _metaDescriptionController.text.trim();

    final MetaSeoData metaSeoData = MetaSeoData(
      metaIndex: storeController.metaIndex,
      metaNoFollow: storeController.noFollow,
      metaNoImageIndex: storeController.noImageIndex,
      metaNoArchive: storeController.noArchive,
      metaNoSnippet: storeController.noSnippet,
      metaMaxSnippet: storeController.maxSnippet,
      metaMaxVideoPreview: storeController.maxVideoPreview,
      metaMaxImagePreview: storeController.maxImagePreview,
      metaMaxSnippetValue: _maxSnippetController.text.trim(),
      metaMaxVideoPreviewValue: _maxVideoPreviewController.text.trim(),
      metaMaxImagePreviewValue: storeController.imagePreviewSelectedType
    );

    _item.metaData = metaSeoData;
    _item.metaTitle = metaTitle;
    _item.metaDescription = metaDescription;
    _item.veg = storeController.isVeg ? 1 : 0;
    _item.isPrescriptionRequired = storeController.isPrescriptionRequired ? 1 : 0;
    _item.isHalal = storeController.isHalal ? 1 : 0;
    _item.isBasicMedicine = storeController.isBasicMedicine ? 1 : 0;
    _item.price = double.parse(price);
    _item.discount = double.parse(discount);
    _item.discountType = storeController.discountTypeIndex == 0 ? 'percent' : 'amount';
    _item.availableTimeStarts = storeController.availableTimeStarts;
    _item.availableTimeEnds = storeController.availableTimeEnds;
    _item.categoryIds = [];
    _item.maxOrderQuantity = maxOrderQuantity;
    _item.categoryIds!.add(CategoryIds(id: categoryController.selectedCategoryID));

    if (categoryController.selectedSubCategoryID != null) {
      _item.categoryIds!.add(CategoryIds(id: categoryController.selectedSubCategoryID));
    } else if (_item.categoryIds!.length > 1) {
      _item.categoryIds!.removeAt(1);
    }

    if (categoryController.selectedMyCategoryID != null) {
      _item.storeCategoryId = int.tryParse(categoryController.selectedMyCategoryID!);
      final match = categoryController.myCategories?.where(
        (c) => c.id.toString() == categoryController.selectedMyCategoryID
      );
      if (match != null && match.isNotEmpty) {
        _item.storeCategoryName = match.first.name;
      }
    }

    _item.addOns = [];
    for (final int index in storeController.selectedAddons!) {
      _item.addOns!.add(Get.find<AddonController>().addonList![index]);
    }

    if (_module!.unit! && storeController.unitList != null && storeController.unitList!.isNotEmpty) {
      _item.unitType = storeController.unitList![storeController.unitIndex!].id.toString();
    }

    if (_module.stock!) {
      _item.stock = int.parse(_stockController.text.trim());
    }

    if (vatTaxEnable) {
      _item.taxVatIds = [];
      _item.taxVatIds = storeController.selectedVatTaxIdList;
    }

    final List<Language> languages = _languageList ?? [];
    final List<Translation> translations = [];
    for (int index = 0; index < languages.length; index++) {
      translations.add(Translation(
        locale: languages[index].key,
        key: 'name',
        value: _nameControllerList[index].text.trim().isNotEmpty
            ? _nameControllerList[index].text.trim()
            : _nameControllerList[0].text.trim()
      ));
      translations.add(Translation(
        locale: languages[index].key,
        key: 'description',
        value: _descriptionControllerList[index].text.trim().isNotEmpty
            ? _descriptionControllerList[index].text.trim()
            : _descriptionControllerList[0].text.trim()
      ));
    }

    _item.translations = [];
    _item.translations!.addAll(translations);

    _item.brandId = storeController.brandList != null
            && storeController.brandList!.isNotEmpty
            && storeController.brandIndex != null
        ? storeController.brandList![storeController.brandIndex!].id
        : 0;
    _item.brandName = storeController.brandList != null
            && storeController.brandList!.isNotEmpty
            && storeController.brandIndex != null
        ? storeController.brandList![storeController.brandIndex!].name
        : null;
    _item.conditionId = storeController.suitableTagList != null
            && storeController.suitableTagList!.isNotEmpty
            && storeController.suitableTagIndex != null
        ? storeController.suitableTagList![storeController.suitableTagIndex!].id
        : 0;

    bool hasEmptyValue = false;
    if (_isNewVariationEnabled) {
      _item.foodVariations = [];
      for (final VariationModelBodyModel variation in storeController.variationList!) {
        if (variation.nameController!.text.trim().isEmpty) {
          hasEmptyValue = true;
          break;
        }

        final List<VariationValue> values = [];
        for (final Option option in variation.options!) {
          if (option.optionNameController!.text.trim().isEmpty || option.optionPriceController!.text.trim().isEmpty) {
            hasEmptyValue = true;
            break;
          }

          values.add(VariationValue(
            level: option.optionNameController!.text.trim(),
            optionPrice: option.optionPriceController!.text.trim()
          ));
        }

        if (hasEmptyValue) {
          break;
        }

        _item.foodVariations!.add(FoodVariation(
          name: variation.nameController!.text.trim(),
          type: variation.isSingle ? 'single' : 'multi',
          min: variation.minController!.text.trim(),
          max: variation.maxController!.text.trim(),
          required: variation.required ? 'on' : 'off',
          variationValues: values
        ));
      }
    }

    if (hasEmptyValue) {
      showCustomSnackBar('set_value_for_all_variation'.tr);
    } else {
      storeController.addItem(
        _item,
        widget.item == null,
        genericNameData: _genericNameSuggestionController.text.trim()
      );
    }
  }

  @override
  void dispose() {
    for(final controller in _nameControllerList) {
      controller.dispose();
    }
    for(final controller in _descriptionControllerList) {
      controller.dispose();
    }
    for(final node in _nameFocusList) {
      node.dispose();
    }
    for(final node in _descriptionFocusList) {
      node.dispose();
    }
    _tabController?.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _tagController.dispose();
    _maxOrderQuantityController.dispose();
    _genericNameSuggestionController.dispose();
    _priceNode.dispose();
    _discountNode.dispose();
    _metaTitleNode.dispose();
    _metaDescriptionNode.dispose();
    selectedSection.dispose();
    _sectionScrollController.dispose();
    _metaTitleController.dispose();
    _metaDescriptionController.dispose();
    _maxVideoPreviewController.dispose();
    _maxSnippetController.dispose();
    _productVideoLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: _update ? 'update_item'.tr : 'add_item'.tr),

      floatingActionButton: Get.find<SplashController>().configModel!.openAiStatus! ? Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          heroTag: 'add_item_fab',
          child: CustomAssetImageWidget(Images.useAi),
          onPressed: () {
            Get.bottomSheet(
              isScrollControlled: true, useRootNavigator: true,
              backgroundColor: Theme.of(context).cardColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge))
              ),
              AiGeneratorBottomSheet(
                languageList: _languageList,
                tabController: _tabController,
                nameControllerList: _nameControllerList,
                descriptionControllerList: _descriptionControllerList,
                priceController: _priceController,
                discountController: _discountController,
                stockController: _stockController,
                maxOrderQuantityController: _maxOrderQuantityController,
                onGeneratedDiscountTypeSelected: () {
                  if (mounted) {
                    setState(() {
                      _discountTypeSelected = true;
                    });
                  }
                },
                onImageDataApplied: () {
                  if (mounted) {
                    _moveToFurthestValidSection(
                      storeController: Get.find<StoreController>(),
                      categoryController: Get.find<CategoryController>()
                    );
                  }
                }
              )
            );
          }
        )
      ) : null,

      body: SafeArea(
        child: GetBuilder<CategoryController>(builder: (categoryController) {
          final bool showMyCategory = categoryController.isMyCategoryFeatureEnabled;
          return GetBuilder<AiController>(builder: (aiController) {
            return GetBuilder<StoreController>(builder: (storeController) {

              List<DropdownItem<int>> unitList = [];
              if(storeController.unitList != null) {
                for(int i = 0; i<storeController.unitList!.length; i++) {
                  unitList.add(DropdownItem<int>(value: i, child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(storeController.unitList![i].unit!)
                    )
                  )));
                }
              }

              List<DropdownItem<int>> categoryList = [];
              if(categoryController.categoryList != null) {
                for(int i=0; i<categoryController.categoryList!.length; i++) {
                  categoryList.add(DropdownItem<int>(value: i, child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(categoryController.categoryList![i].name!)
                    )
                  )));
                }
              }

              List<DropdownItem<int>> subCategoryList = [];
              if(categoryController.subCategoryList != null) {
                for(int i=0; i<categoryController.subCategoryList!.length; i++) {
                  subCategoryList.add(DropdownItem<int>(value: i, child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(categoryController.subCategoryList![i].name!)
                    )
                  )));
                }
              }

              List<DropdownItem<int>> suitableTagList = [];
              if(storeController.suitableTagList != null) {
                for(int i=0; i<storeController.suitableTagList!.length; i++) {
                  suitableTagList.add(DropdownItem<int>(value: i, child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(storeController.suitableTagList![i].name!)
                    )
                  )));
                }
              }

              List<DropdownItem<int>> brandList = [];
              if(storeController.brandList != null) {
                for(int i=0; i<storeController.brandList!.length; i++) {
                  brandList.add(DropdownItem<int>(value: i, child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(storeController.brandList![i].name!)
                    )
                  )));
                }
              }

              List<DropdownItem<int>> discountTypeList = [];
              for(int i=0; i<storeController.discountTypeList.length; i++) {
                discountTypeList.add(DropdownItem<int>(value: i, child: SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(storeController.discountTypeList[i]!.tr)
                  )
                )));
              }

              if(_module!.stock! && storeController.variantTypeList!.isNotEmpty) {
                final String totalStockText = storeController.totalStock.toString();
                if(_stockController.text != totalStockText) {
                  _stockController.text = totalStockText;
                }
              }

              List<int> nutritionSuggestion = [];
              if(storeController.nutritionSuggestionList != null) {
                for(int index = 0; index<storeController.nutritionSuggestionList!.length; index++) {
                  nutritionSuggestion.add(index);
                }
              }

              List<int> allergicIngredientsSuggestion = [];
              if(storeController.allergicIngredientsSuggestionList != null) {
                for(int index = 0; index<storeController.allergicIngredientsSuggestionList!.length; index++) {
                  allergicIngredientsSuggestion.add(index);
                }
              }

              List<int> genericNameSuggestion = [];
              if(storeController.genericNameSuggestionList != null) {
                for(int index = 0; index<storeController.genericNameSuggestionList!.length; index++) {
                  genericNameSuggestion.add(index);
                }
              }

              if(_update){
                if (storeController.vatTaxList != null && storeController.selectedVatTaxIdList.isEmpty && widget.item!.taxVatIds != null && widget.item!.taxVatIds!.isNotEmpty) {
                  storeController.preloadVatTax(vatTaxList: widget.item!.taxVatIds!);
                }
              }

              return (storeController.attributeList != null && categoryController.categoryList != null) || _update ? Column(children: [

                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: ValueListenableBuilder<int>(
                    valueListenable: selectedSection,
                    builder: (context, value, _) {
                      return AddItemSectionSelectorWidget(
                        sectionTitles: ['general_info'.tr, 'price_variation'.tr, 'other_setup'.tr],
                        selectedIndex: value,
                        onSelect: (int index) {
                          _changeSection(
                            targetIndex: index,
                            storeController: storeController,
                            categoryController: categoryController
                          );
                        }
                      );
                    }
                  )
                ),

                Expanded(child: SingleChildScrollView(
                  controller: _sectionScrollController,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: ValueListenableBuilder<int>(
                    valueListenable: selectedSection,
                    builder: (context, value, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if(value == 0) _GeneralInfoWidget(
                            aiController: aiController,
                            categoryController: categoryController,
                            storeController: storeController,
                            suitableTagList: suitableTagList,
                            nutritionSuggestion: nutritionSuggestion,
                            genericNameSuggestion: genericNameSuggestion,
                            brandList: brandList,
                            allergicIngredientsSuggestion: allergicIngredientsSuggestion,
                            module: _module,
                            showMyCategory: showMyCategory,
                            isFood: isFood,
                            isPharmacy: isPharmacy,
                            isEcommerce: isEcommerce,
                            isGrocery: isGrocery,
                            vatTaxEnable: vatTaxEnable,
                            tabController: _tabController,
                            tabs: _tabs,
                            languageList: _languageList,
                            nameControllerList: _nameControllerList,
                            descriptionControllerList: _descriptionControllerList,
                            nameFocusList: _nameFocusList,
                            descriptionFocusList: _descriptionFocusList,
                            priceController: _priceController,
                            discountController: _discountController,
                            stockController: _stockController,
                            maxOrderQuantityController: _maxOrderQuantityController,
                            genericNameSuggestionController: _genericNameSuggestionController,
                            aiTitleDescDebouncer: _aiTitleDescDebouncer,
                            aiOtherDataDebouncer: _aiOtherDataDebouncer,
                            thumbnailPickDebouncer: _thumbnailPickDebouncer,
                            item: widget.item,
                            currentItem: _item,
                            nutritionSuggestionText: _nutritionSuggestionText,
                            onNutritionSuggestionTextChanged: (value) => _nutritionSuggestionText = value,
                            allergicIngredientsSuggestionText: _allergicIngredientsSuggestionText,
                            onAllergicIngredientsSuggestionTextChanged: (value) => _allergicIngredientsSuggestionText = value,
                            setState: setState,
                            setDiscountTypeSelected: (value) => _discountTypeSelected = value
                          ),
                          if(value == 1) _PriceAndVariationWidget(
                            aiController: aiController,
                            storeController: storeController,
                            discountTypeList: discountTypeList,
                            module: _module,
                            unitList: unitList,
                            priceController: _priceController,
                            priceNode: _priceNode,
                            discountNode: _discountNode,
                            discountController: _discountController,
                            maxOrderQuantityController: _maxOrderQuantityController,
                            stockController: _stockController,
                            setDiscountTypeSelected: (value) => _discountTypeSelected = value,
                            validateDiscount: _validateDiscount,
                            item: widget.item,
                            nameControllerList: _nameControllerList,
                            descriptionControllerList: _descriptionControllerList,
                            aiVariationDebouncer: _aiVariationDebouncer,
                            onAddonControllerCreated: (controller) => _addonController = controller,
                            clearAddonController: () => _addonController?.clear()
                          ),
                          if(value == 2) _OtherSetupWidget(
                            aiController: aiController,
                            storeController: storeController,
                            module: _module,
                            tagController: _tagController,
                            additionalImagesPickDebouncer: _additionalImagesPickDebouncer,
                            videoWidgetKey: _videoWidgetKey,
                            currentItem: _item,
                            isEcommerce: isEcommerce,
                            metaTitleController: _metaTitleController,
                            metaTitleNode: _metaTitleNode,
                            metaDescriptionController: _metaDescriptionController,
                            metaDescriptionNode: _metaDescriptionNode,
                            metaImagePickDebouncer: _metaImagePickDebouncer,
                            maxSnippetController: _maxSnippetController,
                            maxVideoPreviewController: _maxVideoPreviewController
                          ),
                        ]
                      );
                    }
                  )
                )),

                // button
                Container(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 5)]
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButtonWidget(
                          buttonText: 'reset'.tr,
                          onPressed: () => _resetDebouncer.run(() => _resetCurrentStep(
                            storeController: storeController,
                            categoryController: categoryController
                          )),
                          textColor: Theme.of(context).disabledColor,
                          color: Theme.of(context).disabledColor.withAlpha(20),
                          borderColor: Theme.of(context).disabledColor.withAlpha(100),
                          isBorder: true
                        )
                      ),
                      SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: ValueListenableBuilder<int>(
                          valueListenable: selectedSection,
                          builder: (context, value, _) {
                            return CustomButtonWidget(
                              buttonText: value == 2 ? (_update ? 'update'.tr : 'submit'.tr) : 'next'.tr,
                              isLoading: value == 2 && storeController.isLoading,
                              onPressed: () => _handlePrimaryAction(
                                storeController: storeController,
                                categoryController: categoryController
                              )
                            );
                          }
                        )
                      ),
                    ]
                  )
                ),

              ]) : const Center(child: CircularProgressIndicator());
            });
          });
        })
      )
    );
  }
}

class _InvalidImageView extends StatelessWidget {
  const _InvalidImageView();

  String get _maxFileSizeText {
    final double maxFileSize = Get.find<SplashController>().configModel!.validationConfig!.maxFileSize;
    if(maxFileSize % 1 == 0) {
      return maxFileSize.toInt().toString();
    }
    return maxFileSize.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Get.theme.colorScheme.error, width: 1)
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline, color: Get.theme.colorScheme.error, size: 28),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            '${'max_size'.tr} $_maxFileSizeText MB',
            style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeExtraSmall),
            textAlign: TextAlign.center
          ),
        ])
      )
    );
  }
}

class _PriceAndVariationWidget extends StatelessWidget {
  const _PriceAndVariationWidget({
    required this.aiController,
    required this.storeController,
    required this.discountTypeList,
    required this.module,
    required this.unitList,
    required TextEditingController priceController,
    required FocusNode priceNode,
    required FocusNode discountNode,
    required TextEditingController discountController,
    required TextEditingController maxOrderQuantityController,
    required TextEditingController stockController,
    required this.setDiscountTypeSelected,
    required this.validateDiscount,
    required this.item,
    required List<TextEditingController> nameControllerList,
    required List<TextEditingController> descriptionControllerList,
    required Debouncer aiVariationDebouncer,
    required this.onAddonControllerCreated,
    required this.clearAddonController,
  }) : _priceController = priceController,
       _priceNode = priceNode,
       _discountNode = discountNode,
       _discountController = discountController,
       _maxOrderQuantityController = maxOrderQuantityController,
       _stockController = stockController,
       _nameControllerList = nameControllerList,
       _descriptionControllerList = descriptionControllerList,
       _aiVariationDebouncer = aiVariationDebouncer;

  final AiController aiController;
  final StoreController storeController;
  final List<DropdownItem<int>> discountTypeList;
  final Module module;
  final List<DropdownItem<int>> unitList;
  final TextEditingController _priceController;
  final FocusNode _priceNode;
  final FocusNode _discountNode;
  final TextEditingController _discountController;
  final TextEditingController _maxOrderQuantityController;
  final TextEditingController _stockController;
  final ValueChanged<bool> setDiscountTypeSelected;
  final VoidCallback validateDiscount;
  final Item? item;
  final List<TextEditingController> _nameControllerList;
  final List<TextEditingController> _descriptionControllerList;
  final Debouncer _aiVariationDebouncer;
  final ValueChanged<TextEditingController> onAddonControllerCreated;
  final VoidCallback clearAddonController;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        // price and other info
        AnimatedBorderContainer(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          isLoading: aiController.otherDataLoading,
          child: AddItemSectionHeaderWidget(
            title: 'price_other_info'.tr,
            isRequired: true,
            subTitle: "price_setup".tr,
            child: Column(children: [
              CustomTextFieldWidget(
                required: true,
                hintText: 'price'.tr,
                labelText: 'price'.tr,
                controller: _priceController,
                focusNode: _priceNode,
                nextFocus: _discountNode,
                isAmount: true
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5))
                ),
                child: CustomDropdown(
                  icon: Icon(Icons.arrow_drop_down),
                  onChange: (int? value, int index) {
                    storeController.setDiscountTypeIndex(value!, true);
                    setDiscountTypeSelected(true);
                    validateDiscount();
                  },
                  dropdownButtonStyle: DropdownButtonStyle(
                    height: 45,
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                    primaryColor: Theme.of(context).textTheme.bodyLarge!.color
                  ),
                  iconColor: Theme.of(context).disabledColor,
                  dropdownStyle: DropdownStyle(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall)
                  ),
                  items: discountTypeList,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Text(storeController.discountTypeList[storeController.discountTypeIndex]!.tr,
                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)
                    )
                  )
                )
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              CustomTextFieldWidget(
                required: true,
                hintText: 'discount'.tr,
                labelText: 'discount'.tr,
                controller: _discountController,
                focusNode: _discountNode,
                isAmount: true,
                onChanged: (value) => validateDiscount()
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              CustomTextFieldWidget(
                hintText: 'maximum_order_quantity'.tr,
                labelText: 'maximum_order_quantity'.tr,
                controller: _maxOrderQuantityController,
                isNumber: true
              ),
              SizedBox(height: (module.stock! || module.unit!) ? Dimensions.paddingSizeExtraLarge : 0),

              module.stock! ? CustomTextFieldWidget(
                hintText: 'total_stock'.tr,
                labelText: 'total_stock'.tr,
                controller: _stockController,
                isNumber: true,
                isEnabled: storeController.variantTypeList!.isEmpty
              ) : const SizedBox(),
              SizedBox(height: module.stock! ? Dimensions.paddingSizeExtraLarge : 0),

              module.unit! ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5))
                ),
                child: CustomDropdown(
                  onChange: (int? value, int index) {
                    storeController.setUnitIndex(value!, true);
                  },
                  dropdownButtonStyle: DropdownButtonStyle(
                    height: 45,
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeExtraSmall,
                      horizontal: Dimensions.paddingSizeExtraSmall
                    ),
                    primaryColor: Theme.of(context).textTheme.bodyLarge!.color
                  ),
                  iconColor: Theme.of(context).disabledColor,
                  icon: Icon(Icons.arrow_drop_down),
                  dropdownStyle: DropdownStyle(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall)
                  ),
                  items: unitList,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      item != null && storeController.unitList != null && storeController.unitList!.isNotEmpty ? storeController.unitList![storeController.unitIndex!].unit!.tr : 'unit'.tr,
                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeLarge)
                    )
                  )
                )

              ) : const SizedBox(),
              SizedBox(height: module.unit! ? Dimensions.paddingSizeSmall : 0),

            ])
          )
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // attributes
        AnimatedBorderContainer(
          isLoading: aiController.variationDataLoading,
          child: AddItemSectionHeaderWidget(
            subTitle: 'item_variation_setup'.tr,
            showAction: Get.find<SplashController>().configModel!.openAiStatus!,
            onTap: () => _aiVariationDebouncer.run(() {
              if(_nameControllerList[0].text.isEmpty) {
                showCustomSnackBar('food_name_required_for_en'.tr);
              }else if(_descriptionControllerList[0].text.isEmpty){
                 showCustomSnackBar('description_required'.tr);
              }else{
                if(Get.find<SplashController>().getStoreModuleConfig().newVariation!){
                  storeController.generateAndSetVariationData(
                  title: _nameControllerList[0].text.trim(),
                  description: _descriptionControllerList[0].text.trim()
                  );
                }else{
                  storeController.generateAndSetAttributeData(
                  title: _nameControllerList[0].text.trim(),
                  description: _descriptionControllerList[0].text.trim()
                  );
                }
              }
            }),
            title: Get.find<SplashController>().getStoreModuleConfig().newVariation! ? "${'food_variation'.tr} ${'optional'.tr}" : 'attribute'.tr,
              child: Get.find<SplashController>().getStoreModuleConfig().newVariation! ? FoodVariationViewWidget(
                storeController: storeController, item: item
                ) : AttributeViewWidget(storeController: storeController, product: item)
          )
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // add ons
        if(module.addOn!) AnimatedBorderContainer(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          isLoading: aiController.otherDataLoading,
          child: AddItemSectionHeaderWidget(
            title: 'addons'.tr,
            child: Column(
            children: [
              module.addOn! ? GetBuilder<AddonController>(builder: (addonController) {
                List<int> addons = [];
                if(addonController.addonList != null) {
                  for(int index=0; index<addonController.addonList!.length; index++) {
                    if(addonController.addonList![index].status == 1 && !storeController.selectedAddons!.contains(index)) {
                      addons.add(index);
                    }
                  }
                }
                return Autocomplete<int>(
                  optionsBuilder: (TextEditingValue value) {
                    if(value.text.isEmpty) {
                      return const Iterable<int>.empty();
                    }else {
                      return addons.where((addon) => addonController.addonList![addon].name!.toLowerCase().contains(value.text.toLowerCase()));
                    }
                  },
                  fieldViewBuilder: (context, controller, node, onComplete) {
                    onAddonControllerCreated(controller);
                    return SizedBox(
                      height: 50,
                      child: CustomTextFieldWidget(
                        controller: controller,
                        focusNode: node,
                        hintText: 'addons'.tr,
                        labelText: 'addons'.tr,
                        onEditingComplete: () {
                          onComplete();
                          controller.text = '';
                        }
                      )
                    );
                  },
                  displayStringForOption: (value) => addonController.addonList![value].name!,
                  onSelected: (int value) {
                    clearAddonController();
                    storeController.setSelectedAddonIndex(value, true);
                    //_addons.removeAt(value);
                  }
                );
              }) : const SizedBox(),
              SizedBox(height: (module.addOn! && storeController.selectedAddons!.isNotEmpty) ? Dimensions.paddingSizeSmall : 0),

              module.addOn! ? SizedBox(
                height: storeController.selectedAddons!.isNotEmpty ? 40 : 0,
                child: ListView.builder(
                  itemCount: storeController.selectedAddons!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall)
                      ),
                      child: Row(children: [
                        GetBuilder<AddonController>(builder: (addonController) {
                          return Text(
                            addonController.addonList![storeController.selectedAddons![index]].name!,
                            style: robotoRegular.copyWith(color: Theme.of(context).disabledColor.withValues(alpha: 0.7))
                          );
                        }),
                        InkWell(
                          onTap: () => storeController.removeAddon(index),
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            child: Icon(Icons.close, size: 15, color: Theme.of(context).disabledColor.withValues(alpha: 0.7))
                          )
                        ),
                      ])
                    );
                  }
                )
              ) : const SizedBox(),
            ]
          )
          )
        )

      ]
    );
  }
}

class _OtherSetupWidget extends StatelessWidget {
  const _OtherSetupWidget({
    required this.aiController,
    required this.storeController,
    required this.module,
    required TextEditingController tagController,
    required Debouncer additionalImagesPickDebouncer,
    required this.videoWidgetKey,
    required Item currentItem,
    required this.isEcommerce,
    required TextEditingController metaTitleController,
    required FocusNode metaTitleNode,
    required TextEditingController metaDescriptionController,
    required FocusNode metaDescriptionNode,
    required Debouncer metaImagePickDebouncer,
    required TextEditingController maxSnippetController,
    required TextEditingController maxVideoPreviewController,
  }) : _tagController = tagController,
       _additionalImagesPickDebouncer = additionalImagesPickDebouncer,
       _item = currentItem,
       _metaTitleController = metaTitleController,
       _metaTitleNode = metaTitleNode,
       _metaDescriptionController = metaDescriptionController,
       _metaDescriptionNode = metaDescriptionNode,
       _metaImagePickDebouncer = metaImagePickDebouncer,
       _maxSnippetController = maxSnippetController,
       _maxVideoPreviewController = maxVideoPreviewController;

  final AiController aiController;
  final StoreController storeController;
  final Module module;
  final TextEditingController _tagController;
  final Debouncer _additionalImagesPickDebouncer;
  final int videoWidgetKey;
  final Item _item;
  final bool isEcommerce;
  final TextEditingController _metaTitleController;
  final FocusNode _metaTitleNode;
  final TextEditingController _metaDescriptionController;
  final FocusNode _metaDescriptionNode;
  final Debouncer _metaImagePickDebouncer;
  final TextEditingController _maxSnippetController;
  final TextEditingController _maxVideoPreviewController;

  String get _maxFileSizeText {
    final double maxFileSize = Get.find<SplashController>().configModel!.validationConfig!.maxFileSize;
    if(maxFileSize % 1 == 0) {
      return maxFileSize.toInt().toString();
    }
    return maxFileSize.toString();
  }

  @override
  Widget build(BuildContext context) {
     return Column(
      children: [

        // tag
        AnimatedBorderContainer(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          isLoading: aiController.otherDataLoading,
          child: AddItemSectionHeaderWidget(
            title: 'tag'.tr,
            subTitle: 'item_tag_setup'.tr,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(children: [

                Expanded(
                  flex: 8,
                  child: CustomTextFieldWidget(
                    hintText: 'tag'.tr,
                    labelText: 'tag'.tr,
                    controller: _tagController,
                    inputAction: TextInputAction.done,
                    onSubmit: (name){
                      if(name != null && name.isNotEmpty) {
                        storeController.setTag(name);
                        _tagController.text = '';
                      }
                    }
                  )
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  flex: 2,
                  child: CustomButtonWidget(buttonText: 'add'.tr, onPressed: (){
                    if(_tagController.text != '' && _tagController.text.isNotEmpty) {
                      storeController.setTag(_tagController.text.trim());
                      _tagController.text = '';
                    }
                  })
                ),

              ]),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              storeController.tagList.isNotEmpty ? SizedBox(
                height: 40,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: storeController.tagList.length,
                    itemBuilder: (context, index){
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                        child: Center(child: Row(children: [
                          Text(storeController.tagList[index]!, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor.withValues(alpha: 0.7))),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          InkWell(onTap: () => storeController.removeTag(index), child: Icon(Icons.clear, size: 18, color: Theme.of(context).disabledColor.withValues(alpha: 0.7))),
                        ]))
                      );
                    })
              ) : const SizedBox(),
            ])
          )
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Item Image Section
        AnimatedBorderContainer(
          isLoading: false,
          child: Column(
            children: [
              AddItemSectionHeaderWidget(
                title: 'additional_images'.tr,
                subTitle: 'thumbnail_image_format'.trParams({'size' : _maxFileSizeText}),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: storeController.savedImages.length + storeController.rawImages.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: Dimensions.paddingSizeSmall,
                    mainAxisSpacing: Dimensions.paddingSizeSmall,
                    childAspectRatio: 1
                  ),
                  itemBuilder: (context, index) {
                      final bool isSavedImage = index < storeController.savedImages.length;
                      final int rawImageIndex = index - storeController.savedImages.length;
                      final bool isAddButton = index == storeController.savedImages.length + storeController.rawImages.length;

                      if(isAddButton) {
                        return InkWell(
                          onTap: () => _additionalImagesPickDebouncer.run(() => storeController.pickImages()),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          child: DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              radius: const Radius.circular(Dimensions.radiusDefault),
                              dashPattern: const [8, 4],
                              strokeWidth: 1,
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.5)
                            ),
                            child: Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Get.isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.photo_camera_solid,
                                    color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                                    size: 28
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),
                                  Text(
                                    'click_to_upload'.tr,
                                    textAlign: TextAlign.center,
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).disabledColor
                                    )
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                  Text(
                                    '${storeController.savedImages.length + storeController.rawImages.length}/${Get.find<SplashController>().configModel!.validationConfig!.maxUploadFileCount}',
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).primaryColor
                                    )
                                  ),
                                ]
                              )
                            )
                          )
                        );
                      }

                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: isSavedImage ? CustomImageWidget(
                              image: storeController.savedImages[index],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover
                            ) : Image.file(
                              File(storeController.rawImages[rawImageIndex].path),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover
                            )
                          ),

                          if(!isSavedImage && !storeController.isAdditionalImageValid(rawImageIndex)) const _InvalidImageView(),

                          Positioned(
                            right: 8,
                            top: 8,
                            child: InkWell(
                              onTap: () => isSavedImage
                                  ? storeController.removeSavedImage(index)
                                  : storeController.removeImage(rawImageIndex),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor.withValues(alpha: 0.9),
                                  shape: BoxShape.circle
                                ),
                                child: Icon(
                                  Icons.delete_forever,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.error
                                )
                              )
                            )
                          ),
                        ]
                      );
                    }
                  )
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault)
            ]
          )
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // product video
        ProductVideoWidget(key: ValueKey(videoWidgetKey), storeController: storeController, item: _item),

        // meta
        isEcommerce ?
        Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text('meta_data'.tr, style: robotoBold),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text('meta_data_des'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomCard(width: context.width, padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextFieldWidget(
                hintText: 'title'.tr,
                labelText: 'title'.tr,
                controller: _metaTitleController,
                capitalization: TextCapitalization.words,
                focusNode: _metaTitleNode,
                nextFocus: _metaDescriptionNode,
                showTitle: false,
                required: true
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              CustomTextFieldWidget(
                hintText: 'meta_description'.tr,
                labelText: 'description'.tr,
                controller: _metaDescriptionController,
                focusNode: _metaDescriptionNode,
                capitalization: TextCapitalization.sentences,
                maxLines: 5,
                inputAction: TextInputAction.done,
                nextFocus:  null,
                showTitle: false,
                required: true
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('meta_image'.tr, style: robotoMedium.copyWith(fontWeight: FontWeight.w600)),
                Text('image_format_and_ratio_for_business_logo'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Stack(clipBehavior: Clip.none, children: [

                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: storeController.pickedMetaImage != null ?
                      Image.file(File(storeController.pickedMetaImage!.path), width: double.infinity, height: 150, fit: BoxFit.cover)
                          : _item.metaImageFullUrl != null ?
                      CustomImageWidget(image: _item.metaImageFullUrl ?? '', height: 150, width: double.infinity, fit: BoxFit.cover)
                          : SizedBox(height: 150, width: double.infinity, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(CupertinoIcons.photo_camera_solid, color: Theme.of(context).disabledColor.withValues(alpha: 0.5), size: 30),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        Text('click_to_upload'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                      ])
                      )
                    )
                  ),

                  if(storeController.pickedMetaImage != null && !storeController.isMetaImageValid) const _InvalidImageView(),

                  Positioned(bottom: 0, right: 0, top: 0, left: 0,
                    child: InkWell(
                      onTap: () => _metaImagePickDebouncer.run(() => storeController.pickMetaImage()),
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: const Radius.circular(Dimensions.radiusDefault),
                          dashPattern: const [8, 4],
                          strokeWidth: 1,
                          color: Theme.of(context).hintColor
                        ),
                        child: const SizedBox(width: 120, height: 120)
                      )
                    )
                  ),

                  Positioned(
                    top: -10, right: -10,
                    child: InkWell(
                      onTap: () => _metaImagePickDebouncer.run(() => storeController.pickMetaImage()),
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 5)],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 0.5)
                        ),
                        child: const Icon(Icons.edit, color: Colors.blue, size: 16)
                      )
                    )
                  ),
                ]),
              ]),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Container(
                width: double.infinity, padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                ),
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    InkWell(
                      onTap: () {
                        storeController.setMetaIndex('index');
                        storeController.setNoFollow('0');
                        storeController.setNoImageIndex('0');
                        storeController.setNoArchive('0');
                        storeController.setNoSnippet('0');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall  + 2),
                          SizedBox(
                            height: 20, width: 20,
                            child: RadioGroup<String>(
                              groupValue: storeController.metaIndex,
                              onChanged: (value) {
                                storeController.setMetaIndex(value!);
                                storeController.setNoFollow('0');
                                storeController.setNoImageIndex('0');
                                storeController.setNoArchive('0');
                                storeController.setNoSnippet('0');
                              },
                              child: Radio<String>(value: 'index')
                            )
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Text('index'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,  color: Theme.of(context).textTheme.bodyLarge?.color)),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          CustomToolTip(
                            message: 'allow_search_engines_to_index_this_page'.tr,
                            size: 16
                          ),
                        ]
                      )
                    ),
                    SizedBox(height: Dimensions.paddingSizeSmall),

                    MetaSeoItem(
                      title: 'no_follow'.tr,
                      value: storeController.noFollow == 'nofollow' ? true : false,
                      callback: (bool? value){
                        storeController.setNoFollow(value! ? 'nofollow' : '0');
                      },
                      message: 'instruct_search_engines_not_to_follow_links_from_this_page'.tr
                    ),

                    MetaSeoItem(
                      title: 'no_image_index'.tr,
                      value: storeController.noImageIndex == 'noimageindex' ? true : false,
                      callback: (bool? value){
                        storeController.setNoImageIndex(value! ? 'noimageindex' : '0');
                      },
                      message: 'prevent_images_from_being_indexed'.tr
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    InkWell(
                      onTap: () {
                        storeController.setMetaIndex('noindex');
                        storeController.setNoFollow('nofollow');
                        storeController.setNoImageIndex('noimageindex');
                        storeController.setNoArchive('noarchive');
                        storeController.setNoSnippet('nosnippet');
                      },
                      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, children: [
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall  + 2),
                        SizedBox(
                          height: 20, width: 20,
                          child: RadioGroup<String>(
                            groupValue: storeController.metaIndex,
                            onChanged: (value) {
                              storeController.setMetaIndex(value!);
                              storeController.setNoFollow('nofollow');
                              storeController.setNoImageIndex('noimageindex');
                              storeController.setNoArchive('noarchive');
                              storeController.setNoSnippet('nosnippet');
                            },
                            child: Radio<String>(value: 'noindex')
                          )
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Text('no_index'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,  color: Theme.of(context).textTheme.bodyLarge?.color)),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        CustomToolTip(
                          message: 'disallow_search_engines_from_indexing_this_page'.tr,
                          size: 16
                        ),
                      ])
                    ),
                    SizedBox(height: Dimensions.paddingSizeSmall),

                    MetaSeoItem(
                      title: 'no_archive'.tr,
                      value: storeController.noArchive == 'noarchive' ? true : false,
                      callback: (bool? value){
                        storeController.setNoArchive(value! ? 'noarchive' : '0');
                      },
                      message: 'prevent_search_engines_from_caching_this_page'.tr
                    ),

                    MetaSeoItem(
                      title: 'no_snippet'.tr,
                      value: storeController.noSnippet == 'nosnippet' ? true : false,
                      callback: (bool? value){
                        storeController.setNoSnippet(value! ? 'nosnippet' : '0');
                      },
                      message: 'prevent_search_engines_from_showing_snippet'.tr
                    ),

                  ])
                )
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Container(
                width: double.infinity, padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                ),
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                  child: Row(children: [
                    Expanded(flex: 3,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        MetaSeoItem(
                          title: 'max_snippet'.tr,
                          value: storeController.maxSnippet == '1' ? true : false,
                          callback: (bool? value){
                            storeController.setMaxSnippet(value! ? '1' : '0');
                          }
                        ),
                        SizedBox(height: Dimensions.paddingSizeSmall),
                        MetaSeoItem(
                          title: 'max_video_preview'.tr,
                          value: storeController.maxVideoPreview == '1' ? true : false,
                          callback: (bool? value){
                            storeController.setMaxVideoPreview(value! ? '1' : '0');
                          }
                        ),
                        SizedBox(height: Dimensions.paddingSizeSmall),
                        MetaSeoItem(
                          title: 'max_image_preview'.tr,
                          value: storeController.maxImagePreview == '1' ? true : false,
                          callback: (bool? value){
                            storeController.setMaxImagePreview(value! ? '1' : '0');
                          }
                        ),
                      ])
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    Expanded(
                      flex: 2,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(
                          height: 48,
                          child: CustomTextFieldWidget(
                            hintText: 'ex_1'.tr,
                            showLabelText: false,
                            inputType: TextInputType.number,
                            controller: _maxSnippetController
                          )
                        ),
                        SizedBox(height: Dimensions.paddingSizeSmall),

                        SizedBox(
                          height: 48,
                          child: CustomTextFieldWidget(
                            hintText: 'ex_1'.tr,
                            showLabelText: false,
                            inputType: TextInputType.number,
                            controller: _maxVideoPreviewController
                          )
                        ),
                        SizedBox(height: Dimensions.paddingSizeSmall),

                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).disabledColor),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                          ),
                          child: DropdownButton<String>(
                            icon: Icon(Icons.arrow_drop_down),
                            value: storeController.imagePreviewSelectedType,
                            items: storeController.imagePreviewType.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color))
                              );
                            }).toList(),
                            onChanged: (value) {
                              storeController.setImagePreviewType(value!);
                            },
                            isExpanded: true,
                            underline: const SizedBox()
                          )
                        ),

                      ])
                    ),

                  ])
                )
              ),
            ])
          ),
        ]
        ) : SizedBox.shrink(),
        const SizedBox(height: Dimensions.paddingSizeDefault),



        module.itemAvailableTime! ? Text('availability'.tr, style: robotoBold) : const SizedBox(),
        SizedBox(height: module.itemAvailableTime! ? Dimensions.paddingSizeSmall : 0),

        module.itemAvailableTime! ? AnimatedBorderContainer(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
          isLoading: aiController.otherDataLoading,
          child: Column(children: [

            CustomTimePickerWidget(
              title: '${'available_time_starts'.tr} *', time: storeController.availableTimeStarts,
              onTimeChanged: (time) {
                storeController.setAvailableTimeStarts(startTime: time);
              }
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            CustomTimePickerWidget(
              title: '${'available_time_ends'.tr} *', time: storeController.availableTimeEnds,
              onTimeChanged: (time) {
                storeController.setAvailableTimeEnds(endTime: time);
              }
            ),

          ])
        ) : const SizedBox(),
        SizedBox(height: module.itemAvailableTime! ? Dimensions.paddingSizeDefault : 0),

      ]
    );
  }
}

class _GeneralInfoWidget extends StatelessWidget {
  const _GeneralInfoWidget({
    required this.aiController,
    required this.categoryController,
    required this.storeController,
    required this.suitableTagList,
    required this.nutritionSuggestion,
    required this.genericNameSuggestion,
    required this.brandList,
    required this.allergicIngredientsSuggestion,
    required this.module,
    required this.showMyCategory,
    required this.isFood,
    required this.isPharmacy,
    required this.isEcommerce,
    required this.isGrocery,
    required this.vatTaxEnable,
    required TabController? tabController,
    required List<Tab> tabs,
    required List<Language>? languageList,
    required List<TextEditingController> nameControllerList,
    required List<TextEditingController> descriptionControllerList,
    required List<FocusNode> nameFocusList,
    required List<FocusNode> descriptionFocusList,
    required TextEditingController priceController,
    required TextEditingController discountController,
    required TextEditingController stockController,
    required TextEditingController maxOrderQuantityController,
    required TextEditingController genericNameSuggestionController,
    required Debouncer aiTitleDescDebouncer,
    required Debouncer aiOtherDataDebouncer,
    required Debouncer thumbnailPickDebouncer,
    required this.item,
    required Item currentItem,
    required String nutritionSuggestionText,
    required this.onNutritionSuggestionTextChanged,
    required String allergicIngredientsSuggestionText,
    required this.onAllergicIngredientsSuggestionTextChanged,
    required this.setState,
    required this.setDiscountTypeSelected,
  }) : _tabController = tabController,
       _tabs = tabs,
       _languageList = languageList,
       _nameControllerList = nameControllerList,
       _descriptionControllerList = descriptionControllerList,
       _nameFocusList = nameFocusList,
       _descriptionFocusList = descriptionFocusList,
       _priceController = priceController,
       _discountController = discountController,
       _stockController = stockController,
       _maxOrderQuantityController = maxOrderQuantityController,
       _genericNameSuggestionController = genericNameSuggestionController,
       _aiTitleDescDebouncer = aiTitleDescDebouncer,
       _aiOtherDataDebouncer = aiOtherDataDebouncer,
       _thumbnailPickDebouncer = thumbnailPickDebouncer,
       _item = currentItem,
       _nutritionSuggestionText = nutritionSuggestionText,
       _allergicIngredientsSuggestionText = allergicIngredientsSuggestionText;

  final AiController aiController;
  final CategoryController categoryController;
  final StoreController storeController;
  final List<DropdownItem<int>> suitableTagList;
  final List<int> nutritionSuggestion;
  final List<int> genericNameSuggestion;
  final List<DropdownItem<int>> brandList;
  final List<int> allergicIngredientsSuggestion;
  final Module module;
  final bool showMyCategory;
  final bool isFood;
  final bool isPharmacy;
  final bool isEcommerce;
  final bool isGrocery;
  final bool vatTaxEnable;
  final TabController? _tabController;
  final List<Tab> _tabs;
  final List<Language>? _languageList;
  final List<TextEditingController> _nameControllerList;
  final List<TextEditingController> _descriptionControllerList;
  final List<FocusNode> _nameFocusList;
  final List<FocusNode> _descriptionFocusList;
  final TextEditingController _priceController;
  final TextEditingController _discountController;
  final TextEditingController _stockController;
  final TextEditingController _maxOrderQuantityController;
  final TextEditingController _genericNameSuggestionController;
  final Debouncer _aiTitleDescDebouncer;
  final Debouncer _aiOtherDataDebouncer;
  final Debouncer _thumbnailPickDebouncer;
  final Item? item;
  final Item _item;
  final String _nutritionSuggestionText;
  final ValueChanged<String> onNutritionSuggestionTextChanged;
  final String _allergicIngredientsSuggestionText;
  final ValueChanged<String> onAllergicIngredientsSuggestionTextChanged;
  final void Function(VoidCallback fn) setState;
  final ValueChanged<bool> setDiscountTypeSelected;

  String get _maxFileSizeText {
    final double maxFileSize = Get.find<SplashController>().configModel!.validationConfig!.maxFileSize;
    if(maxFileSize % 1 == 0) {
      return maxFileSize.toInt().toString();
    }
    return maxFileSize.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // basic info
        AnimatedBorderContainer(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          isLoading: aiController.titleLoading,
          child: AddItemSectionHeaderWidget(
            title: 'basic_info'.tr,
            subTitle: isFood ? "food_info_setup".tr : null,
            showAction: Get.find<SplashController>().configModel!.openAiStatus!,
            onTap: () => _aiTitleDescDebouncer.run(() {
              if(_nameControllerList[_tabController!.index].text.isEmpty) {
                showCustomSnackBar('item_name_required'.tr);
              }else{
                aiController.generateTitleAndDes(
                  title: _nameControllerList[_tabController!.index].text.trim(),
                  langCode: _languageList[_tabController!.index].key!
                ).then((value) {
                  if(aiController.titleDesModel != null){
                    _nameControllerList[_tabController!.index].text = aiController.titleDesModel!.title ?? '';
                    _descriptionControllerList[_tabController!.index].text = aiController.titleDesModel!.description ?? '';
                  }
                });
              }
            }),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color:  Theme.of(context).disabledColor.withAlpha(20)
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                SizedBox(
                  height: 40,
                  child: TabBar(
                    tabAlignment: TabAlignment.start,
                    controller: _tabController,
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorWeight: 3,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Theme.of(context).disabledColor,
                    unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                    labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
                    labelPadding: const EdgeInsets.only(right: Dimensions.radiusDefault),
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: _tabs,
                    onTap: (int ? value) {
                      setState(() {});
                    }
                  )
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                  child: Divider(height: 0)
                ),

                Text('insert_language_wise_item_name_and_description'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                const SizedBox(height: Dimensions.paddingSizeLarge),


                AiGenerateWrapper(
                  showAction: false,
                  child: CustomTextFieldWidget(
                    required: true,
                    hintText: 'name'.tr,
                    labelText: "${'name'.tr} (Default)",
                    controller: _nameControllerList[_tabController!.index],
                    capitalization: TextCapitalization.words,
                    focusNode: _nameFocusList[_tabController!.index],
                    nextFocus: _tabController!.index != _languageList!.length-1 ? _descriptionFocusList[_tabController!.index] : _descriptionFocusList[0],
                    showTitle: false
                  )
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                AiGenerateWrapper(
                  showAction: false,
                  child: CustomTextFieldWidget(
                    required: true,
                    hintText: 'description'.tr,
                    labelText: 'description'.tr,
                    controller: _descriptionControllerList[_tabController!.index],
                    focusNode: _descriptionFocusList[_tabController!.index],
                    capitalization: TextCapitalization.sentences,
                    maxLines: 3,
                    inputAction: _tabController!.index != _languageList.length-1 ? TextInputAction.next : TextInputAction.done,
                    nextFocus: _tabController!.index != _languageList.length-1 ? _nameFocusList[_tabController!.index + 1] : null,
                    showTitle: false,
                    maxLength: 3000
                  )
                ),

              ])
            )
          )
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // is prescription required
        if(isPharmacy) ...[
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedBorderContainer(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              isLoading: aiController.otherDataLoading,
              child: AiGenerateWrapper(
                title: 'prescription_required'.tr,
                showAction: false,
                child: ListTile(
                  onTap: () => storeController.togglePrescriptionRequired(),
                  leading: Checkbox(
                    activeColor: Theme.of(context).primaryColor,
                    value: storeController.isPrescriptionRequired,
                    onChanged: (bool? isChecked) => storeController.togglePrescriptionRequired()
                  ),
                  title: Text('this_item_need_prescription_to_place_order'.tr, style: robotoMedium),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  horizontalTitleGap: 0
                )
              )
            ),

            SizedBox(height: Dimensions.paddingSizeDefault),
          ])
        ],

        // General info
        AnimatedBorderContainer(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          isLoading: aiController.otherDataLoading,
          child:  AddItemSectionHeaderWidget(
            title: "general_info".tr,
            subTitle: isFood ? "food_info_setup".tr : null,
            isLoading: aiController.otherDataLoading,
            showAction: Get.find<SplashController>().configModel!.openAiStatus!,
            onTap: () => _aiOtherDataDebouncer.run(() {
              if(_nameControllerList[0].text.isEmpty) {
                showCustomSnackBar('food_name_required_for_en'.tr);
              }else if(_descriptionControllerList[0].text.isEmpty){
                showCustomSnackBar('description_required'.tr);
              }else{
                setState(() {
                  setDiscountTypeSelected(true);
                });
                storeController.generateAndSetOtherData(
                  title: _nameControllerList[0].text.trim(),
                  description: _descriptionControllerList[0].text.trim(),
                  priceController: _priceController,
                  discountController: _discountController,
                  stockController: _stockController,
                  maxOrderQuantityController: _maxOrderQuantityController
                );
              }
            }),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              CustomDropdownButton(
                dropdownMenuItems: categoryController.categoryList?.map((item) => DropdownMenuItem<String>(
                  value: item.id.toString(),
                  child: Text(item.name ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault))
                )).toList(),
                onChanged: (String? value) {
                  categoryController.setSelectedCategory(value!);
                },
                hintText: '${"category".tr} *',
                selectedValue: (categoryController.categoryList ?? []).any((item) => item.id.toString() == categoryController.selectedCategoryID) ? categoryController.selectedCategoryID : null
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              categoryController.selectedCategoryID != null  && categoryController.subCategoryList != null ? CustomDropdownButton(
                hintText: (categoryController.subCategoryList?.isNotEmpty ?? false) ? '${'sub_category'.tr} *' : 'no_subcategory_found'.tr,
                dropdownMenuItems: categoryController.subCategoryList?.map((item) => DropdownMenuItem<String>(
                  value: item.id.toString(),
                  child: Text(item.name ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault))
                )).toList(),
                onChanged: (String? value) {
                  categoryController.setSelectedSubCategory(value!);
                },
                selectedValue: (categoryController.subCategoryList ?? []).any((item) => item.id.toString() == categoryController.selectedSubCategoryID) ? categoryController.selectedSubCategoryID : null
              ) : SizedBox.shrink(),
              SizedBox(height: categoryController.selectedCategoryID != null  && categoryController.subCategoryList != null ? Dimensions.paddingSizeExtraLarge : 0),

              if(showMyCategory && (categoryController.myCategories?.isNotEmpty ?? false))
                CustomDropdownButton(
                  hintText: '${'my_category'.tr} *',
                  dropdownMenuItems: categoryController.myCategories!.map((item) => DropdownMenuItem<String>(
                    value: item.id.toString(),
                    child: Text(item.name ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault))
                  )).toList(),
                  onChanged: (String? value) {
                    categoryController.setSelectedMyCategory(value);
                  },
                  selectedValue: (categoryController.myCategories ?? []).any((item) => item.id.toString() == categoryController.selectedMyCategoryID) ? categoryController.selectedMyCategoryID : null
                ) ,
              if(showMyCategory && (categoryController.myCategories?.isNotEmpty ?? false)) SizedBox(height: showMyCategory && (categoryController.myCategories?.isNotEmpty ?? false) ? Dimensions.paddingSizeExtraLarge : 0),


              isPharmacy ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5))
                ),
                child: CustomDropdown(
                  onChange: (int? value, int index) {
                    storeController.setSuitableTagIndex(value!, true);
                  },
                  dropdownButtonStyle: DropdownButtonStyle(
                    height: 45,
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeExtraSmall,
                      horizontal: Dimensions.paddingSizeExtraSmall
                    ),
                    primaryColor: Theme.of(context).textTheme.bodyLarge!.color
                  ),
                  iconColor: Theme.of(context).disabledColor,
                  dropdownStyle: DropdownStyle(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall)
                  ),
                  items: suitableTagList,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      item != null && storeController.suitableTagIndex != null ? storeController.suitableTagList![storeController.suitableTagIndex!].name! : 'suitable_for'.tr,
                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeLarge)
                    )
                  )
                )
              ) : const SizedBox(),
              SizedBox(height: isPharmacy ? Dimensions.paddingSizeExtraLarge : 0),

              (isEcommerce || isGrocery) ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.5))
                ),
                child: CustomDropdown(
                  onChange: (int? value, int index) {
                    storeController.setBrandIndex(value!, true);
                  },
                  dropdownButtonStyle: DropdownButtonStyle(
                    height: 45,
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeExtraSmall,
                      horizontal: Dimensions.paddingSizeExtraSmall
                    ),
                    primaryColor: Theme.of(context).textTheme.bodyLarge!.color
                  ),
                  iconColor: Theme.of(context).disabledColor,
                  dropdownStyle: DropdownStyle(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall)
                  ),
                  items: brandList,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      item != null && storeController.brandIndex != null ? storeController.brandList![storeController.brandIndex!].name! : 'brand'.tr,
                      style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeLarge)
                    )
                  )
                )
              ) : const SizedBox(),
              SizedBox(height: (isEcommerce || isGrocery) ? Dimensions.paddingSizeExtraLarge : 0),

              isPharmacy ? Column(children: [
                Row(children: [
                  Expanded(
                    child: Autocomplete<int>(
                      optionsBuilder: (TextEditingValue value) {
                        if(value.text.isEmpty) {
                          return const Iterable<int>.empty();
                        }else {
                          return genericNameSuggestion.where((genericName) => storeController.genericNameSuggestionList![genericName]!.toLowerCase().contains(value.text.toLowerCase()));
                        }
                      },
                      optionsViewBuilder: (context, onAutoCompleteSelect, options) {
                        List<int> result = DataParserHelper.convertIntoListOfInteger(options.toString());

                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            color: Theme.of(context).primaryColorLight,
                            elevation: 4.0,
                            child: Container(
                              color: Theme.of(context).cardColor,
                              width: MediaQuery.of(context).size.width - 110,
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(8.0),
                                itemCount: result.length,
                                separatorBuilder: (context, i) {
                                  return const Divider(height: 0);
                                },
                                itemBuilder: (BuildContext context, int index) {
                                  return CustomInkWellWidget(
                                    onTap: () {
                                      if(storeController.selectedGenericNameList!.length > 1) {
                                      }else {
                                        _genericNameSuggestionController.text = storeController.genericNameSuggestionList![result[index]]!;
                                        storeController.setSelectedGenericNameIndex(result[index], true);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                      child: Text(storeController.genericNameSuggestionList![result[index]]!)
                                    )
                                  );
                                }
                              )
                            )
                          )
                        );
                      },
                      fieldViewBuilder: (context, genericNameController, node, onComplete) {
                        genericNameController.text = _genericNameSuggestionController.text;
                        return Container(
                          height: 50,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                          child: TextField(
                            controller: genericNameController,
                            focusNode: node,
                            onEditingComplete: () {
                              node.unfocus();
                              _genericNameSuggestionController.text = genericNameController.text;
                            },
                            decoration: InputDecoration(
                              hintText: 'generic_name'.tr,
                              labelText: 'generic_name'.tr,
                              hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                              labelStyle : robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                borderSide: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.5))
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                borderSide: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.5))
                              ),
                              suffixIcon: CustomToolTip(
                                message: 'specify_the_medicine_active_ingredient_that_makes_it_work'.tr,
                                preferredDirection: AxisDirection.up
                              )
                            )
                          )
                        );
                      },
                      displayStringForOption: (value) => storeController.genericNameSuggestionList![value]!,
                      onSelected: (int value) {
                        if(storeController.selectedGenericNameList!.length > 1) {
                        }else {
                          _genericNameSuggestionController.text = storeController.genericNameSuggestionList![value]!;
                          storeController.setSelectedGenericNameIndex(value, true);
                        }
                      }
                    )
                  ),
                ]),
              ]) : const SizedBox(),
              SizedBox(height: isPharmacy ? Dimensions.paddingSizeExtraLarge : 0),

              isFood || isGrocery ? Column(children: [
                Row(children: [
                  Expanded(
                    flex: 8,
                    child: Autocomplete<int>(
                      optionsBuilder: (TextEditingValue value) {
                        if(value.text.isEmpty) {
                          return const Iterable<int>.empty();
                        }else {
                          return nutritionSuggestion.where((nutrition) => storeController.nutritionSuggestionList![nutrition]!.toLowerCase().contains(value.text.toLowerCase()));
                        }
                      },
                      optionsViewBuilder: (context, onAutoCompleteSelect, options) {
                        List<int> result = DataParserHelper.convertIntoListOfInteger(options.toString());

                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            color: Theme.of(context).primaryColorLight,
                            elevation: 4.0,
                            child: Container(
                                color: Theme.of(context).cardColor,
                                width: MediaQuery.of(context).size.width - 110,
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(8.0),
                                  itemCount: result.length,
                                  separatorBuilder: (context, i) {
                                    return const Divider(height: 0);
                                  },
                                  itemBuilder: (BuildContext context, int index) {
                                    return CustomInkWellWidget(
                                      onTap: () {
                                        if(storeController.selectedNutritionList!.length >= 5) {
                                          showCustomSnackBar('you_can_select_or_add_maximum_5_nutrition'.tr, isError: true);
                                        }else {
                                          onNutritionSuggestionTextChanged('');
                                          storeController.setSelectedNutritionIndex(result[index], true);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                        child: Text(storeController.nutritionSuggestionList![result[index]]!)
                                      )
                                    );
                                  }
                                )
                            )
                          )
                        );
                      },
                      fieldViewBuilder: (context, controller, node, onComplete) {
                        if(controller.text != _nutritionSuggestionText) {
                          controller.value = TextEditingValue(
                            text: _nutritionSuggestionText,
                            selection: TextSelection.collapsed(offset: _nutritionSuggestionText.length)
                          );
                        }
                        return Container(
                          height: 50,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                          child: TextField(
                            controller: controller,
                            focusNode: node,
                            onChanged: (value) {
                              onNutritionSuggestionTextChanged(value);
                            },
                            onEditingComplete: () {
                              onComplete();
                              onNutritionSuggestionTextChanged('');
                              controller.text = '';
                            },
                            decoration: InputDecoration(
                              hintText: 'type_and_click_add_button'.tr,
                              labelText: 'nutrition'.tr,
                              hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                              labelStyle : robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                borderSide: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.5))
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                borderSide: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.5))
                              ),
                              suffixIcon: CustomToolTip(
                                message: 'specify_the_necessary_keywords_relating_to_energy_values_for_the_item'.tr,
                                preferredDirection: AxisDirection.up
                              )
                            )
                          )
                        );
                      },
                      displayStringForOption: (value) => storeController.nutritionSuggestionList![value]!,
                      onSelected: (int value) {
                        if(storeController.selectedNutritionList!.length >= 5) {
                          showCustomSnackBar('you_can_select_or_add_maximum_5_nutrition'.tr, isError: true);
                        }else {
                          onNutritionSuggestionTextChanged('');
                          storeController.setSelectedNutritionIndex(value, true);
                        }
                      }
                    )
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    flex: 2,
                    child: CustomButtonWidget(buttonText: 'add'.tr, onPressed: (){
                      if(storeController.selectedNutritionList!.length >= 5) {
                        showCustomSnackBar('you_can_select_or_add_maximum_5_nutrition'.tr, isError: true);
                      }else{
                        if(_nutritionSuggestionText.isNotEmpty) {
                          storeController.setNutrition(_nutritionSuggestionText.trim());
                          onNutritionSuggestionTextChanged('');
                        }
                      }
                    })
                  ),
                ]),
                SizedBox(height: storeController.selectedNutritionList != null ? Dimensions.paddingSizeSmall : 0),

                storeController.selectedNutritionList != null ? SizedBox(
                  height: storeController.selectedNutritionList!.isNotEmpty ? 40 : 0,
                  child: ListView.builder(
                    itemCount: storeController.selectedNutritionList!.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall)
                        ),
                        child: Row(children: [

                          Text(
                            storeController.selectedNutritionList![index]!,
                            style: robotoRegular.copyWith(color: Theme.of(context).disabledColor.withValues(alpha: 0.7))
                          ),

                          InkWell(
                            onTap: () => storeController.removeNutrition(index),
                            child: Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Icon(Icons.close, size: 15, color: Theme.of(context).disabledColor.withValues(alpha: 0.7))
                            )
                          ),

                        ])
                      );
                    }
                  )
                ) : const SizedBox(),
              ]) : const SizedBox(),
              SizedBox(height: isFood || isGrocery ? Dimensions.paddingSizeDefault : 0),

              isFood || isGrocery ? Column(children: [
                Row(children: [
                  Expanded(
                    flex: 8,
                    child: Autocomplete<int>(
                      optionsBuilder: (TextEditingValue value) {
                        if(value.text.isEmpty) {
                          return const Iterable<int>.empty();
                        }else {
                          return allergicIngredientsSuggestion.where((allergicIngredients) => storeController.allergicIngredientsSuggestionList![allergicIngredients]!.toLowerCase().contains(value.text.toLowerCase()));
                        }
                      },
                      optionsViewBuilder: (context, onAutoCompleteSelect, options) {
                        List<int> result = DataParserHelper.convertIntoListOfInteger(options.toString());

                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            color: Theme.of(context).primaryColorLight,
                            elevation: 4.0,
                            child: Container(
                                color: Theme.of(context).cardColor,
                                width: MediaQuery.of(context).size.width - 110,
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(8.0),
                                  itemCount: result.length,
                                  separatorBuilder: (context, i) {
                                    return const Divider(height: 0);
                                  },
                                  itemBuilder: (BuildContext context, int index) {
                                    return CustomInkWellWidget(
                                      onTap: () {
                                        if(storeController.selectedAllergicIngredientsList!.length >= 5) {
                                          showCustomSnackBar('you_can_select_or_add_maximum_5_allergic_ingredients'.tr, isError: true);
                                        }else {
                                          onAllergicIngredientsSuggestionTextChanged('');
                                          storeController.setSelectedAllergicIngredientsIndex(result[index], true);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                        child: Text(storeController.allergicIngredientsSuggestionList![result[index]]!)
                                      )
                                    );
                                  }
                                )
                            )
                          )
                        );
                      },
                      fieldViewBuilder: (context, controller, node, onComplete) {
                        if(controller.text != _allergicIngredientsSuggestionText) {
                          controller.value = TextEditingValue(
                            text: _allergicIngredientsSuggestionText,
                            selection: TextSelection.collapsed(offset: _allergicIngredientsSuggestionText.length)
                          );
                        }
                        return Container(
                          height: 50,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                          child: TextField(
                            controller: controller,
                            focusNode: node,
                            onChanged: (value) {
                              onAllergicIngredientsSuggestionTextChanged(value);
                            },
                            onEditingComplete: () {
                              onComplete();
                              onAllergicIngredientsSuggestionTextChanged('');
                              controller.text = '';
                            },
                            decoration: InputDecoration(
                              hintText: 'type_and_click_add_button'.tr,
                              labelText: 'allergic_ingredients'.tr,
                              hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                              labelStyle : robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                borderSide: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.5))
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                borderSide: BorderSide(color: Theme.of(context).disabledColor.withValues(alpha: 0.5))
                              ),
                              suffixIcon: CustomToolTip(
                                message: 'specify_the_ingredients_of_the_item_which_can_make_a_reaction_as_an_allergen'.tr,
                                preferredDirection: AxisDirection.up
                              )
                            )
                          )
                        );
                      },
                      displayStringForOption: (value) => storeController.allergicIngredientsSuggestionList![value]!,
                      onSelected: (int value) {
                        if(storeController.selectedAllergicIngredientsList!.length >= 5) {
                          showCustomSnackBar('you_can_select_or_add_maximum_5_allergic_ingredients'.tr, isError: true);
                        }else {
                          onAllergicIngredientsSuggestionTextChanged('');
                          storeController.setSelectedAllergicIngredientsIndex(value, true);
                        }
                      }
                    )
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    flex: 2,
                    child: CustomButtonWidget(buttonText: 'add'.tr, onPressed: (){
                      if(storeController.selectedAllergicIngredientsList!.length >= 5) {
                        showCustomSnackBar('you_can_select_or_add_maximum_5_allergic_ingredients'.tr, isError: true);
                      }else{
                        if(_allergicIngredientsSuggestionText.isNotEmpty) {
                          storeController.setAllergicIngredients(_allergicIngredientsSuggestionText.trim());
                          onAllergicIngredientsSuggestionTextChanged('');
                        }
                      }
                    })
                  ),
                ]),
                SizedBox(height: storeController.selectedAllergicIngredientsList != null ? Dimensions.paddingSizeSmall : 0),

                storeController.selectedAllergicIngredientsList != null ? SizedBox(
                  height: storeController.selectedAllergicIngredientsList!.isNotEmpty ? 40 : 0,
                  child: ListView.builder(
                    itemCount: storeController.selectedAllergicIngredientsList!.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall)
                        ),
                        child: Row(children: [

                          Text(
                            storeController.selectedAllergicIngredientsList![index]!,
                            style: robotoRegular.copyWith(color: Theme.of(context).disabledColor.withValues(alpha: 0.7))
                          ),

                          InkWell(
                            onTap: () => storeController.removeAllergicIngredients(index),
                            child: Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Icon(Icons.close, size: 15, color: Theme.of(context).disabledColor.withValues(alpha: 0.7))
                            )
                          ),

                    return (storeController.attributeList != null &&
                            categoryController.categoryList != null)
                        ? Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'item_info'.tr,
                                            style: robotoBold,
                                          ),

                                          Get.find<SplashController>()
                                                  .configModel!
                                                  .openAiStatus!
                                              ? InkWell(
                                                  onTap: () {
                                                    if (_nameControllerList[_tabController!
                                                            .index]
                                                        .text
                                                        .isEmpty) {
                                                      showCustomSnackBar(
                                                        'item_name_required'.tr,
                                                      );
                                                    } else {
                                                      aiController
                                                          .generateTitleAndDes(
                                                            title:
                                                                _nameControllerList[_tabController!
                                                                        .index]
                                                                    .text
                                                                    .trim(),
                                                            langCode:
                                                                _languageList[_tabController!
                                                                        .index]
                                                                    .key!,
                                                          )
                                                          .then((value) {
                                                            if (aiController
                                                                    .titleDesModel !=
                                                                null) {
                                                              _nameControllerList[_tabController!
                                                                          .index]
                                                                      .text =
                                                                  aiController
                                                                      .titleDesModel!
                                                                      .title ??
                                                                  '';
                                                              _descriptionControllerList[_tabController!
                                                                          .index]
                                                                      .text =
                                                                  aiController
                                                                      .titleDesModel!
                                                                      .description ??
                                                                  '';
                                                            }
                                                          });
                                                    }
                                                  },
                                                  child:
                                                      !aiController.titleLoading
                                                      ? Icon(
                                                          Icons.auto_awesome,
                                                          color: Colors.blue,
                                                        )
                                                      : Shimmer(
                                                          duration:
                                                              const Duration(
                                                                seconds: 2,
                                                              ),
                                                          color: Colors.blue,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .auto_awesome,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                              const SizedBox(
                                                                width: Dimensions
                                                                    .paddingSizeExtraSmall,
                                                              ),

                                                              Text(
                                                                'generating'.tr,
                                                                style: robotoBold
                                                                    .copyWith(
                                                                      color: Colors
                                                                          .blue,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),

                                      AnimatedBorderContainer(
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeSmall,
                                        ),
                                        isLoading: aiController.titleLoading,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 40,
                                              child: TabBar(
                                                tabAlignment:
                                                    TabAlignment.start,
                                                controller: _tabController,
                                                indicatorColor: Theme.of(
                                                  context,
                                                ).primaryColor,
                                                indicatorWeight: 3,
                                                labelColor: Theme.of(
                                                  context,
                                                ).primaryColor,
                                                unselectedLabelColor: Theme.of(
                                                  context,
                                                ).disabledColor,
                                                unselectedLabelStyle:
                                                    robotoRegular.copyWith(
                                                      color: Theme.of(
                                                        context,
                                                      ).disabledColor,
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                    ),
                                                labelStyle: robotoBold.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                                labelPadding:
                                                    const EdgeInsets.only(
                                                      right: Dimensions
                                                          .radiusDefault,
                                                    ),
                                                isScrollable: true,
                                                indicatorSize:
                                                    TabBarIndicatorSize.tab,
                                                dividerColor:
                                                    Colors.transparent,
                                                tabs: _tabs,
                                                onTap: (int? value) {
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                bottom:
                                                    Dimensions.paddingSizeLarge,
                                              ),
                                              child: Divider(height: 0),
                                            ),

                                            Text(
                                              'insert_language_wise_item_name_and_description'
                                                  .tr,
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Theme.of(
                                                  context,
                                                ).disabledColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeDefault,
                                            ),

                                            CustomTextFieldWidget(
                                              hintText: 'name'.tr,
                                              labelText: 'name'.tr,
                                              controller:
                                                  _nameControllerList[_tabController!
                                                      .index],
                                              capitalization:
                                                  TextCapitalization.words,
                                              focusNode:
                                                  _nameFocusList[_tabController!
                                                      .index],
                                              nextFocus:
                                                  _tabController!.index !=
                                                      _languageList.length - 1
                                                  ? _descriptionFocusList[_tabController!
                                                        .index]
                                                  : _descriptionFocusList[0],
                                              showTitle: false,
                                            ),
                                            const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraLarge,
                                            ),

                                            CustomTextFieldWidget(
                                              hintText: 'description'.tr,
                                              labelText: 'description'.tr,
                                              controller:
                                                  _descriptionControllerList[_tabController!
                                                      .index],
                                              focusNode:
                                                  _descriptionFocusList[_tabController!
                                                      .index],
                                              capitalization:
                                                  TextCapitalization.sentences,
                                              maxLines: 3,
                                              inputAction:
                                                  _tabController!.index !=
                                                      _languageList.length - 1
                                                  ? TextInputAction.next
                                                  : TextInputAction.done,
                                              nextFocus:
                                                  _tabController!.index !=
                                                      _languageList.length - 1
                                                  ? _nameFocusList[_tabController!
                                                            .index +
                                                        1]
                                                  : null,
                                              showTitle: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeDefault,
                                      ),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'item_setup'.tr,
                                            style: robotoMedium,
                                          ),

                                          const SizedBox(),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),

                                      AnimatedBorderContainer(
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeSmall,
                                        ),
                                        isLoading:
                                            aiController.otherDataLoading,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomDropdownButton(
                                              hintText: 'category'.tr,
                                              dropdownMenuItems: categoryController
                                                  .categoryList
                                                  ?.map(
                                                    (
                                                      item,
                                                    ) => DropdownMenuItem<String>(
                                                      value: item.id.toString(),
                                                      child: Text(
                                                        item.name ?? '',
                                                        style: robotoRegular
                                                            .copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeDefault,
                                                            ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                              onChanged: (String? value) {
                                                categoryController
                                                    .setSelectedCategory(
                                                      value!,
                                                    );
                                              },
                                              selectedValue: categoryController
                                                  .selectedCategoryID,
                                            ),
                                            const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraLarge,
                                            ),

                                            categoryController
                                                            .selectedCategoryID !=
                                                        null &&
                                                    categoryController
                                                            .subCategoryList !=
                                                        null &&
                                                    categoryController
                                                        .subCategoryList!
                                                        .isNotEmpty
                                                ? CustomDropdownButton(
                                                    hintText:
                                                        categoryController
                                                                    .subCategoryList !=
                                                                null &&
                                                            categoryController
                                                                .subCategoryList!
                                                                .isNotEmpty
                                                        ? 'sub_category'.tr
                                                        : 'no_sub_category_found'
                                                              .tr,
                                                    dropdownMenuItems: categoryController
                                                        .subCategoryList
                                                        ?.map(
                                                          (
                                                            item,
                                                          ) => DropdownMenuItem<String>(
                                                            value: item.id
                                                                .toString(),
                                                            child: Text(
                                                              item.name ?? '',
                                                              style: robotoRegular
                                                                  .copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeDefault,
                                                                  ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                    onChanged: (String? value) {
                                                      categoryController
                                                          .setSelectedSubCategory(
                                                            value!,
                                                          );
                                                    },
                                                    selectedValue:
                                                        categoryController
                                                            .selectedSubCategoryID,
                                                  )
                                                : SizedBox.shrink(),
                                            SizedBox(
                                              height:
                                                  categoryController
                                                              .selectedCategoryID !=
                                                          null &&
                                                      categoryController
                                                              .subCategoryList !=
                                                          null &&
                                                      categoryController
                                                          .subCategoryList!
                                                          .isNotEmpty
                                                  ? Dimensions
                                                        .paddingSizeExtraLarge
                                                  : 0,
                                            ),

                                            isPharmacy
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            Dimensions
                                                                .radiusDefault,
                                                          ),
                                                      color: Theme.of(
                                                        context,
                                                      ).cardColor,
                                                      border: Border.all(
                                                        color: Theme.of(context)
                                                            .disabledColor
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                      ),
                                                    ),
                                                    child: CustomDropdown(
                                                      onChange:
                                                          (
                                                            int? value,
                                                            int index,
                                                          ) {
                                                            storeController
                                                                .setSuitableTagIndex(
                                                                  value!,
                                                                  true,
                                                                );
                                                          },
                                                      dropdownButtonStyle: DropdownButtonStyle(
                                                        height: 45,
                                                        padding: const EdgeInsets.symmetric(
                                                          vertical: Dimensions
                                                              .paddingSizeExtraSmall,
                                                          horizontal: Dimensions
                                                              .paddingSizeExtraSmall,
                                                        ),
                                                        primaryColor:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .color,
                                                      ),
                                                      iconColor: Theme.of(
                                                        context,
                                                      ).disabledColor,
                                                      dropdownStyle: DropdownStyle(
                                                        elevation: 10,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusDefault,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              Dimensions
                                                                  .paddingSizeExtraSmall,
                                                            ),
                                                      ),
                                                      items: suitableTagList,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              left: 8,
                                                            ),
                                                        child: Text(
                                                          widget.item != null &&
                                                                  storeController
                                                                          .suitableTagIndex !=
                                                                      null
                                                              ? storeController
                                                                    .suitableTagList![storeController
                                                                        .suitableTagIndex!]
                                                                    .name!
                                                              : 'suitable_for'
                                                                    .tr,
                                                          style: robotoRegular
                                                              .copyWith(
                                                                color: Theme.of(
                                                                  context,
                                                                ).disabledColor,
                                                                fontSize: Dimensions
                                                                    .fontSizeLarge,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            SizedBox(
                                              height: isPharmacy
                                                  ? Dimensions
                                                        .paddingSizeExtraLarge
                                                  : 0,
                                            ),

                                            isEcommerce
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            Dimensions
                                                                .radiusDefault,
                                                          ),
                                                      color: Theme.of(
                                                        context,
                                                      ).cardColor,
                                                      border: Border.all(
                                                        color: Theme.of(context)
                                                            .disabledColor
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                      ),
                                                    ),
                                                    child: CustomDropdown(
                                                      onChange:
                                                          (
                                                            int? value,
                                                            int index,
                                                          ) {
                                                            storeController
                                                                .setBrandIndex(
                                                                  value!,
                                                                  true,
                                                                );
                                                          },
                                                      dropdownButtonStyle: DropdownButtonStyle(
                                                        height: 45,
                                                        padding: const EdgeInsets.symmetric(
                                                          vertical: Dimensions
                                                              .paddingSizeExtraSmall,
                                                          horizontal: Dimensions
                                                              .paddingSizeExtraSmall,
                                                        ),
                                                        primaryColor:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .color,
                                                      ),
                                                      iconColor: Theme.of(
                                                        context,
                                                      ).disabledColor,
                                                      dropdownStyle: DropdownStyle(
                                                        elevation: 10,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusDefault,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              Dimensions
                                                                  .paddingSizeExtraSmall,
                                                            ),
                                                      ),
                                                      items: brandList,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              left: 8,
                                                            ),
                                                        child: Text(
                                                          widget.item != null &&
                                                                  storeController
                                                                          .brandIndex !=
                                                                      null
                                                              ? storeController
                                                                    .brandList![storeController
                                                                        .brandIndex!]
                                                                    .name!
                                                              : 'brand'.tr,
                                                          style: robotoRegular
                                                              .copyWith(
                                                                color: Theme.of(
                                                                  context,
                                                                ).disabledColor,
                                                                fontSize: Dimensions
                                                                    .fontSizeLarge,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            SizedBox(
                                              height: isEcommerce
                                                  ? Dimensions
                                                        .paddingSizeExtraLarge
                                                  : 0,
                                            ),

                                            isPharmacy
                                                ? Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Autocomplete<int>(
                                                              optionsBuilder:
                                                                  (
                                                                    TextEditingValue
                                                                    value,
                                                                  ) {
                                                                    if (value
                                                                        .text
                                                                        .isEmpty) {
                                                                      return const Iterable<
                                                                        int
                                                                      >.empty();
                                                                    } else {
                                                                      return genericNameSuggestion.where(
                                                                        (
                                                                          genericName,
                                                                        ) => storeController
                                                                            .genericNameSuggestionList![genericName]!
                                                                            .toLowerCase()
                                                                            .contains(
                                                                              value.text.toLowerCase(),
                                                                            ),
                                                                      );
                                                                    }
                                                                  },
                                                              optionsViewBuilder:
                                                                  (
                                                                    context,
                                                                    onAutoCompleteSelect,
                                                                    options,
                                                                  ) {
                                                                    List<int>
                                                                    result = TypeConverter.convertIntoListOfInteger(
                                                                      options
                                                                          .toString(),
                                                                    );

                                                                    return Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      child: Material(
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).primaryColorLight,
                                                                        elevation:
                                                                            4.0,
                                                                        child: Container(
                                                                          color: Theme.of(
                                                                            context,
                                                                          ).cardColor,
                                                                          width:
                                                                              MediaQuery.of(
                                                                                context,
                                                                              ).size.width -
                                                                              110,
                                                                          child: ListView.separated(
                                                                            shrinkWrap:
                                                                                true,
                                                                            padding: const EdgeInsets.all(
                                                                              8.0,
                                                                            ),
                                                                            itemCount:
                                                                                result.length,
                                                                            separatorBuilder:
                                                                                (
                                                                                  context,
                                                                                  i,
                                                                                ) {
                                                                                  return const Divider(
                                                                                    height: 0,
                                                                                  );
                                                                                },
                                                                            itemBuilder:
                                                                                (
                                                                                  BuildContext context,
                                                                                  int index,
                                                                                ) {
                                                                                  return CustomInkWellWidget(
                                                                                    onTap: () {
                                                                                      if (storeController.selectedGenericNameList!.length >
                                                                                          1) {
                                                                                      } else {
                                                                                        _genericNameSuggestionController.text = storeController.genericNameSuggestionList![result[index]]!;
                                                                                        storeController.setSelectedGenericNameIndex(
                                                                                          result[index],
                                                                                          true,
                                                                                        );
                                                                                      }
                                                                                    },
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.symmetric(
                                                                                        vertical: Dimensions.paddingSizeSmall,
                                                                                      ),
                                                                                      child: Text(
                                                                                        storeController.genericNameSuggestionList![result[index]]!,
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                              fieldViewBuilder:
                                                                  (
                                                                    context,
                                                                    genericNameController,
                                                                    node,
                                                                    onComplete,
                                                                  ) {
                                                                    genericNameController
                                                                            .text =
                                                                        _genericNameSuggestionController
                                                                            .text;
                                                                    return Container(
                                                                      height:
                                                                          50,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusSmall,
                                                                        ),
                                                                      ),
                                                                      child: TextField(
                                                                        controller:
                                                                            genericNameController,
                                                                        focusNode:
                                                                            node,
                                                                        onEditingComplete: () {
                                                                          node.unfocus();
                                                                          _genericNameSuggestionController
                                                                              .text = genericNameController
                                                                              .text;
                                                                        },
                                                                        decoration: InputDecoration(
                                                                          hintText:
                                                                              'generic_name'.tr,
                                                                          labelText:
                                                                              'generic_name'.tr,
                                                                          hintStyle: robotoRegular.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeLarge,
                                                                            color: Theme.of(
                                                                              context,
                                                                            ).disabledColor,
                                                                          ),
                                                                          labelStyle: robotoRegular.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeLarge,
                                                                            color: Theme.of(
                                                                              context,
                                                                            ).disabledColor,
                                                                          ),
                                                                          enabledBorder: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              Dimensions.radiusDefault,
                                                                            ),
                                                                            borderSide: BorderSide(
                                                                              color:
                                                                                  Theme.of(
                                                                                    context,
                                                                                  ).disabledColor.withValues(
                                                                                    alpha: 0.5,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              Dimensions.radiusDefault,
                                                                            ),
                                                                            borderSide: BorderSide(
                                                                              color:
                                                                                  Theme.of(
                                                                                    context,
                                                                                  ).disabledColor.withValues(
                                                                                    alpha: 0.5,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                          suffixIcon: CustomToolTip(
                                                                            message:
                                                                                'specify_the_medicine_active_ingredient_that_makes_it_work'.tr,
                                                                            preferredDirection:
                                                                                AxisDirection.up,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                              displayStringForOption:
                                                                  (
                                                                    value,
                                                                  ) => storeController
                                                                      .genericNameSuggestionList![value]!,
                                                              onSelected: (int value) {
                                                                if (storeController
                                                                        .selectedGenericNameList!
                                                                        .length >
                                                                    1) {
                                                                } else {
                                                                  _genericNameSuggestionController
                                                                          .text =
                                                                      storeController
                                                                          .genericNameSuggestionList![value]!;
                                                                  storeController
                                                                      .setSelectedGenericNameIndex(
                                                                        value,
                                                                        true,
                                                                      );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox(),
                                            SizedBox(
                                              height: isPharmacy
                                                  ? Dimensions
                                                        .paddingSizeExtraLarge
                                                  : 0,
                                            ),

                                            isFood || isGrocery
                                                ? Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 8,
                                                            child: Autocomplete<int>(
                                                              optionsBuilder:
                                                                  (
                                                                    TextEditingValue
                                                                    value,
                                                                  ) {
                                                                    if (value
                                                                        .text
                                                                        .isEmpty) {
                                                                      return const Iterable<
                                                                        int
                                                                      >.empty();
                                                                    } else {
                                                                      return nutritionSuggestion.where(
                                                                        (
                                                                          nutrition,
                                                                        ) => storeController
                                                                            .nutritionSuggestionList![nutrition]!
                                                                            .toLowerCase()
                                                                            .contains(
                                                                              value.text.toLowerCase(),
                                                                            ),
                                                                      );
                                                                    }
                                                                  },
                                                              optionsViewBuilder:
                                                                  (
                                                                    context,
                                                                    onAutoCompleteSelect,
                                                                    options,
                                                                  ) {
                                                                    List<int>
                                                                    result = TypeConverter.convertIntoListOfInteger(
                                                                      options
                                                                          .toString(),
                                                                    );

                                                                    return Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      child: Material(
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).primaryColorLight,
                                                                        elevation:
                                                                            4.0,
                                                                        child: Container(
                                                                          color: Theme.of(
                                                                            context,
                                                                          ).cardColor,
                                                                          width:
                                                                              MediaQuery.of(
                                                                                context,
                                                                              ).size.width -
                                                                              110,
                                                                          child: ListView.separated(
                                                                            shrinkWrap:
                                                                                true,
                                                                            padding: const EdgeInsets.all(
                                                                              8.0,
                                                                            ),
                                                                            itemCount:
                                                                                result.length,
                                                                            separatorBuilder:
                                                                                (
                                                                                  context,
                                                                                  i,
                                                                                ) {
                                                                                  return const Divider(
                                                                                    height: 0,
                                                                                  );
                                                                                },
                                                                            itemBuilder:
                                                                                (
                                                                                  BuildContext context,
                                                                                  int index,
                                                                                ) {
                                                                                  return CustomInkWellWidget(
                                                                                    onTap: () {
                                                                                      if (storeController.selectedNutritionList!.length >=
                                                                                          5) {
                                                                                        showCustomSnackBar(
                                                                                          'you_can_select_or_add_maximum_5_nutrition'.tr,
                                                                                          isError: true,
                                                                                        );
                                                                                      } else {
                                                                                        _nutritionSuggestionController.text = '';
                                                                                        storeController.setSelectedNutritionIndex(
                                                                                          result[index],
                                                                                          true,
                                                                                        );
                                                                                      }
                                                                                    },
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.symmetric(
                                                                                        vertical: Dimensions.paddingSizeSmall,
                                                                                      ),
                                                                                      child: Text(
                                                                                        storeController.nutritionSuggestionList![result[index]]!,
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                              fieldViewBuilder:
                                                                  (
                                                                    context,
                                                                    controller,
                                                                    node,
                                                                    onComplete,
                                                                  ) {
                                                                    _nutritionSuggestionController =
                                                                        controller;
                                                                    return Container(
                                                                      height:
                                                                          50,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusSmall,
                                                                        ),
                                                                      ),
                                                                      child: TextField(
                                                                        controller:
                                                                            controller,
                                                                        focusNode:
                                                                            node,
                                                                        onEditingComplete: () {
                                                                          onComplete();
                                                                          controller.text =
                                                                              '';
                                                                        },
                                                                        decoration: InputDecoration(
                                                                          hintText:
                                                                              'type_and_click_add_button'.tr,
                                                                          labelText:
                                                                              'nutrition'.tr,
                                                                          hintStyle: robotoRegular.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeLarge,
                                                                            color: Theme.of(
                                                                              context,
                                                                            ).disabledColor,
                                                                          ),
                                                                          labelStyle: robotoRegular.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeLarge,
                                                                            color: Theme.of(
                                                                              context,
                                                                            ).disabledColor,
                                                                          ),
                                                                          enabledBorder: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              Dimensions.radiusDefault,
                                                                            ),
                                                                            borderSide: BorderSide(
                                                                              color:
                                                                                  Theme.of(
                                                                                    context,
                                                                                  ).disabledColor.withValues(
                                                                                    alpha: 0.5,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              Dimensions.radiusDefault,
                                                                            ),
                                                                            borderSide: BorderSide(
                                                                              color:
                                                                                  Theme.of(
                                                                                    context,
                                                                                  ).disabledColor.withValues(
                                                                                    alpha: 0.5,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                          suffixIcon: CustomToolTip(
                                                                            message:
                                                                                'specify_the_necessary_keywords_relating_to_energy_values_for_the_item'.tr,
                                                                            preferredDirection:
                                                                                AxisDirection.up,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                              displayStringForOption:
                                                                  (
                                                                    value,
                                                                  ) => storeController
                                                                      .nutritionSuggestionList![value]!,
                                                              onSelected: (int value) {
                                                                if (storeController
                                                                        .selectedNutritionList!
                                                                        .length >=
                                                                    5) {
                                                                  showCustomSnackBar(
                                                                    'you_can_select_or_add_maximum_5_nutrition'
                                                                        .tr,
                                                                    isError:
                                                                        true,
                                                                  );
                                                                } else {
                                                                  _nutritionSuggestionController
                                                                          .text =
                                                                      '';
                                                                  storeController
                                                                      .setSelectedNutritionIndex(
                                                                        value,
                                                                        true,
                                                                      );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeSmall,
                                                          ),

                                                          Expanded(
                                                            flex: 3,
                                                            child: CustomButtonWidget(
                                                              buttonText:
                                                                  'add'.tr,
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              height: 50,
                                                              onPressed: () {
                                                                if (storeController
                                                                        .selectedNutritionList!
                                                                        .length >=
                                                                    5) {
                                                                  showCustomSnackBar(
                                                                    'you_can_select_or_add_maximum_5_nutrition'
                                                                        .tr,
                                                                    isError:
                                                                        true,
                                                                  );
                                                                } else {
                                                                  if (_nutritionSuggestionController
                                                                      .text
                                                                      .isNotEmpty) {
                                                                    storeController.setNutrition(
                                                                      _nutritionSuggestionController
                                                                          .text
                                                                          .trim(),
                                                                    );
                                                                    _nutritionSuggestionController
                                                                            .text =
                                                                        '';
                                                                  }
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            storeController
                                                                    .selectedNutritionList !=
                                                                null
                                                            ? Dimensions
                                                                  .paddingSizeSmall
                                                            : 0,
                                                      ),

                                                      storeController
                                                                  .selectedNutritionList !=
                                                              null
                                                          ? SizedBox(
                                                              height:
                                                                  storeController
                                                                      .selectedNutritionList!
                                                                      .isNotEmpty
                                                                  ? 40
                                                                  : 0,
                                                              child: ListView.builder(
                                                                itemCount:
                                                                    storeController
                                                                        .selectedNutritionList!
                                                                        .length,
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                itemBuilder: (context, index) {
                                                                  return Container(
                                                                    padding: const EdgeInsets.only(
                                                                      left: Dimensions
                                                                          .paddingSizeExtraSmall,
                                                                    ),
                                                                    margin: const EdgeInsets.only(
                                                                      right: Dimensions
                                                                          .paddingSizeSmall,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color: Theme.of(context)
                                                                          .disabledColor
                                                                          .withValues(
                                                                            alpha:
                                                                                0.2,
                                                                          ),
                                                                      borderRadius: BorderRadius.circular(
                                                                        Dimensions
                                                                            .radiusSmall,
                                                                      ),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                          storeController
                                                                              .selectedNutritionList![index]!,
                                                                          style: robotoRegular.copyWith(
                                                                            color:
                                                                                Theme.of(
                                                                                  context,
                                                                                ).disabledColor.withValues(
                                                                                  alpha: 0.7,
                                                                                ),
                                                                          ),
                                                                        ),

                                                                        InkWell(
                                                                          onTap: () => storeController.removeNutrition(
                                                                            index,
                                                                          ),
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.all(
                                                                              Dimensions.paddingSizeExtraSmall,
                                                                            ),
                                                                            child: Icon(
                                                                              Icons.close,
                                                                              size: 15,
                                                                              color:
                                                                                  Theme.of(
                                                                                    context,
                                                                                  ).disabledColor.withValues(
                                                                                    alpha: 0.7,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  )
                                                : const SizedBox(),
                                            SizedBox(
                                              height: isFood || isGrocery
                                                  ? Dimensions
                                                        .paddingSizeDefault
                                                  : 0,
                                            ),

                                            isFood || isGrocery
                                                ? Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 8,
                                                            child: Autocomplete<int>(
                                                              optionsBuilder:
                                                                  (
                                                                    TextEditingValue
                                                                    value,
                                                                  ) {
                                                                    if (value
                                                                        .text
                                                                        .isEmpty) {
                                                                      return const Iterable<
                                                                        int
                                                                      >.empty();
                                                                    } else {
                                                                      return allergicIngredientsSuggestion.where(
                                                                        (
                                                                          allergicIngredients,
                                                                        ) => storeController
                                                                            .allergicIngredientsSuggestionList![allergicIngredients]!
                                                                            .toLowerCase()
                                                                            .contains(
                                                                              value.text.toLowerCase(),
                                                                            ),
                                                                      );
                                                                    }
                                                                  },
                                                              optionsViewBuilder:
                                                                  (
                                                                    context,
                                                                    onAutoCompleteSelect,
                                                                    options,
                                                                  ) {
                                                                    List<int>
                                                                    result = TypeConverter.convertIntoListOfInteger(
                                                                      options
                                                                          .toString(),
                                                                    );

                                                                    return Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topLeft,
                                                                      child: Material(
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).primaryColorLight,
                                                                        elevation:
                                                                            4.0,
                                                                        child: Container(
                                                                          color: Theme.of(
                                                                            context,
                                                                          ).cardColor,
                                                                          width:
                                                                              MediaQuery.of(
                                                                                context,
                                                                              ).size.width -
                                                                              110,
                                                                          child: ListView.separated(
                                                                            shrinkWrap:
                                                                                true,
                                                                            padding: const EdgeInsets.all(
                                                                              8.0,
                                                                            ),
                                                                            itemCount:
                                                                                result.length,
                                                                            separatorBuilder:
                                                                                (
                                                                                  context,
                                                                                  i,
                                                                                ) {
                                                                                  return const Divider(
                                                                                    height: 0,
                                                                                  );
                                                                                },
                                                                            itemBuilder:
                                                                                (
                                                                                  BuildContext context,
                                                                                  int index,
                                                                                ) {
                                                                                  return CustomInkWellWidget(
                                                                                    onTap: () {
                                                                                      if (storeController.selectedAllergicIngredientsList!.length >=
                                                                                          5) {
                                                                                        showCustomSnackBar(
                                                                                          'you_can_select_or_add_maximum_5_allergic_ingredients'.tr,
                                                                                          isError: true,
                                                                                        );
                                                                                      } else {
                                                                                        _allergicIngredientsSuggestionController.text = '';
                                                                                        storeController.setSelectedAllergicIngredientsIndex(
                                                                                          result[index],
                                                                                          true,
                                                                                        );
                                                                                      }
                                                                                    },
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.symmetric(
                                                                                        vertical: Dimensions.paddingSizeSmall,
                                                                                      ),
                                                                                      child: Text(
                                                                                        storeController.allergicIngredientsSuggestionList![result[index]]!,
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                              fieldViewBuilder:
                                                                  (
                                                                    context,
                                                                    controller,
                                                                    node,
                                                                    onComplete,
                                                                  ) {
                                                                    _allergicIngredientsSuggestionController =
                                                                        controller;
                                                                    return Container(
                                                                      height:
                                                                          50,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusSmall,
                                                                        ),
                                                                      ),
                                                                      child: TextField(
                                                                        controller:
                                                                            controller,
                                                                        focusNode:
                                                                            node,
                                                                        onEditingComplete: () {
                                                                          onComplete();
                                                                          controller.text =
                                                                              '';
                                                                        },
                                                                        decoration: InputDecoration(
                                                                          hintText:
                                                                              'type_and_click_add_button'.tr,
                                                                          labelText:
                                                                              'allergic_ingredients'.tr,
                                                                          hintStyle: robotoRegular.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeLarge,
                                                                            color: Theme.of(
                                                                              context,
                                                                            ).disabledColor,
                                                                          ),
                                                                          labelStyle: robotoRegular.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeLarge,
                                                                            color: Theme.of(
                                                                              context,
                                                                            ).disabledColor,
                                                                          ),
                                                                          enabledBorder: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              Dimensions.radiusDefault,
                                                                            ),
                                                                            borderSide: BorderSide(
                                                                              color:
                                                                                  Theme.of(
                                                                                    context,
                                                                                  ).disabledColor.withValues(
                                                                                    alpha: 0.5,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              Dimensions.radiusDefault,
                                                                            ),
                                                                            borderSide: BorderSide(
                                                                              color:
                                                                                  Theme.of(
                                                                                    context,
                                                                                  ).disabledColor.withValues(
                                                                                    alpha: 0.5,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                          suffixIcon: CustomToolTip(
                                                                            message:
                                                                                'specify_the_ingredients_of_the_item_which_can_make_a_reaction_as_an_allergen'.tr,
                                                                            preferredDirection:
                                                                                AxisDirection.up,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                              displayStringForOption:
                                                                  (
                                                                    value,
                                                                  ) => storeController
                                                                      .allergicIngredientsSuggestionList![value]!,
                                                              onSelected: (int value) {
                                                                if (storeController
                                                                        .selectedAllergicIngredientsList!
                                                                        .length >=
                                                                    5) {
                                                                  showCustomSnackBar(
                                                                    'you_can_select_or_add_maximum_5_allergic_ingredients'
                                                                        .tr,
                                                                    isError:
                                                                        true,
                                                                  );
                                                                } else {
                                                                  _allergicIngredientsSuggestionController
                                                                          .text =
                                                                      '';
                                                                  storeController
                                                                      .setSelectedAllergicIngredientsIndex(
                                                                        value,
                                                                        true,
                                                                      );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeSmall,
                                                          ),

                                                          Expanded(
                                                            flex: 3,
                                                            child: CustomButtonWidget(
                                                              buttonText:
                                                                  'add'.tr,
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              height: 50,
                                                              onPressed: () {
                                                                if (storeController
                                                                        .selectedAllergicIngredientsList!
                                                                        .length >=
                                                                    5) {
                                                                  showCustomSnackBar(
                                                                    'you_can_select_or_add_maximum_5_allergic_ingredients'
                                                                        .tr,
                                                                    isError:
                                                                        true,
                                                                  );
                                                                } else {
                                                                  if (_allergicIngredientsSuggestionController
                                                                      .text
                                                                      .isNotEmpty) {
                                                                    storeController.setAllergicIngredients(
                                                                      _allergicIngredientsSuggestionController
                                                                          .text
                                                                          .trim(),
                                                                    );
                                                                    _allergicIngredientsSuggestionController
                                                                            .text =
                                                                        '';
                                                                  }
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            storeController
                                                                    .selectedAllergicIngredientsList !=
                                                                null
                                                            ? Dimensions
                                                                  .paddingSizeSmall
                                                            : 0,
                                                      ),

                                                      storeController
                                                                  .selectedAllergicIngredientsList !=
                                                              null
                                                          ? SizedBox(
                                                              height:
                                                                  storeController
                                                                      .selectedAllergicIngredientsList!
                                                                      .isNotEmpty
                                                                  ? 40
                                                                  : 0,
                                                              child: ListView.builder(
                                                                itemCount:
                                                                    storeController
                                                                        .selectedAllergicIngredientsList!
                                                                        .length,
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                itemBuilder: (context, index) {
                                                                  return Container(
                                                                    padding: const EdgeInsets.only(
                                                                      left: Dimensions
                                                                          .paddingSizeExtraSmall,
                                                                    ),
                                                                    margin: const EdgeInsets.only(
                                                                      right: Dimensions
                                                                          .paddingSizeSmall,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color: Theme.of(context)
                                                                          .disabledColor
                                                                          .withValues(
                                                                            alpha:
                                                                                0.2,
                                                                          ),
                                                                      borderRadius: BorderRadius.circular(
                                                                        Dimensions
                                                                            .radiusSmall,
                                                                      ),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                          storeController
                                                                              .selectedAllergicIngredientsList![index]!,
                                                                          style: robotoRegular.copyWith(
                                                                            color:
                                                                                Theme.of(
                                                                                  context,
                                                                                ).disabledColor.withValues(
                                                                                  alpha: 0.7,
                                                                                ),
                                                                          ),
                                                                        ),

                                                                        InkWell(
                                                                          onTap: () => storeController.removeAllergicIngredients(
                                                                            index,
                                                                          ),
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.all(
                                                                              Dimensions.paddingSizeExtraSmall,
                                                                            ),
                                                                            child: Icon(
                                                                              Icons.close,
                                                                              size: 15,
                                                                              color:
                                                                                  Theme.of(
                                                                                    context,
                                                                                  ).disabledColor.withValues(
                                                                                    alpha: 0.7,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  )
                                                : const SizedBox(),
                                            SizedBox(
                                              height: isFood || isGrocery
                                                  ? Dimensions
                                                        .paddingSizeDefault
                                                  : 0,
                                            ),

                                            (_module.vegNonVeg! &&
                                                    Get.find<SplashController>()
                                                        .configModel!
                                                        .toggleVegNonVeg!)
                                                ? LabelWidget(
                                                    labelText: 'food_type'.tr,
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Row(
                                                            children: [
                                                              RadioGroup(
                                                                groupValue:
                                                                    storeController
                                                                        .isVeg
                                                                    ? 'veg'
                                                                    : 'non_veg',
                                                                onChanged:
                                                                    (
                                                                      String?
                                                                      value,
                                                                    ) => storeController
                                                                        .setVeg(
                                                                          value ==
                                                                              'veg',
                                                                          true,
                                                                        ),
                                                                child: Radio(
                                                                  value: 'veg',
                                                                  fillColor: WidgetStateProperty.all<Color>(
                                                                    storeController
                                                                            .isVeg
                                                                        ? Theme.of(
                                                                            context,
                                                                          ).primaryColor
                                                                        : Theme.of(
                                                                            context,
                                                                          ).disabledColor,
                                                                  ),
                                                                ),
                                                              ),

                                                              Flexible(
                                                                child: Text(
                                                                  'veg'.tr,
                                                                  style: robotoMedium.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall,
                                                                    color:
                                                                        storeController
                                                                            .isVeg
                                                                        ? Theme.of(
                                                                            context,
                                                                          ).textTheme.bodyLarge?.color
                                                                        : Theme.of(
                                                                            context,
                                                                          ).disabledColor,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        Expanded(
                                                          child: Row(
                                                            children: [
                                                              RadioGroup(
                                                                groupValue:
                                                                    storeController
                                                                        .isVeg
                                                                    ? 'veg'
                                                                    : 'non_veg',
                                                                onChanged:
                                                                    (
                                                                      String?
                                                                      value,
                                                                    ) => storeController
                                                                        .setVeg(
                                                                          value ==
                                                                              'veg',
                                                                          true,
                                                                        ),
                                                                child: Radio(
                                                                  value:
                                                                      'non_veg',
                                                                  fillColor: WidgetStateProperty.all<Color>(
                                                                    storeController
                                                                            .isVeg
                                                                        ? Theme.of(
                                                                            context,
                                                                          ).disabledColor
                                                                        : Theme.of(
                                                                            context,
                                                                          ).primaryColor,
                                                                  ),
                                                                ),
                                                              ),
                                                              Flexible(
                                                                child: Text(
                                                                  'non_veg'.tr,
                                                                  style: robotoMedium.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall,
                                                                    color:
                                                                        storeController
                                                                            .isVeg
                                                                        ? Theme.of(
                                                                            context,
                                                                          ).disabledColor
                                                                        : Theme.of(
                                                                            context,
                                                                          ).textTheme.bodyLarge?.color,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            SizedBox(
                                              height:
                                                  Get.find<SplashController>()
                                                              .configModel!
                                                              .systemTaxType ==
                                                          'product_wise' &&
                                                      (_module.vegNonVeg! &&
                                                          Get.find<
                                                                SplashController
                                                              >()
                                                              .configModel!
                                                              .toggleVegNonVeg!)
                                                  ? Dimensions
                                                        .paddingSizeExtraLarge
                                                  : 0,
                                            ),

                                            (isFood || isGrocery) &&
                                                    storeHalalActive
                                                ? LabelWidget(
                                                    labelText: 'halal_tag'.tr,
                                                    padding: const EdgeInsets.only(
                                                      left: Dimensions
                                                          .paddingSizeDefault,
                                                      top: Dimensions
                                                          .paddingSizeExtraSmall,
                                                      bottom: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            'status'.tr,
                                                            style: robotoMedium,
                                                          ),
                                                        ),
                                                        Transform.scale(
                                                          scale: 0.7,
                                                          child: CupertinoSwitch(
                                                            value:
                                                                storeController
                                                                    .isHalal,
                                                            onChanged:
                                                                (
                                                                  bool
                                                                  isChecked,
                                                                ) => storeController
                                                                    .toggleHalal(),
                                                            activeTrackColor:
                                                                Theme.of(
                                                                  context,
                                                                ).primaryColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            SizedBox(
                                              height:
                                                  (isFood || isGrocery) &&
                                                      storeHalalActive
                                                  ? Dimensions
                                                        .paddingSizeExtraLarge
                                                  : 0,
                                            ),

                                            isPharmacy
                                                ? LabelWidget(
                                                    labelText:
                                                        'basic_medicine'.tr,
                                                    padding: const EdgeInsets.only(
                                                      left: Dimensions
                                                          .paddingSizeDefault,
                                                      top: Dimensions
                                                          .paddingSizeExtraSmall,
                                                      bottom: Dimensions
                                                          .paddingSizeExtraSmall,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            'status'.tr,
                                                            style: robotoMedium,
                                                          ),
                                                        ),

                                                        Transform.scale(
                                                          scale: 0.7,
                                                          child: CupertinoSwitch(
                                                            value: storeController
                                                                .isBasicMedicine,
                                                            onChanged:
                                                                (
                                                                  bool?
                                                                  isChecked,
                                                                ) => storeController
                                                                    .toggleBasicMedicine(),
                                                            activeTrackColor:
                                                                Theme.of(
                                                                  context,
                                                                ).primaryColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            SizedBox(
                                              height: isPharmacy
                                                  ? Dimensions
                                                        .paddingSizeExtraLarge
                                                  : 0,
                                            ),

                                            Get.find<SplashController>()
                                                        .configModel!
                                                        .systemTaxType ==
                                                    'product_wise'
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomDropdownButton(
                                                        dropdownMenuItems: storeController.vatTaxList?.map((
                                                          e,
                                                        ) {
                                                          bool isInVatTaxList =
                                                              storeController
                                                                  .selectedVatTaxNameList
                                                                  .contains(
                                                                    e.name,
                                                                  );
                                                          return DropdownMenuItem<
                                                            String
                                                          >(
                                                            value: e.name,
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  '${e.name!} (${e.taxRate}%)',
                                                                  style:
                                                                      robotoRegular,
                                                                ),
                                                                const Spacer(),
                                                                if (isInVatTaxList)
                                                                  const Icon(
                                                                    Icons.check,
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                              ],
                                                            ),
                                                          );
                                                        }).toList(),
                                                        showTitle: false,
                                                        hintText:
                                                            'select_vat_tax'.tr,
                                                        onChanged: (String? value) {
                                                          final selectedVatTax =
                                                              storeController
                                                                  .vatTaxList
                                                                  ?.firstWhere(
                                                                    (vatTax) =>
                                                                        vatTax
                                                                            .name ==
                                                                        value,
                                                                  );
                                                          if (selectedVatTax !=
                                                              null) {
                                                            storeController
                                                                .setSelectedVatTax(
                                                                  selectedVatTax
                                                                      .name,
                                                                  selectedVatTax
                                                                      .id,
                                                                  selectedVatTax
                                                                      .taxRate,
                                                                );
                                                          }
                                                        },
                                                        selectedValue: null,
                                                        selectedItemBuilder: (context) {
                                                          return storeController
                                                                  .vatTaxList
                                                                  ?.map((e) {
                                                                    return Text(
                                                                      'select_vat_tax'
                                                                          .tr,
                                                                      style: robotoRegular.copyWith(
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    );
                                                                  })
                                                                  .toList() ??
                                                              [];
                                                        },
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            storeController
                                                                .selectedVatTaxNameList
                                                                .isNotEmpty
                                                            ? Dimensions
                                                                  .paddingSizeSmall
                                                            : 0,
                                                      ),

                                                      Wrap(
                                                        children: List.generate(
                                                          storeController
                                                              .selectedVatTaxNameList
                                                              .length,
                                                          (index) {
                                                            final vatTaxName =
                                                                storeController
                                                                    .selectedVatTaxNameList[index];
                                                            final vatTaxId =
                                                                storeController
                                                                    .selectedVatTaxIdList[index];
                                                            final taxRate =
                                                                storeController
                                                                    .selectedTaxRateList[index];
                                                            return Padding(
                                                              padding: const EdgeInsets.only(
                                                                right: Dimensions
                                                                    .paddingSizeSmall,
                                                              ),
                                                              child: Stack(
                                                                clipBehavior:
                                                                    Clip.none,
                                                                children: [
                                                                  FilterChip(
                                                                    label: Text(
                                                                      '$vatTaxName ($taxRate%)',
                                                                    ),
                                                                    selected:
                                                                        false,
                                                                    onSelected:
                                                                        (
                                                                          bool
                                                                          value,
                                                                        ) {},
                                                                  ),

                                                                  Positioned(
                                                                    right: -5,
                                                                    top: 0,
                                                                    child: InkWell(
                                                                      onTap: () {
                                                                        storeController.removeVatTax(
                                                                          vatTaxName,
                                                                          vatTaxId,
                                                                          taxRate,
                                                                        );
                                                                      },
                                                                      child: Container(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                              1,
                                                                            ),
                                                                        decoration: BoxDecoration(
                                                                          color: Theme.of(
                                                                            context,
                                                                          ).cardColor,
                                                                          shape:
                                                                              BoxShape.circle,
                                                                          border: Border.all(
                                                                            color:
                                                                                Colors.red,
                                                                            width:
                                                                                1,
                                                                          ),
                                                                        ),
                                                                        child: const Icon(
                                                                          Icons
                                                                              .close,
                                                                          size:
                                                                              15,
                                                                          color:
                                                                              Colors.red,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeDefault,
                                      ),

                                      isPharmacy
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'prescription_required'.tr,
                                                  style: robotoBold,
                                                ),
                                                const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeSmall,
                                                ),

                                                AnimatedBorderContainer(
                                                  padding: const EdgeInsets.all(
                                                    0,
                                                  ),
                                                  isLoading: aiController
                                                      .otherDataLoading,
                                                  child: ListTile(
                                                    onTap: () => storeController
                                                        .togglePrescriptionRequired(),
                                                    leading: Checkbox(
                                                      activeColor: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                      value: storeController
                                                          .isPrescriptionRequired,
                                                      onChanged:
                                                          (
                                                            bool? isChecked,
                                                          ) => storeController
                                                              .togglePrescriptionRequired(),
                                                    ),
                                                    title: Text(
                                                      'this_item_need_prescription_to_place_order'
                                                          .tr,
                                                      style: robotoMedium,
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    dense: true,
                                                    horizontalTitleGap: 0,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const SizedBox(),
                                      SizedBox(
                                        height: isPharmacy
                                            ? Dimensions.paddingSizeDefault
                                            : 0,
                                      ),

                                      Text('price_info'.tr, style: robotoBold),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),

                                      AnimatedBorderContainer(
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeSmall,
                                        ),
                                        isLoading:
                                            aiController.otherDataLoading,
                                        child: Column(
                                          children: [
                                            CustomTextFieldWidget(
                                              hintText: 'price'.tr,
                                              labelText: 'price'.tr,
                                              controller: _priceController,
                                              focusNode: _priceNode,
                                              nextFocus: _discountNode,
                                              isAmount: true,
                                            ),
                                            const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraLarge,
                                            ),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            Dimensions
                                                                .radiusDefault,
                                                          ),
                                                      color: Theme.of(
                                                        context,
                                                      ).cardColor,
                                                      border: Border.all(
                                                        color: Theme.of(context)
                                                            .disabledColor
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                      ),
                                                    ),
                                                    child: CustomDropdown(
                                                      onChange:
                                                          (
                                                            int? value,
                                                            int index,
                                                          ) {
                                                            storeController
                                                                .setDiscountTypeIndex(
                                                                  value!,
                                                                  true,
                                                                );
                                                            _discountTypeSelected =
                                                                true;
                                                            _validateDiscount();
                                                          },
                                                      dropdownButtonStyle:
                                                          DropdownButtonStyle(
                                                            height: 45,
                                                            padding: const EdgeInsets.symmetric(
                                                              vertical: Dimensions
                                                                  .paddingSizeExtraSmall,
                                                            ),
                                                            primaryColor:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .textTheme
                                                                    .bodyLarge!
                                                                    .color,
                                                          ),
                                                      iconColor: Theme.of(
                                                        context,
                                                      ).disabledColor,
                                                      dropdownStyle: DropdownStyle(
                                                        elevation: 10,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusDefault,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              Dimensions
                                                                  .paddingSizeExtraSmall,
                                                            ),
                                                      ),
                                                      items: discountTypeList,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              left: 2,
                                                            ),
                                                        child: Text(
                                                          widget.item != null
                                                              ? storeController
                                                                    .discountTypeList[storeController
                                                                        .discountTypeIndex]!
                                                                    .tr
                                                              : 'discount_type'
                                                                    .tr,
                                                          style: robotoRegular
                                                              .copyWith(
                                                                color: Theme.of(
                                                                  context,
                                                                ).disabledColor,
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeDefault,
                                                ),

                                                Expanded(
                                                  child: CustomTextFieldWidget(
                                                    hintText: 'discount'.tr,
                                                    labelText: 'discount'.tr,
                                                    controller:
                                                        _discountController,
                                                    focusNode: _discountNode,
                                                    isAmount: true,
                                                    onChanged: (value) =>
                                                        _validateDiscount(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraLarge,
                                            ),

                                            CustomTextFieldWidget(
                                              hintText:
                                                  'maximum_order_quantity'.tr,
                                              labelText:
                                                  'maximum_order_quantity'.tr,
                                              controller:
                                                  _maxOrderQuantityController,
                                              isNumber: true,
                                            ),
                                            SizedBox(
                                              height:
                                                  (_module.stock! ||
                                                      _module.unit!)
                                                  ? Dimensions
                                                        .paddingSizeExtraLarge
                                                  : 0,
                                            ),

                                            (_module.stock! || _module.unit!)
                                                ? Row(
                                                    children: [
                                                      _module.stock!
                                                          ? Expanded(
                                                              child: CustomTextFieldWidget(
                                                                hintText:
                                                                    'total_stock'
                                                                        .tr,
                                                                labelText:
                                                                    'total_stock'
                                                                        .tr,
                                                                controller:
                                                                    _stockController,
                                                                isNumber: true,
                                                                isEnabled:
                                                                    storeController
                                                                        .variantTypeList!
                                                                        .isEmpty,
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      SizedBox(
                                                        width: _module.stock!
                                                            ? Dimensions
                                                                  .paddingSizeSmall
                                                            : 0,
                                                      ),

                                                      _module.unit!
                                                          ? Expanded(
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        Dimensions
                                                                            .radiusDefault,
                                                                      ),
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).cardColor,
                                                                  border: Border.all(
                                                                    color:
                                                                        Theme.of(
                                                                          context,
                                                                        ).disabledColor.withValues(
                                                                          alpha:
                                                                              0.5,
                                                                        ),
                                                                  ),
                                                                ),
                                                                child: CustomDropdown(
                                                                  onChange:
                                                                      (
                                                                        int?
                                                                        value,
                                                                        int
                                                                        index,
                                                                      ) {
                                                                        storeController.setUnitIndex(
                                                                          value!,
                                                                          true,
                                                                        );
                                                                      },
                                                                  dropdownButtonStyle: DropdownButtonStyle(
                                                                    height: 45,
                                                                    padding: const EdgeInsets.symmetric(
                                                                      vertical:
                                                                          Dimensions
                                                                              .paddingSizeExtraSmall,
                                                                      horizontal:
                                                                          Dimensions
                                                                              .paddingSizeExtraSmall,
                                                                    ),
                                                                    primaryColor: Theme.of(context)
                                                                        .textTheme
                                                                        .bodyLarge!
                                                                        .color,
                                                                  ),
                                                                  iconColor:
                                                                      Theme.of(
                                                                        context,
                                                                      ).disabledColor,
                                                                  dropdownStyle: DropdownStyle(
                                                                    elevation:
                                                                        10,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusDefault,
                                                                        ),
                                                                    padding: const EdgeInsets.all(
                                                                      Dimensions
                                                                          .paddingSizeExtraSmall,
                                                                    ),
                                                                  ),
                                                                  items:
                                                                      unitList,
                                                                  child: Padding(
                                                                    padding:
                                                                        const EdgeInsets.only(
                                                                          left:
                                                                              8,
                                                                        ),
                                                                    child: Text(
                                                                      widget.item !=
                                                                                  null &&
                                                                              storeController.unitList !=
                                                                                  null &&
                                                                              storeController.unitList!.isNotEmpty
                                                                          ? storeController.unitList![storeController.unitIndex!].unit!.tr
                                                                          : 'unit'.tr,
                                                                      style: robotoRegular.copyWith(
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).disabledColor,
                                                                        fontSize:
                                                                            Dimensions.fontSizeLarge,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                    ],
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeDefault,
                                      ),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Get.find<SplashController>()
                                                  .getStoreModuleConfig()
                                                  .newVariation!
                                              ? Row(
                                                  children: [
                                                    Text(
                                                      'food_variation'.tr,
                                                      style: robotoBold,
                                                    ),
                                                    Text(
                                                      ' (${'optional'.tr})',
                                                      style: robotoRegular
                                                          .copyWith(
                                                            color: Theme.of(
                                                              context,
                                                            ).disabledColor,
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                          ),
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  'attribute'.tr,
                                                  style: robotoBold,
                                                ),

                                          Get.find<SplashController>()
                                                  .configModel!
                                                  .openAiStatus!
                                              ? InkWell(
                                                  onTap: () {
                                                    if (_nameControllerList[0]
                                                        .text
                                                        .isEmpty) {
                                                      showCustomSnackBar(
                                                        'food_name_required_for_en'
                                                            .tr,
                                                      );
                                                    } else if (_descriptionControllerList[0]
                                                        .text
                                                        .isEmpty) {
                                                      showCustomSnackBar(
                                                        'description_required'
                                                            .tr,
                                                      );
                                                    } else {
                                                      if (Get.find<
                                                            SplashController
                                                          >()
                                                          .getStoreModuleConfig()
                                                          .newVariation!) {
                                                        storeController
                                                            .generateAndSetVariationData(
                                                              title:
                                                                  _nameControllerList[0]
                                                                      .text
                                                                      .trim(),
                                                              description:
                                                                  _descriptionControllerList[0]
                                                                      .text
                                                                      .trim(),
                                                            );
                                                      } else {
                                                        storeController
                                                            .generateAndSetAttributeData(
                                                              title:
                                                                  _nameControllerList[0]
                                                                      .text
                                                                      .trim(),
                                                              description:
                                                                  _descriptionControllerList[0]
                                                                      .text
                                                                      .trim(),
                                                            );
                                                      }
                                                    }
                                                  },
                                                  child:
                                                      !aiController
                                                          .variationDataLoading
                                                      ? Icon(
                                                          Icons.auto_awesome,
                                                          color: Colors.blue,
                                                        )
                                                      : Shimmer(
                                                          duration:
                                                              const Duration(
                                                                seconds: 2,
                                                              ),
                                                          color: Colors.blue,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .auto_awesome,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                              const SizedBox(
                                                                width: Dimensions
                                                                    .paddingSizeExtraSmall,
                                                              ),

                                                              Text(
                                                                'generating'.tr,
                                                                style: robotoBold
                                                                    .copyWith(
                                                                      color: Colors
                                                                          .blue,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),

                                      Get.find<SplashController>()
                                              .getStoreModuleConfig()
                                              .newVariation!
                                          ? FoodVariationViewWidget(
                                              storeController: storeController,
                                              item: widget.item,
                                            )
                                          : AttributeViewWidget(
                                              storeController: storeController,
                                              product: widget.item,
                                            ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeDefault,
                                      ),

                                      _module.addOn!
                                          ? Text('addons'.tr, style: robotoBold)
                                          : const SizedBox(),
                                      SizedBox(
                                        height: _module.addOn!
                                            ? Dimensions.paddingSizeSmall
                                            : 0,
                                      ),

                                      _module.addOn!
                                          ? AnimatedBorderContainer(
                                              padding: const EdgeInsets.all(
                                                Dimensions.paddingSizeSmall,
                                              ),
                                              isLoading:
                                                  aiController.otherDataLoading,
                                              child: Column(
                                                children: [
                                                  _module.addOn!
                                                      ? GetBuilder<
                                                          AddonController
                                                        >(
                                                          builder: (addonController) {
                                                            List<int> addons =
                                                                [];
                                                            if (addonController
                                                                    .addonList !=
                                                                null) {
                                                              for (
                                                                int index = 0;
                                                                index <
                                                                    addonController
                                                                        .addonList!
                                                                        .length;
                                                                index++
                                                              ) {
                                                                if (addonController
                                                                            .addonList![index]
                                                                            .status ==
                                                                        1 &&
                                                                    !storeController
                                                                        .selectedAddons!
                                                                        .contains(
                                                                          index,
                                                                        )) {
                                                                  addons.add(
                                                                    index,
                                                                  );
                                                                }
                                                              }
                                                            }
                                                            return Autocomplete<
                                                              int
                                                            >(
                                                              optionsBuilder:
                                                                  (
                                                                    TextEditingValue
                                                                    value,
                                                                  ) {
                                                                    if (value
                                                                        .text
                                                                        .isEmpty) {
                                                                      return const Iterable<
                                                                        int
                                                                      >.empty();
                                                                    } else {
                                                                      return addons.where(
                                                                        (
                                                                          addon,
                                                                        ) => addonController
                                                                            .addonList![addon]
                                                                            .name!
                                                                            .toLowerCase()
                                                                            .contains(
                                                                              value.text.toLowerCase(),
                                                                            ),
                                                                      );
                                                                    }
                                                                  },
                                                              fieldViewBuilder:
                                                                  (
                                                                    context,
                                                                    controller,
                                                                    node,
                                                                    onComplete,
                                                                  ) {
                                                                    _c =
                                                                        controller;
                                                                    return SizedBox(
                                                                      height:
                                                                          50,
                                                                      child: CustomTextFieldWidget(
                                                                        controller:
                                                                            controller,
                                                                        focusNode:
                                                                            node,
                                                                        hintText:
                                                                            'addons'.tr,
                                                                        labelText:
                                                                            'addons'.tr,
                                                                        onEditingComplete: () {
                                                                          onComplete();
                                                                          controller.text =
                                                                              '';
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                              displayStringForOption:
                                                                  (
                                                                    value,
                                                                  ) => addonController
                                                                      .addonList![value]
                                                                      .name!,
                                                              onSelected: (int value) {
                                                                _c.text = '';
                                                                storeController
                                                                    .setSelectedAddonIndex(
                                                                      value,
                                                                      true,
                                                                    );
                                                                //_addons.removeAt(value);
                                                              },
                                                            );
                                                          },
                                                        )
                                                      : const SizedBox(),
                                                  SizedBox(
                                                    height:
                                                        (_module.addOn! &&
                                                            storeController
                                                                .selectedAddons!
                                                                .isNotEmpty)
                                                        ? Dimensions
                                                              .paddingSizeSmall
                                                        : 0,
                                                  ),

                                                  _module.addOn!
                                                      ? SizedBox(
                                                          height:
                                                              storeController
                                                                  .selectedAddons!
                                                                  .isNotEmpty
                                                              ? 40
                                                              : 0,
                                                          child: ListView.builder(
                                                            itemCount:
                                                                storeController
                                                                    .selectedAddons!
                                                                    .length,
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemBuilder: (context, index) {
                                                              return Container(
                                                                padding: const EdgeInsets.only(
                                                                  left: Dimensions
                                                                      .paddingSizeExtraSmall,
                                                                ),
                                                                margin: const EdgeInsets.only(
                                                                  right: Dimensions
                                                                      .paddingSizeSmall,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      Theme.of(
                                                                        context,
                                                                      ).disabledColor.withValues(
                                                                        alpha:
                                                                            0.2,
                                                                      ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        Dimensions
                                                                            .radiusSmall,
                                                                      ),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    GetBuilder<
                                                                      AddonController
                                                                    >(
                                                                      builder:
                                                                          (
                                                                            addonController,
                                                                          ) {
                                                                            return Text(
                                                                              addonController.addonList![storeController.selectedAddons![index]].name!,
                                                                              style: robotoRegular.copyWith(
                                                                                color:
                                                                                    Theme.of(
                                                                                      context,
                                                                                    ).disabledColor.withValues(
                                                                                      alpha: 0.7,
                                                                                    ),
                                                                              ),
                                                                            );
                                                                          },
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () =>
                                                                          storeController.removeAddon(
                                                                            index,
                                                                          ),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(
                                                                          Dimensions
                                                                              .paddingSizeExtraSmall,
                                                                        ),
                                                                        child: Icon(
                                                                          Icons
                                                                              .close,
                                                                          size:
                                                                              15,
                                                                          color:
                                                                              Theme.of(
                                                                                context,
                                                                              ).disabledColor.withValues(
                                                                                alpha: 0.7,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                            )
                                          : const SizedBox(),
                                      SizedBox(
                                        height: _module.addOn!
                                            ? Dimensions.paddingSizeDefault
                                            : 0,
                                      ),

                                      Text('tag'.tr, style: robotoBold),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),

                                      AnimatedBorderContainer(
                                        padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeSmall,
                                        ),
                                        isLoading:
                                            aiController.otherDataLoading,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 8,
                                                  child: CustomTextFieldWidget(
                                                    hintText: 'tag'.tr,
                                                    labelText: 'tag'.tr,
                                                    controller: _tagController,
                                                    inputAction:
                                                        TextInputAction.done,
                                                    onSubmit: (name) {
                                                      if (name != null &&
                                                          name.isNotEmpty) {
                                                        storeController.setTag(
                                                          name,
                                                        );
                                                        _tagController.text =
                                                            '';
                                                      }
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: Dimensions
                                                      .paddingSizeSmall,
                                                ),

                                                Expanded(
                                                  flex: 3,
                                                  child: CustomButtonWidget(
                                                    buttonText: 'add'.tr,
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    height: 50,
                                                    onPressed: () {
                                                      if (_tagController.text !=
                                                              '' &&
                                                          _tagController
                                                              .text
                                                              .isNotEmpty) {
                                                        storeController.setTag(
                                                          _tagController.text
                                                              .trim(),
                                                        );
                                                        _tagController.text =
                                                            '';
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeDefault,
                                            ),

                                            storeController.tagList.isNotEmpty
                                                ? SizedBox(
                                                    height: 40,
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: storeController
                                                          .tagList
                                                          .length,
                                                      itemBuilder: (context, index) {
                                                        return Container(
                                                          margin: const EdgeInsets.symmetric(
                                                            horizontal: Dimensions
                                                                .paddingSizeExtraSmall,
                                                          ),
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: Dimensions
                                                                .paddingSizeSmall,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .disabledColor
                                                                    .withValues(
                                                                      alpha:
                                                                          0.2,
                                                                    ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  Dimensions
                                                                      .radiusSmall,
                                                                ),
                                                          ),
                                                          child: Center(
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  storeController
                                                                      .tagList[index]!,
                                                                  style: robotoRegular.copyWith(
                                                                    color:
                                                                        Theme.of(
                                                                          context,
                                                                        ).disabledColor.withValues(
                                                                          alpha:
                                                                              0.7,
                                                                        ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: Dimensions
                                                                      .paddingSizeExtraSmall,
                                                                ),

                                                                InkWell(
                                                                  onTap: () =>
                                                                      storeController
                                                                          .removeTag(
                                                                            index,
                                                                          ),
                                                                  child: Icon(
                                                                    Icons.clear,
                                                                    size: 18,
                                                                    color:
                                                                        Theme.of(
                                                                          context,
                                                                        ).disabledColor.withValues(
                                                                          alpha:
                                                                              0.7,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeDefault,
                                      ),

                                      _module.itemAvailableTime!
                                          ? Text(
                                              'availability'.tr,
                                              style: robotoBold,
                                            )
                                          : const SizedBox(),
                                      SizedBox(
                                        height: _module.itemAvailableTime!
                                            ? Dimensions.paddingSizeSmall
                                            : 0,
                                      ),

                                      _module.itemAvailableTime!
                                          ? AnimatedBorderContainer(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Dimensions
                                                        .paddingSizeSmall,
                                                    vertical: Dimensions
                                                        .paddingSizeLarge,
                                                  ),
                                              isLoading:
                                                  aiController.otherDataLoading,
                                              child: Column(
                                                children: [
                                                  CustomTimePickerWidget(
                                                    title:
                                                        'available_time_starts'
                                                            .tr,
                                                    time: storeController
                                                        .availableTimeStarts,
                                                    onTimeChanged: (time) {
                                                      storeController
                                                          .setAvailableTimeStarts(
                                                            startTime: time,
                                                          );
                                                    },
                                                  ),
                                                  const SizedBox(
                                                    height: Dimensions
                                                        .paddingSizeExtraLarge,
                                                  ),

                                                  CustomTimePickerWidget(
                                                    title: 'available_time_ends'
                                                        .tr,
                                                    time: storeController
                                                        .availableTimeEnds,
                                                    onTimeChanged: (time) {
                                                      storeController
                                                          .setAvailableTimeEnds(
                                                            endTime: time,
                                                          );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox(),
                                      SizedBox(
                                        height: _module.itemAvailableTime!
                                            ? Dimensions.paddingSizeDefault
                                            : 0,
                                      ),

                                      Text(
                                        'thumbnail_image'.tr,
                                        style: robotoBold,
                                      ),
                                      const SizedBox(
                                        height:
                                            Dimensions.paddingSizeExtraSmall,
                                      ),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeSmall,
                                          vertical: Dimensions.paddingSizeLarge,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              spreadRadius: 0,
                                              blurRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault,
                                                        ),
                                                    child:
                                                        storeController
                                                                .rawLogo !=
                                                            null
                                                        ? GetPlatform.isWeb
                                                              ? Image.network(
                                                                  storeController
                                                                      .rawLogo!
                                                                      .path,
                                                                  width: 150,
                                                                  height: 150,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Image.file(
                                                                  File(
                                                                    storeController
                                                                        .rawLogo!
                                                                        .path,
                                                                  ),
                                                                  width: 150,
                                                                  height: 150,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                        : _item.imageFullUrl !=
                                                              null
                                                        ? CustomImageWidget(
                                                            image:
                                                                _item
                                                                    .imageFullUrl ??
                                                                '',
                                                            height: 150,
                                                            width: 150,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Container(
                                                            height: 150,
                                                            width: 150,
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  Get.isDarkMode
                                                                  ? Colors.white
                                                                        .withValues(
                                                                          alpha:
                                                                              0.05,
                                                                        )
                                                                  : const Color(
                                                                      0xFFFAFAFA,
                                                                    ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    Dimensions
                                                                        .radiusDefault,
                                                                  ),
                                                            ),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  CupertinoIcons
                                                                      .photo_camera_solid,
                                                                  color:
                                                                      Theme.of(
                                                                        context,
                                                                      ).disabledColor.withValues(
                                                                        alpha:
                                                                            0.5,
                                                                      ),
                                                                  size: 30,
                                                                ),
                                                                const SizedBox(
                                                                  height: Dimensions
                                                                      .paddingSizeDefault,
                                                                ),
                                                                Text(
                                                                  'click_to_upload'
                                                                      .tr,
                                                                  style: robotoBold.copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .fontSizeSmall,
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).disabledColor,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                  ),

                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    top: 0,
                                                    left: 0,
                                                    child: InkWell(
                                                      onTap: () =>
                                                          storeController
                                                              .pickImage(
                                                                true,
                                                                false,
                                                              ),
                                                      child: DottedBorder(
                                                        options: RoundedRectDottedBorderOptions(
                                                          radius:
                                                              const Radius.circular(
                                                                Dimensions
                                                                    .radiusDefault,
                                                              ),
                                                          dashPattern: const [
                                                            8,
                                                            4,
                                                          ],
                                                          strokeWidth: 1,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                    alpha: 0.5,
                                                                  ),
                                                        ),
                                                        child: const SizedBox(
                                                          height: 150,
                                                          width: 150,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeDefault,
                                            ),

                                            Text(
                                              'thumbnail_image_format'.tr,
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).disabledColor,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeDefault,
                                      ),

                                      // Item Image Section
                                      Row(
                                        children: [
                                          Text(
                                            'item_images'.tr,
                                            style: robotoBold,
                                          ),
                                          const SizedBox(
                                            width: Dimensions.paddingSizeSmall,
                                          ),

                                          Text(
                                            '(${'max_size_2_mb'.tr})',
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeExtraSmall,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              Dimensions.paddingSizeSmall,
                                          vertical: Dimensions.paddingSizeLarge,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(
                                            Dimensions.radiusDefault,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              spreadRadius: 0,
                                              blurRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                childAspectRatio: (1 / 1),
                                                mainAxisSpacing:
                                                    Dimensions.paddingSizeSmall,
                                                crossAxisSpacing:
                                                    Dimensions.paddingSizeSmall,
                                              ),
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:
                                              storeController
                                                  .savedImages
                                                  .length +
                                              storeController.rawImages.length +
                                              1,
                                          itemBuilder: (context, index) {
                                            bool savedImage =
                                                index <
                                                storeController
                                                    .savedImages
                                                    .length;
                                            XFile? file =
                                                (savedImage ||
                                                    index ==
                                                        (storeController
                                                                .rawImages
                                                                .length +
                                                            storeController
                                                                .savedImages
                                                                .length))
                                                ? null
                                                : storeController
                                                      .rawImages[index -
                                                      storeController
                                                          .savedImages
                                                          .length];
                                            if (index ==
                                                (storeController
                                                        .rawImages
                                                        .length +
                                                    storeController
                                                        .savedImages
                                                        .length)) {
                                              return InkWell(
                                                onTap: () {
                                                  if ((storeController
                                                              .savedImages
                                                              .length +
                                                          storeController
                                                              .rawImages
                                                              .length) <
                                                      6) {
                                                    storeController
                                                        .pickImages();
                                                  } else {
                                                    showCustomSnackBar(
                                                      'maximum_image_limit_is_6'
                                                          .tr,
                                                    );
                                                  }
                                                },
                                                child: DottedBorder(
                                                  options:
                                                      RoundedRectDottedBorderOptions(
                                                        radius:
                                                            const Radius.circular(
                                                              Dimensions
                                                                  .radiusDefault,
                                                            ),
                                                        dashPattern: const [
                                                          8,
                                                          4,
                                                        ],
                                                        strokeWidth: 1,
                                                        color: Theme.of(context)
                                                            .primaryColor
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                      ),
                                                  child: Container(
                                                    width: context.width,
                                                    height: context.width,
                                                    decoration: BoxDecoration(
                                                      color: Get.isDarkMode
                                                          ? Colors.white
                                                                .withValues(
                                                                  alpha: 0.05,
                                                                )
                                                          : const Color(
                                                              0xFFFAFAFA,
                                                            ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            Dimensions
                                                                .radiusDefault,
                                                          ),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          CupertinoIcons
                                                              .photo_camera_solid,
                                                          color:
                                                              Theme.of(context)
                                                                  .disabledColor
                                                                  .withValues(
                                                                    alpha: 0.5,
                                                                  ),
                                                          size: 30,
                                                        ),
                                                        const SizedBox(
                                                          height: Dimensions
                                                              .paddingSizeDefault,
                                                        ),
                                                        Text(
                                                          'click_to_upload'.tr,
                                                          style: robotoBold.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            color: Theme.of(
                                                              context,
                                                            ).disabledColor,
                                                          ),
                                                        ),
                                                        Text(
                                                          'image_format'.tr,
                                                          style: robotoRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeExtraSmall,
                                                            color: Theme.of(
                                                              context,
                                                            ).disabledColor,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                            return DottedBorder(
                                              options:
                                                  RoundedRectDottedBorderOptions(
                                                    radius:
                                                        const Radius.circular(
                                                          Dimensions
                                                              .radiusDefault,
                                                        ),
                                                    dashPattern: const [8, 4],
                                                    strokeWidth: 1,
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withValues(alpha: 0.5),
                                                  ),
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Dimensions
                                                              .radiusDefault,
                                                        ),
                                                    child: savedImage
                                                        ? CustomImageWidget(
                                                            image: storeController
                                                                .savedImages[index],
                                                            width:
                                                                context.width,
                                                            height:
                                                                context.width,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : GetPlatform.isWeb
                                                        ? Image.network(
                                                            file!.path,
                                                            width:
                                                                context.width,
                                                            height:
                                                                context.width,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.file(
                                                            File(file!.path),
                                                            width:
                                                                context.width,
                                                            height:
                                                                context.width,
                                                            fit: BoxFit.cover,
                                                          ),
                                                  ),

                                                  Positioned(
                                                    right: 0,
                                                    top: 0,
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (savedImage) {
                                                          storeController
                                                              .removeSavedImage(
                                                                index,
                                                              );
                                                        } else {
                                                          storeController.removeImage(
                                                            index -
                                                                storeController
                                                                    .savedImages
                                                                    .length,
                                                          );
                                                        }
                                                      },
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(
                                                          Dimensions
                                                              .paddingSizeSmall,
                                                        ),
                                                        child: Icon(
                                                          Icons.delete_forever,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeSmall,
                                      ),

                                      _buildProductVideoSection(context),

                                      // Meta Section
                                      isEcommerce
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeDefault,
                                                ),
                                                Text(
                                                  'meta_data'.tr,
                                                  style: robotoBold,
                                                ),
                                                const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                                Text(
                                                  'meta_data_des'.tr,
                                                  style: robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(
                                                      context,
                                                    ).disabledColor,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                                CustomCard(
                                                  width: context.width,
                                                  padding: const EdgeInsets.all(
                                                    Dimensions
                                                        .paddingSizeDefault,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CustomTextFieldWidget(
                                                        hintText: 'title'.tr,
                                                        labelText: 'title'.tr,
                                                        controller:
                                                            _metaTitleController,
                                                        capitalization:
                                                            TextCapitalization
                                                                .words,
                                                        focusNode:
                                                            _metaTitleNode,
                                                        nextFocus:
                                                            _metaDescriptionNode,
                                                        showTitle: false,
                                                        required: true,
                                                      ),
                                                      const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeExtraLarge,
                                                      ),

                                                      CustomTextFieldWidget(
                                                        hintText:
                                                            'meta_description'
                                                                .tr,
                                                        labelText:
                                                            'description'.tr,
                                                        controller:
                                                            _metaDescriptionController,
                                                        focusNode:
                                                            _metaDescriptionNode,
                                                        capitalization:
                                                            TextCapitalization
                                                                .sentences,
                                                        maxLines: 5,
                                                        inputAction:
                                                            TextInputAction
                                                                .done,
                                                        nextFocus: null,
                                                        showTitle: false,
                                                        required: true,
                                                      ),
                                                      const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeDefault,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'meta_image'.tr,
                                                            style: robotoMedium
                                                                .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                          Text(
                                                            'image_format_and_ratio_for_business_logo'
                                                                .tr,
                                                            style: robotoRegular
                                                                .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeSmall,
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).hintColor,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: Dimensions
                                                                .paddingSizeSmall,
                                                          ),
                                                          Stack(
                                                            clipBehavior:
                                                                Clip.none,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      2,
                                                                    ),
                                                                child: ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        Dimensions
                                                                            .radiusDefault,
                                                                      ),
                                                                  child:
                                                                      storeController
                                                                              .pickedMetaImage !=
                                                                          null
                                                                      ? GetPlatform.isWeb
                                                                            ? Image.network(
                                                                                storeController.pickedMetaImage!.path,
                                                                                width: double.infinity,
                                                                                height: 150,
                                                                                fit: BoxFit.cover,
                                                                              )
                                                                            : Image.file(
                                                                                File(
                                                                                  storeController.pickedMetaImage!.path,
                                                                                ),
                                                                                width: double.infinity,
                                                                                height: 150,
                                                                                fit: BoxFit.cover,
                                                                              )
                                                                      : _item.metaImageFullUrl !=
                                                                            null
                                                                      ? CustomImageWidget(
                                                                          image:
                                                                              _item.metaImageFullUrl ??
                                                                              '',
                                                                          height:
                                                                              150,
                                                                          width:
                                                                              double.infinity,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        )
                                                                      : SizedBox(
                                                                          height:
                                                                              150,
                                                                          width:
                                                                              double.infinity,
                                                                          child: Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Icon(
                                                                                CupertinoIcons.photo_camera_solid,
                                                                                color:
                                                                                    Theme.of(
                                                                                      context,
                                                                                    ).disabledColor.withValues(
                                                                                      alpha: 0.5,
                                                                                    ),
                                                                                size: 30,
                                                                              ),
                                                                              const SizedBox(
                                                                                height: Dimensions.paddingSizeDefault,
                                                                              ),
                                                                              Text(
                                                                                'click_to_upload'.tr,
                                                                                style: robotoBold.copyWith(
                                                                                  fontSize: Dimensions.fontSizeSmall,
                                                                                  color: Theme.of(
                                                                                    context,
                                                                                  ).disabledColor,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                ),
                                                              ),

                                                              Positioned(
                                                                bottom: 0,
                                                                right: 0,
                                                                top: 0,
                                                                left: 0,
                                                                child: InkWell(
                                                                  onTap: () =>
                                                                      storeController
                                                                          .pickMetaImage(),
                                                                  child: DottedBorder(
                                                                    options: RoundedRectDottedBorderOptions(
                                                                      radius: const Radius.circular(
                                                                        Dimensions
                                                                            .radiusDefault,
                                                                      ),
                                                                      dashPattern:
                                                                          const [
                                                                            8,
                                                                            4,
                                                                          ],
                                                                      strokeWidth:
                                                                          1,
                                                                      color: Theme.of(
                                                                        context,
                                                                      ).hintColor,
                                                                    ),
                                                                    child: const SizedBox(
                                                                      width:
                                                                          120,
                                                                      height:
                                                                          120,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),

                                                              Positioned(
                                                                top: -10,
                                                                right: -10,
                                                                child: InkWell(
                                                                  onTap: () =>
                                                                      storeController
                                                                          .pickMetaImage(),
                                                                  child: Container(
                                                                    padding: const EdgeInsets.all(
                                                                      Dimensions
                                                                          .paddingSizeExtraSmall,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color: Theme.of(
                                                                        context,
                                                                      ).cardColor,
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                          color:
                                                                              Colors.black12,
                                                                          spreadRadius:
                                                                              0,
                                                                          blurRadius:
                                                                              5,
                                                                        ),
                                                                      ],
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      border: Border.all(
                                                                        color: Colors
                                                                            .blue,
                                                                        width:
                                                                            0.5,
                                                                      ),
                                                                    ),
                                                                    child: const Icon(
                                                                      Icons
                                                                          .edit,
                                                                      color: Colors
                                                                          .blue,
                                                                      size: 16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeDefault,
                                                      ),

                                                      Container(
                                                        width: double.infinity,
                                                        padding: EdgeInsets.all(
                                                          Dimensions
                                                              .paddingSizeSmall,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .disabledColor
                                                                  .withValues(
                                                                    alpha: 0.07,
                                                                  ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                Dimensions
                                                                    .radiusDefault,
                                                              ),
                                                        ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                Dimensions
                                                                    .paddingSizeSmall,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Theme.of(
                                                              context,
                                                            ).cardColor,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  Dimensions
                                                                      .radiusDefault,
                                                                ),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeDefault,
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  storeController
                                                                      .setMetaIndex(
                                                                        'index',
                                                                      );
                                                                  storeController
                                                                      .setNoFollow(
                                                                        '0',
                                                                      );
                                                                  storeController
                                                                      .setNoImageIndex(
                                                                        '0',
                                                                      );
                                                                  storeController
                                                                      .setNoArchive(
                                                                        '0',
                                                                      );
                                                                  storeController
                                                                      .setNoSnippet(
                                                                        '0',
                                                                      );
                                                                },
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          Dimensions
                                                                              .paddingSizeExtraSmall +
                                                                          2,
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          20,
                                                                      width: 20,
                                                                      child: RadioGroup<String>(
                                                                        groupValue:
                                                                            storeController.metaIndex,
                                                                        onChanged: (value) {
                                                                          storeController.setMetaIndex(
                                                                            value!,
                                                                          );
                                                                          storeController.setNoFollow(
                                                                            '0',
                                                                          );
                                                                          storeController.setNoImageIndex(
                                                                            '0',
                                                                          );
                                                                          storeController.setNoArchive(
                                                                            '0',
                                                                          );
                                                                          storeController.setNoSnippet(
                                                                            '0',
                                                                          );
                                                                        },
                                                                        child:
                                                                            Radio<
                                                                              String
                                                                            >(
                                                                              value: 'index',
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: Dimensions
                                                                          .paddingSizeSmall,
                                                                    ),

                                                                    Text(
                                                                      'index'
                                                                          .tr,
                                                                      style: robotoRegular.copyWith(
                                                                        fontSize:
                                                                            Dimensions.fontSizeDefault,
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).textTheme.bodyLarge?.color,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: Dimensions
                                                                          .paddingSizeSmall,
                                                                    ),

                                                                    CustomToolTip(
                                                                      message:
                                                                          'allow_search_engines_to_index_this_page'
                                                                              .tr,
                                                                      size: 16,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeSmall,
                                                              ),

                                                              MetaSeoItem(
                                                                title:
                                                                    'no_follow'
                                                                        .tr,
                                                                value:
                                                                    storeController
                                                                            .noFollow ==
                                                                        'nofollow'
                                                                    ? true
                                                                    : false,
                                                                callback: (bool? value) {
                                                                  storeController
                                                                      .setNoFollow(
                                                                        value!
                                                                            ? 'nofollow'
                                                                            : '0',
                                                                      );
                                                                },
                                                                message:
                                                                    'instruct_search_engines_not_to_follow_links_from_this_page'
                                                                        .tr,
                                                              ),

                                                              MetaSeoItem(
                                                                title:
                                                                    'no_image_index'
                                                                        .tr,
                                                                value:
                                                                    storeController
                                                                            .noImageIndex ==
                                                                        'noimageindex'
                                                                    ? true
                                                                    : false,
                                                                callback: (bool? value) {
                                                                  storeController
                                                                      .setNoImageIndex(
                                                                        value!
                                                                            ? 'noimageindex'
                                                                            : '0',
                                                                      );
                                                                },
                                                                message:
                                                                    'prevent_images_from_being_indexed'
                                                                        .tr,
                                                              ),
                                                              const SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeSmall,
                                                              ),

                                                              InkWell(
                                                                onTap: () {
                                                                  storeController
                                                                      .setMetaIndex(
                                                                        'noindex',
                                                                      );
                                                                  storeController
                                                                      .setNoFollow(
                                                                        'nofollow',
                                                                      );
                                                                  storeController
                                                                      .setNoImageIndex(
                                                                        'noimageindex',
                                                                      );
                                                                  storeController
                                                                      .setNoArchive(
                                                                        'noarchive',
                                                                      );
                                                                  storeController
                                                                      .setNoSnippet(
                                                                        'nosnippet',
                                                                      );
                                                                },
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          Dimensions
                                                                              .paddingSizeExtraSmall +
                                                                          2,
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          20,
                                                                      width: 20,
                                                                      child: RadioGroup<String>(
                                                                        groupValue:
                                                                            storeController.metaIndex,
                                                                        onChanged: (value) {
                                                                          storeController.setMetaIndex(
                                                                            value!,
                                                                          );
                                                                          storeController.setNoFollow(
                                                                            'nofollow',
                                                                          );
                                                                          storeController.setNoImageIndex(
                                                                            'noimageindex',
                                                                          );
                                                                          storeController.setNoArchive(
                                                                            'noarchive',
                                                                          );
                                                                          storeController.setNoSnippet(
                                                                            'nosnippet',
                                                                          );
                                                                        },
                                                                        child:
                                                                            Radio<
                                                                              String
                                                                            >(
                                                                              value: 'noindex',
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: Dimensions
                                                                          .paddingSizeSmall,
                                                                    ),

                                                                    Text(
                                                                      'no_index'
                                                                          .tr,
                                                                      style: robotoRegular.copyWith(
                                                                        fontSize:
                                                                            Dimensions.fontSizeDefault,
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).textTheme.bodyLarge?.color,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: Dimensions
                                                                          .paddingSizeSmall,
                                                                    ),

                                                                    CustomToolTip(
                                                                      message:
                                                                          'disallow_search_engines_from_indexing_this_page'
                                                                              .tr,
                                                                      size: 16,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: Dimensions
                                                                    .paddingSizeSmall,
                                                              ),

                                                              MetaSeoItem(
                                                                title:
                                                                    'no_archive'
                                                                        .tr,
                                                                value:
                                                                    storeController
                                                                            .noArchive ==
                                                                        'noarchive'
                                                                    ? true
                                                                    : false,
                                                                callback: (bool? value) {
                                                                  storeController
                                                                      .setNoArchive(
                                                                        value!
                                                                            ? 'noarchive'
                                                                            : '0',
                                                                      );
                                                                },
                                                                message:
                                                                    'prevent_search_engines_from_caching_this_page'
                                                                        .tr,
                                                              ),

                                                              MetaSeoItem(
                                                                title:
                                                                    'no_snippet'
                                                                        .tr,
                                                                value:
                                                                    storeController
                                                                            .noSnippet ==
                                                                        'nosnippet'
                                                                    ? true
                                                                    : false,
                                                                callback: (bool? value) {
                                                                  storeController
                                                                      .setNoSnippet(
                                                                        value!
                                                                            ? 'nosnippet'
                                                                            : '0',
                                                                      );
                                                                },
                                                                message:
                                                                    'prevent_search_engines_from_showing_snippet'
                                                                        .tr,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeLarge,
                                                      ),

                                                      Container(
                                                        width: double.infinity,
                                                        padding: EdgeInsets.all(
                                                          Dimensions
                                                              .paddingSizeSmall,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .disabledColor
                                                                  .withValues(
                                                                    alpha: 0.07,
                                                                  ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                Dimensions
                                                                    .radiusDefault,
                                                              ),
                                                        ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                Dimensions
                                                                    .paddingSizeSmall,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Theme.of(
                                                              context,
                                                            ).cardColor,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  Dimensions
                                                                      .radiusDefault,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 3,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    MetaSeoItem(
                                                                      title:
                                                                          'max_snippet'
                                                                              .tr,
                                                                      value:
                                                                          storeController.maxSnippet ==
                                                                              '1'
                                                                          ? true
                                                                          : false,
                                                                      callback:
                                                                          (
                                                                            bool?
                                                                            value,
                                                                          ) {
                                                                            storeController.setMaxSnippet(
                                                                              value!
                                                                                  ? '1'
                                                                                  : '0',
                                                                            );
                                                                          },
                                                                    ),
                                                                    SizedBox(
                                                                      height: Dimensions
                                                                          .paddingSizeSmall,
                                                                    ),
                                                                    MetaSeoItem(
                                                                      title:
                                                                          'max_video_preview'
                                                                              .tr,
                                                                      value:
                                                                          storeController.maxVideoPreview ==
                                                                              '1'
                                                                          ? true
                                                                          : false,
                                                                      callback:
                                                                          (
                                                                            bool?
                                                                            value,
                                                                          ) {
                                                                            storeController.setMaxVideoPreview(
                                                                              value!
                                                                                  ? '1'
                                                                                  : '0',
                                                                            );
                                                                          },
                                                                    ),
                                                                    SizedBox(
                                                                      height: Dimensions
                                                                          .paddingSizeSmall,
                                                                    ),
                                                                    MetaSeoItem(
                                                                      title:
                                                                          'max_image_preview'
                                                                              .tr,
                                                                      value:
                                                                          storeController.maxImagePreview ==
                                                                              '1'
                                                                          ? true
                                                                          : false,
                                                                      callback:
                                                                          (
                                                                            bool?
                                                                            value,
                                                                          ) {
                                                                            storeController.setMaxImagePreview(
                                                                              value!
                                                                                  ? '1'
                                                                                  : '0',
                                                                            );
                                                                          },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: Dimensions
                                                                    .paddingSizeDefault,
                                                              ),

                                                              Expanded(
                                                                flex: 2,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          48,
                                                                      child: CustomTextFieldWidget(
                                                                        hintText:
                                                                            'ex_1'.tr,
                                                                        showLabelText:
                                                                            false,
                                                                        inputType:
                                                                            TextInputType.number,
                                                                        controller:
                                                                            _maxSnippetController,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: Dimensions
                                                                          .paddingSizeSmall,
                                                                    ),

                                                                    SizedBox(
                                                                      height:
                                                                          48,
                                                                      child: CustomTextFieldWidget(
                                                                        hintText:
                                                                            'ex_1'.tr,
                                                                        showLabelText:
                                                                            false,
                                                                        inputType:
                                                                            TextInputType.number,
                                                                        controller:
                                                                            _maxVideoPreviewController,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: Dimensions
                                                                          .paddingSizeSmall,
                                                                    ),

                                                                    Container(
                                                                      height:
                                                                          48,
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            Dimensions.paddingSizeSmall,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                          color: Theme.of(
                                                                            context,
                                                                          ).disabledColor,
                                                                        ),
                                                                        borderRadius: BorderRadius.circular(
                                                                          Dimensions
                                                                              .radiusDefault,
                                                                        ),
                                                                      ),
                                                                      child: DropdownButton<String>(
                                                                        value: storeController
                                                                            .imagePreviewSelectedType,
                                                                        items: storeController.imagePreviewType.map((
                                                                          String
                                                                          value,
                                                                        ) {
                                                                          return DropdownMenuItem<
                                                                            String
                                                                          >(
                                                                            value:
                                                                                value,
                                                                            child: FittedBox(
                                                                              fit: BoxFit.scaleDown,
                                                                              alignment: Alignment.centerLeft,
                                                                              child: Text(
                                                                                value.tr,
                                                                                style: robotoRegular.copyWith(
                                                                                  fontSize: Dimensions.fontSizeDefault,
                                                                                  color: Theme.of(
                                                                                    context,
                                                                                  ).textTheme.bodyLarge?.color,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged: (value) {
                                                                          storeController.setImagePreviewType(
                                                                            value!,
                                                                          );
                                                                        },
                                                                        isExpanded:
                                                                            true,
                                                                        underline:
                                                                            const SizedBox(),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : SizedBox.shrink(),
                                      const SizedBox(
                                        height: Dimensions.paddingSizeDefault,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Button
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeSmall,
                                  horizontal: Dimensions.paddingSizeLarge,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      spreadRadius: 0,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: CustomButtonWidget(
                                  buttonText: _update
                                      ? 'update'.tr
                                      : 'submit'.tr,
                                  isLoading: storeController.isLoading,
                                  onPressed: () {
                                    String price = _priceController.text.trim();
                                    String discount = _discountController.text
                                        .trim();
                                    int maxOrderQuantity =
                                        _maxOrderQuantityController
                                            .text
                                            .isNotEmpty
                                        ? int.parse(
                                            _maxOrderQuantityController.text,
                                          )
                                        : 0;
                                    bool haveBlankVariant = false;
                                    bool blankVariantPrice = false;
                                    bool blankVariantStock = false;

                                    bool variationNameEmpty = false;
                                    bool variationMinMaxEmpty = false;
                                    bool variationOptionNameEmpty = false;
                                    bool variationOptionPriceEmpty = false;
                                    bool variationMinLessThenZero = false;
                                    bool variationMaxSmallThenMin = false;
                                    bool variationMaxBigThenOptions = false;
                                    String metaTitle = _metaTitleController.text
                                        .trim();
                                    String metaDescription =
                                        _metaDescriptionController.text.trim();

                                    for (AttributeModel attr
                                        in storeController.attributeList!) {
                                      if (attr.active &&
                                          attr.variants.isEmpty) {
                                        haveBlankVariant = true;
                                        break;
                                      }
                                    }
                                    if (Get.find<SplashController>()
                                        .getStoreModuleConfig()
                                        .newVariation!) {
                                      for (VariationModelBodyModel
                                          variationModel
                                          in storeController.variationList!) {
                                        if (variationModel
                                            .nameController!
                                            .text
                                            .isEmpty) {
                                          variationNameEmpty = true;
                                        } else if (!variationModel.isSingle) {
                                          if (variationModel
                                                  .minController!
                                                  .text
                                                  .isEmpty ||
                                              variationModel
                                                  .maxController!
                                                  .text
                                                  .isEmpty) {
                                            variationMinMaxEmpty = true;
                                          } else if (int.parse(
                                                variationModel
                                                    .minController!
                                                    .text,
                                              ) <
                                              1) {
                                            variationMinLessThenZero = true;
                                          } else if (int.parse(
                                                variationModel
                                                    .maxController!
                                                    .text,
                                              ) <
                                              int.parse(
                                                variationModel
                                                    .minController!
                                                    .text,
                                              )) {
                                            variationMaxSmallThenMin = true;
                                          } else if (int.parse(
                                                variationModel
                                                    .maxController!
                                                    .text,
                                              ) >
                                              variationModel.options!.length) {
                                            variationMaxBigThenOptions = true;
                                          }
                                        } else {
                                          for (Option option
                                              in variationModel.options!) {
                                            if (option
                                                .optionNameController!
                                                .text
                                                .isEmpty) {
                                              variationOptionNameEmpty = true;
                                            } else if (option
                                                .optionPriceController!
                                                .text
                                                .isEmpty) {
                                              variationOptionPriceEmpty = true;
                                            }
                                          }
                                        }
                                      }
                                    } else {
                                      for (VariantTypeModel variantType
                                          in storeController.variantTypeList!) {
                                        if (variantType
                                            .priceController
                                            .text
                                            .isEmpty) {
                                          blankVariantPrice = true;
                                          break;
                                        }
                                        if (_module.stock! &&
                                            variantType
                                                .stockController
                                                .text
                                                .isEmpty) {
                                          blankVariantStock = true;
                                          break;
                                        }
                                      }
                                    }

                                    bool defaultDataNull = false;
                                    for (
                                      int index = 0;
                                      index < _languageList.length;
                                      index++
                                    ) {
                                      if (_languageList[index].key == 'en') {
                                        if (_nameControllerList[index].text
                                                .trim()
                                                .isEmpty ||
                                            _descriptionControllerList[index]
                                                .text
                                                .trim()
                                                .isEmpty) {
                                          defaultDataNull = true;
                                        }
                                        break;
                                      }
                                    }

                                    bool checkDiscountWithVariationPrice =
                                        false;
                                    if (storeController.discountTypeIndex ==
                                            1 &&
                                        storeController
                                            .variantTypeList!
                                            .isNotEmpty) {
                                      for (VariantTypeModel variantType
                                          in storeController.variantTypeList!) {
                                        double variantPrice = double.parse(
                                          variantType.priceController.text,
                                        );
                                        double discountValue = double.parse(
                                          discount,
                                        );
                                        if (variantPrice < discountValue) {
                                          checkDiscountWithVariationPrice =
                                              true;
                                          break;
                                        }
                                      }
                                    }

                                    if (_videoUploadType == 'link' &&
                                        !_removeProductVideo &&
                                        _productVideoLinkController.text
                                            .trim()
                                            .isEmpty) {
                                      showCustomSnackBar('enter_video_link'.tr);
                                    } else if (_videoUploadType == 'link' &&
                                        !_removeProductVideo &&
                                        !_isValidProductVideoLink(
                                          _productVideoLinkController.text,
                                        )) {
                                      showCustomSnackBar(
                                        'invalid_product_video_link'.tr,
                                      );
                                    } else if (defaultDataNull) {
                                      showCustomSnackBar(
                                        'enter_data_for_english'.tr,
                                      );
                                    } else if (categoryController
                                            .selectedCategoryID ==
                                        null) {
                                      showCustomSnackBar(
                                        'select_a_category'.tr,
                                      );
                                    } else if (Get.find<SplashController>()
                                                .configModel!
                                                .systemTaxType ==
                                            'product_wise' &&
                                        storeController
                                            .selectedVatTaxIdList
                                            .isEmpty) {
                                      showCustomSnackBar('select_vat_tax'.tr);
                                    } else if (price.isEmpty) {
                                      showCustomSnackBar('enter_item_price'.tr);
                                    } else if (!_discountTypeSelected) {
                                      showCustomSnackBar(
                                        'enter_discount_type'.tr,
                                      );
                                    } else if (discount.isEmpty) {
                                      showCustomSnackBar(
                                        'enter_item_discount'.tr,
                                      );
                                    } else if (haveBlankVariant) {
                                      showCustomSnackBar(
                                        'add_at_least_one_variant_for_every_attribute'
                                            .tr,
                                      );
                                    } else if (storeController
                                        .unresolvedTechnicalModels
                                        .isNotEmpty) {
                                      showCustomSnackBar(
                                        'technical_model_brand_required'.tr,
                                      );
                                    } else if (blankVariantPrice) {
                                      showCustomSnackBar(
                                        'enter_price_for_every_variant'.tr,
                                      );
                                    } else if (variationNameEmpty) {
                                      showCustomSnackBar(
                                        'enter_name_for_every_variation'.tr,
                                      );
                                    } else if (variationMinMaxEmpty) {
                                      showCustomSnackBar(
                                        'enter_min_max_for_every_multipart_variation'
                                            .tr,
                                      );
                                    } else if (variationOptionNameEmpty) {
                                      showCustomSnackBar(
                                        'enter_option_name_for_every_variation'
                                            .tr,
                                      );
                                    } else if (variationOptionPriceEmpty) {
                                      showCustomSnackBar(
                                        'enter_option_price_for_every_variation'
                                            .tr,
                                      );
                                    } else if (variationMinLessThenZero) {
                                      showCustomSnackBar(
                                        'minimum_type_cant_be_less_then_1'.tr,
                                      );
                                    } else if (variationMaxSmallThenMin) {
                                      showCustomSnackBar(
                                        'max_type_cant_be_less_then_minimum_type'
                                            .tr,
                                      );
                                    } else if (variationMaxBigThenOptions) {
                                      showCustomSnackBar(
                                        'max_type_length_should_not_be_more_then_options_length'
                                            .tr,
                                      );
                                    } else if (_module.stock! &&
                                        blankVariantStock) {
                                      showCustomSnackBar(
                                        'enter_stock_for_every_variant'.tr,
                                      );
                                    } else if (_module.stock! &&
                                        storeController
                                            .variantTypeList!
                                            .isEmpty &&
                                        _stockController.text.trim().isEmpty) {
                                      showCustomSnackBar('enter_stock'.tr);
                                    } else if (isEcommerce &&
                                        metaTitle.isEmpty) {
                                      showCustomSnackBar('enter_meta_title'.tr);
                                    } else if (isEcommerce &&
                                        metaDescription.isEmpty) {
                                      showCustomSnackBar(
                                        'enter_meta_description'.tr,
                                      );
                                    } else if (_module.unit! &&
                                        (storeController.unitIndex == null)) {
                                      showCustomSnackBar('add_an_unit'.tr);
                                    } else if (maxOrderQuantity < 0) {
                                      showCustomSnackBar(
                                        'maximum_item_order_quantity_can_not_be_negative'
                                            .tr,
                                      );
                                    } else if (_module.itemAvailableTime! &&
                                        storeController.availableTimeStarts ==
                                            null) {
                                      showCustomSnackBar('pick_start_time'.tr);
                                    } else if (_module.itemAvailableTime! &&
                                        storeController.availableTimeEnds ==
                                            null) {
                                      showCustomSnackBar('pick_end_time'.tr);
                                    } else if (!_update &&
                                        storeController.rawLogo == null &&
                                        _item.imageFullUrl == null) {
                                      showCustomSnackBar(
                                        'upload_item_thumbnail_image'.tr,
                                      );
                                    } else if (!_update &&
                                        (Get.find<SplashController>()
                                                .getStoreModuleConfig()
                                                .newVariation!
                                            ? false
                                            : storeController
                                                  .rawImages
                                                  .isEmpty)) {
                                      showCustomSnackBar(
                                        'upload_item_image'.tr,
                                      );
                                    } else if (checkDiscountWithVariationPrice) {
                                      showCustomSnackBar(
                                        'discount_cant_be_more_then_minimum_variation_price'
                                            .tr,
                                      );
                                    } else {
                                      MetaSeoData metaSeoData = MetaSeoData(
                                        metaIndex: storeController.metaIndex,
                                        metaNoFollow: storeController.noFollow,
                                        metaNoImageIndex:
                                            storeController.noImageIndex,
                                        metaNoArchive:
                                            storeController.noArchive,
                                        metaNoSnippet:
                                            storeController.noSnippet,
                                        metaMaxSnippet:
                                            storeController.maxSnippet,
                                        metaMaxVideoPreview:
                                            storeController.maxVideoPreview,
                                        metaMaxImagePreview:
                                            storeController.maxImagePreview,
                                        metaMaxSnippetValue:
                                            _maxSnippetController.text.trim(),
                                        metaMaxVideoPreviewValue:
                                            _maxVideoPreviewController.text
                                                .trim(),
                                        metaMaxImagePreviewValue:
                                            storeController
                                                .imagePreviewSelectedType,
                                      );
                                      _item.metaData = metaSeoData;
                                      _item.metaTitle = metaTitle;
                                      _item.metaDescription = metaDescription;
                                      _item.veg = storeController.isVeg ? 1 : 0;
                                      _item.isPrescriptionRequired =
                                          storeController.isPrescriptionRequired
                                          ? 1
                                          : 0;
                                      _item.isHalal = storeController.isHalal
                                          ? 1
                                          : 0;
                                      _item.isBasicMedicine =
                                          storeController.isBasicMedicine
                                          ? 1
                                          : 0;
                                      _item.price = double.parse(price);
                                      _item.discount = double.parse(discount);
                                      _item.discountType =
                                          storeController.discountTypeIndex == 0
                                          ? 'percent'
                                          : 'amount';
                                      _item.availableTimeStarts =
                                          storeController.availableTimeStarts;
                                      _item.availableTimeEnds =
                                          storeController.availableTimeEnds;
                                      _item.categoryIds = [];
                                      _item.maxOrderQuantity = maxOrderQuantity;
                                      _item.categoryIds!.add(
                                        CategoryIds(
                                          id: categoryController
                                              .selectedCategoryID,
                                        ),
                                      );
                                      if (categoryController
                                              .selectedSubCategoryID !=
                                          null) {
                                        _item.categoryIds!.add(
                                          CategoryIds(
                                            id: categoryController
                                                .selectedSubCategoryID,
                                          ),
                                        );
                                      } else {
                                        if (_item.categoryIds!.length > 1) {
                                          _item.categoryIds!.removeAt(1);
                                        }
                                      }
                                      _item.addOns = [];
                                      for (var index
                                          in storeController.selectedAddons!) {
                                        _item.addOns!.add(
                                          Get.find<AddonController>()
                                              .addonList![index],
                                        );
                                      }
                                      if (_module.unit! &&
                                          storeController.unitList != null &&
                                          storeController
                                              .unitList!
                                              .isNotEmpty) {
                                        _item.unitType = storeController
                                            .unitList![storeController
                                                .unitIndex!]
                                            .id
                                            .toString();
                                      }
                                      if (_module.stock!) {
                                        _item.stock = int.parse(
                                          _stockController.text.trim(),
                                        );
                                      }
                                      if (Get.find<SplashController>()
                                              .configModel!
                                              .systemTaxType ==
                                          'product_wise') {
                                        _item.taxVatIds = [];
                                        _item.taxVatIds = storeController
                                            .selectedVatTaxIdList;
                                      }

                    ])
                  ),

                  Expanded(
                    child: Row(children: [
                      RadioGroup(
                        groupValue: storeController.isVeg ? 'veg' : 'non_veg',
                        onChanged: (String? value) => storeController.setVeg(value == 'veg', true),
                        child: Radio(value: 'non_veg',
                          fillColor: WidgetStateProperty.all<Color>(storeController.isVeg ? Theme.of(context).disabledColor : Theme.of(context).primaryColor)
                        )
                      ),
                      Text(
                        'non_veg'.tr, style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall, color: storeController.isVeg ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge?.color)
                      ),
                    ])
                  ),
                ])
              )  : const SizedBox(),
              SizedBox(height: vatTaxEnable && (module.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!) ? Dimensions.paddingSizeExtraLarge : 0),

              (isFood || isGrocery) && Get.find<ProfileController>().profileModel!.stores!.isHalalActive! ? LabelWidget(
                labelText: 'halal_tag'.tr,
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeExtraSmall, bottom: Dimensions.paddingSizeExtraSmall),
                child: Row(children: [
                  Expanded(child: Text('status'.tr, style: robotoMedium)),
                  Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      value: storeController.isHalal,
                      onChanged: (bool isChecked) => storeController.toggleHalal(),
                      activeTrackColor: Theme.of(context).primaryColor
                    )
                  ),

                ])
              ) : const SizedBox(),
              SizedBox(height: (isFood || isGrocery) && Get.find<ProfileController>().profileModel!.stores!.isHalalActive! ? Dimensions.paddingSizeExtraLarge : 0),

              isPharmacy ? LabelWidget(
                labelText: 'basic_medicine'.tr,
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeExtraSmall, bottom: Dimensions.paddingSizeExtraSmall
                ),
                child: Row(children: [

                  Expanded(child: Text('status'.tr, style: robotoMedium)),

                  Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      value: storeController.isBasicMedicine,
                      onChanged: (bool? isChecked) => storeController.toggleBasicMedicine(),
                      activeTrackColor: Theme.of(context).primaryColor
                    )
                  ),

                ])
              ) : const SizedBox(),
              SizedBox(height: isPharmacy ? Dimensions.paddingSizeExtraLarge : 0),

              vatTaxEnable ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomDropdownButton(
                  dropdownMenuItems: storeController.vatTaxList?.map((e) {
                    bool isInVatTaxList = storeController.selectedVatTaxNameList.contains(e.name);
                    return DropdownMenuItem<String>(
                      value: e.name,
                      child: Row(
                        children: [
                          Text('${e.name!} (${e.taxRate}%)', style: robotoRegular),
                          const Spacer(),
                          if (isInVatTaxList)
                            const Icon(Icons.check, color: Colors.green),
                        ]
                      )
                    );
                  }).toList(),
                  showTitle: false,
                  hintText: '${'select_vat_tax'.tr} *',
                  onChanged: (String? value) {
                    final selectedVatTax = storeController.vatTaxList?.firstWhere((vatTax) => vatTax.name == value);
                    if (selectedVatTax != null) {
                      storeController.setSelectedVatTax(selectedVatTax.name, selectedVatTax.id, selectedVatTax.taxRate);
                    }
                  },
                  selectedValue: null,
                  selectedItemBuilder: (context) {
                    return storeController.vatTaxList?.map((e) {
                      return Text('select_vat_tax'.tr, style: robotoRegular.copyWith(color: Colors.grey));
                    }).toList() ?? [];
                  }
                ),
                SizedBox(height: storeController.selectedVatTaxNameList.isNotEmpty ? Dimensions.paddingSizeSmall : 0),

                Wrap(
                  children: List.generate(storeController.selectedVatTaxNameList.length, (index) {
                    final vatTaxName = storeController.selectedVatTaxNameList[index];
                    final vatTaxId = storeController.selectedVatTaxIdList[index];
                    final taxRate = storeController.selectedTaxRateList[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      child: Stack(clipBehavior: Clip.none, children: [
                        FilterChip(
                          label: Text('$vatTaxName ($taxRate%)'),
                          selected: false,
                          onSelected: (bool value) {}
                        ),

                                      _item.translations = [];
                                      _item.translations!.addAll(translations);

                                      _item.brandId =
                                          storeController.brandList != null &&
                                              storeController
                                                  .brandList!
                                                  .isNotEmpty
                                          ? storeController
                                                .brandList![storeController
                                                    .brandIndex!]
                                                .id
                                          : 0;
                                      _item.conditionId =
                                          storeController.suitableTagList !=
                                                  null &&
                                              storeController
                                                  .suitableTagList!
                                                  .isNotEmpty
                                          ? storeController
                                                .suitableTagList![storeController
                                                    .suitableTagIndex!]
                                                .id
                                          : 0;
                                      bool hasEmptyValue = false;
                                      if (Get.find<SplashController>()
                                          .getStoreModuleConfig()
                                          .newVariation!) {
                                        _item.foodVariations = [];
                                        for (VariationModelBodyModel variation
                                            in storeController.variationList!) {
                                          if (variation.nameController!.text
                                              .trim()
                                              .isEmpty) {
                                            hasEmptyValue = true;
                                            break;
                                          }
                                          List<VariationValue> values = [];
                                          for (Option option
                                              in variation.options!) {
                                            if (option
                                                    .optionNameController!
                                                    .text
                                                    .trim()
                                                    .isEmpty ||
                                                option
                                                    .optionPriceController!
                                                    .text
                                                    .trim()
                                                    .isEmpty) {
                                              hasEmptyValue = true;
                                              break;
                                            }
                                            values.add(
                                              VariationValue(
                                                level: option
                                                    .optionNameController!
                                                    .text
                                                    .trim(),
                                                optionPrice: option
                                                    .optionPriceController!
                                                    .text
                                                    .trim(),
                                              ),
                                            );
                                          }
                                          if (hasEmptyValue) {
                                            break;
                                          }
                                          _item.foodVariations!.add(
                                            FoodVariation(
                                              name: variation
                                                  .nameController!
                                                  .text
                                                  .trim(),
                                              type: variation.isSingle
                                                  ? 'single'
                                                  : 'multi',
                                              min: variation.minController!.text
                                                  .trim(),
                                              max: variation.maxController!.text
                                                  .trim(),
                                              required: variation.required
                                                  ? 'on'
                                                  : 'off',
                                              variationValues: values,
                                            ),
                                          );
                                        }
                                      }
                                      if (hasEmptyValue) {
                                        showCustomSnackBar(
                                          'set_value_for_all_variation'.tr,
                                        );
                                      } else {
                                        storeController.addItem(
                                          _item,
                                          widget.item == null,
                                          genericNameData:
                                              _genericNameSuggestionController
                                                  .text
                                                  .trim(),
                                          videoFile: _pickedProductVideo,
                                          videoUploadType: _videoUploadType,
                                          videoLink: _videoUploadType == 'link'
                                              ? _normalizeProductVideoLink(
                                                  _productVideoLinkController
                                                      .text,
                                                )
                                              : null,
                                          removeVideo: _removeProductVideo,
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                              child: const Icon(Icons.close, size: 15, color: Colors.red)
                            )
                          )
                        ),
                      ])
                    );
                  })
                ),
              ]) : const SizedBox(),

            ])
          )
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // thumbnail
        AnimatedBorderContainer(
          isLoading: false,
          child: Column(
          children: [
            AddItemSectionHeaderWidget(
              title: 'thumbnail_image'.tr,
              isRequired: true,
              subTitle: 'thumbnail_image_format'.trParams({'size' : _maxFileSizeText}),
              child: Align(alignment: Alignment.center, child: Stack(children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: storeController.rawLogo != null ? Image.file(
                    File(storeController.rawLogo!.path), width: 150, height: 150, fit: BoxFit.cover
                  ) : _item.imageFullUrl != null ? CustomImageWidget(
                    image: _item.imageFullUrl ?? '',
                    height: 150, width: 150, fit: BoxFit.cover
                  ) : Container(
                    height: 150, width: 150,
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(CupertinoIcons.photo_camera_solid, color: Theme.of(context).disabledColor.withValues(alpha: 0.5), size: 30),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text('click_to_upload'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                    ])
                  )
                ),

                if(storeController.rawLogo != null && !storeController.isItemThumbnailValid) const _InvalidImageView(),

                Positioned(
                  bottom: 0, right: 0, top: 0, left: 0,
                  child: InkWell(
                    onTap: () => _thumbnailPickDebouncer.run(() => storeController.pickImage(true, false)),
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        radius: const Radius.circular(Dimensions.radiusDefault),
                        dashPattern: const [8, 4],
                        strokeWidth: 1,
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.5)
                      ),
                      child: const SizedBox(height: 150, width: 150)
                    )
                  )
                ),

              ]))
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault)
          ]
        )
        )

      ]
    );
  }
}