import 'dart:async';
import 'dart:convert';

import 'package:carwingsflutter/preferences_types.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static final PREF_DONATED = 'donated';
  static final PREF_THEME = 'theme';
  static final PREF_LOGIN = 'login';
  static final PREF_POLL_INTERVAL = 'pollingInterval';
  static final PREF_GENERAL_SETTINGS = 'generalSettings';
  static final PREF_CHARGING_SCHEDULED = 'chargingScheduled';

  static Future<SharedPreferences> getPreferences() async {
    return SharedPreferences.getInstance();
  }

  static Future<Null> setDonated(bool donated) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(PREF_DONATED, donated);
  }

  static Future<int> getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getInt(PREF_THEME) ?? 0;
  }

  static Future<Null> setTheme(int theme) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(PREF_THEME, theme);
  }

  static Future<LoginSettings?> getLoginSettings() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.getString(PREF_LOGIN);
    return data != null ? LoginSettings.fromJson(json.decode(data)) : null;
  }

  static Future<Null> setLoginSettings(
    String username,
    String password,
    CarwingsRegion region,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(
      PREF_LOGIN,
      json.encode(
        LoginSettings(
          username: username,
          password: password,
          region: region,
        ).toJson(),
      ),
    );
  }

  static Future<Null> clearLoginSettings() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(PREF_LOGIN);
  }

  static Future<GeneralSettings> getGeneralSettings() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? data = preferences.getString(PREF_GENERAL_SETTINGS);
    return data != null
        ? GeneralSettings.fromJson(json.decode(data))
        : GeneralSettings();
  }

  static Future<void> setGeneralSettings(
    GeneralSettings Function(GeneralSettings) settings,
  ) async {
    final generalSettings = settings.call(await getGeneralSettings());

    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setString(
      PREF_GENERAL_SETTINGS,
      json.encode(generalSettings.toJson()),
    );
  }

  // For now save charging schedule in preferences
  // It is not possible to get schedule with Carwings API
  static Future<DateTime> getChargingSchedule() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? chargingSchduled = preferences.getInt(PREF_CHARGING_SCHEDULED);
    return DateTime.fromMillisecondsSinceEpoch(chargingSchduled ?? 0);
  }

  static Future<Null> setChargingSchedule(DateTime chargingSchedule) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt(
      PREF_CHARGING_SCHEDULED,
      chargingSchedule.millisecondsSinceEpoch,
    );
  }

  static Future<Null> clear() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
  }
}
