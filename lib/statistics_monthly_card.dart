import 'dart:async';

import 'package:carwingsflutter/util.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsMonthlyCard extends StatefulWidget {
  StatisticsMonthlyCard({Key key, this.session}) : super(key: key);

  final CarwingsSession session;

  @override
  _StatisticsMonthlyCardState createState() =>
      new _StatisticsMonthlyCardState(session);
}

class _StatisticsMonthlyCardState extends State<StatisticsMonthlyCard> {
  CarwingsSession session;
  CarwingsStatsMonthly statsMonthly;

  _StatisticsMonthlyCardState(this.session) {
    _getMonthlyStatistics();
  }

  _getMonthlyStatistics() async {
    CarwingsStatsMonthly statsMonthly = await session.vehicle
        .requestStatisticsMonthly(new DateTime.now());
    setState(() {
      this.statsMonthly = statsMonthly;
    });
  }

  _updateMonthlyStatistics() async {
    Util.showLoadingDialog(context);
    await _getMonthlyStatistics();
    Util.dismissLoadingDialog(context);
  }

  _withPlaceHolder(DateTime month,
      int totalNumberOfTrips,
      double totalKWhPerKm,
      double totalConsumptionKWh,
      double totalTravelDistanceKm,
      double totalCO2Reduction,) {
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
                              'Monthly Statistics',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            new Padding(padding: const EdgeInsets.all(3.0)),
                            Icon(Icons.access_time),
                            new Padding(padding: const EdgeInsets.all(3.0)),
                            Text(new DateFormat("MMMM").format(month)),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: _updateMonthlyStatistics,
                        ),
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Trips'),
                            Text(
                              '$totalNumberOfTrips',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Average kWh/km'),
                            Text(
                              '${new NumberFormat('0.00').format(
                                  totalKWhPerKm)} kWh',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Consumption'),
                            Text(
                              '${new NumberFormat('0.0').format(
                                  totalConsumptionKWh)} kWh',
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
                            Text('Distance driven'),
                            Text(
                              '${new NumberFormat('0').format(
                                  totalTravelDistanceKm)} km',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),

                      ],
                    )
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 15.0),
        child: statsMonthly != null
            ? _withPlaceHolder(
          statsMonthly.month,
          statsMonthly.totalNumberOfTrips,
          statsMonthly.totalkWhPerKm,
          statsMonthly.totalConsumptionKWh,
          statsMonthly.totalTravelDistanceKm,
          statsMonthly.totalCO2Reduction,
        )
            : _withPlaceHolder(
          new DateTime.now(),
          0,
          .0,
          .0,
          .0,
          .0,
        ));
  }
}
