import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/widget_pulse.dart';
import 'package:carwingsflutter/widget_rotater.dart';
import 'package:dartnissanconnect/dartnissanconnect.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class BatteryLatest extends StatefulWidget {
  BatteryLatest(this.session);

  final Session session;

  @override
  _BatteryLatestState createState() => _BatteryLatestState();
}

class _BatteryLatestState extends State<BatteryLatest> {
  GeneralSettings _generalSettings = GeneralSettings();

  NissanConnectBattery? _battery;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _update();
  }

  _getBatteryStatus() async {
    await widget.session.nissanConnect.vehicle.requestBatteryStatusRefresh();
  }

  _getBatteryStatusLatest() async {
    NissanConnectBattery? battery = await widget.session.nissanConnect.vehicle
        .requestBatteryStatus();
    setState(() {
      this._battery = battery;
    });
    GeneralSettings generalSettings =
        await PreferencesManager.getGeneralSettings();
    setState(() {
      _generalSettings = generalSettings;
    });
  }

  _update() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _getBatteryStatusLatest();
      await _getBatteryStatus();
      await _getBatteryStatusLatest();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _withValues(
    DateTime? date,
    bool isCharging,
    String batteryPercentage,
    String cruisingRangeAcOffKm,
    String cruisingRangeAcOffMiles,
    String cruisingRangeAcOnKm,
    String cruisingRangeAcOnMiles,
    Duration? timeToFullSlow,
    Duration? timeToFullNormal,
    Duration? timeToFullFast,
    String? chargingkWLevelText,
    String? chargingRemainingText,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 33, top: 15, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.scaleDown,
              child: SleekCircularSlider(
                appearance: CircularSliderAppearance(
                  angleRange: 360,
                  startAngle: 90,
                  customColors: CustomSliderColors(
                    progressBarColors: [Colors.white, Colors.white],
                    hideShadow: true,
                    dotColor: Theme.of(context).primaryColor,
                    trackColor: Colors.white,
                    shadowColor: Colors.white,
                  ),
                ),
                min: 0,
                innerWidget: (double percentage) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isCharging
                            ? Column(
                                children: [
                                  WidgetPulse(
                                    Icon(Icons.power, color: Colors.white),
                                    1.0,
                                    1.5,
                                    Duration(milliseconds: 1500),
                                  ),
                                  Text(
                                    'Charging!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              )
                            : Container(),
                        Text(
                          'Battery SOC',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          '${percentage.floor()} %',
                          style: TextStyle(fontSize: 35.0, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
                max: 100,
                initialValue: double.parse(
                  batteryPercentage.replaceAll('%', ''),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.access_time, color: Colors.white),
                      Padding(padding: const EdgeInsets.all(3.0)),
                      Text(
                        date != null
                            ? DateFormat("EEE H:mm").format(date)
                            : '-',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  _isLoading
                      ? WidgetRotater(
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(Icons.refresh, color: Colors.white),
                            onPressed: () => {},
                          ),
                        )
                      : IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Icons.refresh, color: Colors.white),
                          onPressed: _update,
                        ),
                ],
              ),
              Text('Ideal Range', style: TextStyle(color: Colors.white)),
              Row(
                children: <Widget>[
                  Text(
                    '${_generalSettings.useMiles ? cruisingRangeAcOffMiles : cruisingRangeAcOffKm}',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                  Text(
                    ' / ',
                    style: TextStyle(color: Colors.white, fontSize: 30.0),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        '${_generalSettings.useMiles ? cruisingRangeAcOnMiles : cruisingRangeAcOnKm}',
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      ),
                      Text(
                        ' AC',
                        style: TextStyle(color: Colors.white, fontSize: 12.0),
                      ),
                    ],
                  ),
                ],
              ),
              Text("Charging Times", style: TextStyle(color: Colors.white)),
              isCharging
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          chargingRemainingText ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          chargingkWLevelText ?? '',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'slow',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                            Text(
                              '${timeToFullSlow?.inHours ?? '-'} hrs',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Text(
                          ' / ',
                          style: TextStyle(color: Colors.white, fontSize: 30.0),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'normal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                            Text(
                              '${timeToFullNormal?.inHours ?? '-'} hrs',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Text(
                          ' / ',
                          style: TextStyle(color: Colors.white, fontSize: 30.0),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'fast',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                            Text(
                              '${timeToFullFast?.inHours ?? '-'} hrs',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _battery != null
          ? _withValues(
              _battery!.dateTime,
              _battery!.isCharging,
              _battery!.batteryPercentageText,
              _battery!.cruisingRangeAcOffKm,
              _battery!.cruisingRangeAcOffMiles,
              _battery!.cruisingRangeAcOnKm,
              _battery!.cruisingRangeAcOnMiles,
              _battery!.timeToFullSlow,
              _battery!.timeToFullNormal,
              _battery!.timeToFullFast,
              _battery!.chargingkWLevelText,
              _battery!.chargingRemainingText,
            )
          : _withValues(
              null,
              false,
              '0',
              '-',
              '-',
              '-',
              '-',
              Duration(hours: 0),
              Duration(hours: 0),
              Duration(hours: 0),
              '',
              '',
            ),
    );
  }
}
