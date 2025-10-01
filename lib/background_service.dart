import 'package:carwingsflutter/preferences_manager.dart';
import 'package:dartcarwings/dartcarwings.dart';
import 'package:dartnissanconnect/dartnissanconnect.dart';
import 'package:workmanager/workmanager.dart';

/// This is the callback that gets called at intervals in the background; also
/// when the app is not active in background, foreground or not at all.
@pragma('vm:entry-point')
void backgroundServiceCallback() {
  Workmanager().executeTask((task, inputData) async {
    String username = inputData![BackgroundService.username];
    String password = inputData[BackgroundService.password];
    bool isWorld = inputData[BackgroundService.isWorld];
    bool keepAlive = inputData[BackgroundService.keepAlive];
    bool useChargingPercentThreshold =
        inputData[BackgroundService.useChargingPercentThreshold];
    // int chargingPercentThreshold =
    //     inputData[BackgroundService.chargingPercentThreshold];

    if (isWorld) {
      NissanConnectSession nissanConnect = NissanConnectSession();

      await nissanConnect.login(username: username, password: password);

      try {
        /// Used for 'keep vehicle alive' functionality
        ///
        /// Some users have issues with their vehicles going to 'deep sleep'
        /// causing their vehicle to not be reachable through the API/app.
        /// This functionality is reserved for European vehicles produced after
        /// May 2019.
        if (keepAlive && !useChargingPercentThreshold) {
          for (final vehicle in nissanConnect.vehicles)
            await vehicle.requestBatteryStatusRefresh();
        }

        // Used for monitoring charging state and stop charging if the
        // charging percentage treshhold is reached.
        // Only happens if the vehicle is already charging.
        // if (useChargingPercentThreshold) {
        //   for (final vehicle in nissanConnect.vehicles) {
        //     final battery = await vehicle.requestBatteryStatusRefresh().then((
        //       ok,
        //     ) {
        //       if (ok) return vehicle.requestBatteryStatus();
        //       return Future.value(null);
        //     });

        //     if (battery != null &&
        //         battery.isCharging &&
        //         battery.batteryPercentage >= chargingPercentThreshold) {
        //       vehicle.requestChargingStop();
        //     }
        //   }
        // }
      } catch (e) {
        return Future.value(false);
      }

      return true;
    }

    return Future.value(true);
  });
}

class BackgroundService {
  static const isWorld = 'isWorld';
  static const username = 'username';
  static const password = 'password';
  static const chargingPercentThreshold = 'chargingPercentThreshold';
  static const useChargingPercentThreshold = 'useChargingPercentThreshold';
  static const keepAlive = 'keepAlive';

  static enable() async {
    final loginSettings = await PreferencesManager.getLoginSettings();
    final generalSettings = await PreferencesManager.getGeneralSettings();

    Workmanager().cancelAll();

    if (loginSettings != null) {
      Workmanager().registerPeriodicTask(
        '1',
        'backgroundJob',
        frequency: Duration(seconds: 30),
        inputData: {
          isWorld: loginSettings.region == CarwingsRegion.World,
          username: loginSettings.username,
          password: loginSettings.password,
          keepAlive: generalSettings.keepAlive,
          useChargingPercentThreshold:
              generalSettings.useChargingPercentThreshold,
          chargingPercentThreshold: generalSettings.chargingPercentThreshold,
        },
      );
    }
  }

  static disable() {
    Workmanager().cancelAll();
  }
}
