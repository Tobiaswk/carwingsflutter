import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/util.dart';
import 'package:dartnissanconnectna/dartnissanconnectna.dart';
import 'package:flutter/material.dart';

class _ChargeControlPageState extends State<ChargeControlPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Session _session;

  bool _isCharging = false;
  bool _isConnected = false;
  bool _chargeControlReady = false;

  DateTime _chargingScheduled;

  _ChargeControlPageState(this._session);

  @override
  void initState() {
    super.initState();
    _updateBatteryStatus();
  }


  _updateBatteryStatus() async {
    NissanConnectBattery battery =
    await _session.nissanConnectNa.vehicle.requestBatteryStatus();
    setState(() {
      _isCharging = battery.isCharging;
      _isConnected = battery.isConnected;
      _chargeControlReady = true;
    });
  }

  void _requestStartCharging() {
    Util.showLoadingDialog(context);
    _session.nissanConnectNa.vehicle.requestChargingStart().then((_) {
      _updateBatteryStatus();
      _snackbar('Charging request issued');
    }).catchError((error) {
      _isCharging = false;
      _snackbar('Charging request failed');
    }).whenComplete(() => Util.dismissLoadingDialog(context));
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
      body: Center(
        child: new Column(
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
  _ChargeControlPageState createState() => new _ChargeControlPageState(session);
}
