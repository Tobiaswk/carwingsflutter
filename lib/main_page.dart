import 'package:carwingsflutter/battery_latest_card.dart';
import 'package:carwingsflutter/climate_control_page.dart';
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

  CarwingsSession session;
  PreferencesManager preferencesManager =  PreferencesManager();


  _MainPageState(this.session);

  _locateVehicleGoogleMaps() {
    Util.showLoadingDialog(context, ('Locating vehicle..'));
    session.getVehicle().requestLocation().then((location) {
      launch('https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}');
      Util.dismissLoadingDialog(context);
    });
  }

  _openVehicleInfoPage() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return new VehiclePage(session: session);
      },
    ));
  }

  _openClimateControlPage() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return new ClimateControlPage(session: session);
      },
    ));
  }

  void _onPreferencesPressed() {
    Navigator.pushNamed(context, '/preferences');
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
            onTap: _onPreferencesPressed,
          ),
        ],
      ),
    );
  }

  Column _buildVehicleListTiles(context) {
    List<ListTile> accountListTiles = new List<ListTile>();
      accountListTiles.add(new ListTile(
        leading: new ImageIcon(new AssetImage('images/sports-car.png')),
        title: new Text(session.getVehicle().nickname),
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
        title:  new Row(
          children: <Widget>[
            new ImageIcon(new AssetImage('images/car-leaf.png')),
            new Padding(padding: const EdgeInsets.all(3.0)),
            new Text('Dashboard')
          ],
        ),actions: [
        new IconButton(
            icon: new Icon(Icons.power, color: Colors.white),
            onPressed: null),
        new IconButton(
            icon: new ImageIcon(AssetImage('images/aircondition.png'), color: Colors.white),
            onPressed: _openClimateControlPage),
      ]
      ),
      body:  ListView(children: <Widget>[
        new BatteryLatestCard(session: session,),
        new StatisticsDailyCard(session: session,),
        new StatisticsMonthlyCard(session: session,),
      ],),
      drawer: _buildDrawer(context),
    );
  }
}
