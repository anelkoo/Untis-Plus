// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_School _$SchoolFromJson(Map<String, dynamic> json) => _School(
  server: json['server'] as String,
  loginName: json['loginName'] as String,
  displayName: json['displayName'] as String,
  address: json['address'] as String? ?? '',
);

Map<String, dynamic> _$SchoolToJson(_School instance) => <String, dynamic>{
  'server': instance.server,
  'loginName': instance.loginName,
  'displayName': instance.displayName,
  'address': instance.address,
};
