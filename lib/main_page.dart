import 'package:carwingsflutter/preferences_page.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/util.dart';
import 'package:carwingsflutter/widget_api_chooser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  MainPage(this.session);

  final Session session;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var _selectedVehicleValue; // Represents the current selected vehicle by nickname

  @override
  void initState() {
    super.initState();

    _initSelectedVehicle();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  _initSelectedVehicle() {
    setState(() {
      _selectedVehicleValue = widget.session.getVehicle().nickname;
    });
  }

  _locateVehicleGoogleMaps() async {
    Util.showLoadingDialog(context, 'Locating vehicle');
    try {
      var location;
      switch (widget.session.getAPIType()) {
        case API_TYPE.CARWINGS:
          location = await widget.session.carwings.vehicle.requestLocation();
          break;
        case API_TYPE.NISSANCONNECTNA:
          location = await widget.session.nissanConnectNa.vehicle
              .requestLocation(DateTime.now());
          break;
        case API_TYPE.NISSANCONNECT:
          await widget.session.nissanConnect.vehicle.requestLocationRefresh();
          location =
              await widget.session.nissanConnect.vehicle.requestLocation();
          break;
      }
      launch(
          'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}');
    } catch (error) {
      _snackBar('Could not locate your vehicle!');
    } finally {
      Util.dismissLoadingDialog(context);
    }
  }

  _openVehicleInfoPage(vehicle) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return WidgetAPIChooser.vehiclePage(widget.session);
      },
    ));
  }

  _openClimateControlPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return WidgetAPIChooser.climateControlPage(widget.session);
      },
    ));
  }

  _openChargingControlPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return WidgetAPIChooser.chargingControlPage(widget.session);
      },
    ));
  }

  _openTripDetailListPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return WidgetAPIChooser.tripDetailsPage(widget.session);
      },
    ));
  }

  _openPreferencesPage() {
    Navigator.pushNamed(context, '/preferences');
  }

  _signOut() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              child: Center(
                  child: ImageIcon(
            AssetImage('images/car-leaf.png'),
            size: 100.0,
            color: Util.primaryColor(context),
          ))),
          _buildVehicleListTiles(context),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Locate my vehicle'),
            onTap: _locateVehicleGoogleMaps,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Preferences'),
            onTap: _openPreferencesPage,
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sign out'),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  _handleVehicleChange(nickname) {
    setState(() {
      _selectedVehicleValue = nickname;
    });

    // Set selected vehicle on session by vehicle nickname
    widget.session.changeVehicle(nickname);

    // Push replacement page to force refresh with selected vehicle
    Navigator.of(context).pushReplacement(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return MainPage(widget.session);
      },
    ));
  }

  Column _buildVehicleListTiles(context) {
    List<ListTile> vehicleListTiles = <ListTile>[];
    var vehicles = widget.session.getVehicles();
    for (dynamic vehicle in vehicles) {
      vehicleListTiles.add(ListTile(
        leading: ImageIcon(AssetImage('images/sports-car.png')),
        trailing: Radio(
          value: vehicle.nickname,
          groupValue: _selectedVehicleValue,
          onChanged: _handleVehicleChange,
        ),
        title: Text(vehicle.nickname),
        onTap: () => _openVehicleInfoPage(vehicle),
        onLongPress: () => null,
      ));
    }
    return Column(children: vehicleListTiles);
  }

  void _snackBar(message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(duration: Duration(seconds: 5), content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(title: Text('Dashboard'), actions: [
        IconButton(
            icon: Icon(
              Icons.format_list_numbered,
              color: Colors.white,
            ),
            onPressed: _openTripDetailListPage),
        IconButton(
            icon: ImageIcon(AssetImage('images/aircondition.png'),
                color: Colors.white),
            onPressed: _openClimateControlPage),
        IconButton(
            icon: Icon(Icons.power, color: Colors.white),
            onPressed: _openChargingControlPage),
      ]),
      body: FutureBuilder<GeneralSettings>(
        future: preferencesManager.getGeneralSettings(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView(
                  children: <Widget>[
                    WidgetAPIChooser.batteryLatestCard(
                        widget.session, snapshot.data!),
                    WidgetAPIChooser.statisticsDailyCard(widget.session),
                    WidgetAPIChooser.statisticsMonthlyCard(widget.session)
                  ],
                )
              : Container();
        },
      ),
      drawer: _buildDrawer(context),
    );
  }
}
