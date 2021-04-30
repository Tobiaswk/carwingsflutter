import 'package:flutter/material.dart';

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
                  Text('Having problems signing in? Follow these steps below'),
                  Padding(padding: const EdgeInsets.all(5.0)),
                  Text('Vehicles produced after May 2019',
                      style: TextStyle(fontSize: 18.0)),
                  Text(
                      'If you have a vehicle that was produced after May 2019 you need to select \'World\' as your region'),
                  Padding(padding: const EdgeInsets.all(5.0)),
                  Text('Try the official app first',
                      style: TextStyle(fontSize: 18.0)),
                  Text(
                      'If possible make sure you are able to sign in using the official app before you try My Leaf'),
                  Padding(padding: const EdgeInsets.all(5.0)),
                  Text('You+Nissan / NissanConnect',
                      style: TextStyle(fontSize: 18.0)),
                  Text(
                      'Follow the process on the You+Nissan / NissanConnect website for connecting your vehicle to your account. It can take up to 24 hours before you are able to sign in using the app'),
                  Padding(padding: const EdgeInsets.all(5.0)),
                  Text('Password', style: TextStyle(fontSize: 18.0)),
                  Text(
                      'Use a password with a length between 8 and 15 characters'),
                  Padding(padding: const EdgeInsets.all(5.0)),
                  Text('Signing in', style: TextStyle(fontSize: 18.0)),
                  Text(
                      'Make sure you are able to sign in to the You+Nissan / NissanConnect website. You should be able to see your connected vehicles on You+Nissan'),
                  Padding(padding: const EdgeInsets.all(5.0)),
                  Text('Turn on debugging', style: TextStyle(fontSize: 18.0)),
                  Text(
                      'Hold your finger on the My Leaf icon; preferences will open. Press \'Turn on debugging\'. Try signing in again. Hold your finger on the My Leaf icon again; enter \'Debug log\'. Press the clipboard icon in the top right corner'),
                  Padding(padding: const EdgeInsets.all(5.0)),
                  Text('Direct contact', style: TextStyle(fontSize: 18.0)),
                  Text(
                      'Use contact information from the store listing for this app. Include the debug log from above step. Please do this instead of defaulting to a harmful 1 star review '),
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
