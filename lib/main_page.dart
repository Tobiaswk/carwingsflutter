import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:carwingsflutter/preferences_page.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:carwingsflutter/util.dart';
import 'package:carwingsflutter/widget_api_chooser.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  MainPage(this.session);

  final Session session;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  static const String SKU_DONATE = 'donate2';
  static const String SKU_DONATE_10 = 'donate10';
  static const String SKU_DONATE_30 = 'donate30';
  static const String SKU_DONATE_50 = 'donate50';
  static const String SKU_PATRON = 'patron';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _inAppPurchaseSubscription;
  List<ProductDetails>? _inAppProductsAvailable;

  bool _donated = false;

  var _selectedVehicleValue; // Represents the current selected vehicle by nickname

  @override
  void initState() {
    _initSelectedVehicle();

    _initInAppPurchases();

    super.initState();
  }

  Future<void> _initInAppPurchases() async {
    Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;

    _inAppPurchaseSubscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _inAppPurchaseSubscription.cancel();
    });

    if (await _inAppPurchase.isAvailable()) {
      await _inAppPurchase.restorePurchases();

      final ProductDetailsResponse availableProductsResponse =
          await _inAppPurchase.queryProductDetails(<String>{
        SKU_PATRON,
        SKU_DONATE_10,
        SKU_DONATE_30,
        SKU_DONATE_50,
        SKU_DONATE
      });

      _inAppProductsAvailable = availableProductsResponse.productDetails;

      _donateDialog(context, false);
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      _verifyPurchase(purchaseDetails);

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    });
  }

  _verifyPurchase(PurchaseDetails purchaseDetails) async {
    if (Platform.isIOS) {
      // iOS is paid app; set as donated
      setState(() {
        _donated = true;
      });
      return;
    }

    switch (purchaseDetails.productID) {
      case SKU_PATRON:
      case SKU_DONATE:
      case SKU_DONATE_10:
      case SKU_DONATE_30:
      case SKU_DONATE_50:
        switch (purchaseDetails.status) {
          case PurchaseStatus.error:
            _snackBar('Too bad, donation failed!');
            break;
          case PurchaseStatus.purchased:
            Navigator.pop(context); // Donate dialog
            Navigator.pop(context); // Drawer

            _snackBar('Thank you for being a donater! 😊');

            setState(() {
              _donated = true;
            });

            await preferencesManager.setDonated(true);

            break;
          case PurchaseStatus.restored:
            setState(() {
              _donated = true;
            });

            await preferencesManager.setDonated(true);
            break;
          default:
        }
    }
  }

  _donate(ProductDetails? productDetails) async {
    if (productDetails != null) {
      _inAppPurchase.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: productDetails));
    }
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
      launchUrl(Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}'));
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
          _buildDonateListTile(context)
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
      builder: (BuildContext context) => MainPage(widget.session),
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

  void _donateDialog(BuildContext context, bool force) async {
    if (Platform.isIOS) return;
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
                          onPressed: () => _donate(
                              _inAppProductsAvailable?.firstWhere(
                                  (product) => product.id == SKU_DONATE_10)),
                          child: const Text('☕️ A coffee')),
                      TextButton(
                          onPressed: () => _donate(
                              _inAppProductsAvailable?.firstWhere(
                                  (product) => product.id == SKU_DONATE_30)),
                          child: const Text('🍜 Some ramen'))
                    ],
                  )),
                  SimpleDialogOption(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () => _donate(
                              _inAppProductsAvailable?.firstWhere(
                                  (product) => product.id == SKU_DONATE_50)),
                          child: const Text('🍱 A dinner')),
                      TextButton(
                          onPressed: () => _donate(
                              _inAppProductsAvailable?.firstWhere(
                                  (product) => product.id == SKU_DONATE)),
                          child: const Text('🥳 You\'re awesome')),
                    ],
                  )),
                  SimpleDialogOption(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () => _donate(
                              _inAppProductsAvailable?.firstWhere(
                                  (product) => product.id == SKU_PATRON)),
                          child: const Text('❤️ Be a My Leaf monthly patron!'))
                    ],
                  )),
                  SimpleDialogOption(
                    child: Text(
                        'Thank you either way! Also if you have the time I\'d appreciate a review! ☺️'),
                  )
                ],
              ));
    }
  }

  Widget _buildDonateListTile(BuildContext context) {
    if (Platform.isIOS) return Container();
    return ListTile(
      onTap: () => _donateDialog(context, true),
      leading: const Icon(Icons.monetization_on),
      title: Text('Donate'),
    );
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
            ),
            onPressed: _openTripDetailListPage),
        IconButton(
            icon: ImageIcon(
              AssetImage('images/aircondition.png'),
            ),
            onPressed: _openClimateControlPage),
        IconButton(
            icon: Icon(Icons.power), onPressed: _openChargingControlPage),
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
