import 'package:carwingsflutter/about_page.dart';
import 'package:carwingsflutter/debug_page.dart';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'preferences_types.dart';
import 'time_zones.dart';

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

  _PreferencesPageState(this._session);

  @override
  void initState() {
    super.initState();
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
        return new DebugPage(
          _session,
        );
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
              value: _generalSettings.useMiles,
              onChanged: (bool value) {
                setState(() {
                  _generalSettings.useMiles = value;
                  persistGeneralSettings();
                });
              })),
      new ListTile(
          title: Text('Show CO2 reductions'),
          trailing: Switch(
              value: _generalSettings.showCO2,
              onChanged: (bool value) {
                setState(() {
                  _generalSettings.showCO2 = value;
                  persistGeneralSettings();
                });
              })),
      new ListTile(
        title: Text('Use mileage/kWh'),
        trailing: Switch(
            value: _generalSettings.useMileagePerKWh,
            onChanged: (bool value) {
              setState(() {
                _generalSettings.useMileagePerKWh = value;
                persistGeneralSettings();
              });
            }),
      ),
      new ListTile(
        title: Text('Use 12th bar notation (if applicable)'),
        trailing: Switch(
            value: _generalSettings.use12thBarNotation,
            onChanged: (bool value) {
              setState(() {
                _generalSettings.use12thBarNotation = value;
                persistGeneralSettings();
              });
            }),
      ),
      new ListTile(
          title: Text('Override time zone'),
          trailing: Switch(
              value: _generalSettings.timeZoneOverride,
              onChanged: (bool value) {
                setState(() {
                  _generalSettings.timeZoneOverride = value;
                  persistGeneralSettings();
                });
              })),
      _generalSettings.timeZoneOverride
          ? new ListTile(
              trailing: new DropdownButton(
                value: _generalSettings.timeZone != null &&
                        _generalSettings.timeZone.isEmpty
                    ? _buildTimeZoneDropDownMenuItems()[0].value
                    : _generalSettings.timeZone,
                items: _buildTimeZoneDropDownMenuItems(),
                onChanged: (timezone) {
                  setState(() {
                    _generalSettings.timeZone = timezone;
                    persistGeneralSettings();
                  });
                },
              ),
            )
          : new Row(),
      new ListTile(
        title: Text('Turn on debugging'),
        trailing: Switch(
            value: _session.debug != null ? _session.debug : false,
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

  void persistGeneralSettings() {
    preferencesManager.setGeneralSettings(_generalSettings);
    if (_generalSettings.timeZoneOverride) {
      _session.setTimeZoneOverride(_generalSettings.timeZone);
    } else {
      _session.setTimeZoneOverride(null);
    }
  }

  List<DropdownMenuItem> _buildTimeZoneDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String timezone in timeZones) {
      items.add(
          new DropdownMenuItem(value: timezone, child: new Text(timezone)));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: const Text('Preferences')),
        body: buildSettingsPane(context));
  }
}
