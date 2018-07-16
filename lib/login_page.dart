import 'package:carwingsflutter/main_page.dart';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/util.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  PreferencesManager preferencesManager = new PreferencesManager();
  CarwingsSession session;

  TextEditingController _usernameTextController = new TextEditingController();
  TextEditingController _passwordTextController = new TextEditingController();
  bool _rememberCredentials = false;

  _LoginPageState() {
    preferencesManager.getLogin().then((login) {
      if (login != null) {
        _usernameTextController.text = login.username;
        _passwordTextController.text = login.password;
        _onLoginPressed();
      }
    });
  }

  _onLoginPressed() {
    Util.showLoadingDialog(context, 'Signing in...');

    session = new CarwingsSession(
        _usernameTextController.text, _passwordTextController.text);

    session.login().then((vehicle) {
      Util.dismissLoadingDialog(context);

      //Navigator.of(context).pop(); // Login was successful, pop view

      Navigator.of(context).pushReplacement(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return new MainPage(session: session);
        },
      ));

      if (_rememberCredentials) {
        preferencesManager.setLogin(session.username, session.password);
      }
    }).catchError((error) {
      Util.dismissLoadingDialog(context);

      _passwordTextController.clear();
      scaffoldKey.currentState.showSnackBar(new SnackBar(
          duration: new Duration(seconds: 5),
          content: new Text('Login failed. Please try again')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        key: scaffoldKey,
        body: FutureBuilder(
            future: preferencesManager.getLogin(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Theme(
                    data: Theme.of(context).copyWith(
                        primaryColorDark: Colors.white,
                        primaryColorLight: Colors.white,
                        textTheme:
                            TextTheme(body1: TextStyle(color: Colors.white)),
                        primaryColor: Colors.white,
                        accentColor: Colors.white,
                        buttonColor: Colors.white,
                        hintColor: Colors.white,
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
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.white),
                                ),
                                TextFormField(
                                  controller: _usernameTextController,
                                  autofocus: false,
                                  decoration:
                                      InputDecoration(labelText: 'Username'),
                                ),
                                TextFormField(
                                  controller: _passwordTextController,
                                  decoration:
                                      InputDecoration(labelText: 'Password'),
                                  obscureText: true,
                                ),
                                new Padding(
                                    padding: const EdgeInsets.all(10.0)),
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
                                        child: new Text("Login"),
                                        onPressed: _onLoginPressed)
                                  ],
                                )
                              ],
                            )
                          ]),
                    ));
              } else {
                return Center(
                  child: new ImageIcon(
                    AssetImage('images/car-leaf.png'),
                    color: Colors.white,
                    size: 200.0,
                  ),
                );
              }
            }));
  }
}
