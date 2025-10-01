import 'package:flutter/material.dart';

class SafeAreaScaffold extends StatelessWidget {
  final Key? key;
  final AppBar? appBar;
  final Widget? drawer;
  final Widget body;
  final Color? backgroundColor;

  SafeAreaScaffold({
    this.key,
    this.appBar,
    this.drawer,
    required this.body,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    key: key,
    appBar: appBar,
    drawer: drawer,
    body: SafeArea(child: body),
    backgroundColor: backgroundColor,
  );
}
