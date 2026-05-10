import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/helper/server_message_translator.dart';

void showCustomSnackBar(String? message, {bool isError = true}) {
  final String displayMessage = ServerMessageTranslator.translate(message);

  if (displayMessage.isEmpty) {
    return;
  }

  Get.showSnackbar(
    GetSnackBar(
      backgroundColor: isError ? Colors.red : Colors.green,
      message: displayMessage,
      duration: const Duration(seconds: 3),
      snackStyle: SnackStyle.FLOATING,
      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      borderRadius: 10,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    ),
  );
}
