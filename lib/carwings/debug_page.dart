import 'package:carwingsflutter/safe_area_scaffold.dart';
import 'package:carwingsflutter/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _DebugPageState extends State<DebugPage> {
  _copyAll() {
    String text = '';
    widget.session.carwings.debugLog.forEach(
      (logEntry) => text += logEntry + '\n\n',
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("All copied to Clipboard")));
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaScaffold(
      appBar: AppBar(
        title: Text("Debug log"),
        actions: [
          IconButton(icon: Icon(Icons.content_copy), onPressed: _copyAll),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        children: widget.session.carwings.debugLog.reversed.map((
          String logEntry,
        ) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: logEntry.contains('Result:')
                      ? Colors.green.withValues(alpha: .3)
                      : Colors.blue.withValues(alpha: .3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  child: Text(logEntry),
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: logEntry));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Copied to Clipboard")),
                    );
                  },
                ),
              ),
              Padding(padding: const EdgeInsets.all(3.0)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class DebugPage extends StatefulWidget {
  DebugPage(this.session);

  final Session session;

  @override
  _DebugPageState createState() => _DebugPageState();
}
