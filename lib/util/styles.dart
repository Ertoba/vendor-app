// Legacy style identifiers now resolve exclusively to the bundled Noto Sans Georgian faces.
import 'package:sixam_mart_store/util/typography.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

const robotoRegular = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontFamilyFallback: MiliTypography.fallback,
  fontWeight: FontWeight.w400,
);

const robotoMedium = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontFamilyFallback: MiliTypography.fallback,
  fontWeight: FontWeight.w500,
);

const robotoBold = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontFamilyFallback: MiliTypography.fallback,
  fontWeight: FontWeight.w700,
);

const robotoBlack = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontFamilyFallback: MiliTypography.fallback,
  fontWeight: FontWeight.w900,
);
