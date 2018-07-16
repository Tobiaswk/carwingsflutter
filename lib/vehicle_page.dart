import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';

class _VehiclePageState extends State<VehiclePage> {

  CarwingsSession session;


  _VehiclePageState(this.session);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Vehicle info")),
      body: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text('Name'),
            subtitle: Text(session.vehicle.nickname),
          ),
          ListTile(
            title: Text('Model'),
            subtitle: Text(session.vehicle.model),
          ),
          ListTile(
            title: Text('VIN'),
            subtitle: Text(session.vehicle.vin),
          ),
        ],
      ),
    );
  }
}

class VehiclePage extends StatefulWidget {
  VehiclePage({Key key, this.session}) : super(key: key);
  
  CarwingsSession session;

  @override
  _VehiclePageState createState() => new _VehiclePageState(session);
}
