import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/util.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BatteryLatestCard extends StatefulWidget {
  BatteryLatestCard({Key key, this.session}) : super(key: key);

  final CarwingsSession session;

  @override
  _BatteryLatestCardState createState() => new _BatteryLatestCardState(session);
}

class _BatteryLatestCardState extends State<BatteryLatestCard> {
  PreferencesManager preferencesManager = new PreferencesManager();

  bool _useMiles = false;

  CarwingsSession session;
  CarwingsBattery battery;

  _BatteryLatestCardState(this.session) {
    preferencesManager.getUseMiles().then((useMiles) {
      setState(() {
        _useMiles = useMiles;
      });
    });
    _getBatteryLatest();
  }

  _getBatteryLatest() {
    session.vehicle.requestBatteryStatusLatest().then((battery) {
      setState(() {
        this.battery = battery;
      });
    });
  }

  _updateBatteryStatus() {
    Util.showLoadingDialog(context);
    session.vehicle.requestBatteryStatus().then((battery) {
      _getBatteryLatest(); // Kinda hacky, works for now
      Util.dismissLoadingDialog(context);
    });
  }

  _withValues(
      DateTime date,
      double batteryPercentage,
      double cruisingRangeAcOffKm,
      double cruisingRangeAcOffMiles,
      double cruisingRangeAcOnKm,
      double cruisingRangeAcOnMiles,
      Duration timeToFullTrickle,
      Duration timeToFullL2,
      Duration timeToFullL2_6kw) {
    return new Material(
        borderRadius: new BorderRadius.all(new Radius.circular(4.0)),
        elevation: 2.0,
        type: MaterialType.card,
        child: new InkWell(
            child: new Container(
                decoration: new BoxDecoration(),
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
                            battery != null && battery.isCharging
                                ? Icon(Icons.power)
                                : new Row(),
                            Text(
                              '${new NumberFormat('0.0').format(
                                  batteryPercentage)}%',
                              style: TextStyle(fontSize: 40.0),
                            )
                          ],
                        ),
                        Text(
                          '${new NumberFormat('0.0').format(
                              _useMiles ? cruisingRangeAcOffMiles : cruisingRangeAcOffKm)} ${_useMiles ? 'mi' : 'km'}',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        new Row(
                          children: <Widget>[
                            Text(
                              '${new NumberFormat('0.0').format(
                                  _useMiles ? cruisingRangeAcOnMiles : cruisingRangeAcOnKm)} ${_useMiles ? 'mi' : 'km'}',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Text(
                              'AC',
                              style: TextStyle(fontSize: 15.0),
                            )
                          ],
                        )
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Trickle'),
                        Text(
                          '${timeToFullTrickle.inHours} hours',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        Text('~3kW'),
                        Text(
                          '${timeToFullL2.inHours} hours',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        Text('~6kW'),
                        Text(
                          '${timeToFullL2_6kw.inHours} hours',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ],
                    )
                    /**/
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
        child: battery != null
            ? _withValues(
                battery.timeStamp,
                battery.batteryPercentage,
                battery.cruisingRangeAcOffKm,
                battery.cruisingRangeAcOffMiles,
                battery.cruisingRangeAcOnKm,
                battery.cruisingRangeAcOnMiles,
                battery.timeToFullTrickle,
                battery.timeToFullL2,
                battery.timeToFullL2_6kw)
            : _withValues(
                new DateTime.now(),
                .0,
                .0,
                .0,
                .0,
                .0,
                new Duration(hours: 0),
                new Duration(hours: 0),
                new Duration(hours: 0)));
  }
}
