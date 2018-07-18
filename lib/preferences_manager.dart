import 'dart:async';
import 'dart:convert';
import 'package:carwingsflutter/preferences_types.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  final PREF_THEME = 'theme';
  final PREF_LOGIN = 'login';
  final PREF_POLL_INTERVAL = 'pollingInterval';
  final PREF_USE_MILES = 'useMiles';

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

  Future<Login> getLogin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String data = preferences.getString(PREF_LOGIN);
    return data != null ? Login.fromJson(json.decode(data)) : null;
  }

  Future<Null> setLogin(String username, String password, CarwingsRegion region) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(PREF_LOGIN, json.encode(new Login(username: username, password: password, region: region).toJson()));
  }

  Future<Null> clear() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
  }

  Future<bool> getUseMiles() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(PREF_USE_MILES) ?? 0;
  }

  Future<Null> setUseMiles(bool useMiles) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(PREF_USE_MILES, useMiles);
  }

}
