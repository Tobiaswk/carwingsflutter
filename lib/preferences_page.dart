import 'package:carwingsflutter/about_page.dart';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/widget_api_chooser.dart';
import 'package:flutter/material.dart';

import 'preferences_types.dart';
import 'time_zones.dart';

var preferencesManager = PreferencesManager();

class PreferencesPage extends StatefulWidget {
  const PreferencesPage(this.configuration, this.updater, this.session);

  final Setting configuration;
  final ValueChanged<Setting> updater;
  final Session session;

  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  GeneralSettings _generalSettings = GeneralSettings();

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
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return AboutPage();
      },
    ));
  }

  _openDebugPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return WidgetAPIChooser.debugPage(widget.session);
      },
    ));
  }

  void _changeTheme() {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) =>
          SimpleDialog(title: const Text("Color preference"), children: [
        ListTile(
            title: Text("Standard"),
            subtitle: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  width: 20.0,
                ),
              ),
            ),
            onTap: () {
              _handleThemeChanged(ThemeColor.standard);
            }),
        ListTile(
            title: Text("Green"),
            subtitle: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.green,
                  width: 20.0,
                ),
              ),
            ),
            onTap: () {
              _handleThemeChanged(ThemeColor.green);
            }),
        ListTile(
            title: Text("Red"),
            subtitle: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 20.0,
                ),
              ),
            ),
            onTap: () {
              _handleThemeChanged(ThemeColor.red);
            }),
        ListTile(
            title: Text("Purple"),
            subtitle: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.purple,
                  width: 20.0,
                ),
              ),
            ),
            onTap: () {
              _handleThemeChanged(ThemeColor.purple);
            }),
        ListTile(
            title: Text("Dark"),
            subtitle: Container(
              decoration: BoxDecoration(
                border: Border.all(
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
    widget.updater(value);
  }

  Widget buildSettingsPane(BuildContext context) {
    final List<Widget> rows = <Widget>[
      ListTile(
        leading: Icon(Icons.color_lens),
        title: const Text('Color preference'),
        onTap: _changeTheme,
      ),
      ListTile(
          title: Text('Show statistics in miles'),
          trailing: Switch(
              value: _generalSettings.useMiles,
              onChanged: (bool value) {
                setState(() {
                  _generalSettings.useMiles = value;
                  persistGeneralSettings();
                });
              })),
      ListTile(
          title: Text('Show CO2 reductions'),
          trailing: Switch(
              value: _generalSettings.showCO2,
              onChanged: (bool value) {
                setState(() {
                  _generalSettings.showCO2 = value;
                  persistGeneralSettings();
                });
              })),
      ListTile(
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
      ListTile(
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
      ListTile(
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
          ? ListTile(
              trailing: DropdownButton<String>(
                value: _generalSettings.timeZone.isEmpty
                    ? _buildTimeZoneDropDownMenuItems()[0].value
                    : _generalSettings.timeZone,
                items: _buildTimeZoneDropDownMenuItems(),
                onChanged: (timezone) {
                  setState(() {
                    _generalSettings.timeZone = timezone!;
                    persistGeneralSettings();
                  });
                },
              ),
            )
          : Row(),
      ListTile(
        title: Text('Turn on debugging'),
        trailing: Switch(
            value: widget.session.carwings.debug,
            onChanged: (bool value) {
              setState(() {
                widget.session.carwings.debug = value;
                widget.session.nissanConnectNa.debug = value;
                widget.session.nissanConnect.debug = value;
              });
            }),
      ),
      ListTile(
          leading: Icon(Icons.info),
          title: Text("Debug log"),
          onTap: _openDebugPage),
      ListTile(
          leading: Icon(Icons.info),
          title: Text("About"),
          onTap: _openAboutPage),
    ];
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      children: rows,
    );
  }

  void persistGeneralSettings() {
    preferencesManager.setGeneralSettings(_generalSettings);
    if (_generalSettings.timeZoneOverride) {
      widget.session.carwings.setTimeZoneOverride(_generalSettings.timeZone);
    } else {
      widget.session.carwings.setTimeZoneOverride(null);
    }
  }

  List<DropdownMenuItem<String>> _buildTimeZoneDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = [];
    for (String timezone in timeZones) {
      items.add(DropdownMenuItem(value: timezone, child: Text(timezone)));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Preferences')),
        body: buildSettingsPane(context));
  }
}
