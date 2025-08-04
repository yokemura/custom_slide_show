import 'package:custom_slide_show/slideshow_settings_screen_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'slide_item.dart';
import 'providers/slideshow_provider.dart';
import 'providers/animation_provider.dart';
import 'widgets/caption_display.dart';
import 'widgets/slideshow_controls_hooks.dart';

// 定数定義
const double _defaultSlideDuration = 8.0; // デフォルトのスライド表示時間（秒）
const double _fadeAnimationDuration = 1.0; // フェードアニメーション時間（秒）

class SlideshowViewHooks extends HookConsumerWidget {
  final String folderPath;
  final List<SlideItem> slideshowData;
  final int? startIndex;

  const SlideshowViewHooks({
    super.key,
    required this.folderPath,
    required this.slideshowData,
    this.startIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // プロバイダーの状態を取得
    final slideshowState = ref.watch(slideshowProvider);
    final slideshowNotifier = ref.read(slideshowProvider.notifier);

    // コントロール表示状態を管理
    final isControlsVisible = useState(true);
    final controlsTimer = useRef<Timer?>(null);
    
    // コントロール表示/非表示の関数
    final showControls = useCallback(() {
      isControlsVisible.value = true;
      controlsTimer.value?.cancel();
      controlsTimer.value = Timer(const Duration(seconds: 5), () {
        isControlsVisible.value = false;
      });
    }, []);
    

    
    // 画面タップ時の処理
    final handleTap = useCallback(() {
      showControls();
    }, [showControls]);
    
    // コンポーネントのクリーンアップ
    useEffect(() {
      return () {
        controlsTimer.value?.cancel();
      };
    }, []);

    // 初期化（初回のみ実行）
    useEffect(() {
      if (slideshowState.slideshowData.isEmpty && slideshowData.isNotEmpty) {
        Future.microtask(() {
          slideshowNotifier.initialize(slideshowData, startIndex: startIndex);
        });
      }
      return null;
    }, []);

    // アニメーションコントローラー
    final panController = useAnimationController(
      duration: Duration(
        milliseconds: ((slideshowState.currentSlide?.duration ?? _defaultSlideDuration) * 1000).round(),
      ),
    );
    final fadeController = useAnimationController(
      duration: Duration(
        milliseconds: (_fadeAnimationDuration * 1000).round(),
      ),
    );

    // アニメーション
    final panAnimation = useAnimation(
      Tween<Offset>(
        begin: slideshowState.currentSlide != null
            ? calculatePanOffset(slideshowState.currentSlide!)
            : Offset.zero,
        end: slideshowState.currentSlide != null
            ? calculatePanEndOffset(slideshowState.currentSlide!)
            : Offset.zero,
      ).animate(panController),
    );

    final fadeAnimation = useAnimation(
      Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(fadeController),
    );

    // スライド切り替えの処理
    useEffect(() {
      if (slideshowState.currentSlide != null && slideshowState.slideshowData.isNotEmpty) {
        // アニメーションコントローラーのdurationを更新
        final newDuration = Duration(
          milliseconds: ((slideshowState.currentSlide!.duration ?? _defaultSlideDuration) * 1000).round(),
        );
        panController.duration = newDuration;
        
        // パンアニメーション開始
        panController.forward().then((_) {
          // パンアニメーション完了後、次のスライドがある場合はフェードアニメーション開始
          if (slideshowState.hasNextSlide) {
            fadeController.forward().then((_) {
              // フェードアニメーション完了後、次のスライドに移動
              Future.microtask(() {
                slideshowNotifier.goToNextSlide();
                
                // アニメーションコントローラーをリセット
                panController.reset();
                fadeController.reset();
              });
            });
          }
        });
      }
      return null;
    }, [slideshowState.currentIndex, slideshowState.slideshowData.isNotEmpty]);

    // 画面サイズを取得
    final screenSize = MediaQuery.of(context).size;

    if (slideshowState.slideshowData.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            '表示する画像がありません',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: handleTap,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 現在のスライド
            if (slideshowState.currentSlide != null)
              Transform.translate(
                offset: Offset(
                  panAnimation.dx * screenSize.width,
                  panAnimation.dy * screenSize.height,
                ),
                child: _SlideLayer(
                  folderPath: folderPath,
                  slideData: slideshowState.currentSlide!,
                  screenSize: screenSize,
                ),
              ),

            // 次のスライド（重ねて表示）
            if (slideshowState.hasNextSlide && slideshowState.nextSlide != null)
              Opacity(
                opacity: fadeAnimation,
                child: Transform.translate(
                  offset: slideshowState.nextSlide!.pan != null
                      ? Offset(
                          calculatePanOffset(slideshowState.nextSlide!).dx * screenSize.width,
                          calculatePanOffset(slideshowState.nextSlide!).dy * screenSize.height,
                        )
                      : Offset.zero,
                  child: _SlideLayer(
                    folderPath: folderPath,
                    slideData: slideshowState.nextSlide!,
                    screenSize: screenSize,
                  ),
                ),
              ),

            // キャプション表示
            CaptionDisplay(
              captionState: slideshowState.currentSlide?.caption,
            ),

            // コントロールレイヤー（表示制御は親が管理）
            if (isControlsVisible.value)
              SlideshowControlsHooks(
                onBack: () => Navigator.of(context).pop(),
                onPreviousSlide: () {
                  if (slideshowState.hasPreviousSlide) {
                    slideshowNotifier.goToPreviousSlide();
                  }
                },
                onNextSlide: () {
                  if (slideshowState.hasNextSlide) {
                    slideshowNotifier.goToNextSlide();
                  }
                },
                onSettings: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SlideshowSettingsScreenHooks(
                        folderPath: folderPath,
                        slideshowData: slideshowData,
                        currentSlideIndex: slideshowState.currentIndex,
                      ),
                    ),
                  );

                  if (result != null && result is Map<String, dynamic>) {
                    final updatedSlideshowData = result['slideshowData'] as List<SlideItem>;
                    final currentSlideIndex = result['currentSlideIndex'] as int;
                    
                    // スライドショーデータを更新
                    slideshowNotifier.updateSlideshowData(updatedSlideshowData);
                    
                    // 現在のスライドインデックスに移動
                    slideshowNotifier.goToSlide(currentSlideIndex);
                  }
                },
                currentIndex: slideshowState.currentIndex + 1,
                totalSlides: slideshowState.totalSlides,
              ),
          ],
        ),
      ),
    );
  }
}

// スライドレイヤーウィジェット
class _SlideLayer extends StatelessWidget {
  final String folderPath;
  final SlideItem slideData;
  final Size screenSize;

  const _SlideLayer({
    required this.folderPath,
    required this.slideData,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final scale = slideData.scale ?? 1.0;
    final imagePath = '$folderPath/${slideData.image}';
    
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Stack(
        children: [
          // Background blurred image
          Positioned.fill(
            child: Center(
              child: Transform.scale(
                scale: scale,
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Main image
          Positioned.fill(
            child: Center(
              child: Transform.scale(
                scale: scale,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 