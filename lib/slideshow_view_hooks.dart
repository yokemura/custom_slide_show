import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:ui' as ui;
import 'slide_item.dart';
import 'providers/slideshow_provider.dart';
import 'providers/animation_provider.dart';
import 'widgets/caption_display.dart';

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

    return Scaffold(
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
          if (slideshowState.currentCaption.isNotEmpty)
            CaptionDisplay(
              caption: slideshowState.currentCaption,
            ),

          // スライド情報表示
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${slideshowState.currentIndex + 1} / ${slideshowState.totalSlides}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
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