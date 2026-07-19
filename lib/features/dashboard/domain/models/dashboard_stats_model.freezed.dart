// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardStatsModel _$DashboardStatsModelFromJson(Map<String, dynamic> json) {
  return _DashboardStatsModel.fromJson(json);
}

/// @nodoc
mixin _$DashboardStatsModel {
  int get totalPatients => throw _privateConstructorUsedError;
  int get appointmentsToday => throw _privateConstructorUsedError;
  int get proceduresThisMonth => throw _privateConstructorUsedError;
  int get pendingAlerts => throw _privateConstructorUsedError;
  List<MonthlyGrowthModel> get growthData => throw _privateConstructorUsedError;

  /// Serializes this DashboardStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardStatsModelCopyWith<DashboardStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStatsModelCopyWith<$Res> {
  factory $DashboardStatsModelCopyWith(
          DashboardStatsModel value, $Res Function(DashboardStatsModel) then) =
      _$DashboardStatsModelCopyWithImpl<$Res, DashboardStatsModel>;
  @useResult
  $Res call(
      {int totalPatients,
      int appointmentsToday,
      int proceduresThisMonth,
      int pendingAlerts,
      List<MonthlyGrowthModel> growthData});
}

/// @nodoc
class _$DashboardStatsModelCopyWithImpl<$Res, $Val extends DashboardStatsModel>
    implements $DashboardStatsModelCopyWith<$Res> {
  _$DashboardStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalPatients = null,
    Object? appointmentsToday = null,
    Object? proceduresThisMonth = null,
    Object? pendingAlerts = null,
    Object? growthData = null,
  }) {
    return _then(_value.copyWith(
      totalPatients: null == totalPatients
          ? _value.totalPatients
          : totalPatients // ignore: cast_nullable_to_non_nullable
              as int,
      appointmentsToday: null == appointmentsToday
          ? _value.appointmentsToday
          : appointmentsToday // ignore: cast_nullable_to_non_nullable
              as int,
      proceduresThisMonth: null == proceduresThisMonth
          ? _value.proceduresThisMonth
          : proceduresThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      pendingAlerts: null == pendingAlerts
          ? _value.pendingAlerts
          : pendingAlerts // ignore: cast_nullable_to_non_nullable
              as int,
      growthData: null == growthData
          ? _value.growthData
          : growthData // ignore: cast_nullable_to_non_nullable
              as List<MonthlyGrowthModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardStatsModelImplCopyWith<$Res>
    implements $DashboardStatsModelCopyWith<$Res> {
  factory _$$DashboardStatsModelImplCopyWith(_$DashboardStatsModelImpl value,
          $Res Function(_$DashboardStatsModelImpl) then) =
      __$$DashboardStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalPatients,
      int appointmentsToday,
      int proceduresThisMonth,
      int pendingAlerts,
      List<MonthlyGrowthModel> growthData});
}

/// @nodoc
class __$$DashboardStatsModelImplCopyWithImpl<$Res>
    extends _$DashboardStatsModelCopyWithImpl<$Res, _$DashboardStatsModelImpl>
    implements _$$DashboardStatsModelImplCopyWith<$Res> {
  __$$DashboardStatsModelImplCopyWithImpl(_$DashboardStatsModelImpl _value,
      $Res Function(_$DashboardStatsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalPatients = null,
    Object? appointmentsToday = null,
    Object? proceduresThisMonth = null,
    Object? pendingAlerts = null,
    Object? growthData = null,
  }) {
    return _then(_$DashboardStatsModelImpl(
      totalPatients: null == totalPatients
          ? _value.totalPatients
          : totalPatients // ignore: cast_nullable_to_non_nullable
              as int,
      appointmentsToday: null == appointmentsToday
          ? _value.appointmentsToday
          : appointmentsToday // ignore: cast_nullable_to_non_nullable
              as int,
      proceduresThisMonth: null == proceduresThisMonth
          ? _value.proceduresThisMonth
          : proceduresThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      pendingAlerts: null == pendingAlerts
          ? _value.pendingAlerts
          : pendingAlerts // ignore: cast_nullable_to_non_nullable
              as int,
      growthData: null == growthData
          ? _value._growthData
          : growthData // ignore: cast_nullable_to_non_nullable
              as List<MonthlyGrowthModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardStatsModelImpl implements _DashboardStatsModel {
  const _$DashboardStatsModelImpl(
      {required this.totalPatients,
      required this.appointmentsToday,
      required this.proceduresThisMonth,
      required this.pendingAlerts,
      required final List<MonthlyGrowthModel> growthData})
      : _growthData = growthData;

  factory _$DashboardStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardStatsModelImplFromJson(json);

  @override
  final int totalPatients;
  @override
  final int appointmentsToday;
  @override
  final int proceduresThisMonth;
  @override
  final int pendingAlerts;
  final List<MonthlyGrowthModel> _growthData;
  @override
  List<MonthlyGrowthModel> get growthData {
    if (_growthData is EqualUnmodifiableListView) return _growthData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_growthData);
  }

  @override
  String toString() {
    return 'DashboardStatsModel(totalPatients: $totalPatients, appointmentsToday: $appointmentsToday, proceduresThisMonth: $proceduresThisMonth, pendingAlerts: $pendingAlerts, growthData: $growthData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStatsModelImpl &&
            (identical(other.totalPatients, totalPatients) ||
                other.totalPatients == totalPatients) &&
            (identical(other.appointmentsToday, appointmentsToday) ||
                other.appointmentsToday == appointmentsToday) &&
            (identical(other.proceduresThisMonth, proceduresThisMonth) ||
                other.proceduresThisMonth == proceduresThisMonth) &&
            (identical(other.pendingAlerts, pendingAlerts) ||
                other.pendingAlerts == pendingAlerts) &&
            const DeepCollectionEquality()
                .equals(other._growthData, _growthData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalPatients,
      appointmentsToday,
      proceduresThisMonth,
      pendingAlerts,
      const DeepCollectionEquality().hash(_growthData));

  /// Create a copy of DashboardStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStatsModelImplCopyWith<_$DashboardStatsModelImpl> get copyWith =>
      __$$DashboardStatsModelImplCopyWithImpl<_$DashboardStatsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardStatsModelImplToJson(
      this,
    );
  }
}

abstract class _DashboardStatsModel implements DashboardStatsModel {
  const factory _DashboardStatsModel(
          {required final int totalPatients,
          required final int appointmentsToday,
          required final int proceduresThisMonth,
          required final int pendingAlerts,
          required final List<MonthlyGrowthModel> growthData}) =
      _$DashboardStatsModelImpl;

  factory _DashboardStatsModel.fromJson(Map<String, dynamic> json) =
      _$DashboardStatsModelImpl.fromJson;

  @override
  int get totalPatients;
  @override
  int get appointmentsToday;
  @override
  int get proceduresThisMonth;
  @override
  int get pendingAlerts;
  @override
  List<MonthlyGrowthModel> get growthData;

  /// Create a copy of DashboardStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardStatsModelImplCopyWith<_$DashboardStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MonthlyGrowthModel _$MonthlyGrowthModelFromJson(Map<String, dynamic> json) {
  return _MonthlyGrowthModel.fromJson(json);
}

/// @nodoc
mixin _$MonthlyGrowthModel {
  String get month => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Serializes this MonthlyGrowthModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyGrowthModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyGrowthModelCopyWith<MonthlyGrowthModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyGrowthModelCopyWith<$Res> {
  factory $MonthlyGrowthModelCopyWith(
          MonthlyGrowthModel value, $Res Function(MonthlyGrowthModel) then) =
      _$MonthlyGrowthModelCopyWithImpl<$Res, MonthlyGrowthModel>;
  @useResult
  $Res call({String month, int count});
}

/// @nodoc
class _$MonthlyGrowthModelCopyWithImpl<$Res, $Val extends MonthlyGrowthModel>
    implements $MonthlyGrowthModelCopyWith<$Res> {
  _$MonthlyGrowthModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyGrowthModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? count = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthlyGrowthModelImplCopyWith<$Res>
    implements $MonthlyGrowthModelCopyWith<$Res> {
  factory _$$MonthlyGrowthModelImplCopyWith(_$MonthlyGrowthModelImpl value,
          $Res Function(_$MonthlyGrowthModelImpl) then) =
      __$$MonthlyGrowthModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String month, int count});
}

/// @nodoc
class __$$MonthlyGrowthModelImplCopyWithImpl<$Res>
    extends _$MonthlyGrowthModelCopyWithImpl<$Res, _$MonthlyGrowthModelImpl>
    implements _$$MonthlyGrowthModelImplCopyWith<$Res> {
  __$$MonthlyGrowthModelImplCopyWithImpl(_$MonthlyGrowthModelImpl _value,
      $Res Function(_$MonthlyGrowthModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MonthlyGrowthModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? count = null,
  }) {
    return _then(_$MonthlyGrowthModelImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlyGrowthModelImpl implements _MonthlyGrowthModel {
  const _$MonthlyGrowthModelImpl({required this.month, required this.count});

  factory _$MonthlyGrowthModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyGrowthModelImplFromJson(json);

  @override
  final String month;
  @override
  final int count;

  @override
  String toString() {
    return 'MonthlyGrowthModel(month: $month, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyGrowthModelImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, month, count);

  /// Create a copy of MonthlyGrowthModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyGrowthModelImplCopyWith<_$MonthlyGrowthModelImpl> get copyWith =>
      __$$MonthlyGrowthModelImplCopyWithImpl<_$MonthlyGrowthModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyGrowthModelImplToJson(
      this,
    );
  }
}

abstract class _MonthlyGrowthModel implements MonthlyGrowthModel {
  const factory _MonthlyGrowthModel(
      {required final String month,
      required final int count}) = _$MonthlyGrowthModelImpl;

  factory _MonthlyGrowthModel.fromJson(Map<String, dynamic> json) =
      _$MonthlyGrowthModelImpl.fromJson;

  @override
  String get month;
  @override
  int get count;

  /// Create a copy of MonthlyGrowthModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyGrowthModelImplCopyWith<_$MonthlyGrowthModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
