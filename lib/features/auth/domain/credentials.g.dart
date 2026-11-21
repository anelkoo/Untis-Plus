// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Credentials _$CredentialsFromJson(Map<String, dynamic> json) => _Credentials(
  school: School.fromJson(json['school'] as Map<String, dynamic>),
  username: json['username'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$CredentialsToJson(_Credentials instance) =>
    <String, dynamic>{
      'school': instance.school,
      'username': instance.username,
      'password': instance.password,
    };
