import 'package:carwingsflutter/carwings/debug_page.dart' as carwings;
import 'package:carwingsflutter/nissanconnectna/debug_page.dart'
    as nissanconnect;
import 'package:carwingsflutter/carwings/vehicle_page.dart' as carwings;
import 'package:carwingsflutter/nissanconnectna/vehicle_page.dart'
    as nissanconnect;
import 'package:carwingsflutter/carwings/battery_latest_card.dart'
as carwings;
import 'package:carwingsflutter/nissanconnectna/battery_latest_card.dart'
as nissanconnect;
import 'package:carwingsflutter/carwings/statistics_daily_card.dart'
    as carwings;
import 'package:carwingsflutter/nissanconnectna/statistics_daily_card.dart'
    as nissanconnect;
import 'package:carwingsflutter/carwings/statistics_monthly_card.dart'
    as carwings;
import 'package:carwingsflutter/nissanconnectna/statistics_monthly_card.dart'
    as nissanconnect;
import 'package:carwingsflutter/carwings/trip_detail_list.dart'
as carwings;
import 'package:carwingsflutter/nissanconnectna/trip_detail_list.dart'
as nissanconnect;
import 'package:carwingsflutter/carwings/climate_control_page.dart' as carwings;
import 'package:carwingsflutter/nissanconnectna/climate_control_page.dart'
as nissanconnect;
import 'package:carwingsflutter/carwings/charge_control_page.dart' as carwings;
import 'package:carwingsflutter/nissanconnectna/charge_control_page.dart'
as nissanconnect;
import 'package:carwingsflutter/session.dart';

class WidgetDelegator {
  static debugPage(Session session) {
    return session.isNorthAmerica()
        ? new nissanconnect.DebugPage(session)
        : new carwings.DebugPage(session);
  }

  static vehiclePage(Session session) {
    return session.isNorthAmerica()
        ? new nissanconnect.VehiclePage(session)
        : new carwings.VehiclePage(session);
  }
  static statisticsDailyCard(Session session) {
    return session.isNorthAmerica()
        ? new nissanconnect.StatisticsDailyCard(session)
        : new carwings.StatisticsDailyCard(session);
  }

  static batteryLatestCard(Session session) {
    return session.isNorthAmerica()
        ? new nissanconnect.BatteryLatestCard(session)
        : new carwings.BatteryLatestCard(session);
  }

  static statisticsMonthlyCard(Session session) {
    return session.isNorthAmerica()
        ? new nissanconnect.StatisticsMonthlyCard(session)
        : new carwings.StatisticsMonthlyCard(session);
  }

  static tripDetailsPage(Session session) {
    return session.isNorthAmerica()
        ? new nissanconnect.TripDetailList(session)
        : new carwings.TripDetailList(session);
  }

  static climateControlPage(Session session) {
    return session.isNorthAmerica()
        ? new nissanconnect.ClimateControlPage(session)
        : new carwings.ClimateControlPage(session);
  }

  static chargingControlPage(Session session) {
    return session.isNorthAmerica()
        ? new nissanconnect.ChargeControlPage(session)
        : new carwings.ChargeControlPage(session);
  }
}
