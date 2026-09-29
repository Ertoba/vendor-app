import 'package:get/get.dart';
import 'package:sixam_mart_store/common/models/config_model.dart';

const List<String> _requiredLanguageCodes = <String>['en', 'ka', 'ru'];

List<Language> buildInputLanguageList(List<Language>? configuredLanguages) {
  final Map<String, Language> configuredByCode = <String, Language>{
    for (final Language language in configuredLanguages ?? <Language>[])
      if (language.key != null) language.key!.toLowerCase(): language,
  };

  const Map<String, String> fallbackNames = <String, String>{
    'en': 'English',
    'ka': 'ქართული',
    'ru': 'Русский',
  };

  final String currentCode = Get.locale?.languageCode.toLowerCase() ?? 'en';

  final List<String> orderedCodes = <String>[
    if (_requiredLanguageCodes.contains(currentCode)) currentCode,
    ..._requiredLanguageCodes.where((String code) => code != currentCode),
  ];

  return orderedCodes
      .map((String code) {
        final Language? configured = configuredByCode[code];

        return Language(
          key: code,
          value: configured?.value?.trim().isNotEmpty == true
              ? configured!.value
              : fallbackNames[code],
        );
      })
      .toList(growable: false);
}

int englishLanguageIndex(List<Language> languages) {
  final int index = languages.indexWhere(
    (Language language) => language.key == 'en',
  );

  return index >= 0 ? index : 0;
}
