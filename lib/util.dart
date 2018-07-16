import 'package:flutter/material.dart';

class Util {
  static void showLoadingDialog(context, [loadingText = 'Updating...']) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              content: new Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new CircularProgressIndicator(),
                  new Padding(padding: const EdgeInsets.all(10.0)),
                  new Text(loadingText),
                ],
              ),
            ));
  }

  static void dismissLoadingDialog(context) {
    Navigator.of(context).pop();
  }
}
