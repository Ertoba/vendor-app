import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart_store/common/models/config_model.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_store/features/service_module/store/controllers/service_controller.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class ServiceGenerateTitleBottomSheet extends StatefulWidget {
  final List<Language>? languageList;
  final TabController? tabController;
  final List<TextEditingController>? nameControllerList;
  const ServiceGenerateTitleBottomSheet({super.key, this.nameControllerList, this.languageList, this.tabController});

  @override
  State<ServiceGenerateTitleBottomSheet> createState() => _ServiceGenerateTitleBottomSheetState();
}

class _ServiceGenerateTitleBottomSheetState extends State<ServiceGenerateTitleBottomSheet> {

  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<ServiceController>().initializeKeyWords();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Container(
        width: context.width,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
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
                  onTap: () { Get.back(); },
                  child: Icon(Icons.close, color: Theme.of(context).hintColor.withValues(alpha: 0.6), size: 22),
                ),
              ),
            ]),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text('great'.tr, style: robotoBold.copyWith(color: Theme.of(context).hintColor)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Text('now_tell_me_which_service_you_want_to_create_just_type_it_simply_like'.tr, style: robotoBold.copyWith(color: Theme.of(context).hintColor)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Row(children: [
                    CircleAvatar(backgroundColor: Theme.of(context).hintColor, radius: 3),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(child: Text('enter_some_keywords_you_want_in_the_name'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall))),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Row(children: [
                    CircleAvatar(backgroundColor: Theme.of(context).hintColor, radius: 3),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(child: Text('or_you_can_give_related_title_we_will_generate_some_new_title_for_you'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall))),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Text('feel_free_to_describe_it_your_own_way'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),
                  SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(
                          flex: 8,
                          child: CustomTextFieldWidget(
                            hintText: 'enter_sample_keyword'.tr,
                            labelText: 'keyword'.tr,
                            showTitle: false,
                            controller: _titleController,
                            inputAction: TextInputAction.done,
                            onSubmit: (name){
                              if(name.isNotEmpty) { serviceController.setKeyWord(name); _titleController.text = ''; }
                            },
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Expanded(
                          flex: 2,
                          child: CustomButtonWidget(buttonText: 'add'.tr, color: Colors.blue, onPressed: (){
                            if(_titleController.text.isNotEmpty) { serviceController.setKeyWord(_titleController.text.trim()); _titleController.text = ''; }
                          }),
                        ),
                      ]),
                      SizedBox(height: serviceController.keyWordList.isNotEmpty ? Dimensions.paddingSizeSmall : 0),

                      serviceController.keyWordList.isNotEmpty ? SizedBox(
                        height: 40,
                        child: ListView.builder(
                          shrinkWrap: true, scrollDirection: Axis.horizontal,
                          itemCount: serviceController.keyWordList.length,
                          itemBuilder: (context, index){
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(color: Theme.of(context).hintColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                              child: Center(child: Row(children: [
                                Text(serviceController.keyWordList[index]!, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                InkWell(onTap: () => serviceController.removeKeyWord(index), child: Icon(Icons.clear, size: 18, color: Theme.of(context).hintColor)),
                              ])),
                            );
                          },
                        ),
                      ) : const SizedBox(),
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  CustomButtonWidget(
                    icon: Icons.auto_awesome,
                    isLoading: serviceController.suggestionLoading,
                    color: Colors.blue,
                    onPressed: () {
                      if(serviceController.keyWordList.isEmpty){
                        showCustomSnackBar('please_add_a_keyword_to_generate_service_name'.tr);
                      }else{
                        serviceController.generateTitleSuggestions();
                      }
                    },
                    buttonText: 'generate_service_name'.tr,
                  ),
                  SizedBox(height: !serviceController.suggestionLoading ? 0 : Dimensions.paddingSizeLarge),

                  !serviceController.suggestionLoading ? SizedBox() : Shimmer(
                    duration: const Duration(seconds: 2),
                    color: Colors.blue,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.auto_awesome, color: Colors.blue),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text('${'generating'.tr}...', style: robotoBold.copyWith(color: Colors.blue)),
                    ]),
                  ),
                  SizedBox(height: serviceController.titleSuggestionModel?.titles.isNotEmpty ?? false ? Dimensions.paddingSizeLarge : 0),

                  serviceController.titleSuggestionModel?.titles.isNotEmpty ?? false ?
                  Text('suggested_service_name'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)) : SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  serviceController.titleSuggestionModel?.titles.isNotEmpty ?? false ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: serviceController.titleSuggestionModel?.titles.length,
                    itemBuilder: (context, index) {
                      bool isUse = widget.nameControllerList![widget.tabController!.index].text == serviceController.titleSuggestionModel!.titles[index];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          side: BorderSide(color: Theme.of(context).hintColor.withValues(alpha: 0.2), width: 0.5),
                        ),
                        child: ListTile(
                          title: Text(serviceController.titleSuggestionModel?.titles[index] ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                          trailing: InkWell(
                            onTap: () {
                              widget.nameControllerList![widget.tabController!.index].text = serviceController.titleSuggestionModel!.titles[index];
                              Get.back();
                              Get.back();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                border: Border.all(color: isUse ? Theme.of(context).primaryColor : Colors.blue, width: 1),
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(CupertinoIcons.checkmark_rectangle, color: isUse ? Theme.of(context).primaryColor : Colors.blue, size: 16),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Text(isUse ? 'used'.tr : 'use'.tr, style: robotoRegular.copyWith(color: isUse ? Theme.of(context).primaryColor : Colors.blue, fontSize: Dimensions.fontSizeSmall)),
                              ]),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                        ),
                      );
                    },
                  ) : SizedBox(),

                ]),
              ),
            ),

          ]);
        }),
      ),
    );
  }
}
