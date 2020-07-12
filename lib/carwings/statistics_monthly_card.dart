import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/widget_rotater.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsMonthlyCard extends StatefulWidget {
  StatisticsMonthlyCard(this.session);

  final Session session;

  @override
  _StatisticsMonthlyCardState createState() =>
      _StatisticsMonthlyCardState(session);
}

class _StatisticsMonthlyCardState extends State<StatisticsMonthlyCard> {
  PreferencesManager preferencesManager = PreferencesManager();

  GeneralSettings _generalSettings = GeneralSettings();

  Session _session;
  CarwingsStatsMonthly _statsMonthly;

  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  bool _isUpdating = false;

  _StatisticsMonthlyCardState(this._session);

  @override
  void initState() {
    super.initState();
    _update();
  }

  _getMonthlyStatistics() async {
    CarwingsStatsMonthly statsMonthly =
        await _session.carwings.vehicle.requestStatisticsMonthly(_currentMonth);
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
    try {
      await _getMonthlyStatistics();
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  // Present a date picker were only 1st day in each month is selectable
  // Used for changing monthly statistics month
  _changeStatisticsMonth() {
    // selectableDayPredicate is here to only make 1st day in month selectable
    // firstDate is 1 year back
    showDatePicker(
        context: context,
        initialDate: _currentMonth,
        firstDate: _currentMonth.subtract(Duration(days: 365)),
        lastDate: DateTime.now(),
        selectableDayPredicate: (date) => date.day == 1).then((date) {
      if (date != null) {
        _currentMonth = date;
        _update();
      }
    });
  }

  _withValues(
    DateTime date,
    String electricCostScale,
    String mileageUnit,
    String totalNumberOfTrips,
    String totalKWhPerMileage,
    String totalMileagePerKWh,
    String totalConsumptionKWh,
    String totalTravelDistanceMileage,
    String totalCO2Reduction,
  ) {
    return Material(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        elevation: 2.0,
        type: MaterialType.card,
        child: InkWell(
            child: Container(
                decoration: BoxDecoration(),
                padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              'Monthly Statistics',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Padding(padding: const EdgeInsets.all(3.0)),
                            InkWell(
                              onTap: _changeStatisticsMonth,
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.access_time),
                                  Padding(padding: const EdgeInsets.all(3.0)),
                                  Text(date != null
                                      ? DateFormat("MMMM").format(date)
                                      : '-'),
                                ],
                              ),
                            )
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Trips'),
                            Text(
                              '$totalNumberOfTrips',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Distance driven'),
                            Text(
                              '$totalTravelDistanceMileage',
                              style: TextStyle(fontSize: 25.0),
                            ),
                          ],
                        ),
                        Column(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Driving efficiency'),
                            Text(
                              '${_generalSettings.useMileagePerKWh ? totalMileagePerKWh : totalKWhPerMileage}',
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
    return Container(
        padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
        child: _statsMonthly != null
            ? _withValues(
                _statsMonthly.dateTime,
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
                null,
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
