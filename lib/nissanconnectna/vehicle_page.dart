import 'package:carwingsflutter/session.dart';
import 'package:flutter/material.dart';

class _VehiclePageState extends State<VehiclePage> {
  Session _session;

  _VehiclePageState(this._session);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vehicle info")),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text('Name'),
            subtitle: Text(_session.nissanConnectNa.vehicle.nickname),
          ),
          ListTile(
            title: Text('Model year'),
            subtitle: Text(_session.nissanConnectNa.vehicle.modelYear),
          ),
          ListTile(
            title: Text('VIN'),
            subtitle: Text(_session.nissanConnectNa.vehicle.vin),
          ),
        ],
      ),
    );
  }
}

class VehiclePage extends StatefulWidget {
  VehiclePage(this.session);

  Session session;

  @override
  _VehiclePageState createState() => _VehiclePageState(session);
}
