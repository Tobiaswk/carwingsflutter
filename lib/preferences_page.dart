import 'package:carwingsflutter/about_page.dart';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/widget_delegator.dart';
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
  _PreferencesPageState createState() => _PreferencesPageState(session);
}

class _PreferencesPageState extends State<PreferencesPage> {
  GeneralSettings _generalSettings = GeneralSettings();
  Session _session;

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
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return AboutPage();
      },
    ));
  }

  _openDebugPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return WidgetDelegator.debugPage(_session);
      },
    ));
  }

  void _changeTheme() {
    showDialog<bool>(
      context: context,
      child: SimpleDialog(title: const Text("Color preference"), children: [
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
    if (widget.updater != null) widget.updater(value);
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
              trailing: DropdownButton(
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
          : Row(),
      ListTile(
        title: Text('Turn on debugging'),
        trailing: Switch(
            value: _session.carwings.debug != null
                ? _session.carwings.debug
                : false,
            onChanged: (bool value) {
              setState(() {
                _session.carwings.debug = value;
                _session.nissanConnectNa.debug = value;
                _session.nissanConnect.debug = value;
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
      _session.carwings.setTimeZoneOverride(_generalSettings.timeZone);
    } else {
      _session.carwings.setTimeZoneOverride(null);
    }
  }

  List<DropdownMenuItem> _buildTimeZoneDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = List();
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
