import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class _AboutPageState extends State<AboutPage> {

  Future _launchUrl(url) async {
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
              subtitle: const Text('Third party NissanConnect EV app'),
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
              subtitle: const Text('https://gitlab.com/tobiaswkjeldsen/dartcarwings'),
              onTap: () {_launchUrl('https://gitlab.com/tobiaswkjeldsen/dartcarwings');},
            ),
            new ListTile(
              title: const Text('More information and source code'),
              subtitle: const Text('https://gitlab.com/tobiaswkjeldsen/carwingsflutter'),
              onTap: () {_launchUrl('https://gitlab.com/tobiaswkjeldsen/carwingsflutter');},
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
