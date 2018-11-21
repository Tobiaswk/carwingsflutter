import 'dart:async';
import 'dart:io';
import 'package:carwingsflutter/preferences_manager.dart';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _TripDetailListState extends State<TripDetailList> {
  PreferencesManager preferencesManager = new PreferencesManager();

  GeneralSettings _generalSettings = new GeneralSettings();

  DateTime _currentDate = DateTime(DateTime.now().year, DateTime.now().month);

  DateFormat dateFormatWeekDay;
  DateFormat dateFormatDate;

  CarwingsSession _session;
  CarwingsStatsTrips _statsTrips;

  _TripDetailListState(this._session);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _initDateFormatting();

    _update();
  }

  void _initDateFormatting() {
    dateFormatWeekDay = new DateFormat('EEEE');

    Platform.localeName == 'en_US'
        ? dateFormatDate = new DateFormat('MMM d')
        : dateFormatDate = new DateFormat('dd/MM');
  }

  Future<Null> _update() async {
    setState(() {
      _statsTrips = null;
    });
    CarwingsStatsTrips carwingsStatsTrips =
        await _session.vehicle.requestStatisticsMonthlyTrips(_currentDate);
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
        firstDate: _currentDate.subtract(new Duration(days: 90)),
        lastDate: new DateTime.now(),
        selectableDayPredicate: (date) => date.day == 1).then((date) {
      if (date != null) {
        _currentDate = new DateTime(date.year, date.month, date.day);

        _update();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDate;
    return Scaffold(
      appBar: AppBar(
        title: Text("Trip details"),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.calendar_today, color: Colors.white),
              onPressed: _pickDate),
        ],
      ),
      body: _statsTrips != null
          ? ListView(
              padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
              children: _statsTrips.trips.map((carwingsTripDetail) {
                Column column;
                if (currentDate == null ||
                    currentDate.compareTo(carwingsTripDetail.date) != 0) {
                  column = Column(
                    children: <Widget>[
                      new Padding(padding: const EdgeInsets.all(8.0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            dateFormatWeekDay.format(carwingsTripDetail.date),
                            style: TextStyle(fontSize: 17.0),
                          ),
                          Text(
                            dateFormatDate.format(carwingsTripDetail.date),
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.grey,
                      ),
                      Row(
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
                              Text(carwingsTripDetail.CO2Reduction),
                            ],
                          )
                        ],
                      )
                    ],
                  );
                } else {
                  column = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
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
                              Text(carwingsTripDetail.travelDistanceMileage,
                                  style: TextStyle(fontSize: 18.0)),
                              Text(_generalSettings.useMileagePerKWh
                                  ? carwingsTripDetail.mileagePerKWh
                                  : carwingsTripDetail.kWhPerMileage)
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(carwingsTripDetail.consumptionKWh,
                                  style: TextStyle(fontSize: 18.0)),
                              Text(carwingsTripDetail.CO2Reduction),
                            ],
                          )
                        ],
                      )
                    ],
                  );
                }
                currentDate = carwingsTripDetail.date;
                return column;
              }).toList(),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class TripDetailList extends StatefulWidget {
  TripDetailList(this.session);

  final CarwingsSession session;

  @override
  _TripDetailListState createState() => new _TripDetailListState(session);
}
