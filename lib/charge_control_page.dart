import 'package:carwingsflutter/util.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _ChargeControlPageState extends State<ChargeControlPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  CarwingsSession _session;

  bool _isCharging = false;
  bool _chargeControlReady = false;

  DateTime _startDate = new DateTime(new DateTime.now().year,
      new DateTime.now().month, new DateTime.now().day);
  DateTime _currentDate = new DateTime(new DateTime.now().year,
      new DateTime.now().month, new DateTime.now().day);
  DateTime chargingScheduled;

  _ChargeControlPageState(this._session) {
    _updateBatteryStatus();
  }

  _updateBatteryStatus() {
    _session.vehicle.requestBatteryStatus().then((battery) {
      _session.vehicle.requestBatteryStatusLatest().then((battery) {
        setState(() {
          _isCharging = battery.isCharging;
          _chargeControlReady = true;
        });
      }); // Kinda hacky, works for now
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
            Util.showLoadingDialog(context);
            _session.vehicle.requestChargingStart(_currentDate).then((_) {
              _updateBatteryStatus();
              _snackbar('Charging was scheduled');
            }).catchError((error) {
              _isCharging = false;
              _snackbar('Charging was not scheduled');
            }).whenComplete(() => Util.dismissLoadingDialog(context));
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
        onTap: _chargeControlReady ? _updateBatteryStatus : null,
        onLongPress: _chargeControlReady ? _chargingSchedule : null,
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(
                Icons.power,
                color: _isCharging
                    ? Util.primaryColor(context)
                    : Theme.of(context).disabledColor,
                size: 200.0,
              ),
              Text('Charging is ${_chargeControlReady ? _isCharging
                  ? 'on'
                  : 'off' : 'updating...'}'),
              Text('Long press to schedule ${chargingScheduled != null
                  ? '(starts ${new DateFormat('EEEE H:mm').format(
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
  ChargeControlPage(this.session);

  CarwingsSession session;

  @override
  _ChargeControlPageState createState() => new _ChargeControlPageState(session);
}
