// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuditLog {

 String get id; String get usuarioId; String get acao; String get detalhes; DateTime get dataHora; String? get ipAddress;
/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogCopyWith<AuditLog> get copyWith => _$AuditLogCopyWithImpl<AuditLog>(this as AuditLog, _$identity);

  /// Serializes this AuditLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AuditLog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLog&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.usuarioId, _this.usuarioId) || other.usuarioId == _this.usuarioId)&&(identical(other.acao, _this.acao) || other.acao == _this.acao)&&(identical(other.detalhes, _this.detalhes) || other.detalhes == _this.detalhes)&&(identical(other.dataHora, _this.dataHora) || other.dataHora == _this.dataHora)&&(identical(other.ipAddress, _this.ipAddress) || other.ipAddress == _this.ipAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AuditLog;
  return Object.hash(runtimeType,_this.id,_this.usuarioId,_this.acao,_this.detalhes,_this.dataHora,_this.ipAddress);
}

@override
String toString() {
  final _this = this as AuditLog;
  return 'AuditLog(id: ${_this.id}, usuarioId: ${_this.usuarioId}, acao: ${_this.acao}, detalhes: ${_this.detalhes}, dataHora: ${_this.dataHora}, ipAddress: ${_this.ipAddress})';
}


}

/// @nodoc
abstract mixin class $AuditLogCopyWith<$Res>  {
  factory $AuditLogCopyWith(AuditLog value, $Res Function(AuditLog) _then) = _$AuditLogCopyWithImpl;
@useResult
$Res call({
 String id, String usuarioId, String acao, String detalhes, DateTime dataHora, String? ipAddress
});




}
/// @nodoc
class _$AuditLogCopyWithImpl<$Res>
    implements $AuditLogCopyWith<$Res> {
  _$AuditLogCopyWithImpl(this._self, this._then);

  final AuditLog _self;
  final $Res Function(AuditLog) _then;

/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? usuarioId = null,Object? acao = null,Object? detalhes = null,Object? dataHora = null,Object? ipAddress = freezed,}) {
  return _then(AuditLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,usuarioId: null == usuarioId ? _self.usuarioId : usuarioId // ignore: cast_nullable_to_non_nullable
as String,acao: null == acao ? _self.acao : acao // ignore: cast_nullable_to_non_nullable
as String,detalhes: null == detalhes ? _self.detalhes : detalhes // ignore: cast_nullable_to_non_nullable
as String,dataHora: null == dataHora ? _self.dataHora : dataHora // ignore: cast_nullable_to_non_nullable
as DateTime,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLog].
extension AuditLogPatterns on AuditLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLog value)  $default,){
final _that = this;
switch (_that) {
case _AuditLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLog value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String usuarioId,  String acao,  String detalhes,  DateTime dataHora,  String? ipAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
return $default(_that.id,_that.usuarioId,_that.acao,_that.detalhes,_that.dataHora,_that.ipAddress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String usuarioId,  String acao,  String detalhes,  DateTime dataHora,  String? ipAddress)  $default,) {final _that = this;
switch (_that) {
case _AuditLog():
return $default(_that.id,_that.usuarioId,_that.acao,_that.detalhes,_that.dataHora,_that.ipAddress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String usuarioId,  String acao,  String detalhes,  DateTime dataHora,  String? ipAddress)?  $default,) {final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
return $default(_that.id,_that.usuarioId,_that.acao,_that.detalhes,_that.dataHora,_that.ipAddress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditLog implements AuditLog {
  const _AuditLog({required this.id, required this.usuarioId, required this.acao, required this.detalhes, required this.dataHora, this.ipAddress});
  factory _AuditLog.fromJson(Map<String, dynamic> json) => _$AuditLogFromJson(json);

@override final  String id;
@override final  String usuarioId;
@override final  String acao;
@override final  String detalhes;
@override final  DateTime dataHora;
@override final  String? ipAddress;

/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogCopyWith<_AuditLog> get copyWith => __$AuditLogCopyWithImpl<_AuditLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditLogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLog&&(identical(other.id, id) || other.id == id)&&(identical(other.usuarioId, usuarioId) || other.usuarioId == usuarioId)&&(identical(other.acao, acao) || other.acao == acao)&&(identical(other.detalhes, detalhes) || other.detalhes == detalhes)&&(identical(other.dataHora, dataHora) || other.dataHora == dataHora)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,usuarioId,acao,detalhes,dataHora,ipAddress);
}

@override
String toString() {
    return 'AuditLog(id: $id, usuarioId: $usuarioId, acao: $acao, detalhes: $detalhes, dataHora: $dataHora, ipAddress: $ipAddress)';
}


}

/// @nodoc
abstract mixin class _$AuditLogCopyWith<$Res> implements $AuditLogCopyWith<$Res> {
  factory _$AuditLogCopyWith(_AuditLog value, $Res Function(_AuditLog) _then) = __$AuditLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String usuarioId, String acao, String detalhes, DateTime dataHora, String? ipAddress
});




}
/// @nodoc
class __$AuditLogCopyWithImpl<$Res>
    implements _$AuditLogCopyWith<$Res> {
  __$AuditLogCopyWithImpl(this._self, this._then);

  final _AuditLog _self;
  final $Res Function(_AuditLog) _then;

/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? usuarioId = null,Object? acao = null,Object? detalhes = null,Object? dataHora = null,Object? ipAddress = freezed,}) {
  return _then(_AuditLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,usuarioId: null == usuarioId ? _self.usuarioId : usuarioId // ignore: cast_nullable_to_non_nullable
as String,acao: null == acao ? _self.acao : acao // ignore: cast_nullable_to_non_nullable
as String,detalhes: null == detalhes ? _self.detalhes : detalhes // ignore: cast_nullable_to_non_nullable
as String,dataHora: null == dataHora ? _self.dataHora : dataHora // ignore: cast_nullable_to_non_nullable
as DateTime,ipAddress: freezed == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
