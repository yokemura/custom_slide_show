import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:ui' as ui;
import 'tategaki.dart';
import 'slide_item.dart';

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
  int currentIndex = 0;
  int previousIndex = 0;
  bool isFullScreen = false;
  bool isTransitioning = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late AnimationController _panController;
  Animation<Offset>? _panAnimation;

  // キャプション関連の状態
  String? currentCaption;
  bool showCaption = false;

  // Display settings
  static const int displayDuration = 8; // seconds
  static const int crossfadeDuration = 2; // seconds
  
  // Keyboard handler reference
  bool _keyboardHandler(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (HardwareKeyboard.instance.isMetaPressed &&
          event.logicalKey == LogicalKeyboardKey.keyF) {
        _toggleFullScreen();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _exitFullScreen();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _previousSlide();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _nextSlide();
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        _togglePlayPause();
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: crossfadeDuration * 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: crossfadeDuration * 1000),
      vsync: this,
    );

    _panController = AnimationController(
      duration: const Duration(seconds: displayDuration),
      vsync: this,
    );

    // 指定されたインデックスから開始する場合
    if (widget.startIndex != null && 
        widget.startIndex! >= 0 && 
        widget.startIndex! < widget.slideshowData.length) {
      currentIndex = widget.startIndex!;
    }

    // 初期キャプションを設定
    _updateCaption();

    // Start slideshow
    _runSlideshow(widget.startIndex ?? 0);

    // Set up keyboard shortcuts
    _setupKeyboardShortcuts();

    // フルスクリーン状態の監視を開始
    _setupFullScreenListener();
  }

  @override
  void dispose() {
    _fadeController.stop();
    _slideController.stop();
    _panController.stop();
    _fadeController.dispose();
    _slideController.dispose();
    _panController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    HardwareKeyboard.instance.removeHandler(_keyboardHandler);
    super.dispose();
  }

  void _setupKeyboardShortcuts() {
    HardwareKeyboard.instance.addHandler(_keyboardHandler);
  }

  void _setupFullScreenListener() {
    // フルスクリーン状態の変更を監視
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // アプリが非アクティブになった場合、フルスクリーンを解除
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (isFullScreen) {
        setState(() {
          isFullScreen = false;
        });
      }
    }
  }

  Future<void> _toggleFullScreen() async {
    if (isFullScreen) {
      await _exitFullScreen();
    } else {
      await _enterFullScreen();
    }
  }

  Future<void> _enterFullScreen() async {
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      setState(() {
        isFullScreen = true;
      });
    } catch (e) {
      // Failed to enter fullscreen: $e
    }
  }

  Future<void> _exitFullScreen() async {
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, 
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
      setState(() {
        isFullScreen = false;
      });
    } catch (e) {
      // Failed to exit fullscreen: $e
    }
  }

  void _previousSlide() {
    if (currentIndex > 0) {
      _runSlideshow(currentIndex - 1);
    }
  }

  void _nextSlide() {
    if (currentIndex < widget.slideshowData.length - 1) {
      _runSlideshow(currentIndex + 1);
    }
  }

  void _togglePlayPause() {
    // TODO: Implement play/pause functionality
  }

  /// スライド表示のアニメーションを指示し、その完了を待つメソッド
  void _runSlideshow([int? slideIndex]) async {
    if (widget.slideshowData.isEmpty) return;

    // インデックスが指定されていない場合は現在のインデックスを使用
    final targetIndex = slideIndex ?? currentIndex;
    
    // 1. 初期状態を確実に設定（最初の呼び出し時のみ）
    if (isTransitioning) {
      setState(() {
        isTransitioning = false;
      });
    }

    // 2. 現在のスライドのパンアニメーション開始
    _startPanAnimation();

    // 3. スライド表示時間待機
    final currentDuration = widget.slideshowData[targetIndex].duration ?? displayDuration;
    await Future.delayed(Duration(seconds: (currentDuration - crossfadeDuration).round()));
    
    if (mounted) {
      final nextIndex = targetIndex + 1;
      
      // 最後のスライドの場合は最初に戻る（ループ）
      if (nextIndex >= widget.slideshowData.length) {
        _runSlideshow(0); // 最初のスライドから再開
        return;
      }

      // 4. トランジション開始（State更新）
      setState(() {
        previousIndex = targetIndex;
        currentIndex = nextIndex;
        isTransitioning = true;
      });

      // 5. キャプション更新
      _updateCaption();

      // 6. フェードアニメーション指示・完了待機
      await _executeFadeAnimation();

      // 7. トランジション完了（State更新）
      if (mounted) {
        setState(() {
          isTransitioning = false;
        });

        // 8. 次のスライドのパンアニメーション開始
        _startPanAnimation();

        // 9. 再帰的に次のスライドをスケジュール
        _runSlideshow(nextIndex);
      }
    }
  }

  void _startPanAnimation() {
    final slideData = widget.slideshowData[currentIndex];
    final scale = slideData.scale ?? 1.0;
    final pan = slideData.pan;
    
    // scaleが1より大きく、かつpanパラメータがある場合のみパンアニメーションを開始
    if (scale > 1.0 && pan != null) {
      final currentDuration = slideData.duration ?? displayDuration;
      
      // パンコントローラーの時間を現在のスライドの表示時間に設定
      _panController.duration = Duration(seconds: currentDuration.round());
      
      // パン方向に応じてアニメーションを設定
      // scale値に基づいてパン量を計算（画像の端から端まで表示されるように）
      final panAmount = (scale - 1.0); // scale=1.2なら0.2, scale=1.5なら0.5
      
      Offset beginOffset;
      Offset endOffset;
      
      switch (pan) {
        case PanDirection.up:
          // 開始時：画像の下端が画面の下端に一致
          // 終了時：画像の上端が画面の上端に一致
          beginOffset = Offset(0.0, -panAmount * 0.5);
          endOffset = Offset(0.0, panAmount * 0.5);
          break;
        case PanDirection.down:
          // 開始時：画像の上端が画面の上端に一致
          // 終了時：画像の下端が画面の下端に一致
          beginOffset = Offset(0.0, panAmount * 0.5);
          endOffset = Offset(0.0, -panAmount * 0.5);
          break;
        case PanDirection.left:
          // 開始時：画像の右端が画面の右端に一致
          // 終了時：画像の左端が画面の左端に一致
          beginOffset = Offset(-panAmount * 0.5, 0.0);
          endOffset = Offset(panAmount * 0.5, 0.0);
          break;
        case PanDirection.right:
          // 開始時：画像の左端が画面の左端に一致
          // 終了時：画像の右端が画面の右端に一致
          beginOffset = Offset(panAmount * 0.5, 0.0);
          endOffset = Offset(-panAmount * 0.5, 0.0);
          break;
      }
      
      _panAnimation = Tween<Offset>(
        begin: beginOffset,
        end: endOffset,
      ).animate(CurvedAnimation(
        parent: _panController,
        curve: Curves.easeInOut,
      ));
      
      _panController.reset();
      _panController.forward();
    } else {
      // パンアニメーションが不要な場合はnullにリセット
      _panAnimation = null;
    }
  }

  // キャプション更新メソッド
  void _updateCaption() {
    if (currentIndex < widget.slideshowData.length) {
      final slideData = widget.slideshowData[currentIndex];
      final text = slideData.text;
      
      if (text == null) {
        // textプロパティが存在しない場合は表示を継続
        // 何もしない（現在のキャプションを維持）
      } else if (text.isEmpty) {
        // 空文字列の場合はキャプション表示を消去
        setState(() {
          currentCaption = null;
          showCaption = false;
        });
      } else {
        // 新しい文字列の場合はキャプション表示文字列を更新
        setState(() {
          currentCaption = text;
          showCaption = true;
        });
      }
    }
  }

  /// フェードアニメーションのみを実行するメソッド
  Future<void> _executeFadeAnimation() async {
    _fadeController.reset();
    await _fadeController.forward();
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
          if (isFullScreen) {
            _exitFullScreen();
          }
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_fadeController, _panController]),
          builder: (context, child) {
            // Calculate animation values
            final currentOpacity = isTransitioning ? _fadeAnimation.value : 1.0;
            final previousOpacity = isTransitioning ? 1.0 - _fadeAnimation.value : 0.0;

            return Stack(
              children: [
                // Previous image (fading out)
                if (isTransitioning) 
                  Opacity(
                    opacity: previousOpacity,
                    child: _buildSlideLayer(previousIndex),
                  ),

                // Current image (fading in)
                Opacity(
                  opacity: currentOpacity,
                  child: _buildSlideLayer(currentIndex),
                ),

                // キャプション表示
                if (showCaption && currentCaption != null) _buildCaption(),

                // Controls overlay
                if (!isFullScreen) _buildControls(),

                // Progress indicator
                if (!isFullScreen) _buildProgressIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }

  /// フェードなしでスライドを表示するメソッド（パンアニメーション含む）
  Widget _buildSlideLayer(int index) {
    if (index >= widget.slideshowData.length) return Container();

    final imageName = widget.slideshowData[index].image;
    final imagePath = path.join(widget.folderPath, imageName);
    final scale = widget.slideshowData[index].scale ?? 1.0;
    final pan = widget.slideshowData[index].pan;

    // パンアニメーションを適用するかどうかを判定
    final shouldPan = scale > 1.0 && pan != null && (index == currentIndex || index == previousIndex);

    Widget imageWidget = Transform.scale(
      scale: scale,
      child: Stack(
        children: [
          // Background blurred image
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Main image
          Positioned.fill(
            child: Center(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );

    // パンアニメーションを適用
    if (shouldPan) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final windowSize = MediaQuery.of(context).size;
          Offset panOffset;
          if (index == currentIndex) {
            panOffset = _panAnimation?.value ?? const Offset(0.0, 0.0);
          } else {
            // previousIndexの場合はパンの終了位置
            final panAmount = (scale - 1.0);
            switch (pan) {
              case PanDirection.up:
                panOffset = Offset(0.0, panAmount * 0.5);
                break;
              case PanDirection.down:
                panOffset = Offset(0.0, -panAmount * 0.5);
                break;
              case PanDirection.left:
                panOffset = Offset(panAmount * 0.5, 0.0);
                break;
              case PanDirection.right:
                panOffset = Offset(-panAmount * 0.5, 0.0);
                break;
              default:
                panOffset = const Offset(0.0, 0.0);
            }
          }

          final pixelOffset = Offset(
            panOffset.dx * windowSize.width,
            panOffset.dy * windowSize.height,
          );

          return Transform.translate(
            offset: pixelOffset,
            child: imageWidget,
          );
        },
      );
    }

    return Positioned.fill(
      child: imageWidget,
    );
  }



  Widget _buildControls() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
            ),
          ),

          // Fullscreen button
          IconButton(
            onPressed: _toggleFullScreen,
            icon: Icon(
              isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (currentIndex + 1) / widget.slideshowData.length,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),

          const SizedBox(height: 10),

          // Image counter
          Text(
            '${currentIndex + 1} / ${widget.slideshowData.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Image name
          Text(
            widget.slideshowData[currentIndex].image,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // キャプション表示ウィジェット
  Widget _buildCaption() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ウィンドウの横幅に比例してフォントサイズを計算
        // 横幅2048pxのときに32ptになるように設定
        final windowWidth = MediaQuery.of(context).size.width;
        final windowHeight = MediaQuery.of(context).size.height;
        final fontSize = (windowWidth / 2048.0) * 32.0;
        
        // 最小・最大フォントサイズを設定
        final clampedFontSize = fontSize.clamp(16.0, 48.0);
        
        // 文字間隔もフォントサイズに比例して調整
        final space = (clampedFontSize / 32.0) * 6.0;
        
        // 縦幅を画面の90%に設定
        final captionHeight = windowHeight * 0.9;
        
        // テキストの内容に応じて幅を計算
        final textStyle = TextStyle(
          color: Colors.black,
          fontSize: clampedFontSize,
          fontWeight: FontWeight.normal,
          height: 1.5,
        );
        final calculatedWidth = Tategaki.calculateWidth(currentCaption!, textStyle, space, captionHeight);
        
        // 最小幅と最大幅を設定
        final minWidth = clampedFontSize * 1.5; // 最小幅
        final maxWidth = clampedFontSize * 4; // 最大幅
        final finalWidth = calculatedWidth.clamp(minWidth, maxWidth);
        
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(right: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              width: finalWidth, // テキストの内容に応じて動的に計算された幅
              height: captionHeight, // 画面の縦幅の90%
              child: Tategaki(
                currentCaption!,
                style: textStyle,
                space: space, // 文字間隔
              ),
            ),
          ),
        );
      },
    );
  }
}
