import 'package:carwingsflutter/session.dart';
import 'package:flutter/material.dart';

class _VehiclePageState extends State<VehiclePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vehicle info")),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text('Name'),
            subtitle: Text(widget.session.nissanConnect.vehicle.nickname),
          ),
          ListTile(
            title: Text('Model'),
            subtitle: Text(widget.session.nissanConnect.vehicle.modelName),
          ),
          ListTile(
            title: Text('VIN'),
            subtitle: Text(widget.session.nissanConnect.vehicle.vin),
          ),
        ],
      ),
    );
  }
}

class VehiclePage extends StatefulWidget {
  VehiclePage(this.session);

  final Session session;

  @override
  _VehiclePageState createState() => _VehiclePageState();
}
