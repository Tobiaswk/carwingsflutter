import 'package:carwingsflutter/util.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';

class _ClimateControlPageState extends State<ClimateControlPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  CarwingsSession session;

  bool _climateControlOn = false;

  _ClimateControlPageState(this.session) {
    session.vehicle.requestHVACStatus().then((hvac) {
      setState(() {
        _climateControlOn = hvac.isRunning;
      });
    });
  }

  _climateControlToggle() {
    setState(() {
      Util.showLoadingDialog(context);
      _climateControlOn = !_climateControlOn;
      if (_climateControlOn) {
        session.vehicle.requestClimateControlOn().then((_) {
          Util.dismissLoadingDialog(context);
          _snackbar('Climate Control was turned on');
        }).catchError((error) {
          _climateControlOn = !_climateControlOn;
          _snackbar('Error');
        });
        ;
      } else {
        session.vehicle.requestClimateControlOff().then((_) {
          Util.dismissLoadingDialog(context);
          _snackbar('Climate Control was turned off');
        }).catchError((error) {
          _climateControlOn = !_climateControlOn;
          _snackbar('Error');
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
      appBar: new AppBar(title: new Text("Aircondition")),
      body: new InkWell(
        onTap: _climateControlToggle,
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
              Text('Tap to toggle'),
              Text('Climate Control ${_climateControlOn ? 'on' : 'off'}'),
              Text('Hold to schedule')
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
