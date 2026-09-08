import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';

void main() {
  setUp(() => Get.testMode = true);
  tearDown(() => Get.reset());
  testWidgets(
    'nullable controller, focus replacement and long validation remain usable',
    (tester) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final form = GlobalKey<FormState>();
      final first = FocusNode();
      final replacement = FocusNode();
      var focus = first;
      late StateSetter update;
      const error =
          'შეიყვანეთ სწორი მნიშვნელობა და გადაამოწმეთ ყველა აუცილებელი მონაცემი';
      await tester.pumpWidget(
        GetMaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: form,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      update = setState;
                      return CustomTextFieldWidget(
                        focusNode: focus,
                        isPassword: true,
                        labelText: 'პაროლი',
                        validator: (_) => error,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      update(() => focus = replacement);
      await tester.pump();
      first.dispose();
      replacement.requestFocus();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'test-password');
      expect(form.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text(error), findsOneWidget);
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      replacement.dispose();
    },
  );
}
