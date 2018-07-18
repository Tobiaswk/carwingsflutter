import 'package:carwingsflutter/battery_latest_card.dart';
import 'package:carwingsflutter/charge_control_page.dart';
import 'package:carwingsflutter/climate_control_page.dart';
import 'package:carwingsflutter/login_page.dart';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/statistics_daily_card.dart';
import 'package:carwingsflutter/statistics_monthly_card.dart';
import 'package:carwingsflutter/util.dart';
import 'package:carwingsflutter/vehicle_page.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.session}) : super(key: key);

  final CarwingsSession session;

  @override
  _MainPageState createState() =>  _MainPageState(session);
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> scaffoldKey =  GlobalKey<ScaffoldState>();

  CarwingsSession _session;

  _MainPageState(this._session);

  _locateVehicleGoogleMaps() {
    Util.showLoadingDialog(context, ('Locating vehicle..'));
    _session.getVehicle().requestLocation().then((location) {
      launch('https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}');
      Util.dismissLoadingDialog(context);
    });
  }

  _openVehicleInfoPage() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return new VehiclePage(session: _session);
      },
    ));
  }

  _openClimateControlPage() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return new ClimateControlPage(session: _session);
      },
    ));
  }

  _openChargingPage() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return new ChargeControlPage(session: _session);
      },
    ));
  }

  _openPreferences() {
    Navigator.pushNamed(context, '/preferences');
  }

  _logOut() {
    Navigator.of(context).pushReplacement(new MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return new LoginPage();
      },
    ));
  }

  Widget _buildDrawer(BuildContext context) {
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          new DrawerHeader(
              child: new Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new ImageIcon(
                        new AssetImage('images/car-leaf.png'),
                        size: 100.0,
                        color: Theme.of(context).primaryColor,
                      ),
                      new Padding(padding: const EdgeInsets.all(3.0)),
                      Text('My Leaf', style: TextStyle(fontSize: 18.0,color: Theme.of(context).primaryColor),)
                    ],
                  ))),
          _buildVehicleListTiles(context),
          new ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Locate my vehicle'),
            onTap: () => _locateVehicleGoogleMaps(),
          ),
          const Divider(),
          new ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Preferences'),
            onTap: _openPreferences,
          ),
          new ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Log out'),
            onTap: _logOut,
          )
        ],
      ),
    );
  }

  Column _buildVehicleListTiles(context) {
    List<ListTile> accountListTiles = new List<ListTile>();
      accountListTiles.add(new ListTile(
        leading: new ImageIcon(new AssetImage('images/sports-car.png')),
        title: new Text(_session.getVehicle().nickname),
        onTap: () => _openVehicleInfoPage(),
        onLongPress: () => null,
      ));
    return new Column(children: accountListTiles);
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar:  AppBar(
        title:  new Text('Dashboard'),actions: [
        new IconButton(
            icon: new ImageIcon(AssetImage('images/aircondition.png'), color: Colors.white),
            onPressed: _openClimateControlPage),
        new IconButton(
            icon: new Icon(Icons.power, color: Colors.white),
            onPressed: _openChargingPage),
      ]
      ),
      body:  ListView(children: <Widget>[
        new BatteryLatestCard(session: _session,),
        new StatisticsDailyCard(session: _session,),
        new StatisticsMonthlyCard(session: _session,),
      ],),
      drawer: _buildDrawer(context),
    );
  }
}
