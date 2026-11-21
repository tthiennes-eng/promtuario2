// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardSummary {

 int get totalPacientes; int get agendamentosHoje; int get atendimentos;
/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSummaryCopyWith<DashboardSummary> get copyWith => _$DashboardSummaryCopyWithImpl<DashboardSummary>(this as DashboardSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DashboardSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSummary&&(identical(other.totalPacientes, _this.totalPacientes) || other.totalPacientes == _this.totalPacientes)&&(identical(other.agendamentosHoje, _this.agendamentosHoje) || other.agendamentosHoje == _this.agendamentosHoje)&&(identical(other.atendimentos, _this.atendimentos) || other.atendimentos == _this.atendimentos));
}


@override
int get hashCode {
  final _this = this as DashboardSummary;
  return Object.hash(runtimeType,_this.totalPacientes,_this.agendamentosHoje,_this.atendimentos);
}

@override
String toString() {
  final _this = this as DashboardSummary;
  return 'DashboardSummary(totalPacientes: ${_this.totalPacientes}, agendamentosHoje: ${_this.agendamentosHoje}, atendimentos: ${_this.atendimentos})';
}


}

/// @nodoc
abstract mixin class $DashboardSummaryCopyWith<$Res>  {
  factory $DashboardSummaryCopyWith(DashboardSummary value, $Res Function(DashboardSummary) _then) = _$DashboardSummaryCopyWithImpl;
@useResult
$Res call({
 int totalPacientes, int agendamentosHoje, int atendimentos
});




}
/// @nodoc
class _$DashboardSummaryCopyWithImpl<$Res>
    implements $DashboardSummaryCopyWith<$Res> {
  _$DashboardSummaryCopyWithImpl(this._self, this._then);

  final DashboardSummary _self;
  final $Res Function(DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalPacientes = null,Object? agendamentosHoje = null,Object? atendimentos = null,}) {
  return _then(DashboardSummary(
totalPacientes: null == totalPacientes ? _self.totalPacientes : totalPacientes // ignore: cast_nullable_to_non_nullable
as int,agendamentosHoje: null == agendamentosHoje ? _self.agendamentosHoje : agendamentosHoje // ignore: cast_nullable_to_non_nullable
as int,atendimentos: null == atendimentos ? _self.atendimentos : atendimentos // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardSummary].
extension DashboardSummaryPatterns on DashboardSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardSummary value)  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalPacientes,  int agendamentosHoje,  int atendimentos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.totalPacientes,_that.agendamentosHoje,_that.atendimentos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalPacientes,  int agendamentosHoje,  int atendimentos)  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary():
return $default(_that.totalPacientes,_that.agendamentosHoje,_that.atendimentos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalPacientes,  int agendamentosHoje,  int atendimentos)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.totalPacientes,_that.agendamentosHoje,_that.atendimentos);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardSummary implements DashboardSummary {
  const _DashboardSummary({required this.totalPacientes, required this.agendamentosHoje, required this.atendimentos});
  

@override final  int totalPacientes;
@override final  int agendamentosHoje;
@override final  int atendimentos;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardSummaryCopyWith<_DashboardSummary> get copyWith => __$DashboardSummaryCopyWithImpl<_DashboardSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSummary&&(identical(other.totalPacientes, totalPacientes) || other.totalPacientes == totalPacientes)&&(identical(other.agendamentosHoje, agendamentosHoje) || other.agendamentosHoje == agendamentosHoje)&&(identical(other.atendimentos, atendimentos) || other.atendimentos == atendimentos));
}


@override
int get hashCode {
    return Object.hash(runtimeType,totalPacientes,agendamentosHoje,atendimentos);
}

@override
String toString() {
    return 'DashboardSummary(totalPacientes: $totalPacientes, agendamentosHoje: $agendamentosHoje, atendimentos: $atendimentos)';
}


}

/// @nodoc
abstract mixin class _$DashboardSummaryCopyWith<$Res> implements $DashboardSummaryCopyWith<$Res> {
  factory _$DashboardSummaryCopyWith(_DashboardSummary value, $Res Function(_DashboardSummary) _then) = __$DashboardSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalPacientes, int agendamentosHoje, int atendimentos
});




}
/// @nodoc
class __$DashboardSummaryCopyWithImpl<$Res>
    implements _$DashboardSummaryCopyWith<$Res> {
  __$DashboardSummaryCopyWithImpl(this._self, this._then);

  final _DashboardSummary _self;
  final $Res Function(_DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalPacientes = null,Object? agendamentosHoje = null,Object? atendimentos = null,}) {
  return _then(_DashboardSummary(
totalPacientes: null == totalPacientes ? _self.totalPacientes : totalPacientes // ignore: cast_nullable_to_non_nullable
as int,agendamentosHoje: null == agendamentosHoje ? _self.agendamentosHoje : agendamentosHoje // ignore: cast_nullable_to_non_nullable
as int,atendimentos: null == atendimentos ? _self.atendimentos : atendimentos // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
