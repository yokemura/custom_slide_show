import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';
import '../slide_item.dart';
import '../constants/slideshow_constants.dart';
import '../slideshow_repository.dart';
import '../providers/slideshow_repository_provider.dart';

// Provider定義
final slideshowSettingsProvider = ChangeNotifierProvider.autoDispose.family<SlideshowSettingsNotifier, SlideshowSettingsParams>((ref, params) {
  final repository = ref.read(slideshowRepositoryProvider);
  return SlideshowSettingsNotifier(
    repository: repository,
    currentSlideIndex: params.currentSlideIndex,
  );
});

// パラメータクラス
class SlideshowSettingsParams {
  final int currentSlideIndex;
  
  SlideshowSettingsParams({
    required this.currentSlideIndex,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlideshowSettingsParams &&
          runtimeType == other.runtimeType &&
          currentSlideIndex == other.currentSlideIndex;

  @override
  int get hashCode => Object.hash(currentSlideIndex, runtimeType);
}

// ChangeNotifierクラス定義
class SlideshowSettingsNotifier extends ChangeNotifier {
  List<SlideItem> _slideshowData = [];
  int _currentSlideIndex;
  final SlideshowRepository _repository;
  Timer? _debounceTimer;
  
  SlideshowSettingsNotifier({
    required SlideshowRepository repository,
    required int currentSlideIndex,
  }) : _repository = repository,
       _currentSlideIndex = currentSlideIndex {
    // コンストラクタで初期データを取得
    _slideshowData = List.from(_repository.getSlideshowData());
  }
  
  List<SlideItem> get slideshowData => _slideshowData;
  int get currentSlideIndex => _currentSlideIndex;
  
  // 現在のスライドを取得
  SlideItem? get currentSlide => 
      _slideshowData.isNotEmpty ? _slideshowData[_currentSlideIndex] : null;
  
  // スライドデータを更新（遅延通知）
  void updateSlideData({
    CaptionState? caption,
    double? duration,
    double? scale,
    double? xoffset,
    double? yoffset,
    PanDirection? pan,
  }) {
    if (currentSlide == null) return;
    
    final updatedSlide = currentSlide!.copyWith(
      caption: caption ?? currentSlide!.caption,        // nullの場合は既存値を保持
      duration: duration ?? currentSlide!.duration,     // nullの場合は既存値を保持
      scale: scale ?? currentSlide!.scale,             // nullの場合は既存値を保持
      xoffset: xoffset ?? currentSlide!.xoffset,       // nullの場合は既存値を保持
      yoffset: yoffset ?? currentSlide!.yoffset,       // nullの場合は既存値を保持
      pan: pan ?? currentSlide!.pan,                   // nullの場合は既存値を保持
    );

    _slideshowData = List<SlideItem>.from(_slideshowData);
    _slideshowData[_currentSlideIndex] = updatedSlide;
    
    // 既存のタイマーをキャンセル
    _debounceTimer?.cancel();
    
    // 300ms後に通知（入力中のリビルドを防ぐ）
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      notifyListeners();
    });
  }
  
  // 数値フィールドの値を適切に処理する関数
  double? parseNumericValue(String value, double invalidValue) {
    if (value.trim().isEmpty) {
      return null; // 空文字列は「意図的に設定しない」を意味する
    }
    
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return invalidValue; // 無効な値の場合は特殊な値を返す
    }
    
    return parsed;
  }
  
  // 現在の入力値のバリデーション（computed property）
  String? get validationError {
    if (currentSlide == null) return null;
    
    final List<String> invalidFields = [];
    
    if (currentSlide!.duration == SlideshowConstants.invalidDuration) {
      invalidFields.add('表示時間');
    }
    if (currentSlide!.scale == SlideshowConstants.invalidScale) {
      invalidFields.add('スケール');
    }
    if (currentSlide!.xoffset == SlideshowConstants.invalidOffset) {
      invalidFields.add('Xオフセット');
    }
    if (currentSlide!.yoffset == SlideshowConstants.invalidOffset) {
      invalidFields.add('Yオフセット');
    }
    
    if (invalidFields.isEmpty) {
      return null;
    }
    
    return '${invalidFields.join(', ')}に無効な値が入力されています';
  }
  
  // スライドを切り替え（notifyListenersあり）
  void selectSlide(int index) {
    if (index >= 0 && index < _slideshowData.length) {
      _currentSlideIndex = index;
      notifyListeners();
    }
  }
  
  // スライド切り替え時のバリデーションチェック（UI側で使用）
  bool canSelectSlide(int index) {
    if (index < 0 || index >= _slideshowData.length) {
      return false;
    }
    
    // 現在のスライドにバリデーションエラーがある場合は切り替えを許可しない
    if (validationError != null) {
      return false;
    }
    
    return true;
  }
  
  // Repositoryにデータを保存
  Future<void> saveToRepository() async {
    await _repository.saveSlideshowData(_slideshowData);
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
