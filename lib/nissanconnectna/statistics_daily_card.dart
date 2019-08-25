import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/widget_rotater.dart';
import 'package:dartnissanconnectna/dartnissanconnectna.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsDailyCard extends StatefulWidget {
  StatisticsDailyCard(this.session);

  final Session session;

  @override
  _StatisticsDailyCardState createState() =>
      new _StatisticsDailyCardState(session);
}

class _StatisticsDailyCardState extends State<StatisticsDailyCard> {
  PreferencesManager preferencesManager = new PreferencesManager();

  GeneralSettings _generalSettings = new GeneralSettings();

  Session _session;
  NissanConnectStats _stats;

  bool _isLoading = false;

  _StatisticsDailyCardState(this._session);

  @override
  void initState() {
    super.initState();
    _update();
  }

  _getDailyStatistics() async {
    NissanConnectStats statsDaily = await _session.nissanConnectNa.vehicle
        .requestDailyStatistics(new DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day));
    setState(() {
      this._stats = statsDaily;
    });
    GeneralSettings generalSettings =
        await preferencesManager.getGeneralSettings();
    setState(() {
      _generalSettings = generalSettings;
    });
  }

  _update() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _getDailyStatistics();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _withValues(
      DateTime date,
      String kWhPerKilometers,
      String kWhPerMiles,
      String kilometersPerKWh,
      String milesPerKWh,
      String travelDistanceKilometers,
      String travelDistanceMiles,
      String kWhUsed,
      Duration travelTime,
      String co2ReductionKg) {
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
                            Text(date != null
                                ? new DateFormat("EEEE").format(date)
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
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Driving efficiency'),
                            Text(
                              '${_generalSettings.useMileagePerKWh ? _generalSettings.useMiles ? milesPerKWh : kilometersPerKWh : _generalSettings.useMiles ? kWhPerMiles : kWhPerKilometers}',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Consumption'),
                            Text(
                              kWhUsed,
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        )
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Distance'),
                            Text(
                              _generalSettings.useMiles
                                  ? travelDistanceMiles
                                  : travelDistanceKilometers,
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Travel time'),
                            Text(
                              '${travelTime.inHours == 0 ? '-' : '${travelTime.inHours} hrs'}',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        _generalSettings.showCO2
                            ? new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('CO2 savings'),
                                  Text(
                                    co2ReductionKg,
                                    style: TextStyle(fontSize: 25.0),
                                  )
                                ],
                              )
                            : new Column(),
                      ],
                    ),
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
        child: _stats != null
            ? _withValues(
                _stats.date,
                _stats.kWhPerKilometers,
                _stats.kWhPerMiles,
                _stats.kilometersPerKWh,
                _stats.milesPerKWh,
                _stats.travelDistanceKilometers,
                _stats.travelDistanceMiles,
                _stats.kWhUsed,
                _stats.travelTime,
                _stats.co2ReductionKg,
              )
            : _withValues(
                null,
                '-',
                '-',
                '-',
                '-',
                '-',
                '-',
                '-',
                new Duration(minutes: 0),
                '-',
              ));
  }
}
