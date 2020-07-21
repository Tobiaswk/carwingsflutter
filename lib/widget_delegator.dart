import 'package:carwingsflutter/carwings/battery_latest.dart' as carwings;
import 'package:carwingsflutter/carwings/battery_latest_card.dart' as carwings;
import 'package:carwingsflutter/carwings/charge_control_page.dart' as carwings;
import 'package:carwingsflutter/carwings/climate_control_page.dart' as carwings;
import 'package:carwingsflutter/carwings/debug_page.dart' as carwings;
import 'package:carwingsflutter/carwings/statistics_daily_card.dart'
    as carwings;
import 'package:carwingsflutter/carwings/statistics_monthly_card.dart'
    as carwings;
import 'package:carwingsflutter/carwings/trip_detail_list.dart' as carwings;
import 'package:carwingsflutter/carwings/vehicle_page.dart' as carwings;
import 'package:carwingsflutter/nissanconnect/battery_latest.dart'
    as nissanconnect;
import 'package:carwingsflutter/nissanconnect/battery_latest_card.dart'
    as nissanconnect;
import 'package:carwingsflutter/nissanconnect/charge_control_page.dart'
    as nissanconnect;
import 'package:carwingsflutter/nissanconnect/climate_control_page.dart'
    as nissanconnect;
import 'package:carwingsflutter/nissanconnect/debug_page.dart' as nissanconnect;
import 'package:carwingsflutter/nissanconnect/statistics_daily_card.dart'
    as nissanconnect;
import 'package:carwingsflutter/nissanconnect/statistics_monthly_card.dart'
    as nissanconnect;
import 'package:carwingsflutter/nissanconnect/trip_detail_list.dart'
    as nissanconnect;
import 'package:carwingsflutter/nissanconnect/vehicle_page.dart'
    as nissanconnect;
import 'package:carwingsflutter/nissanconnectna/battery_latest_card.dart'
    as nissanconnectna;
import 'package:carwingsflutter/nissanconnectna/charge_control_page.dart'
    as nissanconnectna;
import 'package:carwingsflutter/nissanconnectna/climate_control_page.dart'
    as nissanconnectna;
import 'package:carwingsflutter/nissanconnectna/debug_page.dart'
    as nissanconnectna;
import 'package:carwingsflutter/nissanconnectna/statistics_daily_card.dart'
    as nissanconnectna;
import 'package:carwingsflutter/nissanconnectna/statistics_monthly_card.dart'
    as nissanconnectna;
import 'package:carwingsflutter/nissanconnectna/trip_detail_list.dart'
    as nissanconnectna;
import 'package:carwingsflutter/nissanconnectna/vehicle_page.dart'
    as nissanconnectna;
import 'package:carwingsflutter/preferences_types.dart';
import 'package:carwingsflutter/session.dart';

class WidgetDelegator {
  static debugPage(Session session) {
    switch (session.getAPIType()) {
      case API_TYPE.CARWINGS:
        return carwings.DebugPage(session);
      case API_TYPE.NISSANCONNECTNA:
        return nissanconnectna.DebugPage(session);
      case API_TYPE.NISSANCONNECT:
        return nissanconnect.DebugPage(session);
        break;
    }
  }

  static vehiclePage(Session session) {
    switch (session.getAPIType()) {
      case API_TYPE.CARWINGS:
        return carwings.VehiclePage(session);
      case API_TYPE.NISSANCONNECTNA:
        return nissanconnectna.VehiclePage(session);
      case API_TYPE.NISSANCONNECT:
        return nissanconnect.VehiclePage(session);
        break;
    }
  }

  static statisticsDailyCard(Session session) {
    switch (session.getAPIType()) {
      case API_TYPE.CARWINGS:
        return carwings.StatisticsDailyCard(session);
      case API_TYPE.NISSANCONNECTNA:
        return nissanconnectna.StatisticsDailyCard(session);
      case API_TYPE.NISSANCONNECT:
        return nissanconnect.StatisticsDailyCard(session);
        break;
    }
  }

  static batteryLatestCard(Session session, GeneralSettings generalSettings) {
    switch (session.getAPIType()) {
      case API_TYPE.CARWINGS:
        return generalSettings.use12thBarNotation
            ? carwings.BatteryLatestCard(session)
            : carwings.BatteryLatest(session);
      case API_TYPE.NISSANCONNECTNA:
        return nissanconnectna.BatteryLatestCard(session);
      case API_TYPE.NISSANCONNECT:
        return nissanconnect.BatteryLatest(session);
        break;
    }
  }

  static statisticsMonthlyCard(Session session) {
    switch (session.getAPIType()) {
      case API_TYPE.CARWINGS:
        return carwings.StatisticsMonthlyCard(session);
      case API_TYPE.NISSANCONNECTNA:
        return nissanconnectna.StatisticsMonthlyCard(session);
      case API_TYPE.NISSANCONNECT:
        return nissanconnect.StatisticsMonthlyCard(session);
        break;
    }
  }

  static tripDetailsPage(Session session) {
    switch (session.getAPIType()) {
      case API_TYPE.CARWINGS:
        return carwings.TripDetailList(session);
      case API_TYPE.NISSANCONNECTNA:
        return nissanconnectna.TripDetailList(session);
      case API_TYPE.NISSANCONNECT:
        return nissanconnect.TripDetailList(session);
        break;
    }
  }

  static climateControlPage(Session session) {
    switch (session.getAPIType()) {
      case API_TYPE.CARWINGS:
        return carwings.ClimateControlPage(session);
      case API_TYPE.NISSANCONNECTNA:
        return nissanconnectna.ClimateControlPage(session);
      case API_TYPE.NISSANCONNECT:
        return nissanconnect.ClimateControlPage(session);
        break;
    }
  }

  static chargingControlPage(Session session) {
    switch (session.getAPIType()) {
      case API_TYPE.CARWINGS:
        return carwings.ChargeControlPage(session);
      case API_TYPE.NISSANCONNECTNA:
        return nissanconnectna.ChargeControlPage(session);
      case API_TYPE.NISSANCONNECT:
        return nissanconnect.ChargeControlPage(session);
        break;
    }
  }
}
