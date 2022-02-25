import 'package:carwingsflutter/preferences_manager.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:workmanager/workmanager.dart';

// Used for "keep vehicle alive" functionality
///
/// Some users have issues with their vehicles going to "deep sleep"
/// causing their vehicle to not be reachable through the API/app.
/// This functionality is reserved for European vehicles produced after
/// May 2019.
///
/// This setups the callback that gets called at intervals in the background; also
/// when the app is not active either in background, foreground or not at all.
/// See the [keepAliveVehicleTaskCallbackDispatcher] in [main].
class KeepAliveVehicleHelper {
  static enableKeepAlive(PreferencesManager preferencesManager) async {
    var loginSettings = await preferencesManager.getLoginSettings();

    Workmanager().cancelAll();

    if (loginSettings != null) {
      Workmanager().registerPeriodicTask(
        '1',
        'keepAliveVehicle',
        frequency: Duration(minutes: 30),
        inputData: {
          'isWorld': loginSettings.region == CarwingsRegion.World,
          'username': loginSettings.username,
          'password': loginSettings.password,
        },
      );
    }
  }

  static disableKeepAlive() {
    Workmanager().cancelAll();
  }
}
