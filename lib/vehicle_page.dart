import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';

class _VehiclePageState extends State<VehiclePage> {

  CarwingsVehicle _vehicle;


  _VehiclePageState(this._vehicle);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Vehicle info")),
      body: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text('Name'),
            subtitle: Text(_vehicle.nickname),
          ),
          ListTile(
            title: Text('Model'),
            subtitle: Text(_vehicle.model),
          ),
          ListTile(
            title: Text('VIN'),
            subtitle: Text(_vehicle.vin),
          ),
        ],
      ),
    );
  }
}

class VehiclePage extends StatefulWidget {
  VehiclePage({Key key, this.vehicle}) : super(key: key);
  
  CarwingsVehicle vehicle;

  @override
  _VehiclePageState createState() => new _VehiclePageState(vehicle);
}
