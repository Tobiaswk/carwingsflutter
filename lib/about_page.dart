import 'dart:async';
import 'package:carwingsflutter/util.dart';
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
            new Padding(padding: const EdgeInsets.all(10.0)),
            ImageIcon(
              AssetImage('images/car-leaf.png'),
              color: Util.primaryColor(context),
              size: 100.0,
            ),
            new Padding(padding: const EdgeInsets.all(5.0)),
            new Text('My Leaf', style: TextStyle(fontSize: 20.0),),
            new Text('Third party NissanConnect EV app', style: TextStyle(fontSize: 18.0),),
            new ListTile(
              title: const Text('Developed by'),
              subtitle: const Text('Tobias Westergaard Kjeldsen <me@tobis.dk>'),
              onTap: () {_launchUrl('mailto:me@tobis.dk');},
            ),
            new ListTile(
              title: const Text('My Leaf icon by'),
              subtitle: const Text('Freepik at flaticon.com'),
            ),
            new Text('Libraries and source code', style: TextStyle(fontSize: 20.0),),
            new ListTile(
              title: const Text('dartcarwings library'),
              subtitle: const Text('https://gitlab.com/tobiaswkjeldsen/dartcarwings'),
              onTap: () {_launchUrl('https://gitlab.com/tobiaswkjeldsen/dartcarwings');},
            ),
            new ListTile(
              title: const Text('My Leaf source code'),
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
