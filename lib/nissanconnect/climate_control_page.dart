import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class _ClimateControlPageState extends State<ClimateControlPage> {
  bool _climateControlIsReady = false;
  bool _climateControlOn = false;
  double? _cabinTemperature;
  double _sliderDesiredCabinTemperature = 21.0;

  DateTime _startDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _currentDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime? _climateControlScheduled;

  @override
  void initState() {
    super.initState();
    widget.session.nissanConnect.vehicle
        .requestClimateControlStatusRefresh()
        .then((_) {
      widget.session.nissanConnect.vehicle
          .requestClimateControlStatus()
          .then((hvac) {
        setState(() {
          _climateControlScheduled = hvac.climateScheduled;
          _cabinTemperature = hvac.cabinTemperature;
          _climateControlOn = hvac.isRunning;
          _climateControlIsReady = true;
        });
      });
    });
  }

  int _toFahrenheit(int temperatureCelcius) {
    return (temperatureCelcius * 9 / 5 + 32).floor();
  }

  _climateControlToggle() {
    setState(() {
      Util.showLoadingDialog(context);
      _climateControlOn = !_climateControlOn;
      if (_climateControlOn) {
        widget.session.nissanConnect.vehicle
            .requestClimateControlOn(
                DateTime.now(), _sliderDesiredCabinTemperature.toInt())
            .then((_) {
          _snackbar('Climate Control was turned on');
        }).catchError((error) {
          _climateControlOn = !_climateControlOn;
          _snackbar('Climate Control failed to turn on');
        }).whenComplete(() => Util.dismissLoadingDialog(context));
      } else {
        widget.session.nissanConnect.vehicle
            .requestClimateControlOff()
            .then((_) {
          _snackbar('Climate Control was turned off');
        }).catchError((error) {
          _climateControlOn = !_climateControlOn;
          _snackbar('Climate Control failed to turn off');
        }).whenComplete(() => Util.dismissLoadingDialog(context));
      }
    });
  }

  _climateControlScheduledCancel() {
    Util.showLoadingDialog(context);
    widget.session.nissanConnect.vehicle
        .requestClimateControlScheduledCancel()
        .then((_) {
      _snackbar('Scheduled Climate Control was canceled');
      setState(() {
        _climateControlScheduled = null;
      });
    }).catchError((error) {
      _snackbar('Could not cancel scheduled Climate Control');
    }).whenComplete(() => Util.dismissLoadingDialog(context));
  }

  _climateControlSchedule() {
    if (_climateControlScheduled != null) {
      _climateControlScheduledCancel();
    } else {
      showDatePicker(
              context: context,
              initialDate: _currentDate,
              firstDate: _startDate,
              lastDate: DateTime.now().add(Duration(days: 30)))
          .then((date) {
        if (date != null) {
          showTimePicker(context: context, initialTime: TimeOfDay.now())
              .then((time) {
            if (time != null) {
              _currentDate = DateTime(
                  date.year, date.month, date.day, time.hour, time.minute);
              Util.showLoadingDialog(context);
              widget.session.nissanConnect.vehicle
                  .requestClimateControlOn(_currentDate, 21)
                  .then((_) {
                setState(() {
                  _climateControlScheduled = _currentDate;
                });
                _snackbar('Climate Control was scheduled');
              }).catchError((error) {
                _snackbar('Climate Control schedule failed');
              }).whenComplete(() => Util.dismissLoadingDialog(context));
            }
          });
        }
      });
    }
  }

  _snackbar(message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(duration: Duration(seconds: 5), content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Climate Control")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: ImageIcon(AssetImage('images/aircondition.png')),
              iconSize: 200.0,
              color: _climateControlOn
                  ? Util.primaryColor(context)
                  : Theme.of(context).disabledColor,
              onPressed: _climateControlToggle,
            ),
            Text(
              'Climate Control is ${_climateControlIsReady ? _climateControlOn ? 'on' : 'off' : 'updating...'}',
              style: TextStyle(fontSize: 18.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Slider(
                  label: 'Desired cabin temperature',
                  value: _sliderDesiredCabinTemperature,
                  divisions: 10,
                  min: 16,
                  max: 26,
                  onChanged: !_climateControlOn
                      ? (value) {
                          setState(() {
                            _sliderDesiredCabinTemperature = value;
                          });
                        }
                      : null,
                ),
                Text(
                    '${_sliderDesiredCabinTemperature.floor()}°C / ${_toFahrenheit(_sliderDesiredCabinTemperature.floor())}°F')
              ],
            ),
            Text(
                'Cabin temperature is ${_cabinTemperature != null ? '${_cabinTemperature!.floor()}°C / ${_toFahrenheit(_cabinTemperature!.floor())}°F' : 'updating...'}'),
            IconButton(
              icon: Icon(Icons.access_time),
              iconSize: 200.0,
              color: _climateControlScheduled != null
                  ? Util.primaryColor(context)
                  : Theme.of(context).disabledColor,
              onPressed: _climateControlSchedule,
            ),
            Text(
              _climateControlScheduled != null
                  ? 'At ${DateFormat('HH:mm \'this\' EEEE').format(_climateControlScheduled!)}'
                  : 'Not scheduled',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}

class ClimateControlPage extends StatefulWidget {
  ClimateControlPage(this.session);

  Session session;

  @override
  _ClimateControlPageState createState() => _ClimateControlPageState();
}
