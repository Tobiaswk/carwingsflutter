import 'package:carwingsflutter/rotating_wheel_progress_indicator.dart';
import 'package:flutter/material.dart';

class Util {
  static void showLoadingDialog(context, [loadingText = 'Updating']) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  Padding(padding: const EdgeInsets.all(10.0)),
                  Text('${loadingText}...'),
                ],
              ),
            ));
  }

  static void dismissLoadingDialog(context) {
    Navigator.of(context).pop();
  }

  static void showBigLoadingDialog(context, [loadingText = 'Updating']) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => SizedBox.expand(
              child: Material(
                type: MaterialType.transparency,
                child: Stack(
                  children: [
                    Positioned.fill(
                        child: Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          'One moment... ${loadingText}...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )),
                    Positioned.fill(
                        child: Align(
                            alignment: Alignment.center,
                            child: RotatingWheelProgressIndicator())),
                  ],
                ),
              ),
            ));
  }

  static void dismissBigLoadingDialog(context) {
    Navigator.of(context).pop();
  }

  static Color primaryColor(context) =>
      isDarkTheme(context) ? Colors.white : Theme.of(context).primaryColor;

  static bool isDarkTheme(context) =>
      Theme.of(context).brightness == Brightness.dark;
}
