import 'package:flutter/material.dart';
import '../slide_item.dart';

class SlideshowControls extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onToggleFullScreen;
  final bool isFullScreen;
  final int currentIndex;
  final int totalSlides;
  final SlideItem currentSlide;
  final bool isPaused;
  final VoidCallback onTogglePlayPause;

  const SlideshowControls({
    super.key,
    required this.onBack,
    required this.onToggleFullScreen,
    required this.isFullScreen,
    required this.currentIndex,
    required this.totalSlides,
    required this.currentSlide,
    required this.isPaused,
    required this.onTogglePlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildTopControls(),
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
            ),
          ),

          // Play/Pause button
          IconButton(
            onPressed: onTogglePlayPause,
            icon: Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
            ),
          ),

          // Fullscreen button
          IconButton(
            onPressed: onToggleFullScreen,
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

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (currentIndex + 1) / totalSlides,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),

          const SizedBox(height: 10),

          // Image counter
          Text(
            '${currentIndex + 1} / $totalSlides',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Image name
          Text(
            currentSlide.image,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 