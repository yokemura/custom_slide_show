import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'slide_item.dart';
import 'animations/slideshow_animations.dart';
import 'controllers/fullscreen_controller.dart';
import 'controllers/keyboard_controller.dart';
import 'controllers/slideshow_controller.dart';
import 'widgets/slide_layer.dart';
import 'widgets/slideshow_controls.dart';
import 'widgets/caption_display.dart';
import 'slideshow_settings_screen.dart';

class SlideshowView extends StatefulWidget {
  final String folderPath;
  final List<SlideItem> slideshowData;
  final int? startIndex;

  const SlideshowView({
    super.key,
    required this.folderPath,
    required this.slideshowData,
    this.startIndex,
  });

  @override
  State<SlideshowView> createState() => _SlideshowViewState();
}

class _SlideshowViewState extends State<SlideshowView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late SlideshowAnimations _animations;
  late FullscreenController _fullscreenController;
  late KeyboardController _keyboardController;
  late SlideshowController _slideshowController;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animations = SlideshowAnimations(this);

    // Initialize fullscreen controller
    _fullscreenController = FullscreenController(
      onStateChanged: () => setState(() {}),
    );

    // Initialize slideshow controller
    _slideshowController = SlideshowController(
      slideshowData: widget.slideshowData,
      animations: _animations,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
      onCaptionChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    // Initialize keyboard controller
    _keyboardController = KeyboardController(
      onToggleFullScreen: _fullscreenController.toggleFullScreen,
      onExitFullScreen: _fullscreenController.exitFullScreen,
      onPreviousSlide: _slideshowController.goToPreviousSlide,
      onNextSlide: _slideshowController.goToNextSlide,
      onTogglePlayPause: _slideshowController.togglePlayPause,
      onOpenSettings: _openSettings,
    );

    // Initialize slideshow
    _slideshowController.initialize(widget.startIndex);

    // Set up keyboard shortcuts
    _keyboardController.setupKeyboardShortcuts();

    // フルスクリーン状態の監視を開始
    WidgetsBinding.instance.addObserver(this);

    // Start slideshow
    _slideshowController.runSlideshow(widget.startIndex ?? 0);
  }

  @override
  void dispose() {
    _animations.dispose();
    _keyboardController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _openSettings() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SlideshowSettingsScreen(
          folderPath: widget.folderPath,
          slideshowData: widget.slideshowData,
          currentSlideIndex: _slideshowController.currentIndex,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final updatedSlideshowData = result['slideshowData'] as List<SlideItem>;
      final currentSlideIndex = result['currentSlideIndex'] as int;
      
      // スライドショーコントローラーを更新
      _slideshowController.updateSlideshowData(updatedSlideshowData);
      
      // 現在のスライドインデックスに移動
      _slideshowController.goToSlide(currentSlideIndex);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _fullscreenController.handleAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slideshowData.isEmpty) {
      return const Center(
        child: Text('No images to display'),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          if (_fullscreenController.isFullScreen) {
            _fullscreenController.exitFullScreen();
          }
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _animations.fadeController, 
            _animations.panController
          ]),
          builder: (context, child) {
            // Calculate animation values
            final currentOpacity = _slideshowController.isTransitioning 
                ? _animations.fadeAnimation.value 
                : 1.0;
            final previousOpacity = _slideshowController.isTransitioning 
                ? 1.0 - _animations.fadeAnimation.value 
                : 0.0;

            return Stack(
              children: [
                // Previous image (fading out)
                if (_slideshowController.isTransitioning) 
                  Opacity(
                    opacity: previousOpacity,
                    child: SlideLayer(
                      folderPath: widget.folderPath,
                      slideData: _slideshowController.previousSlideData,
                      isTransitioning: _slideshowController.isTransitioning,
                      isCurrentSlide: false,
                      animations: _animations,
                    ),
                  ),

                // Current image (fading in)
                Opacity(
                  opacity: currentOpacity,
                  child: SlideLayer(
                    folderPath: widget.folderPath,
                    slideData: _slideshowController.currentSlide,
                    isTransitioning: _slideshowController.isTransitioning,
                    isCurrentSlide: true,
                    animations: _animations,
                  ),
                ),

                // キャプション表示
                if (_slideshowController.showCaption && 
                    _slideshowController.currentCaption != null) 
                  CaptionDisplay(
                    caption: _slideshowController.currentCaption!,
                  ),

                // 一時停止中のオーバーレイ
                if (_slideshowController.isPaused)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pause_circle_filled,
                            color: Colors.white,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '一時停止中',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'スペースキーまたは再生ボタンで再開',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Controls overlay
                if (!_fullscreenController.isFullScreen) 
                  SlideshowControls(
                    onBack: () => Navigator.of(context).pop(),
                    onToggleFullScreen: _fullscreenController.toggleFullScreen,
                    isFullScreen: _fullscreenController.isFullScreen,
                    currentIndex: _slideshowController.currentIndex,
                    totalSlides: _slideshowController.totalSlides,
                    currentSlide: _slideshowController.currentSlide,
                    isPaused: _slideshowController.isPaused,
                    onTogglePlayPause: _slideshowController.togglePlayPause,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
