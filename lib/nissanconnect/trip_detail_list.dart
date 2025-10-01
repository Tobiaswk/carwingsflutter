import 'dart:io';

import 'package:carwingsflutter/safe_area_scaffold.dart';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:dartnissanconnect/dartnissanconnect.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _TripDetailListState extends State<TripDetailList> {
  GeneralSettings _generalSettings = GeneralSettings();

  DateTime _currentDate = DateTime(DateTime.now().year, DateTime.now().month);

  late DateFormat dateFormatWeekDay;
  late DateFormat dateFormatDate;

  List<NissanConnectStats>? _statsTrips;
  int tripCounter = 1;

  @override
  void initState() {
    super.initState();
    _initDateFormatting();
    _update();
  }

  void _initDateFormatting() {
    dateFormatWeekDay = DateFormat('EEEE');

    Platform.localeName == 'en_US'
        ? dateFormatDate = DateFormat('MMM d')
        : dateFormatDate = DateFormat('d. MMM');
  }

  Future<Null> _update() async {
    setState(() {
      _statsTrips = null;
    });
    List<NissanConnectStats>? carwingsStatsTrips = await widget
        .session
        .nissanConnect
        .vehicle
        .requestMonthlyTripsStatistics(_currentDate);
    setState(() {
      _statsTrips = carwingsStatsTrips;
    });
    GeneralSettings generalSettings =
        await PreferencesManager.getGeneralSettings();
    setState(() {
      _generalSettings = generalSettings;
    });
  }

  void _pickDate() {
    tripCounter = 1;
    showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: _currentDate.subtract(Duration(days: 90)),
      lastDate: DateTime.now(),
      selectableDayPredicate: (date) => date.day == 1,
    ).then((date) {
      if (date != null) {
        _currentDate = DateTime(date.year, date.month, date.day);

        _update();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaScaffold(
      appBar: AppBar(
        title: Text("Trip Details"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.calendar_today), onPressed: _pickDate),
        ],
      ),
      body: _statsTrips != null
          ? ListView(
              padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
              children: _statsTrips!.where((trip) => trip.tripsNumber > 0).map((
                trip,
              ) {
                return Column(
                  children: <Widget>[
                    Padding(padding: const EdgeInsets.all(8.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          dateFormatWeekDay.format(trip.date),
                          style: TextStyle(fontSize: 17.0),
                        ),
                        Text(
                          dateFormatDate.format(trip.date),
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Chip(label: Text((tripCounter++).toString())),
                        Column(
                          children: <Widget>[
                            Icon(Icons.compare_arrows),
                            Text('${trip.tripsNumber} trips'),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Icon(Icons.timer_outlined),
                            Text('${trip.travelTime.inMinutes.toString()} min'),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              _generalSettings.useMiles
                                  ? trip.travelDistanceMiles
                                  : trip.travelDistanceKilometers,
                              style: TextStyle(fontSize: 18.0),
                            ),
                            Text(
                              _generalSettings.useMileagePerKWh
                                  ? _generalSettings.useMiles
                                        ? trip.milesPerKWh
                                        : trip.kilometersPerKWh
                                  : _generalSettings.useMiles
                                  ? trip.kWhPerMiles
                                  : trip.kWhPerKilometers,
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              '- ${trip.kWhUsed}',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            Text('+ ${trip.kWhGained}'),
                          ],
                        ),
                      ],
                    ),
                    Padding(padding: const EdgeInsets.all(8.0)),
                  ],
                );
              }).toList(),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class TripDetailList extends StatefulWidget {
  TripDetailList(this.session);

  final Session session;

  @override
  _TripDetailListState createState() => _TripDetailListState();
}
