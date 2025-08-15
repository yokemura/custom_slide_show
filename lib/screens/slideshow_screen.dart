import 'package:custom_slide_show/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';
import '../slide_item.dart';
import '../widgets/caption_display.dart';
import '../widgets/slideshow_controls_hooks.dart';
import '../constants/slideshow_constants.dart';
import '../utils/slide_utils.dart';
import '../widgets/slide_layer/slide_layer.dart';
import '../providers/slideshow_screen_viewmodel_provider.dart';

// 定数定義はSlideshowConstantsクラスに移動済み

class SlideshowScreen extends HookConsumerWidget {
  final String folderPath;
  final int? startIndex;

  const SlideshowScreen({
    super.key,
    required this.folderPath,
    this.startIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModelをProviderから取得
    final viewModel = ref.watch(slideshowScreenViewModelProvider(folderPath));

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
      if (viewModel.slideshowData.isEmpty) {
        Future.microtask(() {
          viewModel.initialize(startIndex: startIndex);
        });
      }
      return null;
    }, []);

    // アニメーションコントローラー
    final panController = useAnimationController(
      duration: Duration(
        milliseconds: ((viewModel.currentSlide?.duration ??
                    SlideshowConstants.defaultSlideDuration) *
                1000)
            .round(),
      ),
    );
    final fadeController = useAnimationController(
      duration: Duration(
        milliseconds: (SlideshowConstants.fadeAnimationDuration * 1000).round(),
      ),
    );

    // アニメーション
    final panAnimation = useAnimation(
      Tween<Offset>(
        begin: viewModel.currentSlide != null
            ? SlideUtils.calculatePanOffset(viewModel.currentSlide!)
            : Offset.zero,
        end: viewModel.currentSlide != null
            ? SlideUtils.calculatePanEndOffset(viewModel.currentSlide!)
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
      if (viewModel.currentSlide != null &&
          viewModel.slideshowData.isNotEmpty) {
        // アニメーションコントローラーのdurationを更新
        final newDuration = Duration(
          milliseconds: ((viewModel.currentSlide!.duration ??
                      SlideshowConstants.defaultSlideDuration) *
                  1000)
              .round(),
        );
        panController.duration = newDuration;

        // パンアニメーション開始
        panController.forward().then((_) {
          // パンアニメーション完了後、次のスライドがある場合はフェードアニメーション開始
          if (viewModel.hasNextSlide) {
            fadeController.forward().then((_) {
              // フェードアニメーション完了後、次のスライドに移動
              Future.microtask(() {
                viewModel.goToNextSlide();

                // アニメーションコントローラーをリセット
                panController.reset();
                fadeController.reset();
              });
            });
          }
        });
      }
      return null;
    }, [viewModel.currentSlideIndex, viewModel.slideshowData.isNotEmpty]);

    // ListenableBuilderでViewModelの状態を監視
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        // 画面サイズを取得
        final screenSize = MediaQuery.of(context).size;

        if (viewModel.slideshowData.isEmpty) {
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
                if (viewModel.currentSlide != null)
                  Transform.translate(
                    offset: Offset(
                      panAnimation.dx * screenSize.width,
                      panAnimation.dy * screenSize.height,
                    ),
                    child: SlideLayer(
                      folderPath: folderPath,
                      slideData: viewModel.currentSlide!,
                      screenSize: screenSize,
                    ),
                  ),

                // 次のスライド（重ねて表示）
                if (viewModel.hasNextSlide && viewModel.nextSlide != null)
                  Opacity(
                    opacity: fadeAnimation,
                    child: Transform.translate(
                      offset: viewModel.nextSlide!.pan != null
                          ? Offset(
                              SlideUtils.calculatePanOffset(
                                          viewModel.nextSlide!)
                                      .dx *
                                  screenSize.width,
                              SlideUtils.calculatePanOffset(
                                          viewModel.nextSlide!)
                                      .dy *
                                  screenSize.height,
                            )
                          : Offset.zero,
                      child: SlideLayer(
                        folderPath: folderPath,
                        slideData: viewModel.nextSlide!,
                        screenSize: screenSize,
                      ),
                    ),
                  ),

                // キャプション表示
                CaptionDisplay(
                  caption: viewModel.currentCaption,
                ),

                // コントロールレイヤー（表示制御は親が管理）
                if (isControlsVisible.value)
                  SlideshowControlsHooks(
                    onBack: () => Navigator.of(context).pop(),
                    onPreviousSlide: () {
                      if (viewModel.hasPreviousSlide) {
                        viewModel.goToPreviousSlide();
                      }
                    },
                    onNextSlide: () {
                      if (viewModel.hasNextSlide) {
                        viewModel.goToNextSlide();
                      }
                    },
                    onSettings: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingScreen(
                            currentSlideIndex: viewModel.currentSlideIndex,
                          ),
                        ),
                      );

                      if (result != null && result is Map<String, dynamic>) {
                        final updatedSlideshowData =
                            result['slideshowData'] as List<SlideItem>;
                        final currentSlideIndex =
                            result['currentSlideIndex'] as int;

                        // スライドショーデータを更新
                        viewModel.updateSlideshowData(updatedSlideshowData);

                        // 現在のスライドインデックスに移動
                        viewModel.goToSlide(currentSlideIndex);
                      }
                    },
                    currentIndex: viewModel.currentSlideIndex + 1,
                    totalSlides: viewModel.totalSlides,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
