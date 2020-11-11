import 'package:carwingsflutter/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _DebugPageState extends State<DebugPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  _copyAll() {
    String text = '';
    widget.session.nissanConnectNa.debugLog
        .forEach((logEntry) => text += logEntry + '\n\n');
    Clipboard.setData(ClipboardData(text: text));
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("All copied to Clipboard"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text("Debug log"), actions: [
        IconButton(icon: Icon(Icons.content_copy), onPressed: _copyAll),
      ]),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        children: widget.session.nissanConnect.debugLog.reversed
            .map((String logEntry) {
          return Column(
            children: <Widget>[
              InkWell(
                child: Text(logEntry),
                onLongPress: () {
                  Clipboard.setData(ClipboardData(text: logEntry));
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text("Copied to Clipboard"),
                  ));
                },
              ),
              Padding(padding: const EdgeInsets.all(3.0))
            ],
          );
        }).toList(),
      ),
    );
  }
}

class DebugPage extends StatefulWidget {
  DebugPage(this.session);

  Session session;

  @override
  _DebugPageState createState() => _DebugPageState();
}
