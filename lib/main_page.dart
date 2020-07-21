import 'dart:io' show Platform;

import 'package:carwingsflutter/login_page.dart';
import 'package:carwingsflutter/preferences_page.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/util.dart';
import 'package:carwingsflutter/widget_delegator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payments/flutter_payments.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  MainPage(this.session);

  final Session session;

  @override
  _MainPageState createState() => _MainPageState(session);
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  static final String SKU_DONATE = 'donate2';

  Session _session;

  var _selectedVehicleValue; // Represents the current selected vehicle by nickname
  bool _donated = false;

  _MainPageState(this._session);

  @override
  void initState() {
    super.initState();
    _donationMadeCheck();
    _initSelectedVehicle();
  }

  _donationMadeCheck() async {
    if (Platform.isIOS) {
      // iOS is paid app; set as donated
      setState(() {
        _donated = true;
      });
      return;
    }
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
    await preferencesManager.setDonated(donated);
    setState(() {
      _donated = donated;
    });
  }

  _initSelectedVehicle() {
    setState(() {
      _selectedVehicleValue = _session.getVehicle().nickname;
    });
  }

  _locateVehicleGoogleMaps() async {
    Util.showLoadingDialog(context, 'Locating vehicle...');
    try {
      var location;
      switch (_session.getAPIType()) {
        case API_TYPE.CARWINGS:
          location = await _session.carwings.vehicle.requestLocation();
          break;
        case API_TYPE.NISSANCONNECTNA:
          location = await _session.nissanConnectNa.vehicle
              .requestLocation(DateTime.now());
          break;
        case API_TYPE.NISSANCONNECT:
          await _session.nissanConnect.vehicle.requestLocationRefresh();
          location = await _session.nissanConnect.vehicle.requestLocation();
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
        return WidgetDelegator.vehiclePage(_session);
      },
    ));
  }

  _openClimateControlPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return WidgetDelegator.climateControlPage(_session);
      },
    ));
  }

  _openChargingControlPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return WidgetDelegator.chargingControlPage(_session);
      },
    ));
  }

  _openTripDetailListPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return WidgetDelegator.tripDetailsPage(_session);
      },
    ));
  }

  _openPreferencesPage() {
    Navigator.pushNamed(context, '/preferences');
  }

  _signOut() {
    Navigator.of(context).pushReplacement(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return LoginPage(_session, false);
      },
    ));
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              child: Center(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ImageIcon(
                AssetImage('images/car-leaf.png'),
                size: 100.0,
                color: Util.primaryColor(context),
              ),
            ],
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
          _donated ? Row() : _buildDonateListTile(context)
        ],
      ),
    );
  }

  _handleVehicleChange(nickname) {
    setState(() {
      _selectedVehicleValue = nickname;
    });

    // Set selected vehicle on session by vehicle nickname
    _session.changeVehicle(nickname);

    // Push replacement page to force refresh with selected vehicle
    Navigator.of(context).pushReplacement(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return MainPage(_session);
      },
    ));
  }

  Column _buildVehicleListTiles(context) {
    List<ListTile> accountListTiles = List<ListTile>();
    var vehicles = _session.getVehicles();
    for (dynamic vehicle in vehicles) {
      accountListTiles.add(ListTile(
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
    return Column(children: accountListTiles);
  }

  Widget _buildDonateListTile(BuildContext context) {
    return ListTile(
      onTap: () async {
        try {
          await FlutterPayments.purchase(
            sku: SKU_DONATE,
            type: ProductType.InApp,
          );

          _snackBar('Thank you for the donation!');

          _donationMadeCheck();
        } on FlutterPaymentsException catch (error) {
          _snackBar('Too bad, donation failed!');
        }
      },
      leading: const Icon(Icons.monetization_on),
      title: Text(_session.getAPIType() != API_TYPE.NISSANCONNECT
          ? 'Donate + widgets'
          : 'Donate'),
    );
  }

  void _snackBar(message) {
    scaffoldKey.currentState.showSnackBar(
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
      body: FutureBuilder(
        future: preferencesManager.getGeneralSettings(),
        initialData: List(),
        builder: (context, generalSettingsData) {
          return generalSettingsData.hasData
              ? ListView(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        WidgetDelegator.batteryLatestCard(
                            _session, generalSettingsData.data),
                        WidgetDelegator.statisticsDailyCard(_session),
                        WidgetDelegator.statisticsMonthlyCard(_session)
                      ],
                    )
                  ],
                )
              : null;
        },
      ),
      drawer: _buildDrawer(context),
    );
  }
}
