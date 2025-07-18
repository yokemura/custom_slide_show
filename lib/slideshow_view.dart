import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:ui' as ui;
import 'tategaki.dart';

class SlideshowView extends StatefulWidget {
  final String folderPath;
  final List<Map<String, dynamic>> slideshowData;

  const SlideshowView({
    super.key,
    required this.folderPath,
    required this.slideshowData,
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

    // 初期キャプションを設定
    _updateCaption();

    // Start slideshow
    _startSlideshow();

    // Set up keyboard shortcuts
    _setupKeyboardShortcuts();

    // フルスクリーン状態の監視を開始
    _setupFullScreenListener();
  }

  @override
  void dispose() {
    _fadeController.stop();
    _slideController.stop();
    _fadeController.dispose();
    _slideController.dispose();
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
      _changeSlide(currentIndex - 1);
    }
  }

  void _nextSlide() {
    if (currentIndex < widget.slideshowData.length - 1) {
      _changeSlide(currentIndex + 1);
    }
  }

  void _togglePlayPause() {
    // TODO: Implement play/pause functionality
  }

  void _startSlideshow() {
    if (widget.slideshowData.isEmpty) return;

    _fadeController.forward();

    Future.delayed(const Duration(seconds: displayDuration - crossfadeDuration), () {
      if (mounted) {
        _nextSlide();
      }
    });
  }

  // キャプション更新メソッド
  void _updateCaption() {
    if (currentIndex < widget.slideshowData.length) {
      final slideData = widget.slideshowData[currentIndex];
      final text = slideData['text'] as String?;
      
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

  void _changeSlide(int newIndex) {
    if (newIndex >= 0 && newIndex < widget.slideshowData.length && !isTransitioning) {
      setState(() {
        previousIndex = currentIndex;
        currentIndex = newIndex;
        isTransitioning = true;
      });

      // キャプションを更新
      _updateCaption();

      // Start crossfade animation
      _fadeController.reset();
      _fadeController.forward().then((_) {
        if (mounted) {
          setState(() {
            isTransitioning = false;
          });
        }
      });

      // Schedule next slide
      Future.delayed(const Duration(seconds: displayDuration - crossfadeDuration),
          () {
        if (mounted) {
          _nextSlide();
        }
      });
    }
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
          animation: _fadeController,
          builder: (context, child) {
            // Calculate animation values
            final currentOpacity = isTransitioning ? _fadeAnimation.value : 1.0;
            final previousOpacity = isTransitioning ? 1.0 - _fadeAnimation.value : 0.0;

            return Stack(
              children: [
                // Previous image (fading out)
                if (isTransitioning) _buildImageLayer(previousIndex, previousOpacity),

                // Current image (fading in)
                _buildImageLayer(currentIndex, currentOpacity),

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

  Widget _buildImageLayer(int index, double opacity) {
    if (index >= widget.slideshowData.length) return Container();

    final imageName = widget.slideshowData[index]['image'] as String;
    final imagePath = path.join(widget.folderPath, imageName);

    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
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
      ),
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
            widget.slideshowData[currentIndex]['image'] as String,
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
