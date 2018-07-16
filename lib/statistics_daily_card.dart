import 'dart:async';

import 'package:carwingsflutter/util.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsDailyCard extends StatefulWidget {
  StatisticsDailyCard({Key key, this.session}) : super(key: key);

  final CarwingsSession session;

  @override
  _StatisticsDailyCardState createState() =>
      new _StatisticsDailyCardState(session);
}

class _StatisticsDailyCardState extends State<StatisticsDailyCard> {
  CarwingsSession session;
  CarwingsStatsDaily statsDaily;

  _StatisticsDailyCardState(this.session) {
    _getDailyStatistics();
  }

  _getDailyStatistics() async {
    CarwingsStatsDaily statsDaily = await session.vehicle.requestStatisticsDaily();
    setState(() {
      this.statsDaily = statsDaily;
    });
  }

  _updateDailyStatistics() async {
    Util.showLoadingDialog(context);
    await _getDailyStatistics();
    Util.dismissLoadingDialog(context);
  }

  _withPlaceHolder(
      DateTime date,
      double mileagekWh,
      int mileageLevel,
      double accelerationWh,
      int accelerationLevel,
      double regenerativeWh,
      int regenerativeLevel,
      double auxWh,
      int auxLevel) {
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
                              'Daily Statistics',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            new Padding(padding: const EdgeInsets.all(3.0)),
                            Icon(Icons.access_time),
                            new Padding(padding: const EdgeInsets.all(3.0)),
                            Text(new DateFormat("EEEE").format(date)),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: _updateDailyStatistics,
                        ),
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Usage per km'),
                            Text(
                              '${new NumberFormat('0.00').format(mileagekWh)} kWh',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Rating'),
                            Text(
                              '$mileageLevel / 5',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        )
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Acceleration'),
                            Text(
                              '${new NumberFormat('0.0').format(accelerationWh)} Wh',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Rating'),
                            Text(
                              '$accelerationLevel / 5',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        )
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Regenerative'),
                            Text(
                              '${new NumberFormat('0.0').format(regenerativeWh)} Wh',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Rating'),
                            Text(
                              '$regenerativeLevel / 5',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        )
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Other than driving'),
                            Text(
                              '${new NumberFormat('0.0').format(auxWh)} Wh',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Rating'),
                            Text(
                              '$auxLevel / 5',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
        child: statsDaily != null
            ? _withPlaceHolder(
                statsDaily.date,
                statsDaily.mileagekWh,
                statsDaily.mileageLevel,
                statsDaily.accelerationWh,
                statsDaily.accelerationLevel,
                statsDaily.regenerativeWh,
                statsDaily.regenerativeLevel,
                statsDaily.auxWh,
                statsDaily.auxLevel,
              )
            : _withPlaceHolder(
                new DateTime.now(),
                .0,
                0,
                .0,
                0,
                .0,
                0,
                .0,
                0,
              ));
  }
}
