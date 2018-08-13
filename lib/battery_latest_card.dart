import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/util.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BatteryLatestCard extends StatefulWidget {
  BatteryLatestCard(this.session);

  final CarwingsSession session;

  @override
  _BatteryLatestCardState createState() => new _BatteryLatestCardState(session);
}

class _BatteryLatestCardState extends State<BatteryLatestCard> {
  PreferencesManager preferencesManager = new PreferencesManager();

  GeneralSettings _generalSettings = new GeneralSettings();

  CarwingsSession _session;
  CarwingsBattery _battery;

  _BatteryLatestCardState(this._session) {
    preferencesManager.getGeneralSettings().then((generalSettings) {
      setState(() {
        _generalSettings = generalSettings;
      });
    });
    _getBatteryStatusLatest();
  }

  _getBatteryStatusLatest() async {
    CarwingsBattery battery =
        await _session.vehicle.requestBatteryStatusLatest();
    setState(() {
      this._battery = battery;
    });
  }

  _getBatteryStatus() async {
    await _session.vehicle.requestBatteryStatus();
  }

  _updateBatteryStatus() async {
    Util.showLoadingDialog(context);
    await _getBatteryStatus(); // Requests new battery status polling
    await _getBatteryStatusLatest(); // Kinda hacky, works for now
    Util.dismissLoadingDialog(context);
  }

  _withValues(
      DateTime date,
      String batteryPercentage,
      String cruisingRangeAcOffKm,
      String cruisingRangeAcOffMiles,
      String cruisingRangeAcOnKm,
      String cruisingRangeAcOnMiles,
      Duration timeToFullTrickle,
      Duration timeToFullL2,
      Duration timeToFullL2_6kw) {
    return new Material(
        borderRadius: new BorderRadius.all(new Radius.circular(4.0)),
        elevation: 2.0,
        type: _isDarkTheme()
            ? MaterialType.transparency
            : MaterialType.card,
        child: new InkWell(
            child: new Container(
                decoration: _isDarkTheme()
                    ? new BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('images/leaf-header.png'),
                            fit: BoxFit.cover))
                    : new BoxDecoration(),
                padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
                child: new Column(
                  children: <Widget>[
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Row(
                          children: <Widget>[
                            Text(
                              'Battery',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            new Padding(padding: const EdgeInsets.all(3.0)),
                            Icon(Icons.access_time),
                            new Padding(padding: const EdgeInsets.all(3.0)),
                            Text(new DateFormat("EEEE H:mm").format(date)),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: _updateBatteryStatus,
                        ),
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Row(
                          children: <Widget>[
                            _battery != null && _battery.isCharging
                                ? Icon(Icons.power)
                                : new Row(),
                            Text(
                              '$batteryPercentage',
                              style: TextStyle(fontSize: 40.0),
                            )
                          ],
                        ),
                        Text(
                          '${_generalSettings.useMiles
                              ? cruisingRangeAcOffMiles
                              : cruisingRangeAcOffKm}',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        new Text('/'),
                        new Row(
                          children: <Widget>[
                            Text(
                              '${_generalSettings.useMiles
                                  ? cruisingRangeAcOnMiles
                                  : cruisingRangeAcOnKm}',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Text(
                              'AC',
                              style: TextStyle(fontSize: 15.0),
                            )
                          ],
                        ),
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('~1kW'),
                        Text(
                          '${timeToFullTrickle.inHours} hrs',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        Text('~3kW'),
                        Text(
                          '${timeToFullL2.inHours} hrs',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        Text('~6kW'),
                        Text(
                          '${timeToFullL2_6kw.inHours} hrs',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ],
                    )
                    /**/
                  ],
                ))));
  }

  bool _isDarkTheme() => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
        child: _battery != null
            ? _withValues(
                _battery.timeStamp,
                _battery.batteryPercentage,
                _battery.cruisingRangeAcOffKm,
                _battery.cruisingRangeAcOffMiles,
                _battery.cruisingRangeAcOnKm,
                _battery.cruisingRangeAcOnMiles,
                _battery.timeToFullTrickle,
                _battery.timeToFullL2,
                _battery.timeToFullL2_6kw)
            : _withValues(
                new DateTime.now(),
                '0',
                '0',
                '0',
                '0',
                '0',
                new Duration(hours: 0),
                new Duration(hours: 0),
                new Duration(hours: 0)));
  }
}
