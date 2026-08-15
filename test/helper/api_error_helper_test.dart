import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/helper/api_error_helper.dart';

void main() {
  Future<void> pumpLocale(WidgetTester tester, String languageCode) async {
    await tester.pumpWidget(
      GetMaterialApp(
        locale: Locale(languageCode),
        home: const SizedBox.shrink(),
      ),
    );
  }

  tearDown(Get.reset);

  testWidgets('localizes English credential errors', (tester) async {
    await pumpLocale(tester, 'en');

    expect(
      ApiErrorHelper.userMessage(
        'Credential_do_not_match,_please_try_again',
        statusCode: 401,
      ),
      'The email or password is incorrect.',
    );
  });

  testWidgets('replaces the incorrect Georgian server translation', (
    tester,
  ) async {
    await pumpLocale(tester, 'ka');

    expect(
      ApiErrorHelper.userMessage(
        'სერტიფიკატი არ ემთხვევა, გთხოვთ, სცადოთ ხელახლა',
        statusCode: 401,
      ),
      'ელ-ფოსტა ან პაროლი არასწორია.',
    );
    expect(
      ApiErrorHelper.userMessage(
        'სერთიფიკატი არ ემთხვევა, გთხოვთ, სცადოთ ხელახლა',
        statusCode: 401,
      ),
      'ელ-ფოსტა ან პაროლი არასწორია.',
    );
  });

  testWidgets('normalizes Russian credential errors', (tester) async {
    await pumpLocale(tester, 'ru');

    expect(
      ApiErrorHelper.userMessage(
        'Учетные данные не совпадают, попробуйте еще раз.',
        statusCode: 401,
      ),
      'Неверный адрес электронной почты или пароль.',
    );
  });

  testWidgets('keeps TLS failures separate from credential errors', (
    tester,
  ) async {
    await pumpLocale(tester, 'ka');

    expect(
      ApiErrorHelper.userMessage(
        'HandshakeException: CERTIFICATE_VERIFY_FAILED',
        statusCode: 1,
      ),
      'სერვერთან დაკავშირება ვერ მოხერხდა. შეამოწმეთ ინტერნეტი.',
    );
  });

  testWidgets('preserves account and module status messages', (tester) async {
    await pumpLocale(tester, 'en');

    expect(
      ApiErrorHelper.userMessage('Your account is suspended', statusCode: 403),
      'Your account is suspended',
    );
    expect(
      ApiErrorHelper.userMessage(
        'Rental module is not available',
        statusCode: 401,
      ),
      'Rental module is not available',
    );
    expect(
      ApiErrorHelper.userMessage(
        'Your Subscription Plan is not Active for Mobile App',
        statusCode: 401,
      ),
      'Your Subscription Plan is not Active for Mobile App',
    );
  });
}
