import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/util.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsDailyCard extends StatefulWidget {
  StatisticsDailyCard(this.session);

  final CarwingsSession session;

  @override
  _StatisticsDailyCardState createState() =>
      new _StatisticsDailyCardState(session);
}

class _StatisticsDailyCardState extends State<StatisticsDailyCard> {
  PreferencesManager preferencesManager = new PreferencesManager();

  GeneralSettings _generalSettings = new GeneralSettings();
  CarwingsSession _session;
  CarwingsStatsDaily _statsDaily;

  _StatisticsDailyCardState(this._session) {
    _getDailyStatistics();
  }

  _getDailyStatistics() async {
    CarwingsStatsDaily statsDaily =
        await _session.vehicle.requestStatisticsDaily();
    setState(() {
      this._statsDaily = statsDaily;
    });
    GeneralSettings generalSettings = await preferencesManager.getGeneralSettings();
    setState(() {
      _generalSettings = generalSettings;
    });
  }

  _updateDailyStatistics() async {
    Util.showLoadingDialog(context);
    await _getDailyStatistics();
    Util.dismissLoadingDialog(context);
  }

  Widget _generateStars(int numberOfStars, [int maxNumberOfStars = 5]) {
    List<Icon> stars = new List<Icon>();
    int starsAdded;
    for(starsAdded = 0; starsAdded < numberOfStars; starsAdded++) {
      stars.add(Icon(Icons.star, size: 18.0));
    }
    int starsRemaining = maxNumberOfStars-starsAdded;
    for(; starsRemaining > 0; starsRemaining--) {
      stars.add(Icon(Icons.star_border, size: 18.0,));
    }
    return Row(children: stars,);
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
                            Text('Average mileage'),
                            Text(
                              '${_generalSettings.useMileagePerKWh ? mileagePerKWh : KWhPerMileage}',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Rating'),
                            _generateStars(int.parse(mileageLevel))
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
                              '$accelerationWh',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Rating'),
                            _generateStars(int.parse(accelerationLevel))
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
                              '$regenerativeWh',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Rating'),
                            _generateStars(int.parse(regenerativeLevel))
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
                              '$auxWh',
                              style: TextStyle(fontSize: 25.0),
                            )
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Rating'),
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
    return new Container(
        padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
        child: _statsDaily != null
            ? _withValues(
                _statsDaily.date,
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
                new DateTime.now(),
                'kWh/km',
                '0',
                '0',
                '0',
                '0',
                '0',
                '0',
                '0',
                '0',
                '0',
              ));
  }
}
