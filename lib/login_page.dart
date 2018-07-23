import 'package:blowfish_native/blowfish_native.dart';
import 'package:carwingsflutter/main_page.dart';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/util.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage(this.session, [this.autoLogin = true]);

  CarwingsSession session;
  bool autoLogin;

  @override
  _LoginPageState createState() => new _LoginPageState(session, autoLogin);
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  PreferencesManager preferencesManager = new PreferencesManager();

  CarwingsSession _session;

  bool _autoLogin;

  TextEditingController _usernameTextController = new TextEditingController();
  TextEditingController _passwordTextController = new TextEditingController();

  List<DropdownMenuItem<CarwingsRegion>> _regionDropDownMenuItems;
  CarwingsRegion _regionSelected = CarwingsRegion.Europe;

  bool _rememberCredentials = false;

  _LoginPageState(this._session, [this._autoLogin = false]) {
    _regionDropDownMenuItems = _buildRegionAndGetDropDownMenuItems();
    preferencesManager.getLoginSettings().then((login) {
      if (login != null) {
        _usernameTextController.text = login.username;
        _passwordTextController.text = login.password;
        _regionSelected = login.region;
        _rememberCredentials = true;
        if (_autoLogin) _doLogin();
      }
    });
  }

  _doLogin() {
    Util.showLoadingDialog(context, 'Signing in...');

    _session
        .login(
            username: _usernameTextController.text,
            password: _passwordTextController.text,
            blowfishEncryptCallback: (String key, String password) async {
              var encodedPassword = await BlowfishNative.encrypt(key, password);
              return encodedPassword;
            },
            region: _regionSelected)
        .then((vehicle) {
      Util.dismissLoadingDialog(context);

      // Login was successful, push main view
      Navigator.of(context).pushReplacement(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return new MainPage(_session);
        },
      ));

      if (_rememberCredentials) {
        preferencesManager.setLoginSettings(
            _session.username, _session.password, _regionSelected);
      }
    }).catchError((error) {
      Util.dismissLoadingDialog(context);

      scaffoldKey.currentState.showSnackBar(new SnackBar(
          duration: new Duration(seconds: 5),
          content: new Text('Login failed. Please try again')));
    });
  }

  List<DropdownMenuItem<CarwingsRegion>> _buildRegionAndGetDropDownMenuItems() {
    List<DropdownMenuItem<CarwingsRegion>> items = new List();
    for (CarwingsRegion region in CarwingsRegion.values) {
      items.add(new DropdownMenuItem(
          value: region,
          child:
              new Text(region.toString().replaceAll('CarwingsRegion\.', ''))));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        key: scaffoldKey,
        body: Theme(
            data: Theme.of(context).copyWith(
                primaryColorDark: Colors.white,
                primaryColorLight: Colors.white,
                textTheme: TextTheme(body1: TextStyle(color: Colors.white)),
                primaryColor: Colors.white,
                accentColor: Colors.white,
                buttonColor: Colors.white,
                hintColor: Colors.white,
                canvasColor: Theme.of(context).primaryColor,
                toggleableActiveColor: Colors.white),
            child: new Container(
              padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ImageIcon(
                      AssetImage('images/car-leaf.png'),
                      color: Colors.white,
                      size: 100.0,
                    ),
                    new Padding(padding: const EdgeInsets.all(10.0)),
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Enter your NissanEV Connect, also known as You+Nissan, credentials below',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                        TextFormField(
                          controller: _usernameTextController,
                          autofocus: false,
                          decoration: InputDecoration(labelText: 'Username'),
                        ),
                        TextFormField(
                          controller: _passwordTextController,
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                        ),
                        new Row(
                          children: <Widget>[
                            Text(
                              'Select region',
                              style: TextStyle(color: Colors.white),
                            ),
                            new Padding(padding: const EdgeInsets.all(10.0)),
                            new DropdownButton(
                              value: _regionSelected,
                              items: _regionDropDownMenuItems,
                              onChanged: (region) {
                                setState(() {
                                  _regionSelected = region;
                                });
                              },
                            )
                          ],
                        ),
                        new Padding(padding: const EdgeInsets.all(10.0)),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'Remember credentials',
                              style: TextStyle(color: Colors.white),
                            ),
                            Switch(
                                value: _rememberCredentials,
                                onChanged: (bool value) {
                                  setState(() {
                                    _rememberCredentials = value;
                                  });
                                }),
                            RaisedButton(
                                child: new Text("Login"), onPressed: _doLogin)
                          ],
                        )
                      ],
                    )
                  ]),
            )));
  }
}
