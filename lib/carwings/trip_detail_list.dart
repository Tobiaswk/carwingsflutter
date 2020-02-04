import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class _TripDetailListState extends State<TripDetailList> {
  PreferencesManager preferencesManager = PreferencesManager();

  GeneralSettings _generalSettings = GeneralSettings();

  DateTime _currentDate = DateTime(DateTime.now().year, DateTime.now().month);

  DateFormat dateFormatWeekDay;
  DateFormat dateFormatDate;

  Session _session;
  CarwingsStatsTrips _statsTrips;

  _TripDetailListState(this._session);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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
    CarwingsStatsTrips carwingsStatsTrips = await _session.carwings.vehicle
        .requestStatisticsMonthlyTrips(_currentDate);
    setState(() {
      _statsTrips = carwingsStatsTrips;
    });
    GeneralSettings generalSettings =
        await preferencesManager.getGeneralSettings();
    setState(() {
      _generalSettings = generalSettings;
    });
  }

  void _pickDate() {
    showDatePicker(
        context: context,
        initialDate: _currentDate,
        firstDate: _currentDate.subtract(Duration(days: 90)),
        lastDate: DateTime.now(),
        selectableDayPredicate: (date) => date.day == 1).then((date) {
      if (date != null) {
        _currentDate = DateTime(date.year, date.month, date.day);

        _update();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trip Details"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.white),
              onPressed: _pickDate),
        ],
      ),
      body: _statsTrips != null
          ? ListView(
              padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
              children: _statsTrips.trips.map((carwingsTrip) {
                return Column(
                  children: <Widget>[
                    Padding(padding: const EdgeInsets.all(8.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          dateFormatWeekDay.format(carwingsTrip.date),
                          style: TextStyle(fontSize: 17.0),
                        ),
                        Text(
                          dateFormatDate.format(carwingsTrip.date),
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey,
                    ),
                    Column(
                        children:
                            carwingsTrip.tripsDetails.map((carwingsTripDetail) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          carwingsTripDetail.number % 2 == 0
                              ? Icon(Icons.arrow_back)
                              : Icon(Icons.arrow_forward),
                          Chip(
                              label:
                                  Text(carwingsTripDetail.number.toString())),
                          Column(
                            children: <Widget>[
                              Text(
                                carwingsTripDetail.travelDistanceMileage,
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Text(_generalSettings.useMileagePerKWh
                                  ? carwingsTripDetail.mileagePerKWh
                                  : carwingsTripDetail.kWhPerMileage)
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(carwingsTripDetail.consumptionKWh,
                                  style: TextStyle(fontSize: 18.0)),
                              _generalSettings.showCO2
                                  ? Text(carwingsTripDetail.CO2Reduction)
                                  : Column(),
                            ],
                          )
                        ],
                      );
                    }).toList()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Totals', style: TextStyle(fontSize: 18.0)),
                        Padding(padding: const EdgeInsets.all(8.0)),
                        Column(
                          children: <Widget>[
                            Text(
                              carwingsTrip.travelDistanceMileage,
                              style: TextStyle(fontSize: 18.0),
                            ),
                            Text(_generalSettings.useMileagePerKWh
                                ? carwingsTrip.mileagePerKWh
                                : carwingsTrip.kWhPerMileage)
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(carwingsTrip.consumptionKWh,
                                style: TextStyle(fontSize: 18.0)),
                            _generalSettings.showCO2
                                ? Text(carwingsTrip.CO2Reduction)
                                : Column(),
                          ],
                        )
                      ],
                    )
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
  _TripDetailListState createState() => _TripDetailListState(session);
}
