import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _ClimateControlPageState extends State<ClimateControlPage> {
  bool _climateControlIsReady = true;
  bool _climateControlOn = false;
  double? _cabinTemperature;

  DateTime _startDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _currentDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime? _climateControlScheduled;

  @override
  void initState() {
    super.initState();
    widget.session.nissanConnectNa.vehicle
        .requestClimateControlScheduled()
        .then((date) {
      setState(() {
        _climateControlScheduled = date;
      });
    });
    setState(() {
      _cabinTemperature = widget.session.nissanConnectNa.vehicle.incTemperature;
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
        widget.session.nissanConnectNa.vehicle
            .requestClimateControlOn(DateTime.now().add(Duration(seconds: 5)))
            .then((_) {
          _snackbar('Climate Control was turned on');
        }).catchError((error) {
          _climateControlOn = !_climateControlOn;
          _snackbar('Climate Control failed to turn on');
        }).whenComplete(() => Util.dismissLoadingDialog(context));
      } else {
        widget.session.nissanConnectNa.vehicle
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
    widget.session.nissanConnectNa.vehicle
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
              widget.session.nissanConnectNa.vehicle
                  .requestClimateControlOn(_currentDate)
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
            Text(
              'Tap to engage',
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).disabledColor),
            ),
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

  final Session session;

  @override
  _ClimateControlPageState createState() => _ClimateControlPageState();
}
