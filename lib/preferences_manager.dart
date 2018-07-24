import 'dart:async';
import 'dart:convert';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static final PREF_THEME = 'theme';
  static final PREF_LOGIN = 'login';
  static final PREF_POLL_INTERVAL = 'pollingInterval';
  static final PREF_GENERAL_SETTINGS = 'generalSettings';

  Future<SharedPreferences> getPreferences() async {
    return SharedPreferences.getInstance();
  }

  Future<int> getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getInt(PREF_THEME) ?? 0;
  }

  Future<Null> setTheme(int theme) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(PREF_THEME, theme);
  }

  Future<LoginSettings> getLoginSettings() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String data = preferences.getString(PREF_LOGIN);
    return data != null ? LoginSettings.fromJson(json.decode(data)) : null;
  }

  Future<Null> setLoginSettings(String username, String password, CarwingsRegion region) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(PREF_LOGIN, json.encode(new LoginSettings(username: username, password: password, region: region).toJson()));
  }

  Future<Null> clearLoginSettings() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(PREF_LOGIN);
  }

  Future<GeneralSettings> getGeneralSettings() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String data = preferences.getString(PREF_GENERAL_SETTINGS);
    return data != null ? GeneralSettings.fromJson(json.decode(data)) : new GeneralSettings();
  }

  Future<Null> setGeneralSettings(GeneralSettings generalSettings) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(PREF_GENERAL_SETTINGS, json.encode(generalSettings.toJson()));
  }

  Future<Null> clear() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
  }

}
