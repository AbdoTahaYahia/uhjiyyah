// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_mode.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameMode {

/// Unique identifier for the game mode.
 String get id;/// Arabic title of the game mode.
 String get titleAr;/// English title of the game mode.
 String get titleEn;/// Arabic description explaining the game mode.
 String get descriptionAr;/// English description explaining the game mode.
 String get descriptionEn;/// Icon representing the game mode in the UI.
/// Excluded from JSON serialization since [IconData] is not serializable.
@JsonKey(includeFromJson: false, includeToJson: false) IconData get icon;/// Minimum number of players required for this mode.
 int get minPlayers;/// Maximum number of players allowed in this mode.
 int get maxPlayers;/// Whether this game mode is currently available to play.
 bool get isAvailable;/// The named route used to navigate to this game mode's screen.
 String get routeName;
/// Create a copy of GameMode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameModeCopyWith<GameMode> get copyWith => _$GameModeCopyWithImpl<GameMode>(this as GameMode, _$identity);

  /// Serializes this GameMode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameMode&&(identical(other.id, id) || other.id == id)&&(identical(other.titleAr, titleAr) || other.titleAr == titleAr)&&(identical(other.titleEn, titleEn) || other.titleEn == titleEn)&&(identical(other.descriptionAr, descriptionAr) || other.descriptionAr == descriptionAr)&&(identical(other.descriptionEn, descriptionEn) || other.descriptionEn == descriptionEn)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.minPlayers, minPlayers) || other.minPlayers == minPlayers)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.routeName, routeName) || other.routeName == routeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,titleAr,titleEn,descriptionAr,descriptionEn,icon,minPlayers,maxPlayers,isAvailable,routeName);

@override
String toString() {
  return 'GameMode(id: $id, titleAr: $titleAr, titleEn: $titleEn, descriptionAr: $descriptionAr, descriptionEn: $descriptionEn, icon: $icon, minPlayers: $minPlayers, maxPlayers: $maxPlayers, isAvailable: $isAvailable, routeName: $routeName)';
}


}

/// @nodoc
abstract mixin class $GameModeCopyWith<$Res>  {
  factory $GameModeCopyWith(GameMode value, $Res Function(GameMode) _then) = _$GameModeCopyWithImpl;
@useResult
$Res call({
 String id, String titleAr, String titleEn, String descriptionAr, String descriptionEn,@JsonKey(includeFromJson: false, includeToJson: false) IconData icon, int minPlayers, int maxPlayers, bool isAvailable, String routeName
});




}
/// @nodoc
class _$GameModeCopyWithImpl<$Res>
    implements $GameModeCopyWith<$Res> {
  _$GameModeCopyWithImpl(this._self, this._then);

  final GameMode _self;
  final $Res Function(GameMode) _then;

/// Create a copy of GameMode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? titleAr = null,Object? titleEn = null,Object? descriptionAr = null,Object? descriptionEn = null,Object? icon = null,Object? minPlayers = null,Object? maxPlayers = null,Object? isAvailable = null,Object? routeName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleAr: null == titleAr ? _self.titleAr : titleAr // ignore: cast_nullable_to_non_nullable
as String,titleEn: null == titleEn ? _self.titleEn : titleEn // ignore: cast_nullable_to_non_nullable
as String,descriptionAr: null == descriptionAr ? _self.descriptionAr : descriptionAr // ignore: cast_nullable_to_non_nullable
as String,descriptionEn: null == descriptionEn ? _self.descriptionEn : descriptionEn // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,minPlayers: null == minPlayers ? _self.minPlayers : minPlayers // ignore: cast_nullable_to_non_nullable
as int,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,routeName: null == routeName ? _self.routeName : routeName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GameMode].
extension GameModePatterns on GameMode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameMode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameMode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameMode value)  $default,){
final _that = this;
switch (_that) {
case _GameMode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameMode value)?  $default,){
final _that = this;
switch (_that) {
case _GameMode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String titleAr,  String titleEn,  String descriptionAr,  String descriptionEn, @JsonKey(includeFromJson: false, includeToJson: false)  IconData icon,  int minPlayers,  int maxPlayers,  bool isAvailable,  String routeName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameMode() when $default != null:
return $default(_that.id,_that.titleAr,_that.titleEn,_that.descriptionAr,_that.descriptionEn,_that.icon,_that.minPlayers,_that.maxPlayers,_that.isAvailable,_that.routeName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String titleAr,  String titleEn,  String descriptionAr,  String descriptionEn, @JsonKey(includeFromJson: false, includeToJson: false)  IconData icon,  int minPlayers,  int maxPlayers,  bool isAvailable,  String routeName)  $default,) {final _that = this;
switch (_that) {
case _GameMode():
return $default(_that.id,_that.titleAr,_that.titleEn,_that.descriptionAr,_that.descriptionEn,_that.icon,_that.minPlayers,_that.maxPlayers,_that.isAvailable,_that.routeName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String titleAr,  String titleEn,  String descriptionAr,  String descriptionEn, @JsonKey(includeFromJson: false, includeToJson: false)  IconData icon,  int minPlayers,  int maxPlayers,  bool isAvailable,  String routeName)?  $default,) {final _that = this;
switch (_that) {
case _GameMode() when $default != null:
return $default(_that.id,_that.titleAr,_that.titleEn,_that.descriptionAr,_that.descriptionEn,_that.icon,_that.minPlayers,_that.maxPlayers,_that.isAvailable,_that.routeName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameMode implements GameMode {
  const _GameMode({required this.id, required this.titleAr, required this.titleEn, required this.descriptionAr, required this.descriptionEn, @JsonKey(includeFromJson: false, includeToJson: false) this.icon = Icons.games, this.minPlayers = 2, this.maxPlayers = 20, this.isAvailable = true, required this.routeName});
  factory _GameMode.fromJson(Map<String, dynamic> json) => _$GameModeFromJson(json);

/// Unique identifier for the game mode.
@override final  String id;
/// Arabic title of the game mode.
@override final  String titleAr;
/// English title of the game mode.
@override final  String titleEn;
/// Arabic description explaining the game mode.
@override final  String descriptionAr;
/// English description explaining the game mode.
@override final  String descriptionEn;
/// Icon representing the game mode in the UI.
/// Excluded from JSON serialization since [IconData] is not serializable.
@override@JsonKey(includeFromJson: false, includeToJson: false) final  IconData icon;
/// Minimum number of players required for this mode.
@override@JsonKey() final  int minPlayers;
/// Maximum number of players allowed in this mode.
@override@JsonKey() final  int maxPlayers;
/// Whether this game mode is currently available to play.
@override@JsonKey() final  bool isAvailable;
/// The named route used to navigate to this game mode's screen.
@override final  String routeName;

/// Create a copy of GameMode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameModeCopyWith<_GameMode> get copyWith => __$GameModeCopyWithImpl<_GameMode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameModeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameMode&&(identical(other.id, id) || other.id == id)&&(identical(other.titleAr, titleAr) || other.titleAr == titleAr)&&(identical(other.titleEn, titleEn) || other.titleEn == titleEn)&&(identical(other.descriptionAr, descriptionAr) || other.descriptionAr == descriptionAr)&&(identical(other.descriptionEn, descriptionEn) || other.descriptionEn == descriptionEn)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.minPlayers, minPlayers) || other.minPlayers == minPlayers)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.routeName, routeName) || other.routeName == routeName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,titleAr,titleEn,descriptionAr,descriptionEn,icon,minPlayers,maxPlayers,isAvailable,routeName);

@override
String toString() {
  return 'GameMode(id: $id, titleAr: $titleAr, titleEn: $titleEn, descriptionAr: $descriptionAr, descriptionEn: $descriptionEn, icon: $icon, minPlayers: $minPlayers, maxPlayers: $maxPlayers, isAvailable: $isAvailable, routeName: $routeName)';
}


}

/// @nodoc
abstract mixin class _$GameModeCopyWith<$Res> implements $GameModeCopyWith<$Res> {
  factory _$GameModeCopyWith(_GameMode value, $Res Function(_GameMode) _then) = __$GameModeCopyWithImpl;
@override @useResult
$Res call({
 String id, String titleAr, String titleEn, String descriptionAr, String descriptionEn,@JsonKey(includeFromJson: false, includeToJson: false) IconData icon, int minPlayers, int maxPlayers, bool isAvailable, String routeName
});




}
/// @nodoc
class __$GameModeCopyWithImpl<$Res>
    implements _$GameModeCopyWith<$Res> {
  __$GameModeCopyWithImpl(this._self, this._then);

  final _GameMode _self;
  final $Res Function(_GameMode) _then;

/// Create a copy of GameMode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? titleAr = null,Object? titleEn = null,Object? descriptionAr = null,Object? descriptionEn = null,Object? icon = null,Object? minPlayers = null,Object? maxPlayers = null,Object? isAvailable = null,Object? routeName = null,}) {
  return _then(_GameMode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,titleAr: null == titleAr ? _self.titleAr : titleAr // ignore: cast_nullable_to_non_nullable
as String,titleEn: null == titleEn ? _self.titleEn : titleEn // ignore: cast_nullable_to_non_nullable
as String,descriptionAr: null == descriptionAr ? _self.descriptionAr : descriptionAr // ignore: cast_nullable_to_non_nullable
as String,descriptionEn: null == descriptionEn ? _self.descriptionEn : descriptionEn // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,minPlayers: null == minPlayers ? _self.minPlayers : minPlayers // ignore: cast_nullable_to_non_nullable
as int,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,routeName: null == routeName ? _self.routeName : routeName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
