import 'package:sixam_mart_store/features/language/controllers/language_controller.dart';
import 'package:sixam_mart_store/features/language/domain/models/language_model.dart';
import 'package:sixam_mart_store/util/app_constants.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:flutter/material.dart';

class LanguageCardWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;
  final bool fromBottomSheet;
  final bool fromWeb;

  const LanguageCardWidget({super.key, required this.languageModel, required this.localizationController, required this.index, this.fromBottomSheet = false, this.fromWeb = false});

  @override
  Widget build(BuildContext context) {
    final bool isSelected = localizationController.selectedLanguageIndex == index;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        onTap: () {
          if (fromBottomSheet) {
            localizationController.setLanguage(
              Locale(AppConstants.languages[index].languageCode!, AppConstants.languages[index].countryCode),
              fromBottomSheet: fromBottomSheet,
            );
          }
          localizationController.setSelectLanguageIndex(index);
        },
        child: Container(height: 70,
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor.withValues(alpha: 0.05) : (fromWeb ? theme.cardColor : null),
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            border: Border.all(color: isSelected ? theme.primaryColor.withValues(alpha: 0.2) : (fromWeb ? theme.disabledColor.withValues(alpha: 0.3) : Colors.transparent)),
          ),
          child: Row(
            children: [
              Image.asset(languageModel.imageUrl!, width: 36, height: 36, cacheWidth: 72, cacheHeight: 72),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Text(
                languageModel.languageName!,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const Spacer(),
              if (isSelected)Icon(Icons.check_circle, color: theme.primaryColor, size: 25)
              else const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}