import 'package:carwingsflutter/util.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _ClimateControlPageState extends State<ClimateControlPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  CarwingsSession _session;

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
      });
    });
    _session.vehicle.requestClimateControlScheduleGet().then((date) {
      _climateControlScheduled = date;
    });
  }

  _climateControlToggle() {
    setState(() {
      Util.showLoadingDialog(context);
      _climateControlOn = !_climateControlOn;
      if (_climateControlOn) {
        _session.vehicle.requestClimateControlOn().then((_) {
          Util.dismissLoadingDialog(context);
          _snackbar('Climate Control was turned on');
        }).catchError((error) {
          _climateControlOn = !_climateControlOn;
          _snackbar('Climate Control failed to turn on');
        });
        ;
      } else {
        _session.vehicle.requestClimateControlOff().then((_) {
          Util.dismissLoadingDialog(context);
          _snackbar('Climate Control was turned off');
        }).catchError((error) {
          _climateControlOn = !_climateControlOn;
          _snackbar('Climate Control failed to turn off');
        });
      }
    });
  }

  _climateControlScheduledCancel() {
    Util.showLoadingDialog(context);
    _session.vehicle.requestClimateControlScheduleCancel().then((ok) {
      if (ok) {
        Util.dismissLoadingDialog(context);
        _snackbar('Scheduled Climate Control was canceled');
      } else {
        _snackbar('Could not cancel scheduled Climate Control');
      }
      Util.dismissLoadingDialog(context);
    });
  }

  _climateControlSchedule() {
    if (_climateControlScheduled != null) {
      showDialog<bool>(
          context: context,
          child: new AlertDialog(
              title: const Text("Scheduled Climate Control"),
              content:
                  new Text('Do you want to cancel scheduled Climate Control?'),
              actions: <Widget>[
                new FlatButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.pop(context, false);
                    }),
                new FlatButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      _climateControlScheduledCancel();
                      Navigator.pop(context, false);
                    }),
              ]));
    }
    showDatePicker(
        context: context,
        initialDate: _currentDate,
        firstDate: _startDate,
        lastDate: new DateTime.now().add(new Duration(days: 30))).then((date) {
      if (date != null) {
        showTimePicker(context: context, initialTime: TimeOfDay.now())
            .then((time) {
          if (time != null) {
            _currentDate = new DateTime(
                date.year, date.month, date.day, time.hour, time.minute);
            _session.vehicle
                .requestClimateControlSchedule(_currentDate)
                .then((ok) {
              if (ok) {
                setState(() {
                  _climateControlScheduled = _currentDate;
                });
              }
            });
          }
        });
      }
    });
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
        onTap: _climateControlToggle,
        onLongPress: _climateControlSchedule,
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new ImageIcon(
                AssetImage('images/aircondition.png'),
                color: _climateControlOn
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
                size: 200.0,
              ),
              Text('Climate Control is ${_climateControlOn ? 'on' : 'off'}'),
              Text('Tap to toggle'),
              Text('Long press to schedule ${_climateControlScheduled != null
                  ? '(scheduled for ${new DateFormat('EEEE H:m').format(
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
  ClimateControlPage({Key key, this.session}) : super(key: key);

  CarwingsSession session;

  @override
  _ClimateControlPageState createState() =>
      new _ClimateControlPageState(session);
}
