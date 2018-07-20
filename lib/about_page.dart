import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class _AboutPageState extends State<AboutPage> {

  Future _launchBitbucket(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("About")),
      body: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ListTile(
              title: const Text('My Leaf', ),
              subtitle: const Text('Third party NissanEV Connect app'),
            ),
            const ListTile(
              title: const Text('Developer'),
              subtitle: const Text('Tobias Westergaard Kjeldsen <tobias@wkjeldsen.dk>'),
            ),
            new Text('Graphics', style: TextStyle(fontSize: 20.0),),
            new ListTile(
              title: const Text('Icons'),
              subtitle: const Text('Icons by Freepik at flaticon.com'),
            ),
            new Text('Libraries and source code', style: TextStyle(fontSize: 20.0),),
            new ListTile(
              title: const Text('dartcarwings library'),
              subtitle: const Text('https://bitbucket.org/Tobiaswk/dartcarwings'),
              onTap: () {_launchBitbucket('https://bitbucket.org/Tobiaswk/dartcarwings');},
            ),
            new ListTile(
              title: const Text('More information and source code'),
              subtitle: const Text('https://bitbucket.org/Tobiaswk/carwingsflutter'),
              onTap: () {_launchBitbucket('https://bitbucket.org/Tobiaswk/carwingsflutter');},
            ),
          ],
        ),
    );
  }
}

class AboutPage extends StatefulWidget {
  AboutPage({Key key}) : super(key: key);

  @override
  _AboutPageState createState() => new _AboutPageState();
}
