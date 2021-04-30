import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/util.dart';
import 'package:dartnissanconnect/dartnissanconnect.dart';
import 'package:flutter/material.dart';

class _ChargeControlPageState extends State<ChargeControlPage> {
  bool _isCharging = false;
  bool _isConnected = false;
  bool _chargeControlReady = false;
  bool _chargingOn = false;

  @override
  void initState() {
    super.initState();
    _updateBatteryStatus();
  }

  _updateBatteryStatus() async {
    NissanConnectBattery? battery =
        await widget.session.nissanConnect.vehicle.requestBatteryStatus();
    setState(() {
      _isCharging = battery.isCharging;
      _isConnected = battery.isConnected;
      _chargeControlReady = true;
    });
  }

  void _requestStartCharging() {
    Util.showLoadingDialog(context);
    _chargingOn = !_chargingOn;
    if (_chargingOn) {
      widget.session.nissanConnect.vehicle.requestChargingStart().then((_) {
        _updateBatteryStatus();
        _snackbar('Charging start request issued');
      }).catchError((error) {
        _chargingOn = !_chargingOn;
        _snackbar('Charging start request failed');
      }).whenComplete(() => Util.dismissLoadingDialog(context));
    } else {
      widget.session.nissanConnect.vehicle.requestChargingStop().then((_) {
        _updateBatteryStatus();
        _snackbar('Charging stop request issued');
      }).catchError((error) {
        _chargingOn = !_chargingOn;
        _snackbar('Charging stop request failed');
      }).whenComplete(() => Util.dismissLoadingDialog(context));
    }
  }

  _snackbar(message) {
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
              onPressed: () => _requestStartCharging(),
            ),
            Text(
              'Charging is ${_chargeControlReady ? _isCharging ? 'on' : 'off' : 'updating...'}',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'Cable is ${_chargeControlReady ? _isConnected ? 'connected' : 'not connected' : 'updating...'}',
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
