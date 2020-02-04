import 'package:flutter/material.dart';

class Util {
  static void showLoadingDialog(context, [loadingText = 'Updating...']) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  Padding(padding: const EdgeInsets.all(10.0)),
                  Text(loadingText),
                ],
              ),
            ));
  }

  static void dismissLoadingDialog(context) {
    Navigator.of(context).pop();
  }

  static Color primaryColor(context) =>
      isDarkTheme(context) ? Colors.white : Theme.of(context).primaryColor;

  static bool isDarkTheme(context) =>
      Theme.of(context).brightness == Brightness.dark;
}
