import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preferences_types.g.dart';

@JsonSerializable()
class LoginSettings {
  String username;
  String password;
  CarwingsRegion region;

  LoginSettings({this.username, this.password, this.region});

  factory LoginSettings.fromJson(Map<String, dynamic> json) => _$LoginSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LoginSettingsToJson(this);
}

@JsonSerializable()
class GeneralSettings {
  @JsonKey(defaultValue: false)
  bool useMiles;
  @JsonKey(defaultValue: false)
  bool useMileagePerKWh;
  @JsonKey(defaultValue: false)
  bool timeZoneOverride;
  @JsonKey(defaultValue: false)
  bool use12thBarNotation;
  String timeZone;

  GeneralSettings({this.useMiles = false,
      this.useMileagePerKWh = false, this.timeZoneOverride = false, this.use12thBarNotation = false, this.timeZone});

  factory GeneralSettings.fromJson(Map<String, dynamic> json) => _$GeneralSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$GeneralSettingsToJson(this);
}

enum ThemeColor {standard, green, red, purple, dark}

class Setting {
  Setting({
    @required this.theme,
  }) {
    assert(theme != null);
  }

  final ThemeColor theme;

  Setting copyWith({
    ThemeColor theme,
  }) {
    return new Setting(
      theme: theme ?? this.theme,
    );
  }
}
