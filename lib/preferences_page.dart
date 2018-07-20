import 'package:carwingsflutter/about_page.dart';
import 'package:carwingsflutter/debug_page.dart';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'preferences_types.dart';

var preferencesManager = new PreferencesManager();

class PreferencesPage extends StatefulWidget {
  const PreferencesPage(this.configuration, this.updater, this.session);

  final Setting configuration;
  final ValueChanged<Setting> updater;
  final CarwingsSession session;

  @override
  _PreferencesPageState createState() => new _PreferencesPageState(session);
}

class _PreferencesPageState extends State<PreferencesPage> {
  GeneralSettings _generalSettings = new GeneralSettings();
  CarwingsSession _session;

  _PreferencesPageState(this._session) {
    preferencesManager.getGeneralSettings().then((generalSettings) {
      setState(() {
        _generalSettings = generalSettings;
      });
    });
  }

  void _handleThemeChanged(ThemeColor color) {
    sendUpdates(widget.configuration.copyWith(theme: color));
    preferencesManager.setTheme(color.index);
    Navigator.pop(context, true);
  }

  _openAboutPage() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return new AboutPage();
      },
    ));
  }

  _openDebugPage() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return new DebugPage(session: _session,);
      },
    ));
  }

  void _changeTheme() {
    showDialog<bool>(
      context: context,
      child: new SimpleDialog(title: const Text("Color preference"), children: [
        new ListTile(
            title: new Text("Standard"),
            subtitle: new Container(
              decoration: new BoxDecoration(
                border: new Border.all(
                  color: Colors.blue,
                  width: 20.0,
                ),
              ),
            ),
            onTap: () {
              _handleThemeChanged(ThemeColor.standard);
            }),
        new ListTile(
            title: new Text("Green"),
            subtitle: new Container(
              decoration: new BoxDecoration(
                border: new Border.all(
                  color: Colors.green,
                  width: 20.0,
                ),
              ),
            ),
            onTap: () {
              _handleThemeChanged(ThemeColor.green);
            }),
        new ListTile(
            title: new Text("Red"),
            subtitle: new Container(
              decoration: new BoxDecoration(
                border: new Border.all(
                  color: Colors.red,
                  width: 20.0,
                ),
              ),
            ),
            onTap: () {
              _handleThemeChanged(ThemeColor.red);
            }),
        new ListTile(
            title: new Text("Purple"),
            subtitle: new Container(
              decoration: new BoxDecoration(
                border: new Border.all(
                  color: Colors.purple,
                  width: 20.0,
                ),
              ),
            ),
            onTap: () {
              _handleThemeChanged(ThemeColor.purple);
            }),
        new ListTile(
            title: new Text("Dark"),
            subtitle: new Container(
              decoration: new BoxDecoration(
                border: new Border.all(
                  color: Colors.black87,
                  width: 20.0,
                ),
              ),
            ),
            onTap: () {
              _handleThemeChanged(ThemeColor.dark);
            }),
      ]),
    );
  }

  void sendUpdates(Setting value) {
    if (widget.updater != null) widget.updater(value);
  }

  Widget buildSettingsPane(BuildContext context) {
    final List<Widget> rows = <Widget>[
      new ListTile(
        leading: new Icon(Icons.color_lens),
        title: const Text('Color preference'),
        onTap: _changeTheme,
      ),
      new ListTile(
          title: Text('Show statistics in miles'),
          trailing: Switch(
              value: _generalSettings.useMiles != null
                  ? _generalSettings.useMiles
                  : false,
              onChanged: (bool value) {
                setState(() {
                  _generalSettings.useMiles = value;
                  preferencesManager.setGeneralSettings(_generalSettings);
                });
              }),
          onTap: _openAboutPage),
      new ListTile(
        title: Text('Use mileage/kWh'),
        trailing: Switch(
            value: _generalSettings.useMileagePerKWh != null
                ? _generalSettings.useMileagePerKWh
                : false,
            onChanged: (bool value) {
              setState(() {
                _generalSettings.useMileagePerKWh = value;
                preferencesManager.setGeneralSettings(_generalSettings);
              });
            }),
      ),
      new ListTile(
        title: Text('Turn on debugging'),
        trailing: Switch(
            value: _session.debug != null
                ? _session.debug
                : false,
            onChanged: (bool value) {
              setState(() {
                _session.debug = value;
              });
            }),
      ),
      new ListTile(
          leading: new Icon(Icons.info),
          title: new Text("Debug log"),
          onTap: _openDebugPage),
      new ListTile(
          leading: new Icon(Icons.info),
          title: new Text("About"),
          onTap: _openAboutPage),
    ];
    return new ListView(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      children: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: const Text('Preferences')),
        body: buildSettingsPane(context));
  }
}
