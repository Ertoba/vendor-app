import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sixam_mart_store/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_store/helper/notification_helper.dart';

/// The resubmit notification, copied verbatim from a device log.
const Map<String, dynamic> _resubmitPayload = {
  'image': '', 'trip_id': '', 'sender_type': '', 'sound': 'notification.wav',
  'advertisement_id': '', 'body': 'Your request to join the BOGO offer B2 one G2 one has been submitted and is awaiting review.',
  'type': 'bogo_offer', 'title': 'Request submitted', 'click_action': '', 'module_id': '',
  'data_id': '9', 'conversation_id': '', 'order_type': '', 'order_id': '', 'status': '',
};

void main() {
  test('the FCM data becomes a bogo_offer body carrying the offer id', () {
    final NotificationBodyModel body = NotificationHelper.convertNotification(_resubmitPayload);
    expect(body.notificationType, NotificationType.bogo_offer);
    expect(body.bogoOfferId, 9);
  });

  test('that body survives the local-notification payload round trip', () {
    // What showNotification() writes into fln.show(payload: ...) …
    final String payload = jsonEncode(NotificationHelper.convertNotification(_resubmitPayload).toJson());

    // … and what getLaunchNotification() reads back out of the launch details.
    final NotificationBodyModel restored = NotificationBodyModel.fromJson(jsonDecode(payload));

    expect(restored.notificationType, NotificationType.bogo_offer);
    expect(restored.bogoOfferId, 9);
  });

  test('an empty order_id no longer throws the whole conversion away', () {
    // Every key in the real payload is present but blank; the old
    // int.tryParse(dynamic) calls threw a TypeError on exactly this shape.
    expect(() => NotificationHelper.convertNotification(_resubmitPayload), returnsNormally);
    expect(() => NotificationHelper.convertNotification(const {'type': 'campaign'}), returnsNormally);
    expect(() => NotificationHelper.convertNotification(const {'type': 'new_order'}), returnsNormally);
    expect(() => NotificationHelper.convertNotification(const {}), returnsNormally);
  });
}
