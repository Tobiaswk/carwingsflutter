import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/util.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _ChargeControlPageState extends State<ChargeControlPage> {
  PreferencesManager preferencesManager = PreferencesManager();

  bool _isCharging = false;
  bool _isConnected = false;
  bool _chargeControlReady = false;

  DateTime _startDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _currentDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      DateTime.now().hour,
      DateTime.now().add(Duration(seconds: 5)).minute);
  DateTime? _chargingScheduled;

  @override
  void initState() {
    super.initState();
    _updateBatteryStatus();
    _updateChargingSchedule();
  }

  _updateChargingSchedule() {
    preferencesManager.getChargingSchedule().then((chargingSchedule) {
      setState(() {
        // Charging is "expired"
        if (chargingSchedule.isAfter(DateTime.now())) {
          _chargingScheduled = chargingSchedule;
        }
      });
    });
  }

  _updateBatteryStatus() async {
    try {
      await widget.session.carwings.vehicle.requestBatteryStatus();
    } finally {
      CarwingsBattery? battery =
          await widget.session.carwings.vehicle.requestBatteryStatusLatest();
      setState(() {
        _isCharging = battery?.isCharging ?? false;
        _isConnected = battery?.isConnected ?? false;
        _chargeControlReady = true;
      });
    }
  }

  _chargingSchedule([now = false]) {
    if (now) {
      _requestStartCharging();
      return;
    }
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
            setState(() {
              _chargingScheduled = _currentDate;
            });
            _requestStartCharging();
          }
        });
      }
    });
  }

  void _requestStartCharging() {
    Util.showLoadingDialog(context);
    widget.session.carwings.vehicle
        .requestChargingStart(_currentDate)
        .then((_) {
      _updateBatteryStatus();
      _snackbar('Charging was scheduled');
      preferencesManager.setChargingSchedule(_currentDate);
    }).catchError((error) {
      _isCharging = false;
      _snackbar('Charging was not scheduled');
    }).whenComplete(() => Util.dismissLoadingDialog(context));
  }

  _snackbar(message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(duration: Duration(seconds: 5), content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Charging")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.power),
              iconSize: 200.0,
              color: _isCharging
                  ? Util.primaryColor(context)
                  : Theme.of(context).disabledColor,
              onPressed: () => _chargingSchedule(true),
            ),
            Text(
              'Charging is ${_chargeControlReady ? _isCharging ? 'on' : 'off' : 'updating...'}',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'Cable is ${_chargeControlReady ? _isConnected ? 'connected' : 'not connected' : 'updating...'}',
            ),
            IconButton(
              icon: Icon(Icons.access_time),
              iconSize: 200.0,
              color: _chargingScheduled != null
                  ? Util.primaryColor(context)
                  : Theme.of(context).disabledColor,
              onPressed: () => _chargingSchedule(false),
            ),
            Text(
              _chargingScheduled != null
                  ? 'At ${DateFormat('HH:mm \'this\' EEEE').format(_chargingScheduled!)}'
                  : 'Not scheduled',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}

class ChargeControlPage extends StatefulWidget {
  ChargeControlPage(this.session);

  Session session;

  @override
  _ChargeControlPageState createState() => _ChargeControlPageState();
}
