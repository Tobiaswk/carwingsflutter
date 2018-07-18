import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preferences_types.g.dart';

@JsonSerializable()
class LoginSettings extends Object with _$LoginSettingsSerializerMixin {
  String username;
  String password;
  CarwingsRegion region;

  LoginSettings({this.username, this.password, this.region});

  factory LoginSettings.fromJson(Map<String, dynamic> json) => _$LoginSettingsFromJson(json);
}

@JsonSerializable()
class GeneralSettings extends Object with _$GeneralSettingsSerializerMixin {
  bool useMiles;
  bool useMileagePerKWh;

  GeneralSettings({this.useMiles = false,
      this.useMileagePerKWh = false});

  factory GeneralSettings.fromJson(Map<String, dynamic> json) => _$GeneralSettingsFromJson(json);
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
