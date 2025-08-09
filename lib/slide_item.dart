import 'package:freezed_annotation/freezed_annotation.dart';

part 'slide_item.freezed.dart';

enum PanDirection {
  up,
  down,
  left,
  right,
}

// キャプションの状態を表現するunion
@freezed
class CaptionState with _$CaptionState {
  const factory CaptionState.show(String text) = CaptionShow;
  const factory CaptionState.hide() = CaptionHide;
  const factory CaptionState.keep() = CaptionKeep;
}

@freezed
class SlideItem with _$SlideItem {
  const factory SlideItem({
    required String image,
    CaptionState? caption, // 新しいunion型
    PanDirection? pan,
    double? duration,
    double? scale,
    double? xoffset,
    double? yoffset,
  }) = _SlideItem;

  // カスタムJSONデコーダー
  factory SlideItem.fromJson(Map<String, dynamic> json) {
    // 従来のtextフィールドをcaptionに変換
    final text = json['text'] as String?;
    CaptionState? caption;
    
    if (text == null) {
      caption = const CaptionState.keep();
    } else if (text.isEmpty) {
      caption = const CaptionState.hide();
    } else {
      caption = CaptionState.show(text);
    }

    return SlideItem(
      image: json['image'] as String,
      caption: caption,
      pan: json['pan'] != null ? PanDirection.values.firstWhere(
        (e) => e.name == json['pan'],
      ) : null,
      duration: json['duration'] != null ? (json['duration'] is int ? (json['duration'] as int).toDouble() : json['duration'] as double) : null,
      scale: json['scale'] != null ? (json['scale'] is int ? (json['scale'] as int).toDouble() : json['scale'] as double) : null,
      xoffset: json['xoffset'] != null ? (json['xoffset'] is int ? (json['xoffset'] as int).toDouble() : json['xoffset'] as double) : null,
      yoffset: json['yoffset'] != null ? (json['yoffset'] is int ? (json['yoffset'] as int).toDouble() : json['yoffset'] as double) : null,
    );
  }
}

// ファイル保存用のJSON形式の拡張メソッド
extension SlideItemExtension on SlideItem {
  Map<String, dynamic> toFileJson() {
    String? text;
    if (caption != null) {
      text = caption!.when(
        show: (text) => text,
        hide: () => '',
        keep: () => null,
      );
    }

    return {
      'image': image,
      if (text != null) 'text': text,
      if (pan != null) 'pan': pan!.name,
      if (duration != null) 'duration': duration,
      if (scale != null) 'scale': scale,
      if (xoffset != null) 'xoffset': xoffset,
      if (yoffset != null) 'yoffset': yoffset,
    };
  }
} 