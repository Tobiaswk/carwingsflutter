// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Login _$LoginFromJson(Map<String, dynamic> json) => new Login(
    username: json['username'] as String, password: json['password'] as String);

abstract class _$LoginSerializerMixin {
  String get username;
  String get password;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'username': username, 'password': password};
}
