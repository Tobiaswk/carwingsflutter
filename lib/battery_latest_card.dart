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
  CarwingsSession session;
  CarwingsBattery battery;

  _BatteryLatestCardState(this.session) {
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

  _withPlaceHolder(
      DateTime date,
      double batteryPercentage,
      double cruisingRangeAcOffKm,
      double cruisingRangeAcOnKm,
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
                            Text('Battery', style: TextStyle(fontSize: 20.0),),
                            new Padding(padding: const EdgeInsets.all(3.0)),
                            Icon(Icons.access_time),
                            new Padding(padding: const EdgeInsets.all(3.0)),
                            Text(new DateFormat("EEEE H:m").format(date)),
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
                            battery != null && battery.isCharging ? Icon(Icons.power) : new Row(),
                            Text(
                              '$batteryPercentage%',
                              style: TextStyle(fontSize: 40.0),
                            )
                          ],
                        ),
                        Text(
                          '$cruisingRangeAcOffKm km',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        new Row(
                          children: <Widget>[
                            Text(
                              '$cruisingRangeAcOnKm km',
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
                    battery != null && battery.timeToFullTrickle.inHours != 0
                        ? new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Charging times'),
                              Text('~3kW'),
                              Text(
                                '${timeToFullL2.inHours} hours',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              Text('~6kW'),
                              Text(
                                '${timeToFullL2_6kw.inHours} hours',
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ],
                          )
                        : new Row()
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
        child: battery != null
            ? _withPlaceHolder(
                battery.timeStamp,
                battery.batteryPercentage,
                battery.cruisingRangeAcOffKm,
                battery.cruisingRangeAcOnKm,
                battery.timeToFullTrickle,
                battery.timeToFullL2,
                battery.timeToFullL2_6kw)
            : _withPlaceHolder(
                new DateTime.now(),
                .0,
                .0,
                .0,
                new Duration(hours: 0),
                new Duration(hours: 0),
                new Duration(hours: 0)));
  }
}
