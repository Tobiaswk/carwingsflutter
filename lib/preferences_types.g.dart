// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Login _$LoginFromJson(Map<String, dynamic> json) => new Login(
    username: json['username'] as String,
    password: json['password'] as String,
    region: json['region'] == null
        ? null
        : CarwingsRegion.values.singleWhere(
            (x) => x.toString() == 'CarwingsRegion.${json['region']}'));

abstract class _$LoginSerializerMixin {
  String get username;
  String get password;
  CarwingsRegion get region;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'password': password,
        'region': region == null ? null : region.toString().split('.')[1]
      };
}
