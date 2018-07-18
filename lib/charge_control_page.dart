import 'package:carwingsflutter/util.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _ChargeControlPageState extends State<ChargeControlPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  CarwingsSession session;

  bool _isCharging = false;

  DateTime _startDate = new DateTime(new DateTime.now().year,
      new DateTime.now().month, new DateTime.now().day);
  DateTime _currentDate = new DateTime(new DateTime.now().year,
      new DateTime.now().month, new DateTime.now().day);
  DateTime chargingScheduled;

  _ChargeControlPageState(this.session);

  _getBatteryLatest() {
    session.vehicle.requestBatteryStatusLatest().then((battery) {
      setState(() {
        _isCharging = battery.isCharging;
      });
    });
  }

  _updateBatteryStatus() {
    Util.showLoadingDialog(context);
    session.vehicle.requestBatteryStatus().then((battery) {
      _getBatteryLatest(); // Kinda hacky, works for now
      Util.dismissLoadingDialog(context);
    });
  }

  _chargingSchedule() {
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
            session.vehicle.requestChargingStart(_currentDate).then((ok) {
              if(ok) {
                _updateBatteryStatus();
                _snackbar('Charging was turned on');
              } else {
                _snackbar('Charging did not start');
              }
              Util.dismissLoadingDialog(context);

            }).catchError((error) {
              _isCharging = false;
              _snackbar('Error');
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
      appBar: new AppBar(title: new Text("Charging")),
      body: new InkWell(
        onTap: _updateBatteryStatus,
        onLongPress: _chargingSchedule,
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(
                Icons.power,
                color: _isCharging
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
                size: 200.0,
              ),
              Text('Charging is ${_isCharging ? 'on' : 'off'}'),
              Text('Tap to update'),
              Text('Long press to schedule ${chargingScheduled != null
                  ? '(scheduled for ${new DateFormat('EEEE H:m').format(
                  chargingScheduled)})'
                  : '' }')
            ],
          ),
        ),
      ),
    );
  }
}

class ChargeControlPage extends StatefulWidget {
  ChargeControlPage({Key key, this.session}) : super(key: key);

  CarwingsSession session;

  @override
  _ChargeControlPageState createState() => new _ChargeControlPageState(session);
}
