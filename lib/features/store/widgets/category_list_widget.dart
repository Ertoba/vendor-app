part of '../screens/all_items_screen.dart';

class _CategoryListWidget extends StatelessWidget {
  final StoreController storeController;
  final ScrollController categoryScrollController;
  const _CategoryListWidget({required this.storeController, required this.categoryScrollController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (storeController.categoryNameList != null) {
      return ListView.builder(
        controller: categoryScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: storeController.categoryNameList!.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => storeController.setCategory(index: index, foodType: 'all'),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Row(children: [
              Container(
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeExtraSmall,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                  color: index == storeController.categoryIndex
                      ? theme.primaryColor
                      : theme.hintColor.withValues(alpha: 0.1),
                ),
                child: Text(index == 0 ? 'all'.tr : storeController.categoryNameList![index],
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: index == storeController.categoryIndex
                        ? theme.cardColor
                        : theme.textTheme.bodyLarge?.color,
                    fontWeight: index == storeController.categoryIndex ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ]),
          );
        },
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (_, _) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(Dimensions.radiusSmall + 2),
          color: theme.hintColor.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}


