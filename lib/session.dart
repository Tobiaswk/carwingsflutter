import 'package:dartcarwings/dartcarwings.dart';
import 'package:dartnissanconnect/dartnissanconnect.dart' as nissanconnect;
import 'package:dartnissanconnectna/dartnissanconnectna.dart'
    as nissanconnectna;
import 'package:fk_user_agent/fk_user_agent.dart';

enum API_TYPE { CARWINGS, NISSANCONNECTNA, NISSANCONNECT }

// This class holds a session for the old Carwings API (still used in Europe)
// a session for the newer North American NissanConnect API
// and finally a session for the new NissanConnect API
// For now this class only wraps a subset of calls
class Session {
  CarwingsSession carwings = CarwingsSession();
  nissanconnectna.NissanConnectSession nissanConnectNa =
      nissanconnectna.NissanConnectSession();
  nissanconnect.NissanConnectSession nissanConnect =
      nissanconnect.NissanConnectSession();

  late CarwingsRegion region;

  API_TYPE getAPIType() => isWorld()
      ? API_TYPE.NISSANCONNECT
      : isNorthAmerica()
          ? API_TYPE.NISSANCONNECTNA
          : API_TYPE.CARWINGS;

  bool isCanada() => region == CarwingsRegion.Canada;

  bool isWorld() => region == CarwingsRegion.World;

  bool isNorthAmerica() =>
      region == CarwingsRegion.USA || region == CarwingsRegion.Canada;

  changeVehicle(String nickname) {
    switch (getAPIType()) {
      case API_TYPE.CARWINGS:
        carwings.vehicle =
            carwings.vehicles.firstWhere((v) => v.nickname == nickname);
        break;
      case API_TYPE.NISSANCONNECTNA:
        nissanConnectNa.vehicle =
            nissanConnectNa.vehicles.firstWhere((v) => v.nickname == nickname);
        break;
      case API_TYPE.NISSANCONNECT:
        nissanConnect.vehicle =
            nissanConnect.vehicles.firstWhere((v) => v.nickname == nickname);
        break;
    }
  }

  getVehicle() {
    switch (getAPIType()) {
      case API_TYPE.CARWINGS:
        return carwings.vehicle;
      case API_TYPE.NISSANCONNECTNA:
        return nissanConnectNa.vehicle;
      case API_TYPE.NISSANCONNECT:
        return nissanConnect.vehicle;
    }
  }

  getVehicles() {
    switch (getAPIType()) {
      case API_TYPE.CARWINGS:
        return carwings.vehicles;
      case API_TYPE.NISSANCONNECTNA:
        return nissanConnectNa.vehicles;
      case API_TYPE.NISSANCONNECT:
        return nissanConnect.vehicles;
    }
  }

  Future<Null> login(
      {required String username,
      required String password,
      CarwingsRegion region = CarwingsRegion.Europe,
      Future<String> blowfishEncryptCallback(
          String key, String password)?}) async {
    this.region = region;
    switch (getAPIType()) {
      case API_TYPE.CARWINGS:
        await carwings.login(
            username: username,
            password: password,
            region: region,
            blowfishEncryptCallback: blowfishEncryptCallback!);
        break;
      case API_TYPE.NISSANCONNECTNA:

        /// Used to get appropriate user-agent header for the
        /// North American API client below
        await FkUserAgent.init();

        if (isCanada()) {
          await nissanConnectNa.login(
              username: username,
              password: password,
              countryCode: 'CA',
              userAgent: FkUserAgent.userAgent);
        } else {
          await nissanConnectNa.login(
              username: username,
              password: password,
              userAgent: FkUserAgent.userAgent);
        }
        break;
      case API_TYPE.NISSANCONNECT:
        await nissanConnect.login(username: username, password: password);
        break;
    }
  }
}
