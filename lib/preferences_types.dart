import 'package:dartcarwings/dartcarwings.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preferences_types.g.dart';

@JsonSerializable()
class LoginSettings {
  String username;
  String password;
  CarwingsRegion region;

  LoginSettings(
      {required this.username, required this.password, required this.region});

  factory LoginSettings.fromJson(Map<String, dynamic> json) =>
      _$LoginSettingsFromJson(json);

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
  @JsonKey(defaultValue: true)
  bool showCO2;
  @JsonKey(defaultValue: '')
  String timeZone;

  GeneralSettings(
      {this.useMiles = false,
      this.useMileagePerKWh = false,
      this.timeZoneOverride = false,
      this.use12thBarNotation = false,
      this.showCO2 = true,
      this.timeZone = ''});

  factory GeneralSettings.fromJson(Map<String, dynamic> json) =>
      _$GeneralSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$GeneralSettingsToJson(this);
}

enum ThemeColor { standard, green, red, purple, dark, amoledDark }

class Setting {
  Setting({
    required this.theme,
  });

  final ThemeColor theme;

  Setting copyWith({
    required ThemeColor theme,
  }) {
    return Setting(
      theme: theme,
    );
  }
}
