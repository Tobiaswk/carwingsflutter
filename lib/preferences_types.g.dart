// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginSettings _$LoginSettingsFromJson(Map<String, dynamic> json) {
  return LoginSettings(
      username: json['username'] as String,
      password: json['password'] as String,
      region: _$enumDecodeNullable(_$CarwingsRegionEnumMap, json['region']));
}

Map<String, dynamic> _$LoginSettingsToJson(LoginSettings instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'region': _$CarwingsRegionEnumMap[instance.region]
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$CarwingsRegionEnumMap = <CarwingsRegion, dynamic>{
  CarwingsRegion.USA: 'USA',
  CarwingsRegion.Europe: 'Europe',
  CarwingsRegion.Canada: 'Canada',
  CarwingsRegion.Australia: 'Australia',
  CarwingsRegion.Japan: 'Japan'
};

GeneralSettings _$GeneralSettingsFromJson(Map<String, dynamic> json) {
  return GeneralSettings(
      useMiles: json['useMiles'] as bool ?? false,
      useMileagePerKWh: json['useMileagePerKWh'] as bool ?? false,
      timeZoneOverride: json['timeZoneOverride'] as bool ?? false,
      use12thBarNotation: json['use12thBarNotation'] as bool ?? false,
      showCO2: json['showCO2'] as bool ?? true,
      timeZone: json['timeZone'] as String);
}

Map<String, dynamic> _$GeneralSettingsToJson(GeneralSettings instance) =>
    <String, dynamic>{
      'useMiles': instance.useMiles,
      'useMileagePerKWh': instance.useMileagePerKWh,
      'timeZoneOverride': instance.timeZoneOverride,
      'use12thBarNotation': instance.use12thBarNotation,
      'showCO2': instance.showCO2,
      'timeZone': instance.timeZone
    };
