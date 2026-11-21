// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Named {

 int get id; String get name; String get longName; String? get original;
/// Create a copy of Named
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NamedCopyWith<Named> get copyWith => _$NamedCopyWithImpl<Named>(this as Named, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Named;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Named&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.longName, _this.longName) || other.longName == _this.longName)&&(identical(other.original, _this.original) || other.original == _this.original));
}


@override
int get hashCode {
  final _this = this as Named;
  return Object.hash(runtimeType,_this.id,_this.name,_this.longName,_this.original);
}

@override
String toString() {
  final _this = this as Named;
  return 'Named(id: ${_this.id}, name: ${_this.name}, longName: ${_this.longName}, original: ${_this.original})';
}


}

/// @nodoc
abstract mixin class $NamedCopyWith<$Res>  {
  factory $NamedCopyWith(Named value, $Res Function(Named) _then) = _$NamedCopyWithImpl;
@useResult
$Res call({
 int id, String name, String longName, String? original
});




}
/// @nodoc
class _$NamedCopyWithImpl<$Res>
    implements $NamedCopyWith<$Res> {
  _$NamedCopyWithImpl(this._self, this._then);

  final Named _self;
  final $Res Function(Named) _then;

/// Create a copy of Named
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? longName = null,Object? original = freezed,}) {
  return _then(Named(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,longName: null == longName ? _self.longName : longName // ignore: cast_nullable_to_non_nullable
as String,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Named].
extension NamedPatterns on Named {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Named value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Named() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Named value)  $default,){
final _that = this;
switch (_that) {
case _Named():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Named value)?  $default,){
final _that = this;
switch (_that) {
case _Named() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String longName,  String? original)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Named() when $default != null:
return $default(_that.id,_that.name,_that.longName,_that.original);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String longName,  String? original)  $default,) {final _that = this;
switch (_that) {
case _Named():
return $default(_that.id,_that.name,_that.longName,_that.original);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String longName,  String? original)?  $default,) {final _that = this;
switch (_that) {
case _Named() when $default != null:
return $default(_that.id,_that.name,_that.longName,_that.original);case _:
  return null;

}
}

}

/// @nodoc


class _Named implements Named {
  const _Named({required this.id, this.name = '', this.longName = '', this.original});
  

@override final  int id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String longName;
@override final  String? original;

/// Create a copy of Named
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NamedCopyWith<_Named> get copyWith => __$NamedCopyWithImpl<_Named>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Named&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.longName, longName) || other.longName == longName)&&(identical(other.original, original) || other.original == original));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,longName,original);
}

@override
String toString() {
    return 'Named(id: $id, name: $name, longName: $longName, original: $original)';
}


}

/// @nodoc
abstract mixin class _$NamedCopyWith<$Res> implements $NamedCopyWith<$Res> {
  factory _$NamedCopyWith(_Named value, $Res Function(_Named) _then) = __$NamedCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String longName, String? original
});




}
/// @nodoc
class __$NamedCopyWithImpl<$Res>
    implements _$NamedCopyWith<$Res> {
  __$NamedCopyWithImpl(this._self, this._then);

  final _Named _self;
  final $Res Function(_Named) _then;

/// Create a copy of Named
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? longName = null,Object? original = freezed,}) {
  return _then(_Named(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,longName: null == longName ? _self.longName : longName // ignore: cast_nullable_to_non_nullable
as String,original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Lesson {

 int get id; DateTime get start; DateTime get end; LessonStatus get status; List<Named> get subjects; List<Named> get teachers; List<Named> get rooms; List<Named> get classes; String get lessonText; String get substitutionText; String get info;/// The school's exam type, e.g. "SMÜP", when an exam falls on this lesson.
 String get examType;
/// Create a copy of Lesson
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LessonCopyWith<Lesson> get copyWith => _$LessonCopyWithImpl<Lesson>(this as Lesson, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Lesson;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lesson&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.subjects, _this.subjects)&&const DeepCollectionEquality().equals(other.teachers, _this.teachers)&&const DeepCollectionEquality().equals(other.rooms, _this.rooms)&&const DeepCollectionEquality().equals(other.classes, _this.classes)&&(identical(other.lessonText, _this.lessonText) || other.lessonText == _this.lessonText)&&(identical(other.substitutionText, _this.substitutionText) || other.substitutionText == _this.substitutionText)&&(identical(other.info, _this.info) || other.info == _this.info)&&(identical(other.examType, _this.examType) || other.examType == _this.examType));
}


@override
int get hashCode {
  final _this = this as Lesson;
  return Object.hash(runtimeType,_this.id,_this.start,_this.end,_this.status,const DeepCollectionEquality().hash(_this.subjects),const DeepCollectionEquality().hash(_this.teachers),const DeepCollectionEquality().hash(_this.rooms),const DeepCollectionEquality().hash(_this.classes),_this.lessonText,_this.substitutionText,_this.info,_this.examType);
}

@override
String toString() {
  final _this = this as Lesson;
  return 'Lesson(id: ${_this.id}, start: ${_this.start}, end: ${_this.end}, status: ${_this.status}, subjects: ${_this.subjects}, teachers: ${_this.teachers}, rooms: ${_this.rooms}, classes: ${_this.classes}, lessonText: ${_this.lessonText}, substitutionText: ${_this.substitutionText}, info: ${_this.info}, examType: ${_this.examType})';
}


}

/// @nodoc
abstract mixin class $LessonCopyWith<$Res>  {
  factory $LessonCopyWith(Lesson value, $Res Function(Lesson) _then) = _$LessonCopyWithImpl;
@useResult
$Res call({
 int id, DateTime start, DateTime end, LessonStatus status, List<Named> subjects, List<Named> teachers, List<Named> rooms, List<Named> classes, String lessonText, String substitutionText, String info, String examType
});




}
/// @nodoc
class _$LessonCopyWithImpl<$Res>
    implements $LessonCopyWith<$Res> {
  _$LessonCopyWithImpl(this._self, this._then);

  final Lesson _self;
  final $Res Function(Lesson) _then;

/// Create a copy of Lesson
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? start = null,Object? end = null,Object? status = null,Object? subjects = null,Object? teachers = null,Object? rooms = null,Object? classes = null,Object? lessonText = null,Object? substitutionText = null,Object? info = null,Object? examType = null,}) {
  return _then(Lesson(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LessonStatus,subjects: null == subjects ? _self.subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<Named>,teachers: null == teachers ? _self.teachers : teachers // ignore: cast_nullable_to_non_nullable
as List<Named>,rooms: null == rooms ? _self.rooms : rooms // ignore: cast_nullable_to_non_nullable
as List<Named>,classes: null == classes ? _self.classes : classes // ignore: cast_nullable_to_non_nullable
as List<Named>,lessonText: null == lessonText ? _self.lessonText : lessonText // ignore: cast_nullable_to_non_nullable
as String,substitutionText: null == substitutionText ? _self.substitutionText : substitutionText // ignore: cast_nullable_to_non_nullable
as String,info: null == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as String,examType: null == examType ? _self.examType : examType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Lesson].
extension LessonPatterns on Lesson {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lesson value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lesson() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lesson value)  $default,){
final _that = this;
switch (_that) {
case _Lesson():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lesson value)?  $default,){
final _that = this;
switch (_that) {
case _Lesson() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DateTime start,  DateTime end,  LessonStatus status,  List<Named> subjects,  List<Named> teachers,  List<Named> rooms,  List<Named> classes,  String lessonText,  String substitutionText,  String info,  String examType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lesson() when $default != null:
return $default(_that.id,_that.start,_that.end,_that.status,_that.subjects,_that.teachers,_that.rooms,_that.classes,_that.lessonText,_that.substitutionText,_that.info,_that.examType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DateTime start,  DateTime end,  LessonStatus status,  List<Named> subjects,  List<Named> teachers,  List<Named> rooms,  List<Named> classes,  String lessonText,  String substitutionText,  String info,  String examType)  $default,) {final _that = this;
switch (_that) {
case _Lesson():
return $default(_that.id,_that.start,_that.end,_that.status,_that.subjects,_that.teachers,_that.rooms,_that.classes,_that.lessonText,_that.substitutionText,_that.info,_that.examType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DateTime start,  DateTime end,  LessonStatus status,  List<Named> subjects,  List<Named> teachers,  List<Named> rooms,  List<Named> classes,  String lessonText,  String substitutionText,  String info,  String examType)?  $default,) {final _that = this;
switch (_that) {
case _Lesson() when $default != null:
return $default(_that.id,_that.start,_that.end,_that.status,_that.subjects,_that.teachers,_that.rooms,_that.classes,_that.lessonText,_that.substitutionText,_that.info,_that.examType);case _:
  return null;

}
}

}

/// @nodoc


class _Lesson implements Lesson {
  const _Lesson({required this.id, required this.start, required this.end, this.status = LessonStatus.regular,  List<Named> subjects = const [],  List<Named> teachers = const [],  List<Named> rooms = const [],  List<Named> classes = const [], this.lessonText = '', this.substitutionText = '', this.info = '', this.examType = ''}): _subjects = subjects,_teachers = teachers,_rooms = rooms,_classes = classes;
  

@override final  int id;
@override final  DateTime start;
@override final  DateTime end;
@override@JsonKey() final  LessonStatus status;
 final  List<Named> _subjects;
@override@JsonKey() List<Named> get subjects {
  if (_subjects is EqualUnmodifiableListView) return _subjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subjects);
}

 final  List<Named> _teachers;
@override@JsonKey() List<Named> get teachers {
  if (_teachers is EqualUnmodifiableListView) return _teachers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_teachers);
}

 final  List<Named> _rooms;
@override@JsonKey() List<Named> get rooms {
  if (_rooms is EqualUnmodifiableListView) return _rooms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rooms);
}

 final  List<Named> _classes;
@override@JsonKey() List<Named> get classes {
  if (_classes is EqualUnmodifiableListView) return _classes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_classes);
}

@override@JsonKey() final  String lessonText;
@override@JsonKey() final  String substitutionText;
@override@JsonKey() final  String info;
/// The school's exam type, e.g. "SMÜP", when an exam falls on this lesson.
@override@JsonKey() final  String examType;

/// Create a copy of Lesson
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LessonCopyWith<_Lesson> get copyWith => __$LessonCopyWithImpl<_Lesson>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lesson&&(identical(other.id, id) || other.id == id)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.subjects, _subjects)&&const DeepCollectionEquality().equals(other.teachers, _teachers)&&const DeepCollectionEquality().equals(other.rooms, _rooms)&&const DeepCollectionEquality().equals(other.classes, _classes)&&(identical(other.lessonText, lessonText) || other.lessonText == lessonText)&&(identical(other.substitutionText, substitutionText) || other.substitutionText == substitutionText)&&(identical(other.info, info) || other.info == info)&&(identical(other.examType, examType) || other.examType == examType));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,start,end,status,const DeepCollectionEquality().hash(_subjects),const DeepCollectionEquality().hash(_teachers),const DeepCollectionEquality().hash(_rooms),const DeepCollectionEquality().hash(_classes),lessonText,substitutionText,info,examType);
}

@override
String toString() {
    return 'Lesson(id: $id, start: $start, end: $end, status: $status, subjects: $subjects, teachers: $teachers, rooms: $rooms, classes: $classes, lessonText: $lessonText, substitutionText: $substitutionText, info: $info, examType: $examType)';
}


}

/// @nodoc
abstract mixin class _$LessonCopyWith<$Res> implements $LessonCopyWith<$Res> {
  factory _$LessonCopyWith(_Lesson value, $Res Function(_Lesson) _then) = __$LessonCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime start, DateTime end, LessonStatus status, List<Named> subjects, List<Named> teachers, List<Named> rooms, List<Named> classes, String lessonText, String substitutionText, String info, String examType
});




}
/// @nodoc
class __$LessonCopyWithImpl<$Res>
    implements _$LessonCopyWith<$Res> {
  __$LessonCopyWithImpl(this._self, this._then);

  final _Lesson _self;
  final $Res Function(_Lesson) _then;

/// Create a copy of Lesson
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? start = null,Object? end = null,Object? status = null,Object? subjects = null,Object? teachers = null,Object? rooms = null,Object? classes = null,Object? lessonText = null,Object? substitutionText = null,Object? info = null,Object? examType = null,}) {
  return _then(_Lesson(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LessonStatus,subjects: null == subjects ? _self._subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<Named>,teachers: null == teachers ? _self._teachers : teachers // ignore: cast_nullable_to_non_nullable
as List<Named>,rooms: null == rooms ? _self._rooms : rooms // ignore: cast_nullable_to_non_nullable
as List<Named>,classes: null == classes ? _self._classes : classes // ignore: cast_nullable_to_non_nullable
as List<Named>,lessonText: null == lessonText ? _self.lessonText : lessonText // ignore: cast_nullable_to_non_nullable
as String,substitutionText: null == substitutionText ? _self.substitutionText : substitutionText // ignore: cast_nullable_to_non_nullable
as String,info: null == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as String,examType: null == examType ? _self.examType : examType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
