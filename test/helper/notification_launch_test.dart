import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart_store/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_store/helper/notification_helper.dart';

const Map<String, dynamic> _bogoPayload = {
  'image': '',
  'trip_id': '',
  'sender_type': '',
  'sound': 'notification.wav',
  'advertisement_id': '',
  'body': 'Your request to join the BOGO offer has been submitted.',
  'type': 'bogo_offer',
  'title': 'Request submitted',
  'click_action': '',
  'module_id': '',
  'data_id': '9',
  'conversation_id': '',
  'order_type': '',
  'order_id': '',
  'status': '',
};

void main() {
  test('BOGO notification preserves its offer id', () {
    final NotificationBodyModel body = NotificationHelper.convertNotification(
      _bogoPayload,
    );

    expect(body.notificationType, NotificationType.bogo_offer);
    expect(body.bogoOfferId, 9);
  });

  test('BOGO notification survives the local payload round trip', () {
    final String payload = jsonEncode(
      NotificationHelper.convertNotification(_bogoPayload).toJson(),
    );
    final NotificationBodyModel restored = NotificationBodyModel.fromJson(
      jsonDecode(payload),
    );

    expect(restored.notificationType, NotificationType.bogo_offer);
    expect(restored.bogoOfferId, 9);
  });

  test('blank and missing dynamic ids do not throw', () {
    expect(
      () => NotificationHelper.convertNotification(_bogoPayload),
      returnsNormally,
    );
    expect(
      () => NotificationHelper.convertNotification(const {'type': 'campaign'}),
      returnsNormally,
    );
    expect(
      () => NotificationHelper.convertNotification(const {'type': 'new_order'}),
      returnsNormally,
    );
    expect(
      () => NotificationHelper.convertNotification(const {}),
      returnsNormally,
    );
  });
}
