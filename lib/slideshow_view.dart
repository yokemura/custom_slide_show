import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:ui' as ui;

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
    with TickerProviderStateMixin {
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
  static const int displayDuration = 5; // seconds
  static const int crossfadeDuration = 1; // seconds

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: Duration(milliseconds: crossfadeDuration * 1000),
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
      duration: Duration(milliseconds: crossfadeDuration * 1000),
      vsync: this,
    );

    // 初期キャプションを設定
    _updateCaption();

    // Start slideshow
    _startSlideshow();

    // Set up keyboard shortcuts
    _setupKeyboardShortcuts();
  }

  @override
  void dispose() {
    _fadeController.stop();
    _slideController.stop();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _setupKeyboardShortcuts() {
    RawKeyboard.instance.addListener((event) {
      if (event is RawKeyDownEvent) {
        if (event.isMetaPressed &&
            event.logicalKey == LogicalKeyboardKey.keyF) {
          _toggleFullScreen();
        } else if (event.logicalKey == LogicalKeyboardKey.escape) {
          _exitFullScreen();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _previousSlide();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _nextSlide();
        } else if (event.logicalKey == LogicalKeyboardKey.space) {
          _togglePlayPause();
        }
      }
    });
  }

  void _toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
    });
  }

  void _exitFullScreen() {
    setState(() {
      isFullScreen = false;
    });
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

    Future.delayed(Duration(seconds: displayDuration - crossfadeDuration), () {
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
      print('DEBUG: _changeSlide called: currentIndex=$currentIndex -> newIndex=$newIndex');
      
      setState(() {
        previousIndex = currentIndex;
        currentIndex = newIndex;
        isTransitioning = true;
      });

      // キャプションを更新
      _updateCaption();

      print('DEBUG: Starting crossfade animation');

      // Start crossfade animation
      _fadeController.reset();
      _fadeController.forward().then((_) {
        print('DEBUG: Crossfade animation completed');
        if (mounted) {
          setState(() {
            isTransitioning = false;
          });
          print('DEBUG: isTransitioning set to false');
        }
      });

      // Schedule next slide
      Future.delayed(Duration(seconds: displayDuration - crossfadeDuration),
          () {
        if (mounted) {
          print('DEBUG: Scheduling next slide');
          _nextSlide();
        }
      });
    } else {
      print('DEBUG: _changeSlide rejected: newIndex=$newIndex, isTransitioning=$isTransitioning');
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
            // Debug: Log current animation values
            final currentOpacity = isTransitioning ? _fadeAnimation.value : 1.0;
            final previousOpacity = isTransitioning ? 1.0 - _fadeAnimation.value : 0.0;
            
            print('DEBUG: isTransitioning=$isTransitioning, currentOpacity=$currentOpacity, previousOpacity=$previousOpacity');
            print('DEBUG: currentIndex=$currentIndex, previousIndex=$previousIndex');
            print('DEBUG: _fadeAnimation.value=${_fadeAnimation.value}');

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

    print('DEBUG: Building image layer for index=$index, opacity=$opacity, image=$imageName');

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

  Widget _buildCombinedImage() {
    if (widget.slideshowData.isEmpty) return Container();

    final imageName = widget.slideshowData[currentIndex]['image'] as String;
    final imagePath = path.join(widget.folderPath, imageName);

    return Positioned.fill(
      child: FadeTransition(
        opacity: _fadeAnimation,
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

  Widget _buildBackgroundImage() {
    if (widget.slideshowData.isEmpty) return Container();

    final imageName = widget.slideshowData[currentIndex]['image'] as String;
    final imagePath = path.join(widget.folderPath, imageName);

    return Positioned.fill(
      child: FadeTransition(
        opacity: _fadeAnimation,
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
    );
  }

  Widget _buildMainImage() {
    if (widget.slideshowData.isEmpty) return Container();

    final imageName = widget.slideshowData[currentIndex]['image'] as String;
    final imagePath = path.join(widget.folderPath, imageName);

    return Positioned.fill(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: AspectRatio(
            aspectRatio: 16 / 9, // Adjust based on your needs
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
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
    return Positioned(
      right: 40,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: RotatedBox(
            quarterTurns: 1, // 90度回転して縦書きにする
            child: Text(
              currentCaption!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.normal,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
