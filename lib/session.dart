import 'package:dartcarwings/dartcarwings.dart';
import 'package:dartnissanconnectna/dartnissanconnectna.dart';

// This class holds a session for the old Carwings API (still used in Europe)
// and a session for the newer North American NissanConnect API
// For now this class only wraps a subset of calls
class Session {
  CarwingsSession carwings = new CarwingsSession();
  NissanConnectSession nissanConnectNa = new NissanConnectSession();

  CarwingsRegion region;

  bool isCanada() => region == CarwingsRegion.Canada;

  bool isNorthAmerica() =>
      region == CarwingsRegion.USA || region == CarwingsRegion.Canada;

  changeVehicle(String nickname) {
    if (isNorthAmerica()) {
      nissanConnectNa.vehicle =
          nissanConnectNa.vehicles.firstWhere((v) => v.nickname == nickname);
    } else {
      carwings.vehicle =
          carwings.vehicles.firstWhere((v) => v.nickname == nickname);
    }
  }

  getVehicle() => isNorthAmerica() ? nissanConnectNa.vehicle : carwings.vehicle;

  getVehicles() =>
      isNorthAmerica() ? nissanConnectNa.vehicles : carwings.vehicles;

  Future<Null> login(
      {String username,
      String password,
      CarwingsRegion region = CarwingsRegion.Europe,
      Future<String> blowfishEncryptCallback(
          String key, String password)}) async {
    this.region = region;
    if (isNorthAmerica()) {
      if(isCanada()) {
        await nissanConnectNa.login(username: username, password: password, countryCode: 'CA');
      } else {
        await nissanConnectNa.login(username: username, password: password);
      }
    } else {
      await carwings.login(
          username: username,
          password: password,
          region: region,
          blowfishEncryptCallback: blowfishEncryptCallback);
    }
  }
}
