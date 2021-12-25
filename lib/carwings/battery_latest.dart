import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/widget_pulse.dart';
import 'package:carwingsflutter/widget_rotater.dart';
import 'package:dartcarwings/dartcarwings.dart';
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
  PreferencesManager preferencesManager = PreferencesManager();

  GeneralSettings _generalSettings = GeneralSettings();

  CarwingsBattery? _battery;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _update();
  }

  _getBatteryStatusLatest() async {
    CarwingsBattery? battery =
        await widget.session.carwings.vehicle.requestBatteryStatusLatest();
    setState(() {
      this._battery = battery;
    });
    GeneralSettings generalSettings =
        await preferencesManager.getGeneralSettings();
    setState(() {
      _generalSettings = generalSettings;
    });
  }

  _getBatteryStatus() async {
    await widget.session.carwings.vehicle.requestBatteryStatus();
  }

  _update() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _getBatteryStatusLatest(); // Present cached battery first
      await _getBatteryStatus(); // Requests new battery status polling
    } finally {
      await _getBatteryStatusLatest(); // Force use new cached battery
      setState(() {
        _isLoading = false;
      });
    }
  }

  _withValues(
      DateTime? date,
      bool isCharging,
      String batteryPercentage,
      String? battery12thBar,
      String cruisingRangeAcOffKm,
      String cruisingRangeAcOffMiles,
      String cruisingRangeAcOnKm,
      String cruisingRangeAcOnMiles,
      Duration timeToFullTrickle,
      Duration timeToFullL2,
      Duration timeToFullL2_6kw,
      String? chargingkWLevelText,
      String? chargingRemainingText) {
    return Container(
      height: 155,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 43,
            left: 94,
            child: isCharging
                ? Row(
                    children: <Widget>[
                      WidgetPulse(
                          Icon(
                            Icons.power,
                            color: Colors.white,
                          ),
                          1.0,
                          1.5,
                          Duration(milliseconds: 1500))
                    ],
                  )
                : Row(),
          ),
          Positioned(
            top: 125,
            left: 76,
            child: isCharging
                ? Text(
                    'Charging!',
                    style: TextStyle(color: Colors.white),
                  )
                : Row(),
          ),
          Positioned(
            top: 10,
            left: 20,
            child: SleekCircularSlider(
              appearance: CircularSliderAppearance(
                  size: MediaQuery.of(context).size.width * 0.46,
                  infoProperties: InfoProperties(
                    mainLabelStyle:
                        TextStyle(fontSize: 35.0, color: Colors.white),
                    topLabelText: 'Battery SOC',
                    topLabelStyle: TextStyle(color: Colors.white),
                  ),
                  customColors: CustomSliderColors(
                      progressBarColors: [Colors.white, Colors.white],
                      hideShadow: true,
                      dotColor: Colors.white,
                      trackColor: Colors.white,
                      shadowColor: Colors.white)),
              min: 0,
              max: 100,
              initialValue: double.parse(batteryPercentage.replaceAll('%', '')),
            ),
          ),
          Positioned(
              right: 0,
              child: Container(
                height: 155,
                width: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 40,
                          color: Theme.of(context).primaryColor),
                    ]),
              )),
          Positioned(
            top: 45,
            right: 30,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text('Ideal Range', style: TextStyle(color: Colors.white)),
                  Row(
                    children: <Widget>[
                      Text(
                        '${_generalSettings.useMiles ? cruisingRangeAcOffMiles : cruisingRangeAcOffKm}',
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      ),
                      Text(' / ',
                          style:
                              TextStyle(color: Colors.white, fontSize: 30.0)),
                      Row(
                        children: <Widget>[
                          Text(
                            '${_generalSettings.useMiles ? cruisingRangeAcOnMiles : cruisingRangeAcOnKm}',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0),
                          ),
                          Text(
                            ' AC',
                            style: TextStyle(color: Colors.white),
                          )
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
                                  color: Colors.white),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('~1kW',
                                    style: TextStyle(color: Colors.white)),
                                Text('${timeToFullTrickle.inHours} hrs',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            Text(' / ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 30.0)),
                            Column(
                              children: <Widget>[
                                Text('~3kW',
                                    style: TextStyle(color: Colors.white)),
                                Text('${timeToFullL2.inHours} hrs',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            Text(' / ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 30.0)),
                            Column(
                              children: <Widget>[
                                Text('~6kW',
                                    style: TextStyle(color: Colors.white)),
                                Text('${timeToFullL2_6kw.inHours} hrs',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            )
                          ],
                        )
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 28,
            child: Row(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.access_time, color: Colors.white),
                    Padding(padding: const EdgeInsets.all(3.0)),
                    Text(
                        date != null
                            ? DateFormat("EEE H:mm").format(date)
                            : '-',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                _isLoading
                    ? WidgetRotater(IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                        onPressed: () => {},
                      ))
                    : IconButton(
                        icon: Icon(Icons.refresh, color: Colors.white),
                        onPressed: _update,
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
        child: _battery != null
            ? _withValues(
                _battery!.dateTime,
                _battery!.isCharging,
                _battery!.batteryPercentage,
                _battery!.battery12thBar,
                _battery!.cruisingRangeAcOffKm,
                _battery!.cruisingRangeAcOffMiles,
                _battery!.cruisingRangeAcOnKm,
                _battery!.cruisingRangeAcOnMiles,
                _battery!.timeToFullTrickle,
                _battery!.timeToFullL2,
                _battery!.timeToFullL2_6kw,
                _battery!.chargingkWLevelText,
                _battery!.chargingRemainingText)
            : _withValues(
                null,
                false,
                '0',
                '-',
                '-',
                '-',
                '-',
                '-',
                Duration(hours: 0),
                Duration(hours: 0),
                Duration(hours: 0),
                '',
                ''));
  }
}
