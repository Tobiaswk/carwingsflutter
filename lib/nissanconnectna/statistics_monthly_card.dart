import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/widget_rotater.dart';
import 'package:dartnissanconnectna/dartnissanconnectna.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsMonthlyCard extends StatefulWidget {
  StatisticsMonthlyCard(this.session);

  final Session session;

  @override
  _StatisticsMonthlyCardState createState() => _StatisticsMonthlyCardState();
}

class _StatisticsMonthlyCardState extends State<StatisticsMonthlyCard> {
  PreferencesManager preferencesManager = PreferencesManager();

  GeneralSettings _generalSettings = GeneralSettings();

  NissanConnectStats? _stats;

  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _update();
  }

  _getMonthlyStatistics() async {
    NissanConnectStats? statsDaily = await widget
        .session.nissanConnectNa.vehicle
        .requestMonthlyStatistics(_currentMonth);
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
      await _getMonthlyStatistics();
    } finally {
      setState(() {
        _isLoading = false;
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
      DateTime? date,
      String kWhPerKilometers,
      String kWhPerMiles,
      String kilometersPerKWh,
      String milesPerKWh,
      String travelDistanceKilometers,
      String travelDistanceMiles,
      String kWhUsed,
      Duration travelTime,
      String co2ReductionKg) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Driving efficiency'),
                            Text(
                              '${_generalSettings.useMileagePerKWh ? _generalSettings.useMiles ? milesPerKWh : kilometersPerKWh : _generalSettings.useMiles ? kWhPerMiles : kWhPerKilometers}',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        Column(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
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
                        Column(
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
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('CO2 savings'),
                                  Text(
                                    co2ReductionKg,
                                    style: TextStyle(fontSize: 25.0),
                                  )
                                ],
                              )
                            : Column(),
                      ],
                    ),
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
        child: _stats != null
            ? _withValues(
                _stats!.date,
                _stats!.kWhPerKilometers,
                _stats!.kWhPerMiles,
                _stats!.kilometersPerKWh,
                _stats!.milesPerKWh,
                _stats!.travelDistanceKilometers,
                _stats!.travelDistanceMiles,
                _stats!.kWhUsed,
                _stats!.travelTime,
                _stats!.co2ReductionKg,
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
                Duration(minutes: 0),
                '-',
              ));
  }
}
