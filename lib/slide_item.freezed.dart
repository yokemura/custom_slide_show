// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slide_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CaptionState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) show,
    required TResult Function() hide,
    required TResult Function() keep,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? show,
    TResult? Function()? hide,
    TResult? Function()? keep,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? show,
    TResult Function()? hide,
    TResult Function()? keep,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CaptionShow value) show,
    required TResult Function(CaptionHide value) hide,
    required TResult Function(CaptionKeep value) keep,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CaptionShow value)? show,
    TResult? Function(CaptionHide value)? hide,
    TResult? Function(CaptionKeep value)? keep,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CaptionShow value)? show,
    TResult Function(CaptionHide value)? hide,
    TResult Function(CaptionKeep value)? keep,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaptionStateCopyWith<$Res> {
  factory $CaptionStateCopyWith(
          CaptionState value, $Res Function(CaptionState) then) =
      _$CaptionStateCopyWithImpl<$Res, CaptionState>;
}

/// @nodoc
class _$CaptionStateCopyWithImpl<$Res, $Val extends CaptionState>
    implements $CaptionStateCopyWith<$Res> {
  _$CaptionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CaptionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$CaptionShowImplCopyWith<$Res> {
  factory _$$CaptionShowImplCopyWith(
          _$CaptionShowImpl value, $Res Function(_$CaptionShowImpl) then) =
      __$$CaptionShowImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String text});
}

/// @nodoc
class __$$CaptionShowImplCopyWithImpl<$Res>
    extends _$CaptionStateCopyWithImpl<$Res, _$CaptionShowImpl>
    implements _$$CaptionShowImplCopyWith<$Res> {
  __$$CaptionShowImplCopyWithImpl(
      _$CaptionShowImpl _value, $Res Function(_$CaptionShowImpl) _then)
      : super(_value, _then);

  /// Create a copy of CaptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
  }) {
    return _then(_$CaptionShowImpl(
      null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CaptionShowImpl implements CaptionShow {
  const _$CaptionShowImpl(this.text);

  @override
  final String text;

  @override
  String toString() {
    return 'CaptionState.show(text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaptionShowImpl &&
            (identical(other.text, text) || other.text == text));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text);

  /// Create a copy of CaptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CaptionShowImplCopyWith<_$CaptionShowImpl> get copyWith =>
      __$$CaptionShowImplCopyWithImpl<_$CaptionShowImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) show,
    required TResult Function() hide,
    required TResult Function() keep,
  }) {
    return show(text);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? show,
    TResult? Function()? hide,
    TResult? Function()? keep,
  }) {
    return show?.call(text);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? show,
    TResult Function()? hide,
    TResult Function()? keep,
    required TResult orElse(),
  }) {
    if (show != null) {
      return show(text);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CaptionShow value) show,
    required TResult Function(CaptionHide value) hide,
    required TResult Function(CaptionKeep value) keep,
  }) {
    return show(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CaptionShow value)? show,
    TResult? Function(CaptionHide value)? hide,
    TResult? Function(CaptionKeep value)? keep,
  }) {
    return show?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CaptionShow value)? show,
    TResult Function(CaptionHide value)? hide,
    TResult Function(CaptionKeep value)? keep,
    required TResult orElse(),
  }) {
    if (show != null) {
      return show(this);
    }
    return orElse();
  }
}

abstract class CaptionShow implements CaptionState {
  const factory CaptionShow(final String text) = _$CaptionShowImpl;

  String get text;

  /// Create a copy of CaptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CaptionShowImplCopyWith<_$CaptionShowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CaptionHideImplCopyWith<$Res> {
  factory _$$CaptionHideImplCopyWith(
          _$CaptionHideImpl value, $Res Function(_$CaptionHideImpl) then) =
      __$$CaptionHideImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CaptionHideImplCopyWithImpl<$Res>
    extends _$CaptionStateCopyWithImpl<$Res, _$CaptionHideImpl>
    implements _$$CaptionHideImplCopyWith<$Res> {
  __$$CaptionHideImplCopyWithImpl(
      _$CaptionHideImpl _value, $Res Function(_$CaptionHideImpl) _then)
      : super(_value, _then);

  /// Create a copy of CaptionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CaptionHideImpl implements CaptionHide {
  const _$CaptionHideImpl();

  @override
  String toString() {
    return 'CaptionState.hide()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CaptionHideImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) show,
    required TResult Function() hide,
    required TResult Function() keep,
  }) {
    return hide();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? show,
    TResult? Function()? hide,
    TResult? Function()? keep,
  }) {
    return hide?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? show,
    TResult Function()? hide,
    TResult Function()? keep,
    required TResult orElse(),
  }) {
    if (hide != null) {
      return hide();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CaptionShow value) show,
    required TResult Function(CaptionHide value) hide,
    required TResult Function(CaptionKeep value) keep,
  }) {
    return hide(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CaptionShow value)? show,
    TResult? Function(CaptionHide value)? hide,
    TResult? Function(CaptionKeep value)? keep,
  }) {
    return hide?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CaptionShow value)? show,
    TResult Function(CaptionHide value)? hide,
    TResult Function(CaptionKeep value)? keep,
    required TResult orElse(),
  }) {
    if (hide != null) {
      return hide(this);
    }
    return orElse();
  }
}

abstract class CaptionHide implements CaptionState {
  const factory CaptionHide() = _$CaptionHideImpl;
}

/// @nodoc
abstract class _$$CaptionKeepImplCopyWith<$Res> {
  factory _$$CaptionKeepImplCopyWith(
          _$CaptionKeepImpl value, $Res Function(_$CaptionKeepImpl) then) =
      __$$CaptionKeepImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CaptionKeepImplCopyWithImpl<$Res>
    extends _$CaptionStateCopyWithImpl<$Res, _$CaptionKeepImpl>
    implements _$$CaptionKeepImplCopyWith<$Res> {
  __$$CaptionKeepImplCopyWithImpl(
      _$CaptionKeepImpl _value, $Res Function(_$CaptionKeepImpl) _then)
      : super(_value, _then);

  /// Create a copy of CaptionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CaptionKeepImpl implements CaptionKeep {
  const _$CaptionKeepImpl();

  @override
  String toString() {
    return 'CaptionState.keep()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CaptionKeepImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) show,
    required TResult Function() hide,
    required TResult Function() keep,
  }) {
    return keep();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? show,
    TResult? Function()? hide,
    TResult? Function()? keep,
  }) {
    return keep?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? show,
    TResult Function()? hide,
    TResult Function()? keep,
    required TResult orElse(),
  }) {
    if (keep != null) {
      return keep();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CaptionShow value) show,
    required TResult Function(CaptionHide value) hide,
    required TResult Function(CaptionKeep value) keep,
  }) {
    return keep(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CaptionShow value)? show,
    TResult? Function(CaptionHide value)? hide,
    TResult? Function(CaptionKeep value)? keep,
  }) {
    return keep?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CaptionShow value)? show,
    TResult Function(CaptionHide value)? hide,
    TResult Function(CaptionKeep value)? keep,
    required TResult orElse(),
  }) {
    if (keep != null) {
      return keep(this);
    }
    return orElse();
  }
}

abstract class CaptionKeep implements CaptionState {
  const factory CaptionKeep() = _$CaptionKeepImpl;
}

/// @nodoc
mixin _$SlideItem {
  String get image => throw _privateConstructorUsedError;
  CaptionState? get caption => throw _privateConstructorUsedError; // 新しいunion型
  PanDirection? get pan => throw _privateConstructorUsedError;
  double? get duration => throw _privateConstructorUsedError;
  double? get scale => throw _privateConstructorUsedError;
  double? get xoffset => throw _privateConstructorUsedError;
  double? get yoffset => throw _privateConstructorUsedError;

  /// Create a copy of SlideItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SlideItemCopyWith<SlideItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SlideItemCopyWith<$Res> {
  factory $SlideItemCopyWith(SlideItem value, $Res Function(SlideItem) then) =
      _$SlideItemCopyWithImpl<$Res, SlideItem>;
  @useResult
  $Res call(
      {String image,
      CaptionState? caption,
      PanDirection? pan,
      double? duration,
      double? scale,
      double? xoffset,
      double? yoffset});

  $CaptionStateCopyWith<$Res>? get caption;
}

/// @nodoc
class _$SlideItemCopyWithImpl<$Res, $Val extends SlideItem>
    implements $SlideItemCopyWith<$Res> {
  _$SlideItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SlideItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? image = null,
    Object? caption = freezed,
    Object? pan = freezed,
    Object? duration = freezed,
    Object? scale = freezed,
    Object? xoffset = freezed,
    Object? yoffset = freezed,
  }) {
    return _then(_value.copyWith(
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as CaptionState?,
      pan: freezed == pan
          ? _value.pan
          : pan // ignore: cast_nullable_to_non_nullable
              as PanDirection?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as double?,
      scale: freezed == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as double?,
      xoffset: freezed == xoffset
          ? _value.xoffset
          : xoffset // ignore: cast_nullable_to_non_nullable
              as double?,
      yoffset: freezed == yoffset
          ? _value.yoffset
          : yoffset // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }

  /// Create a copy of SlideItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CaptionStateCopyWith<$Res>? get caption {
    if (_value.caption == null) {
      return null;
    }

    return $CaptionStateCopyWith<$Res>(_value.caption!, (value) {
      return _then(_value.copyWith(caption: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SlideItemImplCopyWith<$Res>
    implements $SlideItemCopyWith<$Res> {
  factory _$$SlideItemImplCopyWith(
          _$SlideItemImpl value, $Res Function(_$SlideItemImpl) then) =
      __$$SlideItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String image,
      CaptionState? caption,
      PanDirection? pan,
      double? duration,
      double? scale,
      double? xoffset,
      double? yoffset});

  @override
  $CaptionStateCopyWith<$Res>? get caption;
}

/// @nodoc
class __$$SlideItemImplCopyWithImpl<$Res>
    extends _$SlideItemCopyWithImpl<$Res, _$SlideItemImpl>
    implements _$$SlideItemImplCopyWith<$Res> {
  __$$SlideItemImplCopyWithImpl(
      _$SlideItemImpl _value, $Res Function(_$SlideItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of SlideItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? image = null,
    Object? caption = freezed,
    Object? pan = freezed,
    Object? duration = freezed,
    Object? scale = freezed,
    Object? xoffset = freezed,
    Object? yoffset = freezed,
  }) {
    return _then(_$SlideItemImpl(
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as CaptionState?,
      pan: freezed == pan
          ? _value.pan
          : pan // ignore: cast_nullable_to_non_nullable
              as PanDirection?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as double?,
      scale: freezed == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as double?,
      xoffset: freezed == xoffset
          ? _value.xoffset
          : xoffset // ignore: cast_nullable_to_non_nullable
              as double?,
      yoffset: freezed == yoffset
          ? _value.yoffset
          : yoffset // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$SlideItemImpl implements _SlideItem {
  const _$SlideItemImpl(
      {required this.image,
      this.caption,
      this.pan,
      this.duration,
      this.scale,
      this.xoffset,
      this.yoffset});

  @override
  final String image;
  @override
  final CaptionState? caption;
// 新しいunion型
  @override
  final PanDirection? pan;
  @override
  final double? duration;
  @override
  final double? scale;
  @override
  final double? xoffset;
  @override
  final double? yoffset;

  @override
  String toString() {
    return 'SlideItem(image: $image, caption: $caption, pan: $pan, duration: $duration, scale: $scale, xoffset: $xoffset, yoffset: $yoffset)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SlideItemImpl &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.pan, pan) || other.pan == pan) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.scale, scale) || other.scale == scale) &&
            (identical(other.xoffset, xoffset) || other.xoffset == xoffset) &&
            (identical(other.yoffset, yoffset) || other.yoffset == yoffset));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, image, caption, pan, duration, scale, xoffset, yoffset);

  /// Create a copy of SlideItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SlideItemImplCopyWith<_$SlideItemImpl> get copyWith =>
      __$$SlideItemImplCopyWithImpl<_$SlideItemImpl>(this, _$identity);
}

abstract class _SlideItem implements SlideItem {
  const factory _SlideItem(
      {required final String image,
      final CaptionState? caption,
      final PanDirection? pan,
      final double? duration,
      final double? scale,
      final double? xoffset,
      final double? yoffset}) = _$SlideItemImpl;

  @override
  String get image;
  @override
  CaptionState? get caption; // 新しいunion型
  @override
  PanDirection? get pan;
  @override
  double? get duration;
  @override
  double? get scale;
  @override
  double? get xoffset;
  @override
  double? get yoffset;

  /// Create a copy of SlideItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SlideItemImplCopyWith<_$SlideItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
