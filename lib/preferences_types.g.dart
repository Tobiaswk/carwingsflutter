// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginSettings _$LoginSettingsFromJson(Map<String, dynamic> json) =>
    new LoginSettings(
        username: json['username'] as String,
        password: json['password'] as String,
        region: json['region'] == null
            ? null
            : CarwingsRegion.values.singleWhere(
                (x) => x.toString() == 'CarwingsRegion.${json['region']}'));

abstract class _$LoginSettingsSerializerMixin {
  String get username;
  String get password;
  CarwingsRegion get region;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'password': password,
        'region': region == null ? null : region.toString().split('.')[1]
      };
}

GeneralSettings _$GeneralSettingsFromJson(Map<String, dynamic> json) =>
    new GeneralSettings(
        useMiles: json['useMiles'] as bool,
        useMileagePerKWh: json['useMileagePerKWh'] as bool);

abstract class _$GeneralSettingsSerializerMixin {
  bool get useMiles;
  bool get useMileagePerKWh;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'useMiles': useMiles,
        'useMileagePerKWh': useMileagePerKWh
      };
}
