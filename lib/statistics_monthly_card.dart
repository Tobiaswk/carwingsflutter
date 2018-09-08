import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/widget_rotater.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsMonthlyCard extends StatefulWidget {
  StatisticsMonthlyCard(this.session);

  final CarwingsSession session;

  @override
  _StatisticsMonthlyCardState createState() =>
      new _StatisticsMonthlyCardState(session);
}

class _StatisticsMonthlyCardState extends State<StatisticsMonthlyCard> {
  PreferencesManager preferencesManager = new PreferencesManager();

  GeneralSettings _generalSettings = new GeneralSettings();

  CarwingsSession _session;
  CarwingsStatsMonthly _statsMonthly;

  bool _isUpdating = false;

  _StatisticsMonthlyCardState(this._session);

  @override
  void initState() {
    super.initState();
    _update();
  }

  _getMonthlyStatistics() async {
    CarwingsStatsMonthly statsMonthly =
        await _session.vehicle.requestStatisticsMonthly(new DateTime.now());
    setState(() {
      this._statsMonthly = statsMonthly;
    });
    GeneralSettings generalSettings =
        await preferencesManager.getGeneralSettings();
    setState(() {
      _generalSettings = generalSettings;
    });
  }

  _update() async {
    setState(() {
      _isUpdating = true;
    });
    await _getMonthlyStatistics();
    setState(() {
      _isUpdating = false;
    });
  }

  _withValues(
    DateTime month,
    String electricCostScale,
    String mileageUnit,
    String totalNumberOfTrips,
    String totalKWhPerMileage,
    String totalMileagePerKWh,
    String totalConsumptionKWh,
    String totalTravelDistanceMileage,
    String totalCO2Reduction,
  ) {
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
                        _isUpdating
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
                            Text('Distance driven'),
                            Text(
                              '$totalTravelDistanceMileage',
                              style: TextStyle(fontSize: 25.0),
                            ),
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Consumption'),
                            Text(
                              '$totalConsumptionKWh',
                              style: TextStyle(fontSize: 25.0),
                            ),
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
                            Text('Driving efficiency'),
                            Text(
                              '${_generalSettings.useMileagePerKWh
                                  ? totalMileagePerKWh
                                  : totalKWhPerMileage}',
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
        child: _statsMonthly != null
            ? _withValues(
                _statsMonthly.month,
                _statsMonthly.electricCostScale,
                _statsMonthly.mileageUnit,
                _statsMonthly.totalNumberOfTrips,
                _statsMonthly.totalkWhPerMileage,
                _statsMonthly.totalMileagePerKWh,
                _statsMonthly.totalConsumptionKWh,
                _statsMonthly.totalTravelDistanceMileage,
                _statsMonthly.totalCO2Reduction,
              )
            : _withValues(
                new DateTime.now(),
                'kWh/km',
                'km',
                '-',
                '-',
                '-',
                '-',
                '-',
                '-',
              ));
  }
}
