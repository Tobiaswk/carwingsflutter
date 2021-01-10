import 'dart:async';

import 'package:carwingsflutter/util.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class _AboutPageState extends State<AboutPage> {
  static var _LICENSE =
      'The MIT License\n\nCopyright (c) 2021 Tobias Westergaard Kjeldsen\n\nPermission is hereby granted, free of charge, to any person obtaining a copyof this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.';

  Future _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About")),
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(padding: const EdgeInsets.all(8.0)),
              ImageIcon(
                AssetImage('images/car-leaf.png'),
                color: Util.primaryColor(context),
                size: 100.0,
              ),
              Padding(padding: const EdgeInsets.all(5.0)),
              Text(
                'My Leaf',
                style: TextStyle(fontSize: 20.0),
              ),
              Text(
                'Third party NissanConnect app',
                style: TextStyle(fontSize: 18.0),
              ),
              ListTile(
                title: const Text('Developed by'),
                subtitle:
                    const Text('Tobias Westergaard Kjeldsen <me@tobis.dk>'),
                onTap: () {
                  _launchUrl('mailto:me@tobis.dk');
                },
              ),
              ListTile(
                title: const Text('My Leaf icon by'),
                subtitle: const Text('Freepik at flaticon.com'),
              ),
              Text(
                'Libraries and source code',
                style: TextStyle(fontSize: 20.0),
              ),
              ListTile(
                title: const Text('dartcarwings library'),
                subtitle: const Text(
                    'https://gitlab.com/tobiaswkjeldsen/dartcarwings'),
                onTap: () {
                  _launchUrl('https://gitlab.com/tobiaswkjeldsen/dartcarwings');
                },
              ),
              ListTile(
                title: const Text('dartnissanconnect library'),
                subtitle: const Text(
                    'https://gitlab.com/tobiaswkjeldsen/dartnissanconnect'),
                onTap: () {
                  _launchUrl(
                      'https://gitlab.com/tobiaswkjeldsen/dartnissanconnect');
                },
              ),
              ListTile(
                title: const Text('dartnissanconnectna library'),
                subtitle: const Text(
                    'https://gitlab.com/tobiaswkjeldsen/dartnissanconnectna'),
                onTap: () {
                  _launchUrl(
                      'https://gitlab.com/tobiaswkjeldsen/dartnissanconnectna');
                },
              ),
              ListTile(
                title: const Text('blowfish_native library'),
                subtitle: const Text(
                    'https://gitlab.com/tobiaswkjeldsen/blowfish_native'),
                onTap: () {
                  _launchUrl(
                      'https://gitlab.com/tobiaswkjeldsen/blowfish_native');
                },
              ),
              ListTile(
                title: const Text('My Leaf source code'),
                subtitle: const Text(
                    'https://gitlab.com/tobiaswkjeldsen/carwingsflutter'),
                onTap: () {
                  _launchUrl(
                      'https://gitlab.com/tobiaswkjeldsen/carwingsflutter');
                },
              ),
              Text(
                'License',
                style: TextStyle(fontSize: 20.0),
              ),
              Container(
                padding: const EdgeInsets.all(15.0),
                child: Text(_LICENSE),
              )
            ],
          )
        ],
      ),
    );
  }
}

class AboutPage extends StatefulWidget {
  AboutPage({Key key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}
