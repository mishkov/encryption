import 'package:flutter/material.dart';

bool checkKey(
  bool Function() isValid,
  String errorMessage,
  BuildContext context,
) {
  if (!isValid()) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showMaterialBanner(
      MaterialBanner(
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return false;
  } else {
    return true;
  }
}
