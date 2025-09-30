import 'package:carwingsflutter/safe_area_scaffold.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/util.dart';
import 'package:dartnissanconnect/dartnissanconnect.dart';
import 'package:flutter/material.dart';

class _ChargeControlPageState extends State<ChargeControlPage> {
  bool _isCharging = false;
  bool _isConnected = false;
  bool _chargeControlReady = false;
  bool _chargingOn = false;

  // int _chargingThreshold = 80;
  // bool _hasKeepAlive = false;

  @override
  void initState() {
    super.initState();

    _updateBatteryStatus();

    // PreferencesManager.getGeneralSettings().then((settings) {
    //   _hasKeepAlive = settings.keepAlive;
    //   _chargingThreshold = settings.chargingPercentThreshold;
    // });
  }

  _updateBatteryStatus() async {
    NissanConnectBattery? battery = await widget.session.nissanConnect.vehicle
        .requestBatteryStatus();
    setState(() {
      _isCharging = battery.isCharging;
      _chargingOn = battery.isCharging;
      _isConnected = battery.isConnected;
      _chargeControlReady = true;
    });
  }

  void _requestStartCharging() {
    Util.showLoadingDialog(context);
    _chargingOn = !_chargingOn;
    if (_chargingOn) {
      widget.session.nissanConnect.vehicle
          .requestChargingStart()
          .then((_) {
            _updateBatteryStatus();
            _snackbar('Charging start request issued');
          })
          .catchError((error) {
            _chargingOn = !_chargingOn;
            _snackbar('Charging start request failed');
          })
          .whenComplete(() => Util.dismissLoadingDialog(context));
    } else {
      widget.session.nissanConnect.vehicle
          .requestChargingStop()
          .then((_) {
            _updateBatteryStatus();
            _snackbar('Charging stop request issued');
          })
          .catchError((error) {
            _chargingOn = !_chargingOn;
            _snackbar('Charging stop request failed');
          })
          .whenComplete(() => Util.dismissLoadingDialog(context));
    }
  }

  _snackbar(message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: Duration(seconds: 5), content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaScaffold(
      appBar: AppBar(title: Text("Charging")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Spacer(),
            Text(
              'Tap to engage',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).disabledColor,
              ),
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
              'Charging is ${_chargeControlReady
                  ? _isCharging
                        ? 'on'
                        : 'off'
                  : 'updating...'}',
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              'Cable is ${_chargeControlReady
                  ? _isConnected
                        ? 'connected'
                        : 'not connected'
                  : 'updating...'}',
            ),
            Spacer(),
            // if (!_hasKeepAlive)
            //   Text(
            //     'You need to activate the background service in preferences to use charging threshold',
            //     textAlign: TextAlign.center,
            //   ),
            // AbsorbPointer(
            //   absorbing: !_hasKeepAlive,
            //   child: Opacity(
            //     opacity: _hasKeepAlive ? 1 : .5,
            //     child: Column(
            //       children: [
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Text(
            //               'Charging threshold',
            //               style: TextStyle(fontSize: 18.0),
            //             ),
            //             Padding(padding: EdgeInsetsGeometry.all(8)),
            //             Text(
            //               '${_chargingThreshold}%',
            //               style: TextStyle(fontSize: 25.0),
            //             ),
            //           ],
            //         ),
            //         Slider(
            //           value: _chargingThreshold.toDouble(),
            //           padding: EdgeInsets.symmetric(horizontal: 16),
            //           divisions: 10,
            //           min: 0,
            //           max: 100,
            //           onChanged: (value) {
            //             setState(() {
            //               _chargingThreshold = value.toInt();

            //               PreferencesManager.setGeneralSettings(
            //                 (settings) =>
            //                     settings
            //                       ..chargingPercentThreshold = value.toInt(),
            //               );
            //             });
            //           },
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class ChargeControlPage extends StatefulWidget {
  ChargeControlPage(this.session);

  final Session session;

  @override
  _ChargeControlPageState createState() => _ChargeControlPageState();
}
