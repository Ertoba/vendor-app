import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/models/config_model.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/category/controllers/category_controller.dart';
import 'package:sixam_mart_store/features/service_module/store/controllers/service_controller.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class ServiceImageAnalyzeBottomSheet extends StatefulWidget {
  final List<Language>? languageList;
  final TabController? tabController;
  final List<TextEditingController>? nameControllerList;
  final List<TextEditingController>? descriptionControllerList;
  final TextEditingController? priceController;
  final TextEditingController? metaTitleController;
  final TextEditingController? metaDescriptionController;
  final VoidCallback? onImageDataApplied;
  const ServiceImageAnalyzeBottomSheet({super.key, this.nameControllerList, this.descriptionControllerList, this.priceController,
    this.metaTitleController, this.metaDescriptionController, this.languageList, this.tabController, this.onImageDataApplied});

  @override
  State<ServiceImageAnalyzeBottomSheet> createState() => _ServiceImageAnalyzeBottomSheetState();
}

class _ServiceImageAnalyzeBottomSheetState extends State<ServiceImageAnalyzeBottomSheet> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ServiceController>().removeThumbnail();
    });
  }

  Future<void> _analyzeAndGenerate(ServiceController serviceController) async {
    if (serviceController.rawLogo == null) {
      showCustomSnackBar('please_upload_an_image'.tr);
      return;
    }

    final Response response = await serviceController.analyzeImage(image: serviceController.rawLogo!);
    if (response.statusCode == 200) {
      final dynamic body = response.body;
      final String? errorMessage = body is Map && body['error'] != null ? body['error'].toString() : null;
      if (errorMessage != null && errorMessage.isNotEmpty) {
        showCustomSnackBar(errorMessage);
        return;
      }

      final dynamic data = body['data'] ?? body;
      final String seedTitle = data['title'] ?? '';

      if (Get.isBottomSheetOpen ?? false) { Get.back(); }
      if (Get.isBottomSheetOpen ?? false) { Get.back(); }

      final String langCode = widget.languageList![widget.tabController!.index].key!;
      final titleDesModel = await serviceController.generateTitleAndDescription(name: seedTitle, langCode: langCode);

      final String name = titleDesModel?.title ?? seedTitle;
      final String description = titleDesModel?.description ?? '';

      if (name.trim().isEmpty) {
        showCustomSnackBar('item_name_required'.tr);
        return;
      }

      if (widget.tabController != null) {
        widget.nameControllerList?[widget.tabController!.index].text = name;
        widget.descriptionControllerList?[widget.tabController!.index].text = description;
      }

      final generalSetup = await serviceController.generateGeneralSetup(name: name, description: description);
      if (generalSetup?.categoryId != null) {
        Get.find<CategoryController>().setCategoryAndSubCategoryForAiData(
          categoryId: generalSetup!.categoryId, subCategoryId: generalSetup.subCategoryId,
        );
      }

      if (widget.priceController != null) {
        await serviceController.generateAndSetPriceVariation(name: name, description: description, priceController: widget.priceController!);
      }

      await serviceController.generateAndSetTags(name: name, description: description);

      final seo = await serviceController.generateSeo(name: name, description: description);
      if (seo != null) {
        widget.metaTitleController?.text = seo.metaTitle ?? '';
        widget.metaDescriptionController?.text = seo.metaDescription ?? '';
      }

      widget.onImageDataApplied?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      child: GetBuilder<ServiceController>(builder: (serviceController) {
        return Column(mainAxisSize: MainAxisSize.min, children: [

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const SizedBox(width: 20),

            Container(
              height: 5, width: 35,
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(5),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(Icons.close, color: Theme.of(context).hintColor.withValues(alpha: 0.6), size: 22),
              ),
            ),
          ]),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text('upload_image'.tr, style: robotoBold.copyWith(color: Theme.of(context).hintColor)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text('please_give_proper_image_to_generate_full_data_for_your_service'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Row(children: [
                CircleAvatar(backgroundColor: Theme.of(context).hintColor, radius: 3),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: Text('try_to_use_a_clean_and_avoid_blur_image'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall))),
              ]),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Row(children: [
                CircleAvatar(backgroundColor: Theme.of(context).hintColor, radius: 3),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: Text('use_as_close_as_your_product_image'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall))),
              ]),
              const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Column(children: [

                  Align(alignment: Alignment.center, child: Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: serviceController.rawLogo != null ? GetPlatform.isWeb ? Image.network(
                        serviceController.rawLogo!.path, width: 150, height: 150, fit: BoxFit.cover,
                      ) : Image.file(
                        File(serviceController.rawLogo!.path), width: 150, height: 150, fit: BoxFit.cover,
                      ) : SizedBox(
                        width: 150, height: 150,
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(CupertinoIcons.camera_fill, color: Theme.of(context).hintColor.withValues(alpha: 0.5), size: 38),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Text('upload_image'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeExtraSmall)),

                        ]),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0, top: 0, left: 0,
                      child: InkWell(
                        onTap: () => serviceController.pickThumbnail(),
                        child: DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            color: Colors.blue,
                            strokeWidth: 1,
                            strokeCap: StrokeCap.butt,
                            dashPattern: const [5, 5],
                            padding: const EdgeInsets.all(0),
                            radius: const Radius.circular(Dimensions.radiusDefault),
                          ),
                          child: Center(
                            child: Visibility(
                              visible: serviceController.rawLogo != null ? true : false,
                              child: Container(
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 2, color: Colors.white),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ])),

                ]),
              ),
              const SizedBox(height: 30),

              CustomButtonWidget(
                icon: Icons.auto_awesome,
                isLoading: serviceController.imageLoading,
                color: Colors.blue,
                onPressed: () => _analyzeAndGenerate(serviceController),
                buttonText: 'analyze_and_generate_content'.tr,
              ),

            ]),
          ),

        ]);
      }),
    );
  }
}
