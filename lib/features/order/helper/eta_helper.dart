import 'package:get/get.dart';
import 'package:sixam_mart_store/features/order/domain/models/order_model.dart';

/// Reads the `eta` object the vendor order APIs attach to delivery orders and
/// turns it into something printable. A `null` return means "show nothing" —
/// the platform only promises a window where an admin configured one for the
/// order's (zone, module) pair.
class EtaHelper {
  EtaHelper._();

  /// Statuses where the order is finished, so the API stops estimating.
  static const List<String> closedStatuses = <String>[
    'delivered', 'canceled', 'failed', 'refunded', 'refund_requested', 'refund_request_canceled',
  ];

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// `day` is null when the window falls on a day the label cannot resolve.
  /// `overdue` means the whole window has passed — style the row, do not hide it.
  static ({String? day, String window, bool overdue})? windowLabel(OrderModel? order) {
    if(order == null || order.orderType != 'delivery') {
      return null;
    }

    if(closedStatuses.contains(order.orderStatus)) {
      return null;
    }

    final bool overdue = order.eta?.overdue ?? false;

    /// When the window has passed the API sends wording ("Any minute now")
    /// instead of clock times, so fall back to that translated text.
    final String window = overdue
        ? (order.eta?.text?.trim() ?? '')
        : (order.eta?.window?.trim() ?? '');
    if(window.isEmpty) {
      return null;
    }

    return (day: overdue ? null : dayLabel(order.eta?.fromAt ?? order.scheduleAt), window: window, overdue: overdue);
  }

  static String? dayLabel(String? stamp) {
    if(stamp == null || stamp.length < 10) {
      return null;
    }

    try {
      final DateTime stampDay = DateTime.parse(stamp.substring(0, 10));
      final DateTime now = DateTime.now();
      final int dayGap = DateTime(stampDay.year, stampDay.month, stampDay.day)
          .difference(DateTime(now.year, now.month, now.day)).inDays;

      if(dayGap == 0) {
        return 'today'.tr;
      }
      if(dayGap == 1) {
        return 'tomorrow'.tr;
      }
      return '${stampDay.day.toString().padLeft(2, '0')} ${_months[stampDay.month - 1]}';
    } catch (_) {
      return null;
    }
  }
}
