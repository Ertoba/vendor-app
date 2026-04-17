import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class DateConverterHelper {
  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd hh:mm:ss').format(dateTime);
  }

  static String estimatedDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy', _dateLocale()).format(dateTime);
  }

  static DateTime convertStringToDatetime(String dateTime) {
    return DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").parse(dateTime);
  }

  static DateTime isoStringToLocalDate(String dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(dateTime).toLocal();
  }

  static String dateTimeStringToDateTime(String dateTime) {
    return DateFormat(
      'dd MMM yyyy  ${_timeFormatter()}',
      _dateLocale(),
    ).format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  static String dateTimeStringToDateOnly(String dateTime) {
    return DateFormat(
      'dd MMM yyyy',
      _dateLocale(),
    ).format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  static DateTime dateTimeStringToDate(String dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime);
  }

  static String isoStringToLocalDateOnly(String dateTime) {
    return DateFormat(
      'dd MMM yyyy',
      _dateLocale(),
    ).format(isoStringToLocalDate(dateTime));
  }

  static String isoStringToLocalDateTimeOnly(String dateTime) {
    return DateFormat(
      'dd MMM yyyy | HH:mm a',
      _dateLocale(),
    ).format(isoStringToLocalDate(dateTime));
  }

  static String localDateToIsoString(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(dateTime);
  }

  static String convertStringTimeToTime(String time) {
    return DateFormat(_timeFormatter()).format(DateFormat('HH:mm').parse(time));
  }

  static String convertTimeToTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static DateTime convertTimeToDateTime(String time) {
    return DateFormat('HH:mm').parse(time);
  }

  static String convertDateToDate(String date) {
    return DateFormat(
      'dd MMM yyyy',
      _dateLocale(),
    ).format(DateFormat('yyyy-MM-dd').parse(date));
  }

  static String dateTimeStringToMonthAndTime(String dateTime) {
    return DateFormat(
      'dd MMM yyyy \nHH:mm a',
      _dateLocale(),
    ).format(dateTimeStringToDate(dateTime));
  }

  static String dateTimeForCoupon(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String utcToDateTime(String dateTime) {
    return DateFormat(
      'dd MMM, yyyy h:mm a',
      _dateLocale(),
    ).format(DateTime.parse(dateTime).toLocal());
  }

  static String utcToDate(String dateTime) {
    return DateFormat(
      'dd MMM, yyyy',
      _dateLocale(),
    ).format(DateTime.parse(dateTime));
  }

  static bool isAvailable(
    String? start,
    String? end, {
    DateTime? time,
    bool isoTime = false,
  }) {
    DateTime currentTime;
    if (time != null) {
      currentTime = time;
    } else {
      currentTime = Get.find<SplashController>().currentTime;
    }
    DateTime start0 = start != null
        ? isoTime
              ? isoStringToLocalDate(start)
              : DateFormat('HH:mm').parse(start)
        : DateTime(currentTime.year);
    DateTime end0 = end != null
        ? isoTime
              ? isoStringToLocalDate(end)
              : DateFormat('HH:mm').parse(end)
        : DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            23,
            59,
          );
    DateTime startTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      start0.hour,
      start0.minute,
      start0.second,
    );
    DateTime endTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      end0.hour,
      end0.minute,
      end0.second,
    );
    if (endTime.isBefore(startTime)) {
      endTime = endTime.add(const Duration(days: 1));
    }
    return currentTime.isAfter(startTime) && currentTime.isBefore(endTime);
  }

  static String _timeFormatter() {
    return Get.find<SplashController>().configModel!.timeformat == '24'
        ? 'HH:mm'
        : 'hh:mm a';
  }

  static String? _dateLocale() {
    return Get.locale?.languageCode == 'ka' ? 'ka' : null;
  }

  static String localDateToIsoStringAMPM(DateTime dateTime) {
    return DateFormat(
      '${_timeFormatter()} | d-MMM-yyyy ',
    ).format(dateTime.toLocal());
  }

  static String dateTimeStringForDisbursement(String time) {
    var newTime = '${time.substring(0, 10)} ${time.substring(11, 23)}';
    return DateFormat(
      'dd MMM, yyyy',
      _dateLocale(),
    ).format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(newTime));
  }

  // static int expireDifferanceInDays(DateTime dateTime) {
  //   return dateTime.difference(DateTime.now()).inDays;
  // }

  static String localDateToMonthDateSince(DateTime dateTime) {
    return DateFormat('MMM d, yyyy ', _dateLocale()).format(dateTime.toLocal());
  }

  static int differenceInDaysIgnoringTime(
    DateTime dateTime1,
    DateTime? dateTime2,
  ) {
    DateTime date1 = DateTime(dateTime1.year, dateTime1.month, dateTime1.day);
    DateTime date2;
    if (dateTime2 != null) {
      date2 = DateTime(dateTime2.year, dateTime2.month, dateTime2.day);
    } else {
      date2 = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
    }
    return date1.difference(date2).inDays;
  }

  static String stringToMDY(String dateTime) {
    return DateFormat('MM/dd/yyyy').format(DateTime.parse(dateTime).toLocal());
  }

  static DateTime stringToDateTimeMDY(String dateTime) {
    return DateFormat('MM/dd/yyyy').parse(dateTime).toLocal();
  }

  static DateTime isoUtcStringToLocalDateOnly(String dateTime) {
    return DateFormat('yyyy-MM-dd').parse(dateTime, true).toLocal();
  }

  static String dateMonthYearTime(DateTime? dateTime) {
    return DateFormat(
      'd MMM, y ${_timeFormatter()}',
      _dateLocale(),
    ).format(dateTime!);
  }

  static DateTime isoUtcStringToLocalDate(String dateTime) {
    return DateFormat(
      'yyyy-MM-ddTHH:mm:ss.SSS',
    ).parse(dateTime, true).toLocal();
  }

  static String stringToLocalDateOnly(String dateTime) {
    return DateFormat(
      'dd MMM, yyyy',
      _dateLocale(),
    ).format(DateTime.parse(dateTime).toLocal());
  }

  static String dayDateTime(String dateTime) {
    return DateFormat(
      'EEEE, dd MMMM yyyy, hh:mm a',
      _dateLocale(),
    ).format(DateTime.parse(dateTime).toLocal());
  }

  static DateTime formattingTripDateTime(
    DateTime pickedTime,
    DateTime pickedDate,
  ) {
    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  static bool isSameDate(DateTime pickedTime) {
    return pickedTime.year == DateTime.now().year &&
        pickedTime.month == DateTime.now().month &&
        pickedTime.day == DateTime.now().day &&
        pickedTime.hour == DateTime.now().hour;
  }

  static bool isAfterCurrentDateTime(DateTime pickedTime) {
    DateTime pick = DateTime(
      pickedTime.year,
      pickedTime.month,
      pickedTime.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    DateTime current = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      DateTime.now().hour,
      DateTime.now().minute,
    );
    return pick.isAfter(current);
  }

  static String dateTimeForTax(DateTime dateTime) {
    return DateFormat('MM/dd/yyyy').format(dateTime);
  }

  static String beforeTimeFormat(
    String time, {
    DateTime? now,
    int showFullDateThreshold = 30,
  }) {
    final currentTime = now ?? DateTime.now();
    DateTime pastTime = dateTimeStringToDate(time);
    final Duration difference = currentTime.difference(pastTime);

    if (difference.isNegative) {
      return _translatedLabel('in_the_future', 'in the future');
    }

    final int seconds = difference.inSeconds;

    if (seconds < 60) {
      return 'just_now'.tr;
    }

    if (seconds < 86400) {
      // Less than 1 day
      final int totalMinutes = difference.inMinutes;
      final int hours = (totalMinutes / 60).floor();
      final int minutes = totalMinutes % 60;

      if (hours > 0) {
        final String hourText = '$hours${_compactUnit('hour_short', 'h')}';
        final String minuteText = minutes > 0
            ? ' $minutes${_compactUnit('minute_short', 'min')}'
            : '';
        return '$hourText$minuteText ${_translatedLabel('ago', 'ago')}';
      } else {
        return '$minutes${_compactUnit('minute_short', 'min')} ${_translatedLabel('ago', 'ago')}';
      }
    } else if (seconds < 604800) {
      // Less than 7 days
      final int totalHours = difference.inHours;
      final int days = (totalHours / 24).floor();
      final int hours = totalHours % 24;

      final String dayText =
          '$days ${_translatedLabel('day_short', _translatedLabel('days', 'day'))}';
      final String hourText = hours > 0
          ? ' $hours${_compactUnit('hour_short', 'h')}'
          : '';
      return '$dayText$hourText ${_translatedLabel('ago', 'ago')}';
    }

    List<_TimeUnit> units = [
      _TimeUnit(
        cutoffSeconds: 2592000,
        unitKey: 'week',
        conversionFactor: 604800,
      ),
      _TimeUnit(
        cutoffSeconds: 31536000,
        unitKey: 'month',
        conversionFactor: 2592000,
      ),
      _TimeUnit(
        cutoffSeconds: 999999999999,
        unitKey: 'year',
        conversionFactor: 31536000,
      ),
    ];

    for (final unit in units) {
      if (seconds < unit.cutoffSeconds) {
        final int value = (seconds / unit.conversionFactor).floor();
        return '$value ${_relativeUnit(unit.unitKey, value)} ${_translatedLabel('ago', 'ago')}';
      }
    }

    final int years = (seconds / 31536000).floor();
    return '$years ${_relativeUnit('year', years)} ${_translatedLabel('ago', 'ago')}';
  }

  static String _translatedLabel(String key, String fallback) {
    final String translated = key.tr;
    return translated == key ? fallback : translated;
  }

  static String _compactUnit(String key, String fallback) {
    return Get.locale?.languageCode == 'ka'
        ? _translatedLabel(key, fallback == 'h' ? 'სთ' : 'წთ')
        : _translatedLabel(key, fallback);
  }

  static String _relativeUnit(String key, int value) {
    if (Get.locale?.languageCode == 'ka') {
      switch (key) {
        case 'week':
          return 'კვირა';
        case 'month':
          return 'თვე';
        case 'year':
          return 'წელი';
      }
    }

    final String singular = _translatedLabel(key, key);
    if (value == 1) {
      return singular;
    }

    return _translatedLabel('${key}s', '${singular}s');
  }
}

class _TimeUnit {
  final int cutoffSeconds;
  final String unitKey;
  final int conversionFactor;

  const _TimeUnit({
    required this.cutoffSeconds,
    required this.unitKey,
    required this.conversionFactor,
  });
}
