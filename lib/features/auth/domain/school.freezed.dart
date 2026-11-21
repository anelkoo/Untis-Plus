// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'school.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$School {

 String get server; String get loginName; String get displayName; String get address;
/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchoolCopyWith<School> get copyWith => _$SchoolCopyWithImpl<School>(this as School, _$identity);

  /// Serializes this School to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as School;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is School&&(identical(other.server, _this.server) || other.server == _this.server)&&(identical(other.loginName, _this.loginName) || other.loginName == _this.loginName)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.address, _this.address) || other.address == _this.address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as School;
  return Object.hash(runtimeType,_this.server,_this.loginName,_this.displayName,_this.address);
}

@override
String toString() {
  final _this = this as School;
  return 'School(server: ${_this.server}, loginName: ${_this.loginName}, displayName: ${_this.displayName}, address: ${_this.address})';
}


}

/// @nodoc
abstract mixin class $SchoolCopyWith<$Res>  {
  factory $SchoolCopyWith(School value, $Res Function(School) _then) = _$SchoolCopyWithImpl;
@useResult
$Res call({
 String server, String loginName, String displayName, String address
});




}
/// @nodoc
class _$SchoolCopyWithImpl<$Res>
    implements $SchoolCopyWith<$Res> {
  _$SchoolCopyWithImpl(this._self, this._then);

  final School _self;
  final $Res Function(School) _then;

/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? server = null,Object? loginName = null,Object? displayName = null,Object? address = null,}) {
  return _then(School(
server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String,loginName: null == loginName ? _self.loginName : loginName // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [School].
extension SchoolPatterns on School {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _School value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _School() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _School value)  $default,){
final _that = this;
switch (_that) {
case _School():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _School value)?  $default,){
final _that = this;
switch (_that) {
case _School() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String server,  String loginName,  String displayName,  String address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _School() when $default != null:
return $default(_that.server,_that.loginName,_that.displayName,_that.address);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String server,  String loginName,  String displayName,  String address)  $default,) {final _that = this;
switch (_that) {
case _School():
return $default(_that.server,_that.loginName,_that.displayName,_that.address);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String server,  String loginName,  String displayName,  String address)?  $default,) {final _that = this;
switch (_that) {
case _School() when $default != null:
return $default(_that.server,_that.loginName,_that.displayName,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _School implements School {
  const _School({required this.server, required this.loginName, required this.displayName, this.address = ''});
  factory _School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);

@override final  String server;
@override final  String loginName;
@override final  String displayName;
@override@JsonKey() final  String address;

/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchoolCopyWith<_School> get copyWith => __$SchoolCopyWithImpl<_School>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchoolToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _School&&(identical(other.server, server) || other.server == server)&&(identical(other.loginName, loginName) || other.loginName == loginName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,server,loginName,displayName,address);
}

@override
String toString() {
    return 'School(server: $server, loginName: $loginName, displayName: $displayName, address: $address)';
}


}

/// @nodoc
abstract mixin class _$SchoolCopyWith<$Res> implements $SchoolCopyWith<$Res> {
  factory _$SchoolCopyWith(_School value, $Res Function(_School) _then) = __$SchoolCopyWithImpl;
@override @useResult
$Res call({
 String server, String loginName, String displayName, String address
});




}
/// @nodoc
class __$SchoolCopyWithImpl<$Res>
    implements _$SchoolCopyWith<$Res> {
  __$SchoolCopyWithImpl(this._self, this._then);

  final _School _self;
  final $Res Function(_School) _then;

/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? server = null,Object? loginName = null,Object? displayName = null,Object? address = null,}) {
  return _then(_School(
server: null == server ? _self.server : server // ignore: cast_nullable_to_non_nullable
as String,loginName: null == loginName ? _self.loginName : loginName // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
