import 'package:carwingsflutter/battery_latest_card.dart';
import 'package:carwingsflutter/charge_control_page.dart';
import 'package:carwingsflutter/climate_control_page.dart';
import 'package:carwingsflutter/login_page.dart';
import 'package:carwingsflutter/statistics_daily_card.dart';
import 'package:carwingsflutter/statistics_monthly_card.dart';
import 'package:carwingsflutter/util.dart';
import 'package:carwingsflutter/vehicle_page.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payments/flutter_payments.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  MainPage(this.session);

  final CarwingsSession session;

  @override
  _MainPageState createState() => _MainPageState(session);
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  static final String SKU_DONATE = 'donate';

  CarwingsSession _session;

  bool _donated = false;

  _MainPageState(this._session) {
    _donationMadeCheck();
  }

  _donationMadeCheck() async {
    List<Purchase> purchases =
        await FlutterPayments.getPurchaseHistory(ProductType.InApp);
    bool donated = false;
    if (purchases != null) {
      for (Purchase purchase in purchases) {
        if (purchase.sku == SKU_DONATE) {
          donated = true;
        }
      }
    }
    setState(() {
      _donated = donated;
    });
  }

  _locateVehicleGoogleMaps() {
    Util.showLoadingDialog(context, ('Locating vehicle...'));
    _session.getVehicle().requestLocation().then((location) {
      launch('https://www.google.com/maps/search/?api=1&query=${location
          .latitude},${location.longitude}');
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
        return new ClimateControlPage(_session);
      },
    ));
  }

  _openChargingPage() {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return new ChargeControlPage(_session);
      },
    ));
  }

  _openPreferences() {
    Navigator.pushNamed(context, '/preferences');
  }

  _logOut() {
    Navigator.of(context).pushReplacement(new MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return new LoginPage(_session, false);
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
            title: const Text('Sign out'),
            onTap: _logOut,
          ),
          _donated ? Row() : _buildDonateListTile(context)
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

  Widget _buildDonateListTile(BuildContext context) {
    return new ListTile(
      onTap: () async {
        try {
          final List<Purchase> list = await FlutterPayments.purchase(
            sku: SKU_DONATE,
            type: ProductType.InApp,
          );

          scaffoldKey.currentState.showSnackBar(new SnackBar(
              duration: new Duration(seconds: 5),
              content: new Text('Thank you for the donation!')));

          _donationMadeCheck();
        } on FlutterPaymentsException catch (error) {
          scaffoldKey.currentState.showSnackBar(new SnackBar(
              duration: new Duration(seconds: 5),
              content: new Text('Too bad, donation failed!')));
        }
      },
      leading: const Icon(Icons.monetization_on),
      title: Text('Donate'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(title: new Text('Dashboard'), actions: [
        new IconButton(
            icon: new ImageIcon(AssetImage('images/aircondition.png'),
                color: Colors.white),
            onPressed: _openClimateControlPage),
        new IconButton(
            icon: new Icon(Icons.power, color: Colors.white),
            onPressed: _openChargingPage),
      ]),
      body: ListView(
        children: <Widget>[
          new BatteryLatestCard(
            _session,
          ),
          new StatisticsDailyCard(
            _session,
          ),
          new StatisticsMonthlyCard(
            _session,
          ),
        ],
      ),
      drawer: _buildDrawer(context),
    );
  }
}
