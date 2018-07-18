import 'package:dartcarwings/dartcarwings.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preferences_types.g.dart';

@JsonSerializable()
class Login extends Object with _$LoginSerializerMixin {
  String username;
  String password;
  CarwingsRegion region;

  Login({this.username, this.password, this.region});

  factory Login.fromJson(Map<String, dynamic> json) => _$LoginFromJson(json);
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
