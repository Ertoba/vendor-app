import 'package:flutter/cupertino.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/item_shimmer_widget.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/features/store/controllers/store_controller.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/profile/domain/models/profile_model.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/store/widgets/item_view_widget.dart';
import 'package:sixam_mart_store/features/chat/widgets/search_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/filter_popup_widget.dart';
part '../widgets/category_list_widget.dart';

class AllItemsScreen extends StatefulWidget {
  const AllItemsScreen({super.key});

  @override
  State<AllItemsScreen> createState() => _AllItemsScreenState();
}

class _AllItemsScreenState extends State<AllItemsScreen> {

  final ScrollController _scrollController = ScrollController();
  final ScrollController _categoryScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final GlobalKey _categoryKey = GlobalKey();
  bool _isCategorySticky = false;
  double _categoryTopOffset = 0;


  @override
  void initState() {
    super.initState();

    Get.find<ProfileController>().getProfile();
    Get.find<StoreController>().getItemList(offset: '1', type: 'all', search: '', categoryId: 0, willUpdate: false);
    Get.find<StoreController>().getStoreCategories(isUpdate: false);

    _scrollController.addListener(() {
      if (_categoryTopOffset == 0) return;

      if (_scrollController.offset >= _categoryTopOffset &&
          !_isCategorySticky) {
        setState(() => _isCategorySticky = true);
      } else if (_scrollController.offset < _categoryTopOffset &&
          _isCategorySticky) {
        setState(() => _isCategorySticky = false);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box =
      _categoryKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        _categoryTopOffset = box.localToGlobal(Offset.zero).dy;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _categoryScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      return GetBuilder<ProfileController>(builder: (profileController) {
        Store? store = profileController.profileModel?.stores;
        final theme = Theme.of(context);
        bool isShowingTrialContent = profileController.profileModel != null && profileController.profileModel!.subscription != null
            && profileController.profileModel!.subscription!.isTrial == true
            && DateConverterHelper.differenceInDaysIgnoringTime(DateTime.parse(profileController.profileModel!.subscription!.expiryDate!), null) > 0;

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              // Reset filters when navigating back
              storeController.resetFilters();
            }
          },
          child: Scaffold(
          appBar: CustomAppBarWidget(title: 'all_items'.tr),

          floatingActionButton: storeController.isFabVisible && Get.find<ProfileController>().modulePermission!.item! ? Padding(
            padding: EdgeInsets.only(bottom: isShowingTrialContent ? 100 : 0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: FloatingActionButton(
                heroTag: 'all_items_fab',
                onPressed: () {
                  if(Get.find<ProfileController>().profileModel!.stores!.itemSection!) {
                    if (store != null) {
                      Get.toNamed(RouteHelper.getAddItemRoute(null));
                    }
                  }else {
                    showCustomSnackBar('this_feature_is_blocked_by_admin'.tr);
                  }
                },
                backgroundColor: theme.primaryColor,
                child: Icon(Icons.add, color: theme.cardColor, size: 30),
              ),
            ),
          ) : const SizedBox(),

          body: store != null ? Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                controller: _scrollController,
                child: Column(children: [

                  SizedBox(key: _categoryKey, height: 40, child: _CategoryListWidget(storeController: storeController, categoryScrollController: _categoryScrollController)),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Row(children: [
                    if(storeController.itemSize != null)
                      Text('${'items'.tr} (${storeController.itemSize})', style: robotoMedium),
                    const Spacer(),

                    InkWell(
                      onTap: () {
                        _searchController.clear();
                        storeController.setCategoryForSearch(index: 0);
                        _categoryScrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                        storeController.getItemList(offset: '1', type: 'all', search: '', categoryId: 0);
                        storeController.setSearchVisibility();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall - 2),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Icon(storeController.isSearchVisible ? Icons.close : CupertinoIcons.search, color: theme.primaryColor, size: 18),
                      ),
                    ),
                    SizedBox(width: (Get.find<SplashController>().configModel!.toggleVegNonVeg! && Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg!) ? Dimensions.paddingSizeSmall : 0),

                    (store.module?.moduleType == 'food' && Get.find<SplashController>().configModel!.toggleVegNonVeg! && Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg!)
                        ? GestureDetector(onTapDown: (details) {
                        // showCustomBottomSheet(child: const FilterDataBottomSheet());
                        showFilterPopup(
                          context: context,
                          offset: details.globalPosition,
                          selectedType: storeController.type,
                          onSelected: (val) {
                            storeController.setType(val);
                            storeController.getItemList(offset: '1', type: val, search: '', categoryId: storeController.categoryId
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          border: Border.all(color: theme.primaryColor),
                        ),
                        child: Icon(Icons.filter_list, color: theme.primaryColor, size: 18),
                      ),
                    ) : const SizedBox(),

                  ]),
                  SizedBox(height: Dimensions.paddingSizeDefault),

                  Visibility(
                    visible: storeController.isSearchVisible,
                    child: SizedBox(
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: SearchFieldWidget(
                          fromReview: true,
                          controller: _searchController,
                          hint: '${'search_by_item_name'.tr}...',
                          suffixIcon: storeController.isSearching ? CupertinoIcons.clear_thick : CupertinoIcons.search,
                          iconPressed: () {
                            if (!storeController.isSearching) {
                              if (_searchController.text.trim().isNotEmpty) {
                                storeController.setCategoryForSearch(index: 0);
                                _categoryScrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                                storeController.getItemList(offset: '1', type: 'all', search: _searchController.text.trim(), categoryId: 0);
                              } else {
                                showCustomSnackBar('write_item_name_for_search'.tr);
                              }
                            } else {
                              _searchController.clear();
                              storeController.setCategoryForSearch(index: 0);
                              _categoryScrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                              storeController.getItemList(offset: '1', type: 'all', search: '', categoryId: 0);
                            }
                          },
                          onSubmit: (String text) {
                            if (_searchController.text.trim().isNotEmpty) {
                              storeController.setCategoryForSearch(index: 0);
                              _categoryScrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                              storeController.getItemList(offset: '1', type: 'all', search: _searchController.text.trim(), categoryId: 0);
                            } else {
                              showCustomSnackBar('write_item_name_for_search'.tr);
                            }
                          },
                        ),

                      ),
                    ),
                  ),
                  SizedBox(height: storeController.isSearchVisible ? Dimensions.paddingSizeDefault : 0),

                  Container(
                    child: Get.find<ProfileController>().modulePermission!.item!
                        ? storeController.isLoading || storeController.itemList != null
                      ? ItemViewWidget(scrollController: _scrollController, fromAllItems: true, type: storeController.type, search: _searchController.text)
                    : ItemShimmerWidget(isEnabled: true, hasDivider: false)
                        : Center(child: Padding(padding: const EdgeInsets.only(top: 100),
                      child: Text('you_have_no_permission_to_access_this_feature'.tr, style: robotoMedium),
                    )),
                  ),

                ]),
              ),

              // Header Category
              if (_isCategorySticky)
                Positioned(top: 0, left: 0, right: 0,
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                    color: theme.cardColor,
                    child: _CategoryListWidget(storeController: storeController, categoryScrollController: _categoryScrollController),
                  ),
                ),
            ],
          ) : const Center(child: CircularProgressIndicator()),
          ),
        );
      });
    });
  }
}

