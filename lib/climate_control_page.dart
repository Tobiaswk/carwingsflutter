import 'package:carwingsflutter/util.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _ClimateControlPageState extends State<ClimateControlPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  CarwingsSession _session;

  bool _climateControlIsReady = false;
  bool _climateControlOn = false;

  DateTime _startDate = new DateTime(new DateTime.now().year,
      new DateTime.now().month, new DateTime.now().day);
  DateTime _currentDate = new DateTime(new DateTime.now().year,
      new DateTime.now().month, new DateTime.now().day);
  DateTime _climateControlScheduled;

  _ClimateControlPageState(this._session) {
    _session.vehicle.requestHVACStatus().then((hvac) {
      setState(() {
        _climateControlOn = hvac.isRunning;
        _climateControlIsReady = true;
      });
      _session.vehicle.requestClimateControlScheduleGet().then((date) {
        setState(() {
          _climateControlScheduled = date;
        });
      });
    });
  }

  _climateControlToggle() {
    setState(() {
      Util.showLoadingDialog(context);
      _climateControlOn = !_climateControlOn;
      if (_climateControlOn) {
        _session.vehicle.requestClimateControlOn().then((_) {
          _snackbar('Climate Control was turned on');
        }).catchError((error) {
          _climateControlOn = !_climateControlOn;
          _snackbar('Climate Control failed to turn on');
        }).whenComplete(() => Util.dismissLoadingDialog(context));
      } else {
        _session.vehicle.requestClimateControlOff().then((_) {
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
    _session.vehicle.requestClimateControlScheduleCancel().then((_) {
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
              lastDate: new DateTime.now().add(new Duration(days: 30)))
          .then((date) {
        if (date != null) {
          showTimePicker(context: context, initialTime: TimeOfDay.now())
              .then((time) {
            if (time != null) {
              _currentDate = new DateTime(
                  date.year, date.month, date.day, time.hour, time.minute);
              Util.showLoadingDialog(context);
              _session.vehicle
                  .requestClimateControlSchedule(_currentDate)
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
    scaffoldKey.currentState.showSnackBar(new SnackBar(
        duration: new Duration(seconds: 5), content: new Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(title: new Text("Climate Control")),
      body: new InkWell(
        onTap: _climateControlIsReady ? _climateControlToggle : null,
        onLongPress: _climateControlIsReady ? _climateControlSchedule : null,
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new ImageIcon(
                AssetImage('images/aircondition.png'),
                color:
                _climateControlOn
                    ? Util.primaryColor(context)
                    : Theme.of(context).disabledColor,
                size: 200.0,
              ),
              Text('Climate Control is ${_climateControlIsReady
                  ? _climateControlOn ? 'on' : 'off'
                  : 'updating...'}'),
              Text('Tap to toggle'),
              Text('Long press to schedule ${_climateControlScheduled != null
                  ? '(starts ${new DateFormat('EEEE H:mm').format(
                  _climateControlScheduled)})'
                  : '' }')
            ],
          ),
        ),
      ),
    );
  }
}

class ClimateControlPage extends StatefulWidget {
  ClimateControlPage(this.session);

  CarwingsSession session;

  @override
  _ClimateControlPageState createState() =>
      new _ClimateControlPageState(session);
}
