import 'package:carwingsflutter/help_page.dart';
import 'package:carwingsflutter/main_page.dart';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/util.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  LoginPage(this.session);

  final Session session;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  PreferencesManager preferencesManager = PreferencesManager();

  CarwingsRegion _regionSelected = CarwingsRegion.World;
  bool _rememberLoginSettings = false;

  TextEditingController _usernameTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();

  String? _serverStatus;

  @override
  void initState() {
    super.initState();

    preferencesManager.getLoginSettings().then((login) {
      if (login != null) {
        _usernameTextController.text = login.username;
        _passwordTextController.text = login.password;
        _regionSelected = login.region;

        setState(() {
          _rememberLoginSettings = true;
        });

        _doLogin();
      }
    });

    preferencesManager.getGeneralSettings().then((generalSettings) {
      if (generalSettings.timeZoneOverride) {
        widget.session.carwings.setTimeZoneOverride(generalSettings.timeZone);
      }
    });

    _getServerStatus();
  }

  _getServerStatus() async {
    http.Response response =
        await http.get(Uri.parse('https://wkjeldsen.dk/myleaf/server_status'));

    setState(() {
      _serverStatus = response.body.trim();
    });
  }

  _doLogin() {
    Util.showBigLoadingDialog(context, 'Signing in');

    _getServerStatus();

    var username = _usernameTextController.text.trim();
    var password = _passwordTextController.text.trim();

    widget.session
        .login(username: username, password: password, region: _regionSelected)
        .then((_) {
      Util.dismissBigLoadingDialog(context);

      // Login was successful, push main view
      _openMainPage();

      if (_rememberLoginSettings) {
        preferencesManager.setLoginSettings(
            username, password, _regionSelected);
      } else {
        preferencesManager.clearLoginSettings();
      }
    }).catchError((error) {
      Util.dismissBigLoadingDialog(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 5),
          content: Text(
              'Sign in failed! Please make sure your credentials are valid!')));

      if (_serverStatus != null && _serverStatus!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 10), content: Text(_serverStatus!)));
      }
    });
  }

  List<DropdownMenuItem<CarwingsRegion>> _buildRegionAndGetDropDownMenuItems() {
    return CarwingsRegion.values.map((region) {
      return DropdownMenuItem(
          value: region,
          child: Text(region.toString().replaceAll('CarwingsRegion\.', '')));
    }).toList();
  }

  _openMainPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return MainPage(widget.session);
      },
    ));
  }

  _openHelpPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return HelpPage();
      },
    ));
  }

  _openPreferencesPage() {
    Navigator.pushNamed(context, '/preferences');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(.8),
        key: scaffoldKey,
        body: Theme(
            data: Theme.of(context).copyWith(
              primaryColorDark: Colors.white,
              primaryColorLight: Colors.white,
              textTheme: TextTheme(
                  bodySmall: TextStyle(color: Colors.white),
                  bodyMedium: TextStyle(color: Colors.white),
                  bodyLarge: TextStyle(color: Colors.white)),
              primaryColor: Colors.white,
              inputDecorationTheme: InputDecorationTheme(
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  )),
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: Colors.white,
                selectionColor: Colors.white,
                selectionHandleColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                          (states) => Colors.black),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (states) => Colors.white))),
              hintColor: Colors.white,
              canvasColor: Theme.of(context).primaryColor,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      child: ImageIcon(
                        AssetImage('images/car-leaf.png'),
                        color: Colors.white,
                        size: 100.0,
                      ),
                      onLongPress: _openPreferencesPage,
                    ),
                    Padding(padding: const EdgeInsets.all(10.0)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'My Leaf greets you welcome!',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                        Text(
                          'Ready your NissanConnect credentials',
                          style: TextStyle(fontSize: 15.0, color: Colors.white),
                        ),
                        TextFormField(
                            controller: _usernameTextController,
                            autofocus: false,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: InputDecoration(
                              labelText: 'Username',
                            )),
                        TextFormField(
                          controller: _passwordTextController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Region',
                              style: TextStyle(color: Colors.white),
                            ),
                            Padding(padding: const EdgeInsets.all(10.0)),
                            DropdownButton<CarwingsRegion>(
                              value: _regionSelected,
                              items: _buildRegionAndGetDropDownMenuItems(),
                              onChanged: (region) {
                                setState(() {
                                  _regionSelected =
                                      region ?? CarwingsRegion.World;
                                });
                              },
                            ),
                            TextButton.icon(
                                onPressed: _openHelpPage,
                                icon: Icon(
                                  Icons.help,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Help',
                                  style: TextStyle(color: Colors.white),
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'Remember',
                              style: TextStyle(color: Colors.white),
                            ),
                            Switch(
                                value: _rememberLoginSettings,
                                onChanged: (bool value) {
                                  setState(() {
                                    _rememberLoginSettings = value;
                                  });
                                }),
                            ElevatedButton(
                                child: Text("Sign in"), onPressed: _doLogin)
                          ],
                        )
                      ],
                    )
                  ]),
            )));
  }
}
