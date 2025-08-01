import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullscreenController {
  bool isFullScreen = false;
  final VoidCallback onStateChanged;

  FullscreenController({required this.onStateChanged});

  Future<void> toggleFullScreen() async {
    if (isFullScreen) {
      await exitFullScreen();
    } else {
      await enterFullScreen();
    }
  }

  Future<void> enterFullScreen() async {
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      isFullScreen = true;
      onStateChanged();
    } catch (e) {
      // Failed to enter fullscreen: $e
    }
  }

  Future<void> exitFullScreen() async {
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, 
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
      isFullScreen = false;
      onStateChanged();
    } catch (e) {
      // Failed to exit fullscreen: $e
    }
  }

  void handleAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (isFullScreen) {
        isFullScreen = false;
        onStateChanged();
      }
    }
  }
} 