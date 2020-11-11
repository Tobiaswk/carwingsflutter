import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/widget_rotater.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsDailyCard extends StatefulWidget {
  StatisticsDailyCard(this.session);

  final Session session;

  @override
  _StatisticsDailyCardState createState() => _StatisticsDailyCardState();
}

class _StatisticsDailyCardState extends State<StatisticsDailyCard> {
  PreferencesManager preferencesManager = PreferencesManager();

  GeneralSettings _generalSettings = GeneralSettings();

  CarwingsStatsDaily _statsDaily;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _update();
  }

  _getDailyStatistics() async {
    CarwingsStatsDaily statsDaily =
        await widget.session.carwings.vehicle.requestStatisticsDaily();
    setState(() {
      this._statsDaily = statsDaily;
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

  Widget _generateStars(int numberOfStars, [int maxNumberOfStars = 5]) {
    List<Icon> stars = List<Icon>();
    int starsAdded;
    for (starsAdded = 0; starsAdded < numberOfStars; starsAdded++) {
      stars.add(Icon(Icons.star, size: 18.0));
    }
    int starsRemaining = maxNumberOfStars - starsAdded;
    for (; starsRemaining > 0; starsRemaining--) {
      stars.add(Icon(
        Icons.star_border,
        size: 18.0,
      ));
    }
    return Row(
      children: stars,
    );
  }

  _withValues(
      DateTime date,
      String electricCostScale,
      String mileagePerKWh,
      String KWhPerMileage,
      String mileageLevel,
      String accelerationWh,
      String accelerationLevel,
      String regenerativeWh,
      String regenerativeLevel,
      String auxWh,
      String auxLevel) {
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
                              'Daily Statistics',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Padding(padding: const EdgeInsets.all(3.0)),
                            Icon(Icons.access_time),
                            Padding(padding: const EdgeInsets.all(3.0)),
                            Text(date != null
                                ? DateFormat("EEEE").format(date)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Driving efficiency'),
                            Text(
                              '${_generalSettings.useMileagePerKWh ? mileagePerKWh : KWhPerMileage}',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Rating'),
                            _generateStars(int.parse(mileageLevel))
                          ],
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Tooltip(
                          message: 'The gentler acceleration the better',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Acceleration'),
                              Text(
                                '$accelerationWh',
                                style: TextStyle(fontSize: 25.0),
                              )
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _generateStars(int.parse(accelerationLevel))
                          ],
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Tooltip(
                          message: 'The higher regeneration the better',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Regenerative'),
                              Text(
                                '$regenerativeWh',
                                style: TextStyle(fontSize: 25.0),
                              )
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _generateStars(int.parse(regenerativeLevel))
                          ],
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Tooltip(
                          message:
                              'The lower usage of other systems the better',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Other than driving'),
                              Text(
                                '$auxWh',
                                style: TextStyle(fontSize: 25.0),
                              )
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _generateStars(int.parse(auxLevel))
                          ],
                        )
                      ],
                    )
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
        child: _statsDaily != null
            ? _withValues(
                _statsDaily.dateTime,
                _statsDaily.electricCostScale,
                _statsDaily.mileagePerKWh,
                _statsDaily.KWhPerMileage,
                _statsDaily.mileageLevel,
                _statsDaily.accelerationWh,
                _statsDaily.accelerationLevel,
                _statsDaily.regenerativeWh,
                _statsDaily.regenerativeLevel,
                _statsDaily.auxWh,
                _statsDaily.auxLevel,
              )
            : _withValues(
                null,
                'kWh/km',
                '-',
                '-',
                '0',
                '-',
                '0',
                '-',
                '0',
                '-',
                '0',
              ));
  }
}
