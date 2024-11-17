import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Help")),
      body: ListView(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(padding: const EdgeInsets.all(5.0)),
                  Text(
                    'Having problems signing in? Follow these steps below',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Padding(padding: const EdgeInsets.all(5.0)),
                  Text('Setup / Before you use',
                      style: TextStyle(fontSize: 18.0)),
                  Text(
                      '1. Remember to first complete the initial sign up process of your NissanConnect account and vehicle with the official app from Nissan before trying My Leaf'),
                  Padding(padding: const EdgeInsets.all(5.0)),
                  Text(
                      '2. Remember that My Leaf is directly affected by Nissan\'s infrastructure! If the services/official app are down/unstable so is My Leaf'),
                  Padding(padding: const EdgeInsets.all(5.0)),
                  Text(
                      '3. To use My Leaf a NissanConnect subscription from Nissan is required'),
                  Padding(padding: const EdgeInsets.all(5.0)),
                  Text('Vehicles produced after May 2019',
                      style: TextStyle(fontSize: 18.0)),
                  Text(
                      'If you have a vehicle that was produced after May 2019 you need to select \'World\' as your region'),
                  Padding(padding: const EdgeInsets.all(5.0)),
                  Text('Turn on debugging', style: TextStyle(fontSize: 18.0)),
                  Text(
                      '1. Hold your finger on the My Leaf icon; preferences will open'),
                  Text('2. Press \'Turn on debugging\''),
                  Text('3. Try signing in again'),
                  Text(
                      '4. Hold your finger on the My Leaf icon again; enter \'Debug log\''),
                  Text('5. Press the clipboard icon in the top right corner'),
                  Padding(padding: const EdgeInsets.all(5.0)),
                  Text('Direct contact', style: TextStyle(fontSize: 18.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () =>
                              launchUrl(Uri.parse('mailto:me@tobis.dk')),
                          child: Text('Send an email')),
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: 'me@tobis.dk'));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Email copied"),
                          ));
                        },
                      )
                    ],
                  ),
                  Text(
                      'Include the debugging information from above step. Please do this instead of turning to a 1-star review '),
                ],
              ))
        ],
      ),
    );
  }
}

class HelpPage extends StatefulWidget {
  HelpPage();

  @override
  _HelpPageState createState() => _HelpPageState();
}
