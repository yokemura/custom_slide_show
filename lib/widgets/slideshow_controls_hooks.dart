import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';
import '../providers/slideshow_provider.dart';

class SlideshowControlsHooks extends HookConsumerWidget {
  final VoidCallback onBack;
  final VoidCallback onPreviousSlide;
  final VoidCallback onNextSlide;
  final int currentIndex;
  final int totalSlides;

  const SlideshowControlsHooks({
    super.key,
    required this.onBack,
    required this.onPreviousSlide,
    required this.onNextSlide,
    required this.currentIndex,
    required this.totalSlides,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 表示状態を管理
    final isVisible = useState(true);
    
    // タイマーを管理
    final timer = useRef<Timer?>(null);
    
    // 5秒後に非表示にする関数
    final hideControls = useCallback(() {
      isVisible.value = false;
    }, []);
    
    // 表示状態をリセットする関数
    final showControls = useCallback(() {
      isVisible.value = true;
      
      // 既存のタイマーをキャンセル
      timer.value?.cancel();
      
      // 5秒後に非表示にするタイマーを開始
      timer.value = Timer(const Duration(seconds: 5), hideControls);
    }, [hideControls]);
    
    // 画面表示時とタップ時にコントロールを表示
    useEffect(() {
      showControls();
      return null;
    }, [currentIndex]); // スライドが変わった時も表示
    
    // コンポーネントのクリーンアップ
    useEffect(() {
      return () {
        timer.value?.cancel();
      };
    }, []);
    
    // 画面タップ時の処理
    final handleTap = useCallback(() {
      showControls();
    }, [showControls]);
    
    if (!isVisible.value) {
      return GestureDetector(
        onTap: handleTap,
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    
    return GestureDetector(
      onTap: handleTap,
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // 上部のコントロール
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 戻るボタン
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        shape: const CircleBorder(),
                      ),
                    ),
                    
                    // スライド番号表示
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$currentIndex / $totalSlides',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    // プレースホルダー（左右のバランスを取るため）
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            
            // 下部のコントロール
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 前のスライドボタン
                    IconButton(
                      onPressed: onPreviousSlide,
                      icon: const Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: 32,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        shape: const CircleBorder(),
                      ),
                    ),
                    
                    // 次のスライドボタン
                    IconButton(
                      onPressed: onNextSlide,
                      icon: const Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 32,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 