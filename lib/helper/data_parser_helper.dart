import 'package:flutter/foundation.dart';

class DataParserHelper {
  static List<int> convertIntoListOfInteger(String options) {
    final List<int> result = [];
    final List<String> values = options
        .replaceAll('(', '')
        .replaceAll(')', '')
        .split(',');
    for (final String value in values) {
      try {
        result.add(int.parse(value));
      } catch (error) {
        if (kDebugMode) {
          print('=====not converted : $error');
        }
      }
    }
    return result;
  }

  static bool parseBool(dynamic value) {
    return value == 'true' || value == true || value == 1 || value == '1';
  }

  static int? parseInt(dynamic value, {bool keepDefaultZero = true}) {
    return num.tryParse(value.toString())?.toInt() ??
        (keepDefaultZero ? 0 : null);
  }

  static double? parseDouble(dynamic value, {bool keepDefaultZero = true}) {
    return num.tryParse(value.toString())?.toDouble() ??
        (keepDefaultZero ? 0.0 : null);
  }
}
