import 'dart:io' show Platform;
import 'dart:math';

import 'package:carwingsflutter/login_page.dart';
import 'package:carwingsflutter/preferences_page.dart';
import 'package:carwingsflutter/preferences_types.dart';
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
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  static final String SKU_DONATE = 'donate2';
  static final String SKU_DONATE_10 = 'donate10';
  static final String SKU_DONATE_30 = 'donate30';
  static final String SKU_DONATE_50 = 'donate50';

  var _selectedVehicleValue; // Represents the current selected vehicle by nickname
  bool _donated = false;

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
        if (purchase.sku == SKU_DONATE ||
            purchase.sku == SKU_DONATE_10 ||
            purchase.sku == SKU_DONATE_30 ||
            purchase.sku == SKU_DONATE_50) {
          donated = true;
        }
      }
    }

    await preferencesManager.setDonated(donated);

    setState(() {
      _donated = donated;
    });

    _donateDialog(context, false);
  }

  _initSelectedVehicle() {
    setState(() {
      _selectedVehicleValue = widget.session.getVehicle().nickname;
    });
  }

  _locateVehicleGoogleMaps() async {
    Util.showLoadingDialog(context, 'Locating vehicle...');
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
        return WidgetDelegator.vehiclePage(widget.session);
      },
    ));
  }

  _openClimateControlPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return WidgetDelegator.climateControlPage(widget.session);
      },
    ));
  }

  _openChargingControlPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return WidgetDelegator.chargingControlPage(widget.session);
      },
    ));
  }

  _openTripDetailListPage() {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return WidgetDelegator.tripDetailsPage(widget.session);
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
    widget.session.changeVehicle(nickname);

    // Push replacement page to force refresh with selected vehicle
    Navigator.of(context).pushReplacement(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        return MainPage(widget.session);
      },
    ));
  }

  Column _buildVehicleListTiles(context) {
    List<ListTile> accountListTiles = List<ListTile>();
    var vehicles = widget.session.getVehicles();
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

  void _donateDialog(BuildContext context, bool force) async {
    if ((!_donated && Random.secure().nextInt(10) > 6) || force) {
      showDialog<bool>(
          context: context,
          builder: (BuildContext context) => SimpleDialog(
                title: const Text("Consider supporting My Leaf!"),
                children: [
                  SimpleDialogOption(
                    child: Text(
                        'This is Tobias! The developer behind My Leaf! As you may know My Leaf is a free and fully open source project! Naturally it takes time to maintain, improve and support! Even a small donation goes a long way!'),
                  ),
                  SimpleDialogOption(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () => _donate(SKU_DONATE_10),
                          child: const Text('☕️ A coffee')),
                      TextButton(
                          onPressed: () => _donate(SKU_DONATE_30),
                          child: const Text('🍜 Some ramen'))
                    ],
                  )),
                  SimpleDialogOption(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () => _donate(SKU_DONATE_50),
                          child: const Text('🍱 A dinner')),
                      TextButton(
                          onPressed: () => _donate(SKU_DONATE),
                          child: const Text('🥳 You\'re awesome'))
                    ],
                  )),
                  SimpleDialogOption(
                    child: Text('Thank you either way!'),
                  )
                ],
              ));
    }
  }

  _donate(String sku) async {
    try {
      await FlutterPayments.purchase(
        sku: sku,
        type: ProductType.InApp,
      );

      Navigator.pop(context);

      _snackBar('Thank you for the donation!');

      _donationMadeCheck();
    } on FlutterPaymentsException catch (error) {
      _snackBar('Too bad, donation failed!');
    }
  }

  Widget _buildDonateListTile(BuildContext context) {
    return ListTile(
      onTap: () => _donateDialog(context, true),
      leading: const Icon(Icons.monetization_on),
      title: Text('Donate'),
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
      body: FutureBuilder<GeneralSettings>(
        future: preferencesManager.getGeneralSettings(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        WidgetDelegator.batteryLatestCard(
                            widget.session, snapshot.data),
                        WidgetDelegator.statisticsDailyCard(widget.session),
                        WidgetDelegator.statisticsMonthlyCard(widget.session)
                      ],
                    )
                  ],
                )
              : Container();
        },
      ),
      drawer: _buildDrawer(context),
    );
  }
}
