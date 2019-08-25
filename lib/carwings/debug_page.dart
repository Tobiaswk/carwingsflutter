import 'package:carwingsflutter/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _DebugPageState extends State<DebugPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Session _session;

  _DebugPageState(this._session);

  _copyAll() {
    String text = '';
    _session.carwings.debugLog.forEach((logEntry) => text+=logEntry+'\n\n');
    Clipboard.setData(new ClipboardData(text: text));
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text("All copied to Clipboard"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(title: new Text("Debug log"), actions: [
        new IconButton(icon: Icon(Icons.content_copy), onPressed: _copyAll),
      ]),
      body: new ListView(
        padding: new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        children: _session.carwings.debugLog.reversed.map((String logEntry) {
          return Column(
            children: <Widget>[
              new InkWell(
                child: new Text(logEntry),
                onLongPress: () {
                  Clipboard.setData(new ClipboardData(text: logEntry));
                  scaffoldKey.currentState.showSnackBar(new SnackBar(
                    content: new Text("Copied to Clipboard"),
                  ));
                },
              ),
              new Padding(padding: const EdgeInsets.all(3.0))
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
  _DebugPageState createState() => new _DebugPageState(session);
}
