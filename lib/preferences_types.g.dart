// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginSettings _$LoginSettingsFromJson(Map<String, dynamic> json) =>
    LoginSettings(
      username: json['username'] as String,
      password: json['password'] as String,
      region: $enumDecode(_$CarwingsRegionEnumMap, json['region']),
    );

Map<String, dynamic> _$LoginSettingsToJson(LoginSettings instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'region': _$CarwingsRegionEnumMap[instance.region],
    };

const _$CarwingsRegionEnumMap = {
  CarwingsRegion.World: 'World',
  CarwingsRegion.USA: 'USA',
  CarwingsRegion.Europe: 'Europe',
  CarwingsRegion.Canada: 'Canada',
  CarwingsRegion.Australia: 'Australia',
  CarwingsRegion.Japan: 'Japan',
};

GeneralSettings _$GeneralSettingsFromJson(Map<String, dynamic> json) =>
    GeneralSettings(
      useMiles: json['useMiles'] as bool? ?? false,
      useMileagePerKWh: json['useMileagePerKWh'] as bool? ?? false,
      timeZoneOverride: json['timeZoneOverride'] as bool? ?? false,
      use12thBarNotation: json['use12thBarNotation'] as bool? ?? false,
      showCO2: json['showCO2'] as bool? ?? true,
      timeZone: json['timeZone'] as String? ?? '',
      keepAlive: json['keepAlive'] as bool? ?? false,
    );

Map<String, dynamic> _$GeneralSettingsToJson(GeneralSettings instance) =>
    <String, dynamic>{
      'useMiles': instance.useMiles,
      'useMileagePerKWh': instance.useMileagePerKWh,
      'timeZoneOverride': instance.timeZoneOverride,
      'use12thBarNotation': instance.use12thBarNotation,
      'showCO2': instance.showCO2,
      'timeZone': instance.timeZone,
      'keepAlive': instance.keepAlive,
    };
