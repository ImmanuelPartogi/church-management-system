// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial_report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FinancialPeriodModel _$FinancialPeriodModelFromJson(Map<String, dynamic> json) {
  return _FinancialPeriodModel.fromJson(json);
}

/// @nodoc
mixin _$FinancialPeriodModel {
  String get from => throw _privateConstructorUsedError;
  String get to => throw _privateConstructorUsedError;

  /// Serializes this FinancialPeriodModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FinancialPeriodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FinancialPeriodModelCopyWith<FinancialPeriodModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinancialPeriodModelCopyWith<$Res> {
  factory $FinancialPeriodModelCopyWith(FinancialPeriodModel value,
          $Res Function(FinancialPeriodModel) then) =
      _$FinancialPeriodModelCopyWithImpl<$Res, FinancialPeriodModel>;
  @useResult
  $Res call({String from, String to});
}

/// @nodoc
class _$FinancialPeriodModelCopyWithImpl<$Res,
        $Val extends FinancialPeriodModel>
    implements $FinancialPeriodModelCopyWith<$Res> {
  _$FinancialPeriodModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FinancialPeriodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = null,
    Object? to = null,
  }) {
    return _then(_value.copyWith(
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as String,
      to: null == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FinancialPeriodModelImplCopyWith<$Res>
    implements $FinancialPeriodModelCopyWith<$Res> {
  factory _$$FinancialPeriodModelImplCopyWith(_$FinancialPeriodModelImpl value,
          $Res Function(_$FinancialPeriodModelImpl) then) =
      __$$FinancialPeriodModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String from, String to});
}

/// @nodoc
class __$$FinancialPeriodModelImplCopyWithImpl<$Res>
    extends _$FinancialPeriodModelCopyWithImpl<$Res, _$FinancialPeriodModelImpl>
    implements _$$FinancialPeriodModelImplCopyWith<$Res> {
  __$$FinancialPeriodModelImplCopyWithImpl(_$FinancialPeriodModelImpl _value,
      $Res Function(_$FinancialPeriodModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of FinancialPeriodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = null,
    Object? to = null,
  }) {
    return _then(_$FinancialPeriodModelImpl(
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as String,
      to: null == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FinancialPeriodModelImpl extends _FinancialPeriodModel {
  const _$FinancialPeriodModelImpl({required this.from, required this.to})
      : super._();

  factory _$FinancialPeriodModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinancialPeriodModelImplFromJson(json);

  @override
  final String from;
  @override
  final String to;

  @override
  String toString() {
    return 'FinancialPeriodModel(from: $from, to: $to)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinancialPeriodModelImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, from, to);

  /// Create a copy of FinancialPeriodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FinancialPeriodModelImplCopyWith<_$FinancialPeriodModelImpl>
      get copyWith =>
          __$$FinancialPeriodModelImplCopyWithImpl<_$FinancialPeriodModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FinancialPeriodModelImplToJson(
      this,
    );
  }
}

abstract class _FinancialPeriodModel extends FinancialPeriodModel {
  const factory _FinancialPeriodModel(
      {required final String from,
      required final String to}) = _$FinancialPeriodModelImpl;
  const _FinancialPeriodModel._() : super._();

  factory _FinancialPeriodModel.fromJson(Map<String, dynamic> json) =
      _$FinancialPeriodModelImpl.fromJson;

  @override
  String get from;
  @override
  String get to;

  /// Create a copy of FinancialPeriodModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FinancialPeriodModelImplCopyWith<_$FinancialPeriodModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

FinancialSummaryModel _$FinancialSummaryModelFromJson(
    Map<String, dynamic> json) {
  return _FinancialSummaryModel.fromJson(json);
}

/// @nodoc
mixin _$FinancialSummaryModel {
  @JsonKey(name: 'total_income')
  double get totalIncome => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_expense')
  double get totalExpense => throw _privateConstructorUsedError;
  @JsonKey(name: 'net_balance')
  double get netBalance => throw _privateConstructorUsedError;

  /// Serializes this FinancialSummaryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FinancialSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FinancialSummaryModelCopyWith<FinancialSummaryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinancialSummaryModelCopyWith<$Res> {
  factory $FinancialSummaryModelCopyWith(FinancialSummaryModel value,
          $Res Function(FinancialSummaryModel) then) =
      _$FinancialSummaryModelCopyWithImpl<$Res, FinancialSummaryModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'total_income') double totalIncome,
      @JsonKey(name: 'total_expense') double totalExpense,
      @JsonKey(name: 'net_balance') double netBalance});
}

/// @nodoc
class _$FinancialSummaryModelCopyWithImpl<$Res,
        $Val extends FinancialSummaryModel>
    implements $FinancialSummaryModelCopyWith<$Res> {
  _$FinancialSummaryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FinancialSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalIncome = null,
    Object? totalExpense = null,
    Object? netBalance = null,
  }) {
    return _then(_value.copyWith(
      totalIncome: null == totalIncome
          ? _value.totalIncome
          : totalIncome // ignore: cast_nullable_to_non_nullable
              as double,
      totalExpense: null == totalExpense
          ? _value.totalExpense
          : totalExpense // ignore: cast_nullable_to_non_nullable
              as double,
      netBalance: null == netBalance
          ? _value.netBalance
          : netBalance // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FinancialSummaryModelImplCopyWith<$Res>
    implements $FinancialSummaryModelCopyWith<$Res> {
  factory _$$FinancialSummaryModelImplCopyWith(
          _$FinancialSummaryModelImpl value,
          $Res Function(_$FinancialSummaryModelImpl) then) =
      __$$FinancialSummaryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'total_income') double totalIncome,
      @JsonKey(name: 'total_expense') double totalExpense,
      @JsonKey(name: 'net_balance') double netBalance});
}

/// @nodoc
class __$$FinancialSummaryModelImplCopyWithImpl<$Res>
    extends _$FinancialSummaryModelCopyWithImpl<$Res,
        _$FinancialSummaryModelImpl>
    implements _$$FinancialSummaryModelImplCopyWith<$Res> {
  __$$FinancialSummaryModelImplCopyWithImpl(_$FinancialSummaryModelImpl _value,
      $Res Function(_$FinancialSummaryModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of FinancialSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalIncome = null,
    Object? totalExpense = null,
    Object? netBalance = null,
  }) {
    return _then(_$FinancialSummaryModelImpl(
      totalIncome: null == totalIncome
          ? _value.totalIncome
          : totalIncome // ignore: cast_nullable_to_non_nullable
              as double,
      totalExpense: null == totalExpense
          ? _value.totalExpense
          : totalExpense // ignore: cast_nullable_to_non_nullable
              as double,
      netBalance: null == netBalance
          ? _value.netBalance
          : netBalance // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FinancialSummaryModelImpl extends _FinancialSummaryModel {
  const _$FinancialSummaryModelImpl(
      {@JsonKey(name: 'total_income') required this.totalIncome,
      @JsonKey(name: 'total_expense') required this.totalExpense,
      @JsonKey(name: 'net_balance') required this.netBalance})
      : super._();

  factory _$FinancialSummaryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinancialSummaryModelImplFromJson(json);

  @override
  @JsonKey(name: 'total_income')
  final double totalIncome;
  @override
  @JsonKey(name: 'total_expense')
  final double totalExpense;
  @override
  @JsonKey(name: 'net_balance')
  final double netBalance;

  @override
  String toString() {
    return 'FinancialSummaryModel(totalIncome: $totalIncome, totalExpense: $totalExpense, netBalance: $netBalance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinancialSummaryModelImpl &&
            (identical(other.totalIncome, totalIncome) ||
                other.totalIncome == totalIncome) &&
            (identical(other.totalExpense, totalExpense) ||
                other.totalExpense == totalExpense) &&
            (identical(other.netBalance, netBalance) ||
                other.netBalance == netBalance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, totalIncome, totalExpense, netBalance);

  /// Create a copy of FinancialSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FinancialSummaryModelImplCopyWith<_$FinancialSummaryModelImpl>
      get copyWith => __$$FinancialSummaryModelImplCopyWithImpl<
          _$FinancialSummaryModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FinancialSummaryModelImplToJson(
      this,
    );
  }
}

abstract class _FinancialSummaryModel extends FinancialSummaryModel {
  const factory _FinancialSummaryModel(
          {@JsonKey(name: 'total_income') required final double totalIncome,
          @JsonKey(name: 'total_expense') required final double totalExpense,
          @JsonKey(name: 'net_balance') required final double netBalance}) =
      _$FinancialSummaryModelImpl;
  const _FinancialSummaryModel._() : super._();

  factory _FinancialSummaryModel.fromJson(Map<String, dynamic> json) =
      _$FinancialSummaryModelImpl.fromJson;

  @override
  @JsonKey(name: 'total_income')
  double get totalIncome;
  @override
  @JsonKey(name: 'total_expense')
  double get totalExpense;
  @override
  @JsonKey(name: 'net_balance')
  double get netBalance;

  /// Create a copy of FinancialSummaryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FinancialSummaryModelImplCopyWith<_$FinancialSummaryModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

AccountBreakdownModel _$AccountBreakdownModelFromJson(
    Map<String, dynamic> json) {
  return _AccountBreakdownModel.fromJson(json);
}

/// @nodoc
mixin _$AccountBreakdownModel {
  @JsonKey(name: 'account_code')
  String get accountCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_name')
  String get accountName => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_amount')
  double get totalAmount => throw _privateConstructorUsedError;

  /// Serializes this AccountBreakdownModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AccountBreakdownModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AccountBreakdownModelCopyWith<AccountBreakdownModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountBreakdownModelCopyWith<$Res> {
  factory $AccountBreakdownModelCopyWith(AccountBreakdownModel value,
          $Res Function(AccountBreakdownModel) then) =
      _$AccountBreakdownModelCopyWithImpl<$Res, AccountBreakdownModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'account_code') String accountCode,
      @JsonKey(name: 'account_name') String accountName,
      @JsonKey(name: 'total_amount') double totalAmount});
}

/// @nodoc
class _$AccountBreakdownModelCopyWithImpl<$Res,
        $Val extends AccountBreakdownModel>
    implements $AccountBreakdownModelCopyWith<$Res> {
  _$AccountBreakdownModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AccountBreakdownModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountCode = null,
    Object? accountName = null,
    Object? totalAmount = null,
  }) {
    return _then(_value.copyWith(
      accountCode: null == accountCode
          ? _value.accountCode
          : accountCode // ignore: cast_nullable_to_non_nullable
              as String,
      accountName: null == accountName
          ? _value.accountName
          : accountName // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccountBreakdownModelImplCopyWith<$Res>
    implements $AccountBreakdownModelCopyWith<$Res> {
  factory _$$AccountBreakdownModelImplCopyWith(
          _$AccountBreakdownModelImpl value,
          $Res Function(_$AccountBreakdownModelImpl) then) =
      __$$AccountBreakdownModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'account_code') String accountCode,
      @JsonKey(name: 'account_name') String accountName,
      @JsonKey(name: 'total_amount') double totalAmount});
}

/// @nodoc
class __$$AccountBreakdownModelImplCopyWithImpl<$Res>
    extends _$AccountBreakdownModelCopyWithImpl<$Res,
        _$AccountBreakdownModelImpl>
    implements _$$AccountBreakdownModelImplCopyWith<$Res> {
  __$$AccountBreakdownModelImplCopyWithImpl(_$AccountBreakdownModelImpl _value,
      $Res Function(_$AccountBreakdownModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AccountBreakdownModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountCode = null,
    Object? accountName = null,
    Object? totalAmount = null,
  }) {
    return _then(_$AccountBreakdownModelImpl(
      accountCode: null == accountCode
          ? _value.accountCode
          : accountCode // ignore: cast_nullable_to_non_nullable
              as String,
      accountName: null == accountName
          ? _value.accountName
          : accountName // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountBreakdownModelImpl extends _AccountBreakdownModel {
  const _$AccountBreakdownModelImpl(
      {@JsonKey(name: 'account_code') required this.accountCode,
      @JsonKey(name: 'account_name') required this.accountName,
      @JsonKey(name: 'total_amount') required this.totalAmount})
      : super._();

  factory _$AccountBreakdownModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountBreakdownModelImplFromJson(json);

  @override
  @JsonKey(name: 'account_code')
  final String accountCode;
  @override
  @JsonKey(name: 'account_name')
  final String accountName;
  @override
  @JsonKey(name: 'total_amount')
  final double totalAmount;

  @override
  String toString() {
    return 'AccountBreakdownModel(accountCode: $accountCode, accountName: $accountName, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountBreakdownModelImpl &&
            (identical(other.accountCode, accountCode) ||
                other.accountCode == accountCode) &&
            (identical(other.accountName, accountName) ||
                other.accountName == accountName) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, accountCode, accountName, totalAmount);

  /// Create a copy of AccountBreakdownModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountBreakdownModelImplCopyWith<_$AccountBreakdownModelImpl>
      get copyWith => __$$AccountBreakdownModelImplCopyWithImpl<
          _$AccountBreakdownModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountBreakdownModelImplToJson(
      this,
    );
  }
}

abstract class _AccountBreakdownModel extends AccountBreakdownModel {
  const factory _AccountBreakdownModel(
          {@JsonKey(name: 'account_code') required final String accountCode,
          @JsonKey(name: 'account_name') required final String accountName,
          @JsonKey(name: 'total_amount') required final double totalAmount}) =
      _$AccountBreakdownModelImpl;
  const _AccountBreakdownModel._() : super._();

  factory _AccountBreakdownModel.fromJson(Map<String, dynamic> json) =
      _$AccountBreakdownModelImpl.fromJson;

  @override
  @JsonKey(name: 'account_code')
  String get accountCode;
  @override
  @JsonKey(name: 'account_name')
  String get accountName;
  @override
  @JsonKey(name: 'total_amount')
  double get totalAmount;

  /// Create a copy of AccountBreakdownModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AccountBreakdownModelImplCopyWith<_$AccountBreakdownModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

FinancialReportModel _$FinancialReportModelFromJson(Map<String, dynamic> json) {
  return _FinancialReportModel.fromJson(json);
}

/// @nodoc
mixin _$FinancialReportModel {
  FinancialPeriodModel get period => throw _privateConstructorUsedError;
  FinancialSummaryModel get summary => throw _privateConstructorUsedError;
  @JsonKey(name: 'income_breakdown')
  List<AccountBreakdownModel> get incomeBreakdown =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'expense_breakdown')
  List<AccountBreakdownModel> get expenseBreakdown =>
      throw _privateConstructorUsedError;

  /// Serializes this FinancialReportModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FinancialReportModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FinancialReportModelCopyWith<FinancialReportModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinancialReportModelCopyWith<$Res> {
  factory $FinancialReportModelCopyWith(FinancialReportModel value,
          $Res Function(FinancialReportModel) then) =
      _$FinancialReportModelCopyWithImpl<$Res, FinancialReportModel>;
  @useResult
  $Res call(
      {FinancialPeriodModel period,
      FinancialSummaryModel summary,
      @JsonKey(name: 'income_breakdown')
      List<AccountBreakdownModel> incomeBreakdown,
      @JsonKey(name: 'expense_breakdown')
      List<AccountBreakdownModel> expenseBreakdown});

  $FinancialPeriodModelCopyWith<$Res> get period;
  $FinancialSummaryModelCopyWith<$Res> get summary;
}

/// @nodoc
class _$FinancialReportModelCopyWithImpl<$Res,
        $Val extends FinancialReportModel>
    implements $FinancialReportModelCopyWith<$Res> {
  _$FinancialReportModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FinancialReportModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? summary = null,
    Object? incomeBreakdown = null,
    Object? expenseBreakdown = null,
  }) {
    return _then(_value.copyWith(
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as FinancialPeriodModel,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as FinancialSummaryModel,
      incomeBreakdown: null == incomeBreakdown
          ? _value.incomeBreakdown
          : incomeBreakdown // ignore: cast_nullable_to_non_nullable
              as List<AccountBreakdownModel>,
      expenseBreakdown: null == expenseBreakdown
          ? _value.expenseBreakdown
          : expenseBreakdown // ignore: cast_nullable_to_non_nullable
              as List<AccountBreakdownModel>,
    ) as $Val);
  }

  /// Create a copy of FinancialReportModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FinancialPeriodModelCopyWith<$Res> get period {
    return $FinancialPeriodModelCopyWith<$Res>(_value.period, (value) {
      return _then(_value.copyWith(period: value) as $Val);
    });
  }

  /// Create a copy of FinancialReportModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FinancialSummaryModelCopyWith<$Res> get summary {
    return $FinancialSummaryModelCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FinancialReportModelImplCopyWith<$Res>
    implements $FinancialReportModelCopyWith<$Res> {
  factory _$$FinancialReportModelImplCopyWith(_$FinancialReportModelImpl value,
          $Res Function(_$FinancialReportModelImpl) then) =
      __$$FinancialReportModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {FinancialPeriodModel period,
      FinancialSummaryModel summary,
      @JsonKey(name: 'income_breakdown')
      List<AccountBreakdownModel> incomeBreakdown,
      @JsonKey(name: 'expense_breakdown')
      List<AccountBreakdownModel> expenseBreakdown});

  @override
  $FinancialPeriodModelCopyWith<$Res> get period;
  @override
  $FinancialSummaryModelCopyWith<$Res> get summary;
}

/// @nodoc
class __$$FinancialReportModelImplCopyWithImpl<$Res>
    extends _$FinancialReportModelCopyWithImpl<$Res, _$FinancialReportModelImpl>
    implements _$$FinancialReportModelImplCopyWith<$Res> {
  __$$FinancialReportModelImplCopyWithImpl(_$FinancialReportModelImpl _value,
      $Res Function(_$FinancialReportModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of FinancialReportModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? period = null,
    Object? summary = null,
    Object? incomeBreakdown = null,
    Object? expenseBreakdown = null,
  }) {
    return _then(_$FinancialReportModelImpl(
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as FinancialPeriodModel,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as FinancialSummaryModel,
      incomeBreakdown: null == incomeBreakdown
          ? _value._incomeBreakdown
          : incomeBreakdown // ignore: cast_nullable_to_non_nullable
              as List<AccountBreakdownModel>,
      expenseBreakdown: null == expenseBreakdown
          ? _value._expenseBreakdown
          : expenseBreakdown // ignore: cast_nullable_to_non_nullable
              as List<AccountBreakdownModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FinancialReportModelImpl extends _FinancialReportModel {
  const _$FinancialReportModelImpl(
      {required this.period,
      required this.summary,
      @JsonKey(name: 'income_breakdown')
      required final List<AccountBreakdownModel> incomeBreakdown,
      @JsonKey(name: 'expense_breakdown')
      required final List<AccountBreakdownModel> expenseBreakdown})
      : _incomeBreakdown = incomeBreakdown,
        _expenseBreakdown = expenseBreakdown,
        super._();

  factory _$FinancialReportModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinancialReportModelImplFromJson(json);

  @override
  final FinancialPeriodModel period;
  @override
  final FinancialSummaryModel summary;
  final List<AccountBreakdownModel> _incomeBreakdown;
  @override
  @JsonKey(name: 'income_breakdown')
  List<AccountBreakdownModel> get incomeBreakdown {
    if (_incomeBreakdown is EqualUnmodifiableListView) return _incomeBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_incomeBreakdown);
  }

  final List<AccountBreakdownModel> _expenseBreakdown;
  @override
  @JsonKey(name: 'expense_breakdown')
  List<AccountBreakdownModel> get expenseBreakdown {
    if (_expenseBreakdown is EqualUnmodifiableListView)
      return _expenseBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_expenseBreakdown);
  }

  @override
  String toString() {
    return 'FinancialReportModel(period: $period, summary: $summary, incomeBreakdown: $incomeBreakdown, expenseBreakdown: $expenseBreakdown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinancialReportModelImpl &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality()
                .equals(other._incomeBreakdown, _incomeBreakdown) &&
            const DeepCollectionEquality()
                .equals(other._expenseBreakdown, _expenseBreakdown));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      period,
      summary,
      const DeepCollectionEquality().hash(_incomeBreakdown),
      const DeepCollectionEquality().hash(_expenseBreakdown));

  /// Create a copy of FinancialReportModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FinancialReportModelImplCopyWith<_$FinancialReportModelImpl>
      get copyWith =>
          __$$FinancialReportModelImplCopyWithImpl<_$FinancialReportModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FinancialReportModelImplToJson(
      this,
    );
  }
}

abstract class _FinancialReportModel extends FinancialReportModel {
  const factory _FinancialReportModel(
          {required final FinancialPeriodModel period,
          required final FinancialSummaryModel summary,
          @JsonKey(name: 'income_breakdown')
          required final List<AccountBreakdownModel> incomeBreakdown,
          @JsonKey(name: 'expense_breakdown')
          required final List<AccountBreakdownModel> expenseBreakdown}) =
      _$FinancialReportModelImpl;
  const _FinancialReportModel._() : super._();

  factory _FinancialReportModel.fromJson(Map<String, dynamic> json) =
      _$FinancialReportModelImpl.fromJson;

  @override
  FinancialPeriodModel get period;
  @override
  FinancialSummaryModel get summary;
  @override
  @JsonKey(name: 'income_breakdown')
  List<AccountBreakdownModel> get incomeBreakdown;
  @override
  @JsonKey(name: 'expense_breakdown')
  List<AccountBreakdownModel> get expenseBreakdown;

  /// Create a copy of FinancialReportModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FinancialReportModelImplCopyWith<_$FinancialReportModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
