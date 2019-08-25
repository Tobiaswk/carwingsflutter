import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/util.dart';
import 'package:carwingsflutter/widget_rotater.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BatteryLatestCard extends StatefulWidget {
  BatteryLatestCard(this.session);

  final Session session;

  @override
  _BatteryLatestCardState createState() => new _BatteryLatestCardState(session);
}

class _BatteryLatestCardState extends State<BatteryLatestCard> {
  PreferencesManager preferencesManager = new PreferencesManager();

  GeneralSettings _generalSettings = new GeneralSettings();

  Session _session;
  dynamic _battery;

  bool _isLoading = false;

  _BatteryLatestCardState(this._session);

  @override
  void initState() {
    super.initState();
    _update();
  }

  _getBatteryStatusLatest() async {
    CarwingsBattery battery =
        await _session.carwings.vehicle.requestBatteryStatusLatest();
    setState(() {
      this._battery = battery;
    });
    GeneralSettings generalSettings =
        await preferencesManager.getGeneralSettings();
    setState(() {
      _generalSettings = generalSettings;
    });
  }

  _getBatteryStatus() async {
    await _session.carwings.vehicle.requestBatteryStatus();
  }

  _update() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _getBatteryStatusLatest(); // Present cached battery first
      await _getBatteryStatus(); // Requests new battery status polling
    } finally {
      await _getBatteryStatusLatest(); // Force use new cached battery
      setState(() {
        _isLoading = false;
      });
    }
  }

  _withValues(
      DateTime date,
      bool isCharging,
      String batteryPercentage,
      String battery12thBar,
      String cruisingRangeAcOffKm,
      String cruisingRangeAcOffMiles,
      String cruisingRangeAcOnKm,
      String cruisingRangeAcOnMiles,
      Duration timeToFullTrickle,
      Duration timeToFullL2,
      Duration timeToFullL2_6kw,
      String chargingkWLevelText,
      String chargingRemainingText) {
    return new Material(
        borderRadius: new BorderRadius.all(new Radius.circular(4.0)),
        elevation: 2.0,
        type: Util.isDarkTheme(context)
            ? MaterialType.transparency
            : MaterialType.card,
        child: new InkWell(
            child: new Container(
                decoration: Util.isDarkTheme(context)
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
                            Text(date != null
                                ? new DateFormat("EEEE H:mm").format(date)
                                : '-'),
                          ],
                        ),
                        _isLoading
                            ? WidgetRotater(IconButton(
                                icon: Icon(Icons.refresh),
                                onPressed: () => {},
                              ))
                            : IconButton(
                                icon: Icon(Icons.refresh),
                                onPressed: _update,
                              ),
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Row(
                          children: <Widget>[
                            isCharging ? Icon(Icons.power) : new Row(),
                            Text(
                              '${_generalSettings.use12thBarNotation && battery12thBar != null ? battery12thBar : batteryPercentage}',
                              style: TextStyle(fontSize: 40.0),
                            )
                          ],
                        ),
                        Text(
                          '${_generalSettings.useMiles ? cruisingRangeAcOffMiles : cruisingRangeAcOffKm}',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        new Text('/'),
                        new Row(
                          children: <Widget>[
                            Text(
                              '${_generalSettings.useMiles ? cruisingRangeAcOnMiles : cruisingRangeAcOnKm}',
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
                    isCharging
                        ? new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                chargingRemainingText,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                chargingkWLevelText,
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ],
                          )
                        : new Row(
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
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
        child: _battery != null
            ? _withValues(
                _battery.dateTime,
                _battery.isCharging,
                _battery.batteryPercentage,
                _battery.battery12thBar,
                _battery.cruisingRangeAcOffKm,
                _battery.cruisingRangeAcOffMiles,
                _battery.cruisingRangeAcOnKm,
                _battery.cruisingRangeAcOnMiles,
                _battery.timeToFullTrickle,
                _battery.timeToFullL2,
                _battery.timeToFullL2_6kw,
                _battery.chargingkWLevelText,
                _battery.chargingRemainingText)
            : _withValues(
                null,
                false,
                '-',
                '-',
                '-',
                '-',
                '-',
                '-',
                new Duration(hours: 0),
                new Duration(hours: 0),
                new Duration(hours: 0),
                '',
                ''));
  }
}
