import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/util.dart';
import 'package:dartnissanconnectna/dartnissanconnectna.dart';
import 'package:flutter/material.dart';

class _ChargeControlPageState extends State<ChargeControlPage> {
  bool _isCharging = false;
  bool _isConnected = false;
  bool _chargeControlReady = false;

  @override
  void initState() {
    super.initState();
    _updateBatteryStatus();
  }

  _updateBatteryStatus() async {
    NissanConnectBattery? battery =
        await widget.session.nissanConnectNa.vehicle.requestBatteryStatus();
    setState(() {
      _isCharging = battery.isCharging;
      _isConnected = battery.isConnected;
      _chargeControlReady = true;
    });
  }

  void _requestStartCharging() {
    Util.showLoadingDialog(context);
    widget.session.nissanConnectNa.vehicle.requestChargingStart().then((_) {
      _updateBatteryStatus();
      _snackbar('Charging request issued');
    }).catchError((error) {
      _isCharging = false;
      _snackbar('Charging request failed');
    }).whenComplete(() => Util.dismissLoadingDialog(context));
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
            Text(
              'Tap to engage',
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).disabledColor),
            ),
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
