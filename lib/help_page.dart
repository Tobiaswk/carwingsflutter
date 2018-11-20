import 'package:flutter/material.dart';

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Help")),
      body: new ListView(
        children: <Widget>[
          new Container(
              padding: const EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 30.0),
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Padding(padding: const EdgeInsets.all(5.0)),
                  new Text(
                      'Having problems signing in? Follow the steps below.'),
                  new Padding(padding: const EdgeInsets.all(5.0)),
                  new Text('You+Nissan',
                      style: TextStyle(fontSize: 18.0)),
                  new Text(
                      'Follow the process on You+Nissan for connecting your vehicle to your account. It can take up to 24 hours before you are able to sign in using the app.'),
                  new Padding(padding: const EdgeInsets.all(5.0)),
                  new Text('A valid password',
                      style: TextStyle(fontSize: 18.0)),
                  new Text(
                      'Make a password with a length between 8 and 15 characters.'),
                  new Padding(padding: const EdgeInsets.all(5.0)),
                  new Text('Signing in',
                      style: TextStyle(fontSize: 18.0)),
                  new Text(
                      'Make sure you are able to sign in to the You+Nissan webpage. You should be able to see your connected vehicles on You+Nissan.'),
                  new Padding(padding: const EdgeInsets.all(5.0)),
                  new Text('Try the official app first',
                      style: TextStyle(fontSize: 18.0)),
                  new Text(
                      'Make sure you are able to sign in using the official NissanConnect EV app before you try My Leaf.'),
                  new Padding(padding: const EdgeInsets.all(5.0)),
                  new Text('Turn on debugging',
                      style: TextStyle(fontSize: 18.0)),
                  new Text(
                      'Hold your finger on the My Leaf icon; preferences will open. Press \'Turn on debugging\'. Try signing in again. Hold your finger on the My Leaf icon again; enter \'Debug log\'. If you see a log containing the text \'INVALID PARAMS\' the problem is NOT related to My Leaf but instead Nissan\'s Carwings API.'),
                  new Padding(padding: const EdgeInsets.all(5.0)),
                  new Text('Direct contact',
                      style: TextStyle(fontSize: 18.0)),
                  new Text(
                      'As a last resort you are welcome to contact me at me@tobis.dk. Please do this instead of defaulting to a harmful 1 star review.'),
                ],
              ))
        ],
      ),
    );
  }
}

class HelpPage extends StatefulWidget {
  HelpPage({Key key}) : super(key: key);

  @override
  _HelpPageState createState() => new _HelpPageState();
}
